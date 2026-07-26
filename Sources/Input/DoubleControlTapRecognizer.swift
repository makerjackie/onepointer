import Foundation

nonisolated struct DoubleControlTapRecognizer {
    let maximumInterval: TimeInterval
    let maximumPressDuration: TimeInterval
    let cooldownDuration: TimeInterval

    private(set) var activeSide: ControlKeySide?
    private(set) var pressStartedAt: TimeInterval?
    private(set) var firstReleaseAt: TimeInterval?
    private(set) var cooldownUntil: TimeInterval = 0

    init(
        maximumInterval: TimeInterval = 0.35,
        maximumPressDuration: TimeInterval = 0.3,
        cooldownDuration: TimeInterval = 0.5
    ) {
        self.maximumInterval = maximumInterval
        self.maximumPressDuration = maximumPressDuration
        self.cooldownDuration = cooldownDuration
    }

    mutating func consume(_ event: ControlTapEvent) -> Bool {
        switch event {
        case let .otherInput(timestamp):
            if timestamp >= cooldownUntil {
                resetSequence()
            }
            return false

        case let .controlChanged(side, isPressed, timestamp):
            guard timestamp >= cooldownUntil else {
                return false
            }

            if isPressed {
                beginPress(side: side, timestamp: timestamp)
                return false
            }

            return finishPress(side: side, timestamp: timestamp)
        }
    }

    private mutating func beginPress(side: ControlKeySide, timestamp: TimeInterval) {
        if let firstReleaseAt, timestamp - firstReleaseAt > maximumInterval {
            resetSequence()
        }

        if let activeSide, activeSide != side {
            resetSequence()
        }

        activeSide = side
        pressStartedAt = timestamp
    }

    private mutating func finishPress(side: ControlKeySide, timestamp: TimeInterval) -> Bool {
        guard
            activeSide == side,
            let pressStartedAt,
            timestamp >= pressStartedAt,
            timestamp - pressStartedAt <= maximumPressDuration
        else {
            resetSequence()
            return false
        }

        self.pressStartedAt = nil

        guard let firstReleaseAt else {
            self.firstReleaseAt = timestamp
            return false
        }

        guard timestamp - firstReleaseAt <= maximumInterval else {
            self.firstReleaseAt = timestamp
            return false
        }

        cooldownUntil = timestamp + cooldownDuration
        resetSequence(keepingCooldown: true)
        return true
    }

    private mutating func resetSequence(keepingCooldown: Bool = false) {
        activeSide = nil
        pressStartedAt = nil
        firstReleaseAt = nil
        if !keepingCooldown {
            cooldownUntil = 0
        }
    }
}
