import AppKit
import Combine
import CoreGraphics

@MainActor
final class AppModel: ObservableObject {
    enum InputMonitoringState {
        case granted
        case required
    }

    @Published private(set) var inputMonitoringState: InputMonitoringState = .required

    var focusNow: () -> Void = {}
    var checkForUpdates: () -> Void = {}
    var inputMonitoringDidChange: () -> Void = {}

    init() {
        refreshInputMonitoringState()
    }

    var isInputMonitoringGranted: Bool {
        inputMonitoringState == .granted
    }

    func refreshInputMonitoringState() {
        inputMonitoringState = CGPreflightListenEventAccess() ? .granted : .required
        inputMonitoringDidChange()
    }

    func requestInputMonitoring() {
        if CGRequestListenEventAccess() {
            refreshInputMonitoringState()
        } else {
            openInputMonitoringSettings()
        }
    }

    func openInputMonitoringSettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
        ) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
