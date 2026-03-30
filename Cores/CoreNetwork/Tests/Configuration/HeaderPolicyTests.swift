@testable import CoreNetwork
import XCTest

final class HeaderPolicyTests: XCTestCase {
    func testAppDefaultHeadersContainInternalMetadata() {
        let environment = NetworkEnvironment(
            baseURL: URL(string: "https://example.com")!,
            environmentName: "test"
        )

        let headers = environment.resolvedHeaders(for: .appDefault)

        XCTAssertEqual(headers["Accept-Language"], environment.preferredLanguage)
        XCTAssertEqual(headers["User-Agent"], environment.userAgent)
        XCTAssertEqual(headers["X-Sample-Client"], environment.clientIdentifier)
        XCTAssertEqual(headers["X-Sample-Environment"], "test")
    }

    func testExternalHeadersExcludeInternalMetadata() {
        let environment = NetworkEnvironment(baseURL: URL(string: "https://example.com")!)

        let headers = environment.resolvedHeaders(for: .external)

        XCTAssertEqual(headers["Accept-Language"], environment.preferredLanguage)
        XCTAssertEqual(headers["User-Agent"], environment.userAgent)
        XCTAssertNil(headers["X-Sample-Client"])
        XCTAssertNil(headers["X-Sample-Environment"])
    }
}
