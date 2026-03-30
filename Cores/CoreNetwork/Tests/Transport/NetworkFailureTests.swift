@testable import CoreNetwork
import Foundation
import InnoNetwork
import XCTest

final class NetworkFailureTests: XCTestCase {
    func testMapsStatusCodeError() {
        let request = URLRequest(url: URL(string: "https://example.com/users")!)
        let response = Response(
            statusCode: 503,
            data: Data("error".utf8),
            request: request,
            response: HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
        )

        let failure = NetworkFailure(networkError: .statusCode(response))

        XCTAssertEqual(failure, .invalidStatus(code: 503, data: Data("error".utf8), request: request))
    }

    func testMapsDecodingError() {
        let request = URLRequest(url: URL(string: "https://example.com/users")!)
        let response = Response(
            statusCode: 200,
            data: Data("broken".utf8),
            request: request,
            response: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        )
        let error = SendableUnderlyingError(domain: "test", code: 1, message: "decode")

        let failure = NetworkFailure(networkError: .objectMapping(error, response))

        XCTAssertEqual(failure, .decoding(error, data: Data("broken".utf8), request: request))
    }

    func testCancelledFlag() {
        let failure = NetworkFailure(networkError: .cancelled)

        XCTAssertTrue(failure.isCancelled)
    }
}
