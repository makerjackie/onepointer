@MainActor
protocol InputMonitoringAuthorizing {
    func currentState() -> InputMonitoringState

    @discardableResult
    func requestAccess() -> Bool
}
