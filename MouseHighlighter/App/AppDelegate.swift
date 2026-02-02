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
        let permissions = PermissionsManager.shared
        permissions.checkPermissions()

        if permissions.hasInputMonitoringPermission {
            startMouseTracking()
        } else {
            permissions.requestInputMonitoringPermission()

            NotificationCenter.default.addObserver(
                forName: .permissionGranted,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.startMouseTracking()
            }
        }
    }

    private func startMouseTracking() {
        mouseMonitor = MouseEventMonitor()
        mouseMonitor?.delegate = self

        if mouseMonitor?.start() == true {
            print("Mouse tracking started successfully")
        } else {
            print("Failed to start mouse tracking")
            showPermissionAlert()
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Input Monitoring Permission Required"
        alert.informativeText = "Mouse Highlighter needs Input Monitoring permission to track mouse movement. Please grant permission in System Settings > Privacy & Security > Input Monitoring."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            PermissionsManager.shared.openSystemPreferences()
        }
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
        PermissionsManager.shared.stopPolling()
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
