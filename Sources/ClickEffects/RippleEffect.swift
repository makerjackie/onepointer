import Cocoa
import CoreGraphics

struct RippleEffect {
    static func draw(in context: CGContext, effect: ClickEffectState) {
        let progress = effect.progress
        let easedProgress = TimedAnimation.easeOutCubic(progress)

        let maxRadius = effect.size * 2
        let currentRadius = effect.size * 0.5 + (maxRadius - effect.size * 0.5) * easedProgress

        let opacity = (1 - easedProgress) * 0.6

        guard opacity > 0.01 else { return }

        context.saveGState()

        let rect = CGRect(
            x: effect.position.x - currentRadius,
            y: effect.position.y - currentRadius,
            width: currentRadius * 2,
            height: currentRadius * 2
        )

        let ringThickness: CGFloat = 3 * (1 - easedProgress * 0.5)
        context.setStrokeColor(effect.color.withAlphaComponent(opacity).cgColor)
        context.setLineWidth(ringThickness)
        context.strokeEllipse(in: rect.insetBy(dx: ringThickness / 2, dy: ringThickness / 2))

        if easedProgress < 0.5 {
            let fillOpacity = opacity * 0.3 * (1 - easedProgress * 2)
            let fillRadius = currentRadius * 0.8

            let fillRect = CGRect(
                x: effect.position.x - fillRadius,
                y: effect.position.y - fillRadius,
                width: fillRadius * 2,
                height: fillRadius * 2
            )

            let colors = [
                effect.color.withAlphaComponent(fillOpacity).cgColor,
                effect.color.withAlphaComponent(0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]

            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: locations
            ) {
                context.addEllipse(in: fillRect)
                context.clip()

                context.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: effect.position.x, y: effect.position.y),
                    startRadius: 0,
                    endCenter: CGPoint(x: effect.position.x, y: effect.position.y),
                    endRadius: fillRadius,
                    options: []
                )
            }
        }

        context.restoreGState()
    }
}
