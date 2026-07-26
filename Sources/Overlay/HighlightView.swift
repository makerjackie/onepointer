import Cocoa
import Combine

final class HighlightView: NSView, AnimationControllerDelegate {
    private var mousePosition: NSPoint = .zero
    private var lastMousePosition: NSPoint = .zero
    private var isHighlightVisible: Bool = true
    private var isMouseOnScreen: Bool = false

    private var activeClickEffects: [ClickEffectState] = []
    private let animationController = AnimationController()

    // Position change threshold for redraw optimization
    private let positionChangeThreshold: CGFloat = 0.5

    private var cancellables = Set<AnyCancellable>()

    private var circleHighlight: CircleHighlight?
    private var spotlightHighlight: SpotlightHighlight?
    private var ringHighlight: RingHighlight?
    private var crosshairHighlight: CrosshairHighlight?
    private var pulseHighlight: PulseHighlight?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        circleHighlight = CircleHighlight()
        spotlightHighlight = SpotlightHighlight()
        ringHighlight = RingHighlight()
        crosshairHighlight = CrosshairHighlight()
        pulseHighlight = PulseHighlight()

        animationController.delegate = self
        animationController.start()

        setupBindings()
    }

    private func setupBindings() {
        let settings = SettingsManager.shared

        settings.$isEnabled
            .sink { [weak self] enabled in
                self?.isHighlightVisible = enabled
                self?.needsDisplay = true
            }
            .store(in: &cancellables)

        settings.$highlightStyle
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)

        settings.$highlightColor
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)

        settings.$highlightSize
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)

        settings.$highlightOpacity
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
    }

    func updateMousePosition(_ point: NSPoint, isVisible: Bool) {
        // Only update if position changed significantly
        let dx = abs(point.x - lastMousePosition.x)
        let dy = abs(point.y - lastMousePosition.y)

        if dx > positionChangeThreshold || dy > positionChangeThreshold || isVisible != isMouseOnScreen {
            mousePosition = point
            lastMousePosition = point
            isMouseOnScreen = isVisible
            animationController.notifyActivity()
            needsDisplay = true
        }
    }

    func setHighlightVisible(_ visible: Bool) {
        isHighlightVisible = visible
        needsDisplay = true
    }

    func triggerClickEffect(at point: NSPoint, button: MouseButton) {
        let settings = SettingsManager.shared

        guard settings.isClickEffectEnabled && settings.clickEffect != .none else { return }

        let effect = ClickEffectState(
            position: point,
            button: button,
            effectType: settings.clickEffect,
            duration: settings.effectDuration,
            color: settings.highlightColor,
            size: settings.highlightSize
        )

        activeClickEffects.append(effect)
        animationController.setHasActiveAnimations(true)
        animationController.notifyActivity()
    }

    func animationTick(deltaTime: TimeInterval) {
        var needsRedraw = false

        activeClickEffects = activeClickEffects.compactMap { effect in
            var mutableEffect = effect
            mutableEffect.update(deltaTime: deltaTime)

            if mutableEffect.isComplete {
                needsRedraw = true
                return nil
            }

            needsRedraw = true
            return mutableEffect
        }

        // Update animation controller about active effects
        animationController.setHasActiveAnimations(!activeClickEffects.isEmpty)

        // Pulse style needs continuous redraw for animation
        let settings = SettingsManager.shared
        if settings.highlightStyle == .pulse && settings.isEnabled && isHighlightVisible && isMouseOnScreen {
            needsRedraw = true
        }

        if needsRedraw || !activeClickEffects.isEmpty {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.clear(bounds)

        let settings = SettingsManager.shared

        if isHighlightVisible && isMouseOnScreen && settings.isEnabled {
            switch settings.highlightStyle {
            case .circle:
                circleHighlight?.draw(
                    in: context,
                    at: mousePosition,
                    size: settings.highlightSize,
                    color: settings.highlightColor,
                    opacity: settings.highlightOpacity
                )

            case .spotlight:
                spotlightHighlight?.draw(
                    in: context,
                    at: mousePosition,
                    size: settings.highlightSize,
                    bounds: bounds,
                    dimOpacity: settings.spotlightDimOpacity
                )

            case .ring:
                ringHighlight?.draw(
                    in: context,
                    at: mousePosition,
                    size: settings.highlightSize,
                    color: settings.highlightColor,
                    opacity: settings.highlightOpacity,
                    thickness: settings.ringThickness,
                    glowIntensity: settings.ringGlowIntensity
                )

            case .crosshair:
                crosshairHighlight?.draw(
                    in: context,
                    at: mousePosition,
                    length: settings.crosshairLength,
                    thickness: settings.crosshairThickness,
                    color: settings.highlightColor,
                    opacity: settings.highlightOpacity,
                    style: settings.crosshairStyle
                )

            case .pulse:
                pulseHighlight?.draw(
                    in: context,
                    at: mousePosition,
                    baseSize: settings.highlightSize,
                    color: settings.highlightColor,
                    opacity: settings.highlightOpacity,
                    speed: settings.pulseSpeed,
                    intensity: settings.pulseIntensity
                )
            }
        }

        for effect in activeClickEffects {
            drawClickEffect(effect, in: context)
        }
    }

    private func drawClickEffect(_ effect: ClickEffectState, in context: CGContext) {
        switch effect.effectType {
        case .ripple:
            RippleEffect.draw(in: context, effect: effect)

        case .colorFlash:
            ColorFlashEffect.draw(in: context, effect: effect)

        case .shrinkBounce:
            ShrinkBounceEffect.draw(in: context, effect: effect)

        case .none:
            break
        }
    }

    func shutdown() {
        animationController.stop()
    }
}

struct ClickEffectState {
    let position: NSPoint
    let button: MouseButton
    let effectType: ClickEffect
    let duration: CGFloat
    let color: NSColor
    let size: CGFloat

    var elapsed: TimeInterval = 0

    var progress: CGFloat {
        return CGFloat(min(elapsed / TimeInterval(duration), 1.0))
    }

    var isComplete: Bool {
        return elapsed >= TimeInterval(duration)
    }

    mutating func update(deltaTime: TimeInterval) {
        elapsed += deltaTime
    }
}
