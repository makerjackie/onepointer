import CoreGraphics

/// Pure, dependency-free helpers for the mouse-tracking math. Kept free of AppKit so the
/// logic can be unit-tested in isolation (see Tests/GeometryTests.swift).
enum Geometry {
    /// Map a point in global Cocoa coordinates (bottom-left origin, spanning all displays)
    /// into a screen's local coordinate space. `NSEvent.mouseLocation` is already in this
    /// global system, so mapping to each screen is a plain origin subtraction — correct for
    /// any monitor arrangement (side-by-side, stacked, mixed sizes).
    static func localPoint(global: CGPoint, screenOrigin: CGPoint) -> CGPoint {
        CGPoint(x: global.x - screenOrigin.x, y: global.y - screenOrigin.y)
    }

    /// Diff two `NSEvent.pressedMouseButtons` bitmasks and return which buttons changed.
    /// Each result is the button index (0 = left, 1 = right, 2+ = other) and whether it is
    /// now pressed. Used to synthesize down/up events from polled button state.
    static func buttonTransitions(old: Int, new: Int, maxButtons: Int = 3) -> [(index: Int, isDown: Bool)] {
        var changes: [(index: Int, isDown: Bool)] = []
        for bit in 0..<maxButtons {
            let flag = 1 << bit
            let was = (old & flag) != 0
            let now = (new & flag) != 0
            if was != now {
                changes.append((index: bit, isDown: now))
            }
        }
        return changes
    }

    /// The lowest-indexed button currently held in a pressed-buttons bitmask, or nil if none.
    /// Used to attribute a drag to a specific button.
    static func lowestHeldButton(in mask: Int, maxButtons: Int = 3) -> Int? {
        for bit in 0..<maxButtons where (mask & (1 << bit)) != 0 {
            return bit
        }
        return nil
    }
}
