@testable import Domain
import XCTest

final class DomainErrorTests: XCTestCase {
    func testEmptyResponseHasExpectedLocalizedDescription() {
        let error = DomainError.emptyResponse("사용자")

        XCTAssertEqual(error.errorDescription, "사용자 응답이 비어 있습니다.")
        XCTAssertEqual(error.localizedDescription, "사용자 응답이 비어 있습니다.")
    }
}
