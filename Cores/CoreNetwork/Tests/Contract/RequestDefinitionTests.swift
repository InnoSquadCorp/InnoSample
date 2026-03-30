@testable import CoreNetwork
import XCTest

final class RequestDefinitionTests: XCTestCase {
    func testDefaultValuesMatchCoreNetworkPolicy() {
        let request = TransportTestRequest()

        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.queryItems, [])
        XCTAssertEqual(request.body, .none)
        XCTAssertEqual(request.contentType, .json)
        XCTAssertEqual(request.headerPolicy, .appDefault)
        XCTAssertEqual(request.additionalHeaders, [:])
        XCTAssertEqual(request.responsePolicy, .json)
    }
}
