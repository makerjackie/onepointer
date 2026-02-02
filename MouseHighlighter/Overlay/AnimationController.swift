import Cocoa
import QuartzCore

protocol AnimationControllerDelegate: AnyObject {
    func animationTick(deltaTime: TimeInterval)
}

final class AnimationController {
    weak var delegate: AnimationControllerDelegate?

    private var displayLink: CVDisplayLink?
    private var lastTimestamp: TimeInterval = 0
    private var isRunning = false

    private let updateQueue = DispatchQueue(label: "com.mousehighlighter.animation", qos: .userInteractive)

    func start() {
        guard !isRunning else { return }

        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)

        guard let displayLink = link else { return }

        self.displayLink = displayLink
        lastTimestamp = CACurrentMediaTime()

        let callback: CVDisplayLinkOutputCallback = { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, displayLinkContext) -> CVReturn in
            guard let context = displayLinkContext else { return kCVReturnSuccess }

            let controller = Unmanaged<AnimationController>.fromOpaque(context).takeUnretainedValue()
            controller.tick()

            return kCVReturnSuccess
        }

        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkSetOutputCallback(displayLink, callback, refcon)
        CVDisplayLinkStart(displayLink)
        isRunning = true
    }

    func stop() {
        guard isRunning, let link = displayLink else { return }

        CVDisplayLinkStop(link)
        displayLink = nil
        isRunning = false
    }

    private func tick() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastTimestamp
        lastTimestamp = currentTime

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.animationTick(deltaTime: deltaTime)
        }
    }

    deinit {
        stop()
    }
}

struct AnimatedValue {
    var current: CGFloat
    var target: CGFloat
    var velocity: CGFloat = 0
    let stiffness: CGFloat
    let damping: CGFloat

    init(initial: CGFloat, stiffness: CGFloat = 300, damping: CGFloat = 20) {
        self.current = initial
        self.target = initial
        self.stiffness = stiffness
        self.damping = damping
    }

    mutating func update(deltaTime: TimeInterval) {
        let dt = CGFloat(deltaTime)
        let displacement = current - target
        let springForce = -stiffness * displacement
        let dampingForce = -damping * velocity
        let acceleration = springForce + dampingForce

        velocity += acceleration * dt
        current += velocity * dt

        if abs(velocity) < 0.001 && abs(displacement) < 0.001 {
            current = target
            velocity = 0
        }
    }

    var isAnimating: Bool {
        return abs(current - target) > 0.001 || abs(velocity) > 0.001
    }
}

struct TimedAnimation {
    let duration: TimeInterval
    var elapsed: TimeInterval = 0
    let easingFunction: (CGFloat) -> CGFloat

    var progress: CGFloat {
        let t = CGFloat(min(elapsed / duration, 1.0))
        return easingFunction(t)
    }

    var isComplete: Bool {
        return elapsed >= duration
    }

    mutating func update(deltaTime: TimeInterval) {
        elapsed += deltaTime
    }

    static func easeOutQuad(_ t: CGFloat) -> CGFloat {
        return 1 - (1 - t) * (1 - t)
    }

    static func easeOutCubic(_ t: CGFloat) -> CGFloat {
        return 1 - pow(1 - t, 3)
    }

    static func easeOutElastic(_ t: CGFloat) -> CGFloat {
        if t == 0 { return 0 }
        if t == 1 { return 1 }
        let p: CGFloat = 0.3
        let s = p / 4
        return pow(2, -10 * t) * sin((t - s) * (2 * .pi) / p) + 1
    }

    static func easeOutBack(_ t: CGFloat) -> CGFloat {
        let c1: CGFloat = 1.70158
        let c3 = c1 + 1
        return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2)
    }
}
