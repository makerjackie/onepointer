// Standalone tests for the pure mouse-tracking math in Core/Geometry.swift.
//
// There is no Xcode test target; these are dependency-free (CoreGraphics only) and run
// directly with the Swift toolchain:
//
//     swiftc -parse-as-library MouseHighlighter/Core/Geometry.swift \
//         Tests/GeometryTests.swift -o /tmp/geomtests && /tmp/geomtests
//
// Exits non-zero if any assertion fails.

import CoreGraphics
import Foundation

@main
struct GeometryTests {
    static var failures = 0

    static func check(_ condition: Bool, _ message: String) {
        if condition {
            print("  ok: \(message)")
        } else {
            print("  FAIL: \(message)")
            failures += 1
        }
    }

    static func main() {
        // MARK: localPoint
        print("localPoint:")
        // Primary screen at origin: identity mapping.
        check(Geometry.localPoint(global: CGPoint(x: 100, y: 200), screenOrigin: .zero) == CGPoint(x: 100, y: 200),
              "origin screen maps identically")
        // Secondary screen to the right (origin x = 1920): subtract origin.
        check(Geometry.localPoint(global: CGPoint(x: 2000, y: 300), screenOrigin: CGPoint(x: 1920, y: 0)) == CGPoint(x: 80, y: 300),
              "right-of-primary screen subtracts x origin")
        // Secondary screen above primary (origin y = 1080).
        check(Geometry.localPoint(global: CGPoint(x: 50, y: 1100), screenOrigin: CGPoint(x: 0, y: 1080)) == CGPoint(x: 50, y: 20),
              "above-primary screen subtracts y origin")
        // Secondary screen with negative origin (left of / below primary).
        check(Geometry.localPoint(global: CGPoint(x: -100, y: -50), screenOrigin: CGPoint(x: -200, y: -100)) == CGPoint(x: 100, y: 50),
              "negative-origin screen maps into positive local space")

        // MARK: buttonTransitions
        print("buttonTransitions:")
        check(Geometry.buttonTransitions(old: 0, new: 0).isEmpty, "no change → no transitions")

        let leftDown = Geometry.buttonTransitions(old: 0, new: 0b1)
        check(leftDown.count == 1 && leftDown[0].index == 0 && leftDown[0].isDown, "left press → (0, down)")

        let leftUp = Geometry.buttonTransitions(old: 0b1, new: 0)
        check(leftUp.count == 1 && leftUp[0].index == 0 && !leftUp[0].isDown, "left release → (0, up)")

        let rightDown = Geometry.buttonTransitions(old: 0, new: 0b10)
        check(rightDown.count == 1 && rightDown[0].index == 1 && rightDown[0].isDown, "right press → (1, down)")

        // Left and right pressed simultaneously between polls.
        let both = Geometry.buttonTransitions(old: 0, new: 0b11)
        check(both.count == 2, "two simultaneous presses → two transitions")
        check(both.contains { $0.index == 0 && $0.isDown } && both.contains { $0.index == 1 && $0.isDown },
              "both transitions are presses for indices 0 and 1")

        // One up, one down across the same poll.
        let swap = Geometry.buttonTransitions(old: 0b1, new: 0b10)
        check(swap.contains { $0.index == 0 && !$0.isDown } && swap.contains { $0.index == 1 && $0.isDown },
              "left up + right down detected together")

        // MARK: lowestHeldButton
        print("lowestHeldButton:")
        check(Geometry.lowestHeldButton(in: 0) == nil, "no buttons held → nil")
        check(Geometry.lowestHeldButton(in: 0b1) == 0, "left held → 0")
        check(Geometry.lowestHeldButton(in: 0b10) == 1, "right held → 1")
        check(Geometry.lowestHeldButton(in: 0b11) == 0, "left+right held → lowest (0)")
        check(Geometry.lowestHeldButton(in: 0b100) == 2, "other held → 2")

        print("")
        if failures == 0 {
            print("All tests passed.")
            exit(0)
        } else {
            print("\(failures) test(s) failed.")
            exit(1)
        }
    }
}
