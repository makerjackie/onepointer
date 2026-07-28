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
    private lazy var settingsWindowController = SettingsWindowController(appModel: appModel)

    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupApplicationMenu()
        setupOverlays()
        setupMouseMonitor()
        setupHotKey()
        setupUpdater()
        setupBindings()
        setupQuickFocus()
        settingsWindowController.showSettings()
    }

    private func setupOverlays() {
        overlayController = OverlayWindowController()
        overlayController?.setupOverlays()
        transientFocusController = TransientFocusOverlayController()
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

        Publishers.CombineLatest(
            SettingsManager.shared.$quickFocusShortcutEnabled,
            SettingsManager.shared.$quickFocusModifier
        )
            .removeDuplicates { previous, current in
                previous.0 == current.0 && previous.1 == current.1
            }
            .sink { [weak self] _, _ in
                self?.configureDoubleModifierMonitor()
                self?.appModel.presentInputMonitoringOnboardingIfNeeded(
                    quickFocusEnabled: SettingsManager.shared.quickFocusShortcutEnabled
                )
            }
            .store(in: &cancellables)
    }

    private func configureDoubleModifierMonitor() {
        guard
            SettingsManager.shared.quickFocusShortcutEnabled,
            appModel.isInputMonitoringGranted
        else {
            doubleModifierMonitor?.stop()
            return
        }

        if doubleModifierMonitor?.start(for: SettingsManager.shared.quickFocusModifier) == false {
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
        if !flag {
            settingsWindowController.showSettings()
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
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
