import Foundation
import InnoNetwork
@testable import Remote
import XCTest

final class RemoteFailureTests: XCTestCase {
    func testCancelledNetworkErrorMapsToCancelledRemoteFailure() {
        let failure = RemoteFailure(networkError: .cancelled)

        XCTAssertTrue(failure.isCancelled)
        XCTAssertEqual(failure.errorDescription, "Remote request was cancelled")
    }

    func testInvalidBaseURLMapsToTransportFailure() {
        let failure = RemoteFailure(networkError: .configuration(reason: .invalidBaseURL("://broken")))

        guard case .transport(let error, nil) = failure else {
            return XCTFail("Unexpected failure: \(failure)")
        }

        XCTAssertEqual(error.domain, "com.innosquad.remote")
        XCTAssertEqual(error.code, NetworkErrorCode.configurationInvalidBaseURL.rawValue)
    }
}
