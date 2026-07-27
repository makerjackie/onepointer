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

        XCTAssertEqual(
            timeline.spotlightRadius(at: 0.1, initialRadius: 520, reduceMotion: true),
            92
        )
        XCTAssertEqual(
            timeline.spotlightRadius(at: 0.7, initialRadius: 520, reduceMotion: true),
            92
        )
    }

    func testSpotlightContractsQuicklyFromLargeRadius() {
        let timeline = FocusAnimationTimeline()
        let initialRadius = 520.0

        let initial = timeline.spotlightRadius(
            at: 0,
            initialRadius: initialRadius,
            reduceMotion: false
        )
        let early = timeline.spotlightRadius(
            at: 0.08,
            initialRadius: initialRadius,
            reduceMotion: false
        )
        let late = timeline.spotlightRadius(
            at: 0.24,
            initialRadius: initialRadius,
            reduceMotion: false
        )

        XCTAssertEqual(initial, initialRadius)
        XCTAssertGreaterThan(initial, early)
        XCTAssertGreaterThan(early, late)
        XCTAssertLessThan(late, 100)
    }

    func testSpotlightReboundsThenSettlesAtTarget() {
        let timeline = FocusAnimationTimeline()

        let contracted = timeline.spotlightRadius(
            at: timeline.contractionDuration,
            initialRadius: 520,
            reduceMotion: false
        )
        let rebounded = timeline.spotlightRadius(
            at: timeline.contractionDuration + timeline.reboundDuration,
            initialRadius: 520,
            reduceMotion: false
        )
        let settled = timeline.spotlightRadius(
            at: timeline.duration,
            initialRadius: 520,
            reduceMotion: false
        )

        XCTAssertEqual(contracted, timeline.contractedRadius)
        XCTAssertEqual(rebounded, timeline.reboundRadius)
        XCTAssertEqual(settled, timeline.targetRadius)
    }
}
