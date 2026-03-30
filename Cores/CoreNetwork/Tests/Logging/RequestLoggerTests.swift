@testable import CoreNetwork
import Foundation
import InnoNetwork
import XCTest

final class RequestLoggerTests: XCTestCase {
    func testLoggerMethodsDoNotThrow() {
        let logger = RequestLogger()
        let request = URLRequest(url: URL(string: "https://example.com/users")!)
        let response = Response(
            statusCode: 200,
            data: Data("{}".utf8),
            request: request,
            response: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        )

        logger.log(request: request)
        logger.log(response: response, isError: false)
        logger.log(error: .undefined)
    }
}
