import AppKit
import Combine

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var inputMonitoringState: InputMonitoringState = .notDetermined
    @Published var isInputMonitoringOnboardingPresented = false

    var focusNow: () -> Void = {}
    var checkForUpdates: () -> Void = {}
    var runInBackground: () -> Void = {}
    var quit: () -> Void = {}
    var inputMonitoringDidChange: () -> Void = {}

    private let inputMonitoringAuthorization: any InputMonitoringAuthorizing
    private let defaults: UserDefaults
    private let inputMonitoringOnboardingKey = "hasSeenInputMonitoringOnboarding"

    init(
        inputMonitoringAuthorization: any InputMonitoringAuthorizing =
            SystemInputMonitoringAuthorization(),
        defaults: UserDefaults = .standard
    ) {
        self.inputMonitoringAuthorization = inputMonitoringAuthorization
        self.defaults = defaults
        refreshInputMonitoringState()
    }

    var isInputMonitoringGranted: Bool {
        inputMonitoringState == .granted
    }

    func refreshInputMonitoringState() {
        let state = inputMonitoringAuthorization.currentState()
        guard state != inputMonitoringState else { return }
        inputMonitoringState = state
        // A failed event tap can refresh authorization again. Notify only on a
        // real change so an unchanged grant cannot cause recursive retries.
        inputMonitoringDidChange()
    }

    func requestInputMonitoring() {
        acknowledgeInputMonitoringOnboarding()
        inputMonitoringAuthorization.requestAccess()
        refreshInputMonitoringState()
    }

    func presentInputMonitoringOnboardingIfNeeded(quickFocusEnabled: Bool) {
        guard
            quickFocusEnabled,
            inputMonitoringState != .granted,
            !defaults.bool(forKey: inputMonitoringOnboardingKey)
        else {
            return
        }

        isInputMonitoringOnboardingPresented = true
    }

    func acknowledgeInputMonitoringOnboarding() {
        defaults.set(true, forKey: inputMonitoringOnboardingKey)
        isInputMonitoringOnboardingPresented = false
    }

    func openInputMonitoringSettings() {
        acknowledgeInputMonitoringOnboarding()
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
        ) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
