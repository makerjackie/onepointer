import Cocoa
import Combine
import Sparkle
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayController: OverlayWindowController?
    private var transientFocusController: TransientFocusOverlayController?
    private var mouseMonitor: MouseEventMonitor?
    private var doubleModifierMonitor: DoubleModifierMonitor?
    private let hotKeyManager = HotKeyManager()
    private let appModel = AppModel()
    private var updaterController: SPUStandardUpdaterController?
    private var menuBarController: MenuBarController?
    private lazy var settingsWindowController = SettingsWindowController(appModel: appModel)

    private var cancellables = Set<AnyCancellable>()

    func applicationWillFinishLaunching(_ notification: Notification) {
        // The activation policy has to be resolved before the app is on screen,
        // otherwise the Dock icon flashes for users who keep OnePointer in the
        // menu bar only. The status item is registered in
        // applicationDidFinishLaunching, the conventional point for NSStatusBar.
        SettingsManager.shared.applyActivationPolicy()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupApplicationMenu()
        setupOverlays()
        setupMouseMonitor()
        setupHotKey()
        setupUpdater()
        setupQuickFocus()
        setupBindings()
        appModel.runInBackground = { [weak self] in
            SettingsManager.shared.showMenuBarIcon = true
            self?.settingsWindowController.hideSettings()
        }
        appModel.quit = { NSApp.terminate(nil) }
        if AppLaunchContext.shouldShowSettings(
            event: NSAppleEventManager.shared().currentAppleEvent,
            arguments: ProcessInfo.processInfo.arguments
        ) {
            settingsWindowController.showSettings()
        }
    }

    private func setupOverlays() {
        overlayController = OverlayWindowController()
        overlayController?.setupOverlays()
        transientFocusController = TransientFocusOverlayController()
    }

    /// Creates or removes the menu bar status item.
    ///
    /// The setting is passed in rather than read back from `SettingsManager`:
    /// `@Published` publishes from `willSet`, so a subscriber that reads the
    /// property itself still gets the previous value. Reading it here made the
    /// status item react exactly one toggle late — turning the setting off
    /// created the icon and turning it on removed it. The Dock/⌘⇥ visibility is
    /// handled by `SettingsManager`, which applies the matching activation policy
    /// in its own `didSet` and once at launch.
    private func updateMenuBarItem(showMenuBarIcon: Bool) {
        guard showMenuBarIcon else {
            menuBarController?.invalidate()
            menuBarController = nil
            return
        }

        guard menuBarController == nil else { return }
        let controller = MenuBarController(appModel: appModel, settings: SettingsManager.shared)
        controller.delegate = self
        menuBarController = controller
    }

    private func setupMouseMonitor() {
        // No permissions required: MouseEventMonitor polls NSEvent.mouseLocation /
        // pressedMouseButtons, so tracking can start immediately.
        mouseMonitor = MouseEventMonitor()
        mouseMonitor?.delegate = self
        // Only poll when enabled — saves CPU/battery while the highlighter is off.
        if SettingsManager.shared.isEnabled {
            mouseMonitor?.start()
        }
    }

    private func setupHotKey() {
        hotKeyManager.onToggle = {
            SettingsManager.shared.isEnabled.toggle()
        }
        hotKeyManager.register()
    }

    private func setupUpdater() {
        let updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        self.updaterController = updaterController
        appModel.checkForUpdates = { [weak updaterController] in
            updaterController?.checkForUpdates(nil)
        }
    }

    private func setupQuickFocus() {
        let monitor = DoubleModifierMonitor()
        monitor.onDoubleTap = { [weak self] in
            self?.showQuickFocus()
        }
        doubleModifierMonitor = monitor

        appModel.focusNow = { [weak self] in
            self?.showQuickFocus()
        }
        appModel.inputMonitoringDidChange = { [weak self] in
            self?.configureDoubleModifierMonitor()
        }
        configureDoubleModifierMonitor()
    }

    private func setupBindings() {
        SettingsManager.shared.$showMenuBarIcon
            .removeDuplicates()
            .sink { [weak self] showMenuBarIcon in
                self?.updateMenuBarItem(showMenuBarIcon: showMenuBarIcon)
            }
            .store(in: &cancellables)

        SettingsManager.shared.$isEnabled
            .sink { [weak self] enabled in
                self?.overlayController?.setHighlightsVisible(enabled)
                if enabled {
                    self?.mouseMonitor?.start()
                } else {
                    self?.mouseMonitor?.stop()
                }
            }
            .store(in: &cancellables)

        SettingsManager.shared.$targetFrameRate
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] frameRate in
                self?.mouseMonitor?.updateFrameRate(frameRate)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(
            SettingsManager.shared.$quickFocusShortcutEnabled,
            SettingsManager.shared.$quickFocusModifier
        )
            .removeDuplicates { previous, current in
                previous.0 == current.0 && previous.1 == current.1
            }
            .sink { [weak self] shortcutEnabled, modifier in
                // Use the delivered values: reading the settings back inside a
                // sink of a @Published property returns the *previous* value,
                // which left the monitor and the permission prompt one change
                // behind the toggle.
                self?.configureDoubleModifierMonitor(
                    shortcutEnabled: shortcutEnabled,
                    modifier: modifier
                )
                self?.appModel.presentInputMonitoringOnboardingIfNeeded(
                    quickFocusEnabled: shortcutEnabled
                )
            }
            .store(in: &cancellables)
    }

    /// The two parameters default to the current settings so that callers that
    /// are not reacting to a change (a permission change, or launch) can simply
    /// re-read them; the subscriber in `setupBindings` passes the values it was
    /// handed, because the property it would read is still the old one.
    private func configureDoubleModifierMonitor(
        shortcutEnabled: Bool = SettingsManager.shared.quickFocusShortcutEnabled,
        modifier: QuickFocusModifier = SettingsManager.shared.quickFocusModifier
    ) {
        guard shortcutEnabled, appModel.isInputMonitoringGranted else {
            doubleModifierMonitor?.stop()
            return
        }

        if doubleModifierMonitor?.start(for: modifier) == false {
            appModel.refreshInputMonitoringState()
        }
    }

    private func showQuickFocus() {
        transientFocusController?.show()
    }

    private func setupApplicationMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: String(localized: "About OnePointer"),
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: ""
        )
        appMenu.addItem(
            withTitle: String(localized: "Check for Updates…"),
            action: #selector(checkForUpdates(_:)),
            keyEquivalent: ""
        )
        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: String(localized: "Hide OnePointer"),
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )
        appMenu.addItem(
            withTitle: String(localized: "Quit OnePointer"),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenuItem.submenu = appMenu
        NSApp.mainMenu = mainMenu
    }

    @objc private func checkForUpdates(_ sender: Any?) {
        updaterController?.checkForUpdates(sender)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Transparent overlays also count as visible windows. A deliberate
        // reopen must always bring settings back, including a minimized window.
        settingsWindowController.showSettings()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        cancellables.removeAll()
        menuBarController?.invalidate()
        menuBarController = nil
        mouseMonitor?.stop()
        doubleModifierMonitor?.stop()
        hotKeyManager.unregister()
        transientFocusController?.shutdown()
        overlayController?.shutdown()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        appModel.refreshInputMonitoringState()
    }
}

extension AppDelegate: MenuBarControllerDelegate {
    func menuBarControllerDidRequestSettings() {
        settingsWindowController.showSettings()
    }
}

extension AppDelegate: MouseEventDelegate {
    func mouseMoved(to point: NSPoint) {
        overlayController?.updateMousePosition(point)
    }

    func mouseDown(at point: NSPoint, button: MouseButton) {
        overlayController?.triggerClickEffect(at: point, button: button)
    }

    func mouseUp(at point: NSPoint, button: MouseButton) {
    }

    func mouseDragged(to point: NSPoint, button: MouseButton) {
        overlayController?.updateMousePosition(point)
    }
}
