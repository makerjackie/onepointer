import Cocoa
import CoreGraphics

enum CrosshairStyle: String, CaseIterable, Codable {
    case plus = "Plus (+)"
    case x = "X (×)"

    var localizedName: String {
        switch self {
        case .plus:
            String(localized: "Plus (+)")
        case .x:
            String(localized: "X (×)")
        }
    }
}

final class CrosshairHighlight {
    func draw(
        in context: CGContext,
        at point: NSPoint,
        length: CGFloat,
        thickness: CGFloat,
        color: NSColor,
        opacity: CGFloat,
        style: CrosshairStyle
    ) {
        context.saveGState()

        context.setStrokeColor(color.withAlphaComponent(opacity).cgColor)
        context.setLineWidth(thickness)
        context.setLineCap(.round)

        let halfLength = length / 2

        switch style {
        case .plus:
            // Horizontal line
            context.move(to: CGPoint(x: point.x - halfLength, y: point.y))
            context.addLine(to: CGPoint(x: point.x + halfLength, y: point.y))

            // Vertical line
            context.move(to: CGPoint(x: point.x, y: point.y - halfLength))
            context.addLine(to: CGPoint(x: point.x, y: point.y + halfLength))

        case .x:
            // Diagonal from top-left to bottom-right
            let offset = halfLength / sqrt(2)
            context.move(to: CGPoint(x: point.x - offset, y: point.y - offset))
            context.addLine(to: CGPoint(x: point.x + offset, y: point.y + offset))

            // Diagonal from top-right to bottom-left
            context.move(to: CGPoint(x: point.x + offset, y: point.y - offset))
            context.addLine(to: CGPoint(x: point.x - offset, y: point.y + offset))
        }

        context.strokePath()

        context.restoreGState()
    }

    func drawWithGlow(
        in context: CGContext,
        at point: NSPoint,
        length: CGFloat,
        thickness: CGFloat,
        color: NSColor,
        opacity: CGFloat,
        style: CrosshairStyle,
        glowIntensity: CGFloat = 0.5
    ) {
        context.saveGState()

        // Draw glow layers
        if glowIntensity > 0 {
            let glowLayers = 3
            for i in 0..<glowLayers {
                let progress = CGFloat(i + 1) / CGFloat(glowLayers)
                let glowThickness = thickness + (thickness * 2 * progress * glowIntensity)
                let glowOpacity = opacity * (1 - progress) * 0.3 * glowIntensity

                context.setStrokeColor(color.withAlphaComponent(glowOpacity).cgColor)
                context.setLineWidth(glowThickness)
                context.setLineCap(.round)

                drawLines(in: context, at: point, length: length, style: style)
                context.strokePath()
            }
        }

        // Draw main crosshair
        draw(in: context, at: point, length: length, thickness: thickness, color: color, opacity: opacity, style: style)

        context.restoreGState()
    }

    private func drawLines(in context: CGContext, at point: NSPoint, length: CGFloat, style: CrosshairStyle) {
        let halfLength = length / 2

        switch style {
        case .plus:
            context.move(to: CGPoint(x: point.x - halfLength, y: point.y))
            context.addLine(to: CGPoint(x: point.x + halfLength, y: point.y))
            context.move(to: CGPoint(x: point.x, y: point.y - halfLength))
            context.addLine(to: CGPoint(x: point.x, y: point.y + halfLength))

        case .x:
            let offset = halfLength / sqrt(2)
            context.move(to: CGPoint(x: point.x - offset, y: point.y - offset))
            context.addLine(to: CGPoint(x: point.x + offset, y: point.y + offset))
            context.move(to: CGPoint(x: point.x + offset, y: point.y - offset))
            context.addLine(to: CGPoint(x: point.x - offset, y: point.y + offset))
        }
    }
}
