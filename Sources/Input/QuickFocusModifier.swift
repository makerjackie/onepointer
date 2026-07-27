import CoreGraphics

nonisolated enum QuickFocusModifier: String, CaseIterable, Codable, Identifiable {
    case leftOption
    case rightOption
    case leftControl
    case rightControl
    case leftCommand
    case rightCommand
    case leftShift
    case rightShift

    var id: String {
        rawValue
    }

    var keyCode: Int64 {
        switch self {
        case .leftOption:
            58
        case .rightOption:
            61
        case .leftControl:
            59
        case .rightControl:
            62
        case .leftCommand:
            55
        case .rightCommand:
            54
        case .leftShift:
            56
        case .rightShift:
            60
        }
    }

    var eventFlag: CGEventFlags {
        switch self {
        case .leftOption, .rightOption:
            .maskAlternate
        case .leftControl, .rightControl:
            .maskControl
        case .leftCommand, .rightCommand:
            .maskCommand
        case .leftShift, .rightShift:
            .maskShift
        }
    }

    var symbol: String {
        switch self {
        case .leftOption, .rightOption:
            "⌥"
        case .leftControl, .rightControl:
            "⌃"
        case .leftCommand, .rightCommand:
            "⌘"
        case .leftShift, .rightShift:
            "⇧"
        }
    }

    var localizedName: String {
        switch self {
        case .leftOption:
            String(localized: "Left Option")
        case .rightOption:
            String(localized: "Right Option")
        case .leftControl:
            String(localized: "Left Control")
        case .rightControl:
            String(localized: "Right Control")
        case .leftCommand:
            String(localized: "Left Command")
        case .rightCommand:
            String(localized: "Right Command")
        case .leftShift:
            String(localized: "Left Shift")
        case .rightShift:
            String(localized: "Right Shift")
        }
    }

    func standalonePressState(
        keyCode eventKeyCode: Int64,
        flags: CGEventFlags
    ) -> Bool? {
        guard eventKeyCode == keyCode else {
            return nil
        }

        let standardModifierFlags: CGEventFlags = [
            .maskAlternate,
            .maskCommand,
            .maskControl,
            .maskShift,
        ]
        let activeModifiers = flags.intersection(standardModifierFlags)
        let isPressed = activeModifiers.contains(eventFlag)

        guard
            (isPressed && activeModifiers == eventFlag)
                || (!isPressed && activeModifiers.isEmpty)
        else {
            return nil
        }

        return isPressed
    }
}
