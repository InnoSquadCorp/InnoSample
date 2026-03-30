public protocol AnalyticsService: Sendable {
    func track(_ event: AnalyticsEvent) async
}
