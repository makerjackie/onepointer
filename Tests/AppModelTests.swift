import IOKit.hid
import XCTest
@testable import OnePointer

@MainActor
final class AppModelTests: XCTestCase {
    func testSystemAccessStatesMapToAppStates() {
        XCTAssertEqual(
            SystemInputMonitoringAuthorization.state(for: kIOHIDAccessTypeUnknown),
            .notDetermined
        )
        XCTAssertEqual(
            SystemInputMonitoringAuthorization.state(for: kIOHIDAccessTypeDenied),
            .denied
        )
        XCTAssertEqual(
            SystemInputMonitoringAuthorization.state(for: kIOHIDAccessTypeGranted),
            .granted
        )
    }

    func testFirstLaunchPresentsOnboardingWhenQuickFocusNeedsPermission() throws {
        let defaults = try makeDefaults()
        let authorization = MockInputMonitoringAuthorization(state: .notDetermined)
        let model = AppModel(
            inputMonitoringAuthorization: authorization,
            defaults: defaults
        )

        model.presentInputMonitoringOnboardingIfNeeded(quickFocusEnabled: true)

        XCTAssertTrue(model.isInputMonitoringOnboardingPresented)
    }

    func testOnboardingDoesNotAppearWhenQuickFocusIsDisabled() throws {
        let defaults = try makeDefaults()
        let authorization = MockInputMonitoringAuthorization(state: .notDetermined)
        let model = AppModel(
            inputMonitoringAuthorization: authorization,
            defaults: defaults
        )

        model.presentInputMonitoringOnboardingIfNeeded(quickFocusEnabled: false)

        XCTAssertFalse(model.isInputMonitoringOnboardingPresented)
    }

    func testDismissingOnboardingPreventsItFromReappearing() throws {
        let defaults = try makeDefaults()
        let authorization = MockInputMonitoringAuthorization(state: .notDetermined)
        let model = AppModel(
            inputMonitoringAuthorization: authorization,
            defaults: defaults
        )

        model.presentInputMonitoringOnboardingIfNeeded(quickFocusEnabled: true)
        model.acknowledgeInputMonitoringOnboarding()
        model.presentInputMonitoringOnboardingIfNeeded(quickFocusEnabled: true)

        XCTAssertFalse(model.isInputMonitoringOnboardingPresented)
    }

    func testRequestRefreshesPermissionStateAndCompletesOnboarding() throws {
        let defaults = try makeDefaults()
        let authorization = MockInputMonitoringAuthorization(
            state: .notDetermined,
            stateAfterRequest: .granted
        )
        let model = AppModel(
            inputMonitoringAuthorization: authorization,
            defaults: defaults
        )
        model.presentInputMonitoringOnboardingIfNeeded(quickFocusEnabled: true)

        model.requestInputMonitoring()

        XCTAssertEqual(authorization.requestCount, 1)
        XCTAssertEqual(model.inputMonitoringState, .granted)
        XCTAssertFalse(model.isInputMonitoringOnboardingPresented)
    }

    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "studio.oneapps.onepointer.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        addTeardownBlock {
            defaults.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }
}

@MainActor
private final class MockInputMonitoringAuthorization: InputMonitoringAuthorizing {
    private(set) var requestCount = 0
    private var state: InputMonitoringState
    private let stateAfterRequest: InputMonitoringState

    init(
        state: InputMonitoringState,
        stateAfterRequest: InputMonitoringState? = nil
    ) {
        self.state = state
        self.stateAfterRequest = stateAfterRequest ?? state
    }

    func currentState() -> InputMonitoringState {
        state
    }

    func requestAccess() -> Bool {
        requestCount += 1
        state = stateAfterRequest
        return state == .granted
    }
}
