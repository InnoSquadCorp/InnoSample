@testable import CoreNetwork
import XCTest

final class NetworkFactoryTests: XCTestCase {
    func testMakeEnvironmentUsesExpectedDefaults() {
        let baseURL = URL(string: "https://example.com")!

        let environment = NetworkFactory.makeEnvironment(baseURL: baseURL)

        XCTAssertEqual(environment.baseURL, baseURL)
        XCTAssertEqual(environment.appName, "InnoSample")
        XCTAssertEqual(environment.appVersion, "1.0.0")
        XCTAssertEqual(environment.environmentName, "sample-dev")
        XCTAssertEqual(environment.clientIdentifier, "InnoSample\(expectedPlatformName)")
        XCTAssertEqual(environment.userAgent, "InnoSample/1.0.0 (\(expectedPlatformName))")
    }

    func testClientIdentifierUsesConfiguredAppName() {
        let environment = NetworkEnvironment(
            baseURL: URL(string: "https://example.com")!,
            appName: "CustomApp",
            appVersion: "2.0.0"
        )

        XCTAssertEqual(environment.clientIdentifier, "CustomApp\(expectedPlatformName)")
        XCTAssertEqual(environment.userAgent, "CustomApp/2.0.0 (\(expectedPlatformName))")
    }

    func testMakeDefaultsIncludesExpectedPolicyObjects() {
        let defaults = NetworkFactory.makeDefaults(
            environment: NetworkEnvironment(baseURL: URL(string: "https://example.com")!)
        )

        XCTAssertEqual(defaults.requestInterceptors.count, 1)
        XCTAssertEqual(defaults.responseInterceptors.count, 1)
        XCTAssertTrue(defaults.logger is RequestLogger)
        XCTAssertTrue(defaults.requestInterceptors.first is NetworkMetadataInterceptor)
        XCTAssertTrue(defaults.responseInterceptors.first is NetworkStatusInterceptor)
    }

    private var expectedPlatformName: String {
        #if os(iOS)
        "iOS"
        #elseif os(macOS)
        "macOS"
        #elseif os(watchOS)
        "watchOS"
        #elseif os(tvOS)
        "tvOS"
        #elseif os(visionOS)
        "visionOS"
        #else
        "unknown"
        #endif
    }
}
