import IOKit.hid

@MainActor
struct SystemInputMonitoringAuthorization: InputMonitoringAuthorizing {
    func currentState() -> InputMonitoringState {
        Self.state(for: IOHIDCheckAccess(kIOHIDRequestTypeListenEvent))
    }

    @discardableResult
    func requestAccess() -> Bool {
        IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
    }

    static func state(for accessType: IOHIDAccessType) -> InputMonitoringState {
        switch accessType {
        case kIOHIDAccessTypeGranted:
            .granted
        case kIOHIDAccessTypeDenied:
            .denied
        case kIOHIDAccessTypeUnknown:
            .notDetermined
        default:
            .notDetermined
        }
    }
}
