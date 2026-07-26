import Cocoa
import CoreGraphics

struct ShrinkBounceEffect {
    static func draw(in context: CGContext, effect: ClickEffectState) {
        let progress = effect.progress

        let scale: CGFloat
        let opacity: CGFloat

        if progress < 0.2 {
            let shrinkProgress = progress / 0.2
            scale = 1.0 - (0.3 * TimedAnimation.easeOutQuad(shrinkProgress))
            opacity = 0.7
        } else if progress < 0.6 {
            let bounceProgress = (progress - 0.2) / 0.4
            scale = 0.7 + (0.5 * TimedAnimation.easeOutElastic(bounceProgress))
            opacity = 0.7 - (0.2 * bounceProgress)
        } else {
            let fadeProgress = (progress - 0.6) / 0.4
            scale = 1.2 - (0.2 * fadeProgress)
            opacity = 0.5 * (1 - TimedAnimation.easeOutQuad(fadeProgress))
        }

        guard opacity > 0.01 else { return }

        context.saveGState()

        let baseRadius = effect.size * 0.5
        let currentRadius = baseRadius * scale

        let rect = CGRect(
            x: effect.position.x - currentRadius,
            y: effect.position.y - currentRadius,
            width: currentRadius * 2,
            height: currentRadius * 2
        )

        let centerColor = effect.color.withAlphaComponent(opacity).cgColor
        let midColor = effect.color.withAlphaComponent(opacity * 0.6).cgColor
        let edgeColor = effect.color.withAlphaComponent(0).cgColor

        let colors = [centerColor, midColor, edgeColor] as CFArray
        let locations: [CGFloat] = [0.0, 0.5, 1.0]

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: locations
        ) else {
            context.restoreGState()
            return
        }

        context.addEllipse(in: rect)
        context.clip()

        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: effect.position.x, y: effect.position.y),
            startRadius: 0,
            endCenter: CGPoint(x: effect.position.x, y: effect.position.y),
            endRadius: currentRadius,
            options: []
        )

        context.restoreGState()

        if progress < 0.4 {
            drawRing(in: context, effect: effect, radius: currentRadius, opacity: opacity)
        }
    }

    private static func drawRing(in context: CGContext, effect: ClickEffectState, radius: CGFloat, opacity: CGFloat) {
        context.saveGState()

        let ringThickness: CGFloat = 2

        let ringRect = CGRect(
            x: effect.position.x - radius,
            y: effect.position.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.setStrokeColor(effect.color.withAlphaComponent(opacity * 0.8).cgColor)
        context.setLineWidth(ringThickness)
        context.strokeEllipse(in: ringRect.insetBy(dx: ringThickness / 2, dy: ringThickness / 2))

        context.restoreGState()
    }
}
