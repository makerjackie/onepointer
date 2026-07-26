import Cocoa
import CoreGraphics

final class SpotlightHighlight {
    func draw(in context: CGContext, at point: NSPoint, size: CGFloat, bounds: CGRect, dimOpacity: CGFloat) {
        let radius = size / 2

        context.saveGState()

        let dimColor = NSColor.black.withAlphaComponent(dimOpacity).cgColor
        context.setFillColor(dimColor)

        let screenPath = CGMutablePath()
        screenPath.addRect(bounds)

        let circleRect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: size,
            height: size
        )
        screenPath.addEllipse(in: circleRect)

        context.addPath(screenPath)
        context.fillPath(using: .evenOdd)

        drawSoftEdge(in: context, at: point, radius: radius, dimOpacity: dimOpacity)

        context.restoreGState()
    }

    private func drawSoftEdge(in context: CGContext, at point: NSPoint, radius: CGFloat, dimOpacity: CGFloat) {
        let fadeWidth: CGFloat = radius * 0.2
        let outerRadius = radius + fadeWidth
        let innerRadius = radius

        let outerRect = CGRect(
            x: point.x - outerRadius,
            y: point.y - outerRadius,
            width: outerRadius * 2,
            height: outerRadius * 2
        )

        let colors = [
            NSColor.black.withAlphaComponent(dimOpacity).cgColor,
            NSColor.black.withAlphaComponent(0).cgColor
        ] as CFArray
        let locations: [CGFloat] = [0.0, 1.0]

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: locations
        ) else { return }

        context.saveGState()

        let innerPath = CGMutablePath()
        innerPath.addEllipse(in: CGRect(
            x: point.x - innerRadius,
            y: point.y - innerRadius,
            width: innerRadius * 2,
            height: innerRadius * 2
        ))

        let outerPath = CGMutablePath()
        outerPath.addEllipse(in: outerRect)

        context.addPath(outerPath)
        context.addPath(innerPath)
        context.clip(using: .evenOdd)

        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: point.x, y: point.y),
            startRadius: outerRadius,
            endCenter: CGPoint(x: point.x, y: point.y),
            endRadius: innerRadius,
            options: []
        )

        context.restoreGState()
    }
}
