import XCTest
@testable import OnePointer

final class DoubleControlTapRecognizerTests: XCTestCase {
    func testTwoQuickTapsOnSameControlTrigger() {
        var recognizer = DoubleControlTapRecognizer()

        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.05)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.18)))
        XCTAssertTrue(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.23)))
    }

    func testDifferentControlSidesDoNotTrigger() {
        var recognizer = DoubleControlTapRecognizer()

        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.05)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .right, isPressed: true, timestamp: 1.15)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .right, isPressed: false, timestamp: 1.20)))
    }

    func testOtherInputCancelsSequence() {
        var recognizer = DoubleControlTapRecognizer()

        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.05)))
        XCTAssertFalse(recognizer.consume(.otherInput(timestamp: 1.10)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.15)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.20)))
    }

    func testLongPressDoesNotCountAsTap() {
        var recognizer = DoubleControlTapRecognizer()

        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.00)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.50)))
    }

    func testThirdTapInsideCooldownDoesNotTriggerAgain() {
        var recognizer = DoubleControlTapRecognizer()

        _ = recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.00))
        _ = recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.05))
        _ = recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.15))
        XCTAssertTrue(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.20)))

        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: true, timestamp: 1.30)))
        XCTAssertFalse(recognizer.consume(.controlChanged(side: .left, isPressed: false, timestamp: 1.35)))
    }
}
