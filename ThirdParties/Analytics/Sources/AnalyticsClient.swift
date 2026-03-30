import AnalyticsInterface
import Foundation

public actor AnalyticsClient: AnalyticsService {
    private let sdk: FakeAnalyticsSDK

    public init(apiKey: String) {
        self.sdk = FakeAnalyticsSDK(apiKey: apiKey)
    }

    init(sdk: FakeAnalyticsSDK) {
        self.sdk = sdk
    }

    public func track(_ event: AnalyticsEvent) async {
        await sdk.log(event)
    }
}
