import AppKit

final class TransientFocusView: NSView {
    var spotlightCenter: NSPoint?
    var overlayOpacity: Double = 0
    var spotlightRadius: Double = 92

    override var isFlipped: Bool {
        false
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        context.clear(bounds)
        guard overlayOpacity > 0.001 else {
            return
        }

        let dimColor = NSColor.black.withAlphaComponent(0.42 * overlayOpacity)

        context.saveGState()
        context.setFillColor(dimColor.cgColor)

        let path = CGMutablePath()
        path.addRect(bounds)

        if let spotlightCenter {
            let radius = spotlightRadius
            path.addEllipse(
                in: CGRect(
                    x: spotlightCenter.x - radius,
                    y: spotlightCenter.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
            )
        }

        context.addPath(path)
        context.drawPath(using: .eoFill)
        context.restoreGState()

        guard let spotlightCenter else {
            return
        }

        let radius = spotlightRadius
        let ringRect = CGRect(
            x: spotlightCenter.x - radius,
            y: spotlightCenter.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.saveGState()
        context.setShadow(
            offset: .zero,
            blur: 18,
            color: NSColor.white.withAlphaComponent(0.48 * overlayOpacity).cgColor
        )
        context.setStrokeColor(
            NSColor.white.withAlphaComponent(0.9 * overlayOpacity).cgColor
        )
        context.setLineWidth(2)
        context.strokeEllipse(in: ringRect.insetBy(dx: 1, dy: 1))
        context.restoreGState()
    }
}
