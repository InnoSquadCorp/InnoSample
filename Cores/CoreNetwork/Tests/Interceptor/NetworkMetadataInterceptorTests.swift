@testable import CoreNetwork
import Foundation
import XCTest

final class NetworkMetadataInterceptorTests: XCTestCase {
    func testInterceptorAppliesAppDefaultHeadersAndStripsMarker() async throws {
        let environment = NetworkEnvironment(
            baseURL: URL(string: "https://example.com")!,
            environmentName: "test"
        )
        let interceptor = NetworkMetadataInterceptor(environment: environment)
        var request = URLRequest(url: URL(string: "https://example.com/users")!)
        request.setValue(HeaderPolicy.appDefault.rawValue, forHTTPHeaderField: HeaderPolicyMarker.headerName)

        let adapted = try await interceptor.adapt(request)

        XCTAssertNil(adapted.value(forHTTPHeaderField: HeaderPolicyMarker.headerName))
        XCTAssertEqual(adapted.value(forHTTPHeaderField: "User-Agent"), environment.userAgent)
        XCTAssertEqual(adapted.value(forHTTPHeaderField: "X-Sample-Environment"), "test")
        XCTAssertEqual(adapted.value(forHTTPHeaderField: "X-Sample-Client"), environment.clientIdentifier)
        XCTAssertNotNil(adapted.value(forHTTPHeaderField: "X-Request-ID"))
    }

    func testCustomPolicySkipsEnvironmentHeadersButKeepsRequestIdentifier() async throws {
        let interceptor = NetworkMetadataInterceptor(
            environment: NetworkEnvironment(baseURL: URL(string: "https://example.com")!)
        )
        var request = URLRequest(url: URL(string: "https://example.com/users")!)
        request.setValue(HeaderPolicy.custom.rawValue, forHTTPHeaderField: HeaderPolicyMarker.headerName)

        let adapted = try await interceptor.adapt(request)

        XCTAssertNil(adapted.value(forHTTPHeaderField: "User-Agent"))
        XCTAssertNil(adapted.value(forHTTPHeaderField: "X-Sample-Environment"))
        XCTAssertNil(adapted.value(forHTTPHeaderField: "X-Sample-Client"))
        XCTAssertNotNil(adapted.value(forHTTPHeaderField: "X-Request-ID"))
    }
}
