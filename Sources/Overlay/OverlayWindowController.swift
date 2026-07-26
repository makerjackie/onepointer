import Cocoa
import Combine

final class OverlayWindowController {
    private var overlayWindows: [NSScreen: NSWindow] = [:]
    private var highlightViews: [NSScreen: HighlightView] = [:]
    private var screenObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupScreenObserver()
    }

    func setupOverlays() {
        removeAllOverlays()

        for screen in NSScreen.screens {
            createOverlayWindow(for: screen)
        }
    }

    private func createOverlayWindow(for screen: NSScreen) {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)) - 1)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false

        let highlightView = HighlightView(frame: screen.frame)
        highlightView.wantsLayer = true
        highlightView.layer?.backgroundColor = NSColor.clear.cgColor

        window.contentView = highlightView
        window.orderFrontRegardless()

        overlayWindows[screen] = window
        highlightViews[screen] = highlightView
    }

    private func setupScreenObserver() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.setupOverlays()
            }
        }
    }

    func removeAllOverlays() {
        highlightViews.values.forEach { $0.shutdown() }
        for (_, window) in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
        highlightViews.removeAll()
    }

    // The incoming point comes from NSEvent.mouseLocation, which is already in Cocoa
    // global coordinates (bottom-left origin, Y up) spanning all displays. No conversion
    // is needed — mapping into each screen's local space is a simple origin subtraction,
    // which is inherently correct for any monitor arrangement (side-by-side, stacked,
    // mixed sizes).
    func updateMousePosition(_ globalPoint: NSPoint) {
        for (screen, view) in highlightViews {
            let localPoint = Geometry.localPoint(global: globalPoint, screenOrigin: screen.frame.origin)
            let isOnThisScreen = screen.frame.contains(globalPoint)
            view.updateMousePosition(localPoint, isVisible: isOnThisScreen)
        }
    }

    func triggerClickEffect(at globalPoint: NSPoint, button: MouseButton) {
        for (screen, view) in highlightViews {
            if screen.frame.contains(globalPoint) {
                let localPoint = Geometry.localPoint(global: globalPoint, screenOrigin: screen.frame.origin)
                view.triggerClickEffect(at: localPoint, button: button)
                break
            }
        }
    }

    func setHighlightsVisible(_ visible: Bool) {
        for (_, view) in highlightViews {
            view.setHighlightVisible(visible)
        }
    }

    func shutdown() {
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
            screenObserver = nil
        }
        removeAllOverlays()
    }
}
