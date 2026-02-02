import Cocoa
import CoreGraphics

struct ColorFlashEffect {
    static func draw(in context: CGContext, effect: ClickEffectState) {
        let progress = effect.progress

        let flashPhase: CGFloat
        let opacity: CGFloat

        if progress < 0.3 {
            flashPhase = progress / 0.3
            opacity = flashPhase * 0.8
        } else {
            flashPhase = 1.0
            opacity = 0.8 * (1 - (progress - 0.3) / 0.7)
        }

        guard opacity > 0.01 else { return }

        context.saveGState()

        let radius = effect.size * 0.6
        let rect = CGRect(
            x: effect.position.x - radius,
            y: effect.position.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        let flashColor: NSColor
        switch effect.button {
        case .left:
            flashColor = effect.color
        case .right:
            flashColor = NSColor.systemOrange
        case .other:
            flashColor = NSColor.systemPurple
        }

        let brightColor = flashColor.blended(withFraction: 0.3, of: NSColor.white) ?? flashColor

        let centerColor = brightColor.withAlphaComponent(opacity).cgColor
        let edgeColor = flashColor.withAlphaComponent(opacity * 0.5).cgColor
        let outerColor = flashColor.withAlphaComponent(0).cgColor

        let colors = [centerColor, edgeColor, outerColor] as CFArray
        let locations: [CGFloat] = [0.0, 0.6, 1.0]

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
            endRadius: radius,
            options: []
        )

        context.restoreGState()
    }
}
