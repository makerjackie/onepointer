import Foundation

nonisolated enum ModifierTapEvent: Equatable {
    case modifierChanged(isPressed: Bool, timestamp: TimeInterval)
    case otherInput(timestamp: TimeInterval)
}
