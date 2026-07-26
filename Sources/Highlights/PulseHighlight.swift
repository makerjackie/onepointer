import Cocoa
import CoreGraphics

enum PulseSpeed: String, CaseIterable, Codable {
    case slow = "Slow"
    case medium = "Medium"
    case fast = "Fast"

    var localizedName: String {
        switch self {
        case .slow:
            String(localized: "Slow")
        case .medium:
            String(localized: "Medium")
        case .fast:
            String(localized: "Fast")
        }
    }

    var frequency: CGFloat {
        switch self {
        case .slow: return 0.5
        case .medium: return 1.0
        case .fast: return 2.0
        }
    }
}

enum PulseIntensity: String, CaseIterable, Codable {
    case subtle = "Subtle"
    case moderate = "Moderate"
    case strong = "Strong"

    var localizedName: String {
        switch self {
        case .subtle:
            String(localized: "Subtle")
        case .moderate:
            String(localized: "Moderate")
        case .strong:
            String(localized: "Strong")
        }
    }

    var sizeVariation: CGFloat {
        switch self {
        case .subtle: return 0.15
        case .moderate: return 0.3
        case .strong: return 0.5
        }
    }
}

final class PulseHighlight {
    private var animatedSize = AnimatedValue(initial: 1.0, stiffness: 100, damping: 10)
    private var pulsePhase: CGFloat = 0
    private var lastUpdateTime: TimeInterval = CACurrentMediaTime()

    func draw(
        in context: CGContext,
        at point: NSPoint,
        baseSize: CGFloat,
        color: NSColor,
        opacity: CGFloat,
        speed: PulseSpeed,
        intensity: PulseIntensity
    ) {
        // Update animation phase
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update pulse phase based on speed
        pulsePhase += CGFloat(deltaTime) * speed.frequency * 2 * .pi
        if pulsePhase > 2 * .pi {
            pulsePhase -= 2 * .pi
        }

        // Calculate pulsing size using sine wave
        let sizeMultiplier = 1.0 + sin(pulsePhase) * intensity.sizeVariation
        let currentSize = baseSize * sizeMultiplier

        // Draw the pulsing circle with gradient
        drawPulsingCircle(
            in: context,
            at: point,
            size: currentSize,
            color: color,
            opacity: opacity,
            pulsePhase: pulsePhase,
            intensity: intensity
        )
    }

    private func drawPulsingCircle(
        in context: CGContext,
        at point: NSPoint,
        size: CGFloat,
        color: NSColor,
        opacity: CGFloat,
        pulsePhase: CGFloat,
        intensity: PulseIntensity
    ) {
        let radius = size / 2
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: size,
            height: size
        )

        context.saveGState()

        // Modulate opacity slightly with pulse for breathing effect
        let opacityVariation = intensity.sizeVariation * 0.3
        let currentOpacity = opacity * (1.0 - opacityVariation + sin(pulsePhase) * opacityVariation)

        let colorWithOpacity = color.withAlphaComponent(currentOpacity)
        let centerColor = colorWithOpacity.cgColor
        let edgeColor = color.withAlphaComponent(0).cgColor

        let colors = [centerColor, centerColor, edgeColor] as CFArray
        let locations: [CGFloat] = [0.0, 0.4, 1.0]

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

    func reset() {
        pulsePhase = 0
        lastUpdateTime = CACurrentMediaTime()
    }
}
