import Foundation

public struct AnalyticsEvent: Sendable, Equatable {
    public let name: String
    public let properties: [String: String]

    public init(
        name: String,
        properties: [String: String] = [:]
    ) {
        self.name = name
        self.properties = properties
    }
}

public extension AnalyticsEvent {
    static let appLaunched = AnalyticsEvent(name: "app_launched")
}
