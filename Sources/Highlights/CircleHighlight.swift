import Cocoa
import CoreGraphics

final class CircleHighlight {
    func draw(in context: CGContext, at point: NSPoint, size: CGFloat, color: NSColor, opacity: CGFloat) {
        let radius = size / 2
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: size,
            height: size
        )

        context.saveGState()

        let colorWithOpacity = color.withAlphaComponent(opacity)
        let centerColor = colorWithOpacity.cgColor
        let edgeColor = color.withAlphaComponent(0).cgColor

        let colors = [centerColor, centerColor, edgeColor] as CFArray
        let locations: [CGFloat] = [0.0, 0.5, 1.0]

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: locations
        ) else {
            context.restoreGState()
            return
        }

        let centerPoint = CGPoint(x: point.x, y: point.y)

        context.addEllipse(in: rect)
        context.clip()

        context.drawRadialGradient(
            gradient,
            startCenter: centerPoint,
            startRadius: 0,
            endCenter: centerPoint,
            endRadius: radius,
            options: [.drawsAfterEndLocation]
        )

        context.restoreGState()
    }

    func drawSolid(in context: CGContext, at point: NSPoint, size: CGFloat, color: NSColor, opacity: CGFloat) {
        let radius = size / 2
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: size,
            height: size
        )

        context.saveGState()

        context.setFillColor(color.withAlphaComponent(opacity).cgColor)
        context.fillEllipse(in: rect)

        context.restoreGState()
    }
}
