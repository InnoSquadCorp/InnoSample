@testable import Analytics
import AnalyticsInterface
import XCTest

final class AnalyticsClientTests: XCTestCase {
    func testTrackRecordsEventIntoUnderlyingSDK() async {
        let sdk = FakeAnalyticsSDK(apiKey: "test-key")
        let analyticsClient = AnalyticsClient(sdk: sdk)

        await analyticsClient.track(.appLaunched)
        let records = await sdk.recordedEvents()

        XCTAssertEqual(
            records,
            [FakeAnalyticsRecord(apiKey: "test-key", event: .appLaunched)]
        )
    }
}
