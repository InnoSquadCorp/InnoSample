@testable import CoreNetwork
import Foundation
import InnoNetwork
import XCTest

final class NetworkStatusInterceptorTests: XCTestCase {
    func testInterceptorReturnsRetryCandidateResponsesUnchanged() async throws {
        let interceptor = NetworkStatusInterceptor()
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let response = Response(
            statusCode: 503,
            data: Data(),
            request: request,
            response: HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
        )

        let adapted = try await interceptor.adapt(response, request: request)

        XCTAssertEqual(adapted.statusCode, 503)
    }
}
