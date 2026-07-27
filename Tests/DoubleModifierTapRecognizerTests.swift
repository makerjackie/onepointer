import XCTest
@testable import OnePointer

final class DoubleModifierTapRecognizerTests: XCTestCase {
    func testTwoQuickModifierTapsTrigger() {
        var recognizer = DoubleModifierTapRecognizer()

        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.05)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.18)))
        XCTAssertTrue(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.23)))
    }

    func testOtherInputCancelsSequence() {
        var recognizer = DoubleModifierTapRecognizer()

        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.05)))
        XCTAssertFalse(recognizer.consume(.otherInput(timestamp: 1.10)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.15)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.20)))
    }

    func testLongPressDoesNotCountAsTap() {
        var recognizer = DoubleModifierTapRecognizer()

        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.50)))
    }

    func testLateSecondTapStartsANewSequenceWithoutTriggering() {
        var recognizer = DoubleModifierTapRecognizer()

        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.05)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.50)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.55)))
    }

    func testThirdTapInsideCooldownDoesNotTriggerAgain() {
        var recognizer = DoubleModifierTapRecognizer()

        _ = recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.00))
        _ = recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.05))
        _ = recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.15))
        XCTAssertTrue(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.20)))

        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: true, timestamp: 1.30)))
        XCTAssertFalse(recognizer.consume(.modifierChanged(isPressed: false, timestamp: 1.35)))
    }
}
