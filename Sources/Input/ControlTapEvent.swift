import Foundation

nonisolated enum ControlTapEvent: Equatable {
    case controlChanged(side: ControlKeySide, isPressed: Bool, timestamp: TimeInterval)
    case otherInput(timestamp: TimeInterval)
}
