import CoreGraphics
import XCTest
@testable import OnePointer

final class QuickFocusModifierTests: XCTestCase {
    func testEveryChoiceUsesADistinctPhysicalKeyCode() {
        let keyCodes = Set(QuickFocusModifier.allCases.map(\.keyCode))

        XCTAssertEqual(keyCodes.count, QuickFocusModifier.allCases.count)
    }

    func testLeftOptionRecognizesStandalonePressAndRelease() {
        let modifier = QuickFocusModifier.leftOption

        XCTAssertEqual(
            modifier.standalonePressState(
                keyCode: modifier.keyCode,
                flags: .maskAlternate
            ),
            true
        )
        XCTAssertEqual(
            modifier.standalonePressState(
                keyCode: modifier.keyCode,
                flags: []
            ),
            false
        )
    }

    func testModifierChordDoesNotCountAsStandaloneTap() {
        let modifier = QuickFocusModifier.leftOption

        XCTAssertNil(
            modifier.standalonePressState(
                keyCode: modifier.keyCode,
                flags: [.maskAlternate, .maskCommand]
            )
        )
    }

    func testOtherModifierSideDoesNotCountAsSelectedKey() {
        XCTAssertNil(
            QuickFocusModifier.leftOption.standalonePressState(
                keyCode: QuickFocusModifier.rightOption.keyCode,
                flags: .maskAlternate
            )
        )
    }
}
