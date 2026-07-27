import Foundation

nonisolated struct FocusAnimationTimeline {
    let duration: TimeInterval
    let fadeInDuration: TimeInterval
    let holdUntil: TimeInterval
    let contractionDuration: TimeInterval
    let reboundDuration: TimeInterval
    let settleDuration: TimeInterval
    let targetRadius: Double
    let contractedRadius: Double
    let reboundRadius: Double

    init(
        duration: TimeInterval = 0.85,
        fadeInDuration: TimeInterval = 0.06,
        holdUntil: TimeInterval = 0.50,
        contractionDuration: TimeInterval = 0.32,
        reboundDuration: TimeInterval = 0.10,
        settleDuration: TimeInterval = 0.10,
        targetRadius: Double = 92,
        contractedRadius: Double = 82,
        reboundRadius: Double = 98
    ) {
        self.duration = duration
        self.fadeInDuration = fadeInDuration
        self.holdUntil = holdUntil
        self.contractionDuration = contractionDuration
        self.reboundDuration = reboundDuration
        self.settleDuration = settleDuration
        self.targetRadius = targetRadius
        self.contractedRadius = contractedRadius
        self.reboundRadius = reboundRadius
    }

    func overlayOpacity(at elapsed: TimeInterval, reduceMotion: Bool) -> Double {
        guard elapsed > 0, elapsed < duration else {
            return 0
        }

        if reduceMotion {
            return elapsed < holdUntil ? 1 : max(0, 1 - ((elapsed - holdUntil) / (duration - holdUntil)))
        }

        if elapsed < fadeInDuration {
            return min(1, elapsed / fadeInDuration)
        }

        if elapsed <= holdUntil {
            return 1
        }

        let fadeProgress = (elapsed - holdUntil) / (duration - holdUntil)
        return max(0, 1 - (fadeProgress * fadeProgress))
    }

    func spotlightRadius(
        at elapsed: TimeInterval,
        initialRadius: Double,
        reduceMotion: Bool
    ) -> Double {
        guard !reduceMotion else {
            return targetRadius
        }

        if elapsed <= 0 {
            return initialRadius
        }

        if elapsed < contractionDuration {
            let progress = elapsed / contractionDuration
            return interpolate(
                from: initialRadius,
                to: contractedRadius,
                progress: easeOutCubic(progress)
            )
        }

        let reboundEnd = contractionDuration + reboundDuration
        if elapsed < reboundEnd {
            let progress = (elapsed - contractionDuration) / reboundDuration
            return interpolate(
                from: contractedRadius,
                to: reboundRadius,
                progress: easeOutCubic(progress)
            )
        }

        let settleEnd = reboundEnd + settleDuration
        if elapsed < settleEnd {
            let progress = (elapsed - reboundEnd) / settleDuration
            return interpolate(
                from: reboundRadius,
                to: targetRadius,
                progress: easeOutCubic(progress)
            )
        }

        return targetRadius
    }

    private func interpolate(from start: Double, to end: Double, progress: Double) -> Double {
        start + ((end - start) * min(max(progress, 0), 1))
    }

    private func easeOutCubic(_ progress: Double) -> Double {
        1 - pow(1 - min(max(progress, 0), 1), 3)
    }
}
