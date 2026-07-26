import Foundation

nonisolated struct FocusAnimationTimeline {
    let duration: TimeInterval
    let fadeInDuration: TimeInterval
    let holdUntil: TimeInterval

    init(
        duration: TimeInterval = 0.85,
        fadeInDuration: TimeInterval = 0.08,
        holdUntil: TimeInterval = 0.32
    ) {
        self.duration = duration
        self.fadeInDuration = fadeInDuration
        self.holdUntil = holdUntil
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

    func spotlightRadius(at elapsed: TimeInterval, reduceMotion: Bool) -> Double {
        guard !reduceMotion else {
            return 92
        }
        let progress = min(max(elapsed / duration, 0), 1)
        let eased = 1 - pow(1 - progress, 3)
        return 82 + (14 * eased)
    }
}
