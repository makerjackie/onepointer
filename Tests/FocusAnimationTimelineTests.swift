import XCTest
@testable import OnePointer

final class FocusAnimationTimelineTests: XCTestCase {
    func testTimelineBeginsAndEndsTransparent() {
        let timeline = FocusAnimationTimeline()

        XCTAssertEqual(timeline.overlayOpacity(at: 0, reduceMotion: false), 0)
        XCTAssertEqual(timeline.overlayOpacity(at: timeline.duration, reduceMotion: false), 0)
    }

    func testTimelineReachesFullOpacityDuringHold() {
        let timeline = FocusAnimationTimeline()

        XCTAssertEqual(timeline.overlayOpacity(at: 0.2, reduceMotion: false), 1)
    }

    func testReduceMotionKeepsRadiusFixed() {
        let timeline = FocusAnimationTimeline()

        XCTAssertEqual(timeline.spotlightRadius(at: 0.1, reduceMotion: true), 92)
        XCTAssertEqual(timeline.spotlightRadius(at: 0.7, reduceMotion: true), 92)
    }
}
