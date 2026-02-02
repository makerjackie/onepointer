import Cocoa
import CoreGraphics

final class RingHighlight {
    func draw(
        in context: CGContext,
        at point: NSPoint,
        size: CGFloat,
        color: NSColor,
        opacity: CGFloat,
        thickness: CGFloat,
        glowIntensity: CGFloat
    ) {
        let radius = size / 2

        context.saveGState()

        if glowIntensity > 0 {
            drawGlow(
                in: context,
                at: point,
                radius: radius,
                color: color,
                opacity: opacity,
                thickness: thickness,
                intensity: glowIntensity
            )
        }

        drawRing(
            in: context,
            at: point,
            radius: radius,
            color: color,
            opacity: opacity,
            thickness: thickness
        )

        context.restoreGState()
    }

    private func drawGlow(
        in context: CGContext,
        at point: NSPoint,
        radius: CGFloat,
        color: NSColor,
        opacity: CGFloat,
        thickness: CGFloat,
        intensity: CGFloat
    ) {
        let glowLayers = 4
        let maxGlowRadius = thickness * 3 * intensity

        for i in 0..<glowLayers {
            let progress = CGFloat(i + 1) / CGFloat(glowLayers)
            let glowRadius = maxGlowRadius * progress
            let glowOpacity = opacity * (1 - progress) * 0.3 * intensity

            let ringRadius = radius + glowRadius / 2
            let glowThickness = thickness + glowRadius

            let rect = CGRect(
                x: point.x - ringRadius,
                y: point.y - ringRadius,
                width: ringRadius * 2,
                height: ringRadius * 2
            )

            context.setStrokeColor(color.withAlphaComponent(glowOpacity).cgColor)
            context.setLineWidth(glowThickness)
            context.strokeEllipse(in: rect.insetBy(dx: glowThickness / 2, dy: glowThickness / 2))
        }
    }

    private func drawRing(
        in context: CGContext,
        at point: NSPoint,
        radius: CGFloat,
        color: NSColor,
        opacity: CGFloat,
        thickness: CGFloat
    ) {
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.setStrokeColor(color.withAlphaComponent(opacity).cgColor)
        context.setLineWidth(thickness)
        context.strokeEllipse(in: rect.insetBy(dx: thickness / 2, dy: thickness / 2))

        let innerHighlightThickness = thickness * 0.3
        let innerRadius = radius - thickness / 2 + innerHighlightThickness / 2

        let innerRect = CGRect(
            x: point.x - innerRadius,
            y: point.y - innerRadius,
            width: innerRadius * 2,
            height: innerRadius * 2
        )

        context.setStrokeColor(NSColor.white.withAlphaComponent(opacity * 0.3).cgColor)
        context.setLineWidth(innerHighlightThickness)
        context.strokeEllipse(in: innerRect.insetBy(dx: innerHighlightThickness / 2, dy: innerHighlightThickness / 2))
    }
}
