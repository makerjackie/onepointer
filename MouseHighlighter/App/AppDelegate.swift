import Cocoa
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var overlayController: OverlayWindowController?
    private var mouseMonitor: MouseEventMonitor?
    private let settingsWindowController = SettingsWindowController()

    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("App launched!")

        NSApp.setActivationPolicy(.regular)

        setupMenuBar()
        setupOverlays()
        setupMouseMonitor()
        setupBindings()

        // Show settings on first launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.settingsWindowController.showSettings()
        }
    }

    private func setupMenuBar() {
        menuBarController = MenuBarController()
        menuBarController?.delegate = self
    }

    private func setupOverlays() {
        overlayController = OverlayWindowController()
        overlayController?.setupOverlays()
    }

    private func setupMouseMonitor() {
        // No permissions required: MouseEventMonitor polls NSEvent.mouseLocation /
        // pressedMouseButtons, so tracking can start immediately.
        mouseMonitor = MouseEventMonitor()
        mouseMonitor?.delegate = self
        mouseMonitor?.start()
        print("Mouse tracking started")
    }

    private func setupBindings() {
        SettingsManager.shared.$isEnabled
            .sink { [weak self] enabled in
                self?.overlayController?.setHighlightsVisible(enabled)
                self?.menuBarController?.updateIcon(enabled: enabled)
            }
            .store(in: &cancellables)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            settingsWindowController.showSettings()
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        mouseMonitor?.stop()
        overlayController?.removeAllOverlays()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
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

extension AppDelegate: MenuBarControllerDelegate {
    func menuBarControllerDidRequestSettings() {
        settingsWindowController.showSettings()
    }
}
