import AnalyticsInterface
import Foundation

struct FakeAnalyticsRecord: Sendable, Equatable {
    let apiKey: String
    let event: AnalyticsEvent
}

actor FakeAnalyticsSDK {
    private let apiKey: String
    private var records: [FakeAnalyticsRecord] = []

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func log(_ event: AnalyticsEvent) {
        records.append(FakeAnalyticsRecord(apiKey: apiKey, event: event))
    }

    func recordedEvents() -> [FakeAnalyticsRecord] {
        records
    }
}
