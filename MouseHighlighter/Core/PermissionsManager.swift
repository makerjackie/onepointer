import Cocoa
import Combine

final class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()

    @Published private(set) var hasInputMonitoringPermission: Bool = false

    private var permissionCheckTimer: Timer?

    private init() {
        checkPermissions()
    }

    func checkPermissions() {
        hasInputMonitoringPermission = CGPreflightListenEventAccess()
    }

    func requestInputMonitoringPermission() {
        if !hasInputMonitoringPermission {
            let trusted = CGRequestListenEventAccess()
            hasInputMonitoringPermission = trusted

            if !trusted {
                startPermissionPolling()
            }
        }
    }

    func openSystemPreferences() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func startPermissionPolling() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkPermissions()
            if self?.hasInputMonitoringPermission == true {
                self?.permissionCheckTimer?.invalidate()
                self?.permissionCheckTimer = nil
                NotificationCenter.default.post(name: .permissionGranted, object: nil)
            }
        }
    }

    func stopPolling() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
    }
}

extension Notification.Name {
    static let permissionGranted = Notification.Name("permissionGranted")
}
