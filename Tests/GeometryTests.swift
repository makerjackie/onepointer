import XCTest
@testable import OnePointer

final class GeometryTests: XCTestCase {
    func testGlobalPointMapsIntoSecondaryScreen() {
        XCTAssertEqual(
            Geometry.localPoint(
                global: CGPoint(x: 2_000, y: 300),
                screenOrigin: CGPoint(x: 1_920, y: 0)
            ),
            CGPoint(x: 80, y: 300)
        )
    }

    func testNegativeScreenOriginMapsToPositiveLocalPoint() {
        XCTAssertEqual(
            Geometry.localPoint(
                global: CGPoint(x: -100, y: -50),
                screenOrigin: CGPoint(x: -200, y: -100)
            ),
            CGPoint(x: 100, y: 50)
        )
    }
}
