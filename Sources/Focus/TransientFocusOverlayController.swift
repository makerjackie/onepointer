import AppKit

@MainActor
final class TransientFocusOverlayController {
    private struct Overlay {
        let screen: NSScreen
        let window: NSWindow
        let view: TransientFocusView
    }

    private let timeline = FocusAnimationTimeline()
    private var overlays: [Overlay] = []
    private var animationTimer: Timer?
    private var startedAt: TimeInterval = 0
    private var screenObserver: NSObjectProtocol?

    init() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.rebuildOverlays()
            }
        }
        rebuildOverlays()
    }

    func show() {
        guard !NSScreen.screens.isEmpty else {
            return
        }

        if overlays.count != NSScreen.screens.count {
            rebuildOverlays()
        }

        startedAt = ProcessInfo.processInfo.systemUptime
        update(elapsed: 0)
        overlays.forEach { $0.window.orderFrontRegardless() }

        animationTimer?.invalidate()
        let timer = Timer(timeInterval: 1 / 60, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        animationTimer = timer
    }

    private func tick() {
        let elapsed = ProcessInfo.processInfo.systemUptime - startedAt
        guard elapsed < timeline.duration else {
            hide()
            return
        }
        update(elapsed: elapsed)
    }

    private func update(elapsed: TimeInterval) {
        let mouseLocation = NSEvent.mouseLocation
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let opacity = timeline.overlayOpacity(at: elapsed, reduceMotion: reduceMotion)
        let radius = timeline.spotlightRadius(at: elapsed, reduceMotion: reduceMotion)

        var selectedScreenIndex: Int?
        for (index, overlay) in overlays.enumerated() where overlay.screen.frame.contains(mouseLocation) {
            selectedScreenIndex = index
            break
        }

        for (index, overlay) in overlays.enumerated() {
            overlay.view.overlayOpacity = opacity
            overlay.view.spotlightRadius = radius
            if index == selectedScreenIndex {
                overlay.view.spotlightCenter = Geometry.localPoint(
                    global: mouseLocation,
                    screenOrigin: overlay.screen.frame.origin
                )
            } else {
                overlay.view.spotlightCenter = nil
            }
            overlay.view.needsDisplay = true
        }
    }

    private func hide() {
        animationTimer?.invalidate()
        animationTimer = nil
        overlays.forEach { overlay in
            overlay.view.overlayOpacity = 0
            overlay.view.needsDisplay = true
            overlay.window.orderOut(nil)
        }
    }

    private func rebuildOverlays() {
        hide()
        overlays.forEach { $0.window.close() }
        overlays = NSScreen.screens.map(createOverlay)
    }

    private func createOverlay(for screen: NSScreen) -> Overlay {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = NSWindow.Level(
            rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)) - 1
        )
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle,
            .fullScreenAuxiliary
        ]
        window.isReleasedWhenClosed = false

        let view = TransientFocusView(frame: CGRect(origin: .zero, size: screen.frame.size))
        window.contentView = view
        return Overlay(screen: screen, window: window, view: view)
    }

    func shutdown() {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
            self.screenObserver = nil
        }
        animationTimer?.invalidate()
        animationTimer = nil
        overlays.forEach { $0.window.close() }
        overlays.removeAll()
    }
}
