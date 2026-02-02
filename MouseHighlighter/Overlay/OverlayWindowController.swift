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
            self?.setupOverlays()
        }
    }

    func removeAllOverlays() {
        for (_, window) in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
        highlightViews.removeAll()
    }

    func updateMousePosition(_ globalPoint: NSPoint) {
        // Convert from CGEvent coordinates (origin top-left) to NSScreen coordinates (origin bottom-left)
        guard let mainScreen = NSScreen.main else { return }
        let flippedY = mainScreen.frame.height - globalPoint.y
        let convertedPoint = NSPoint(x: globalPoint.x, y: flippedY)

        for (screen, view) in highlightViews {
            let localPoint = NSPoint(
                x: convertedPoint.x - screen.frame.origin.x,
                y: convertedPoint.y - screen.frame.origin.y
            )

            let isOnThisScreen = screen.frame.contains(convertedPoint)
            view.updateMousePosition(localPoint, isVisible: isOnThisScreen)
        }
    }

    func triggerClickEffect(at globalPoint: NSPoint, button: MouseButton) {
        // Convert from CGEvent coordinates (origin top-left) to NSScreen coordinates (origin bottom-left)
        guard let mainScreen = NSScreen.main else { return }
        let flippedY = mainScreen.frame.height - globalPoint.y
        let convertedPoint = NSPoint(x: globalPoint.x, y: flippedY)

        for (screen, view) in highlightViews {
            if screen.frame.contains(convertedPoint) {
                let localPoint = NSPoint(
                    x: convertedPoint.x - screen.frame.origin.x,
                    y: convertedPoint.y - screen.frame.origin.y
                )
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

    deinit {
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        removeAllOverlays()
    }
}
