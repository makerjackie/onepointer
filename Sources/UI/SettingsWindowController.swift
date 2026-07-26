import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let appModel: AppModel
    private var window: NSWindow?

    init(appModel: AppModel) {
        self.appModel = appModel
    }

    func showSettings() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let rootView = SettingsView(
            appModel: appModel,
            settings: SettingsManager.shared
        )
        let hostingController = NSHostingController(rootView: rootView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "OnePointer"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 720, height: 700))
        window.minSize = NSSize(width: 620, height: 560)
        window.center()
        window.setFrameAutosaveName("OnePointerMainWindow")
        window.isReleasedWhenClosed = false
        window.delegate = self

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
