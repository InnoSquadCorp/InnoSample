import Domain
@testable import Data
import XCTest

final class DefaultUserRepositoryTests: XCTestCase {
    @MainActor
    func testFetchUsersMapsRemoteModelsToDomainSummaries() async throws {
        let repository = DefaultUserRepository(
            remoteDataSource: StubUserRemoteDataSource(
                users: try makeUserRemoteModels(),
                error: nil,
                counter: nil
            )
        )

        let users = try await repository.fetchUsers()

        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users.first?.name, "User 1")
        XCTAssertEqual(users.first?.company, "Company 1")
        XCTAssertEqual(users.first?.city, "City 1")
    }

    @MainActor
    func testFetchUsersThrowsEmptyResponseWhenRemoteReturnsNoUsers() async throws {
        let repository = DefaultUserRepository(
            remoteDataSource: StubUserRemoteDataSource(users: [], error: nil, counter: nil)
        )

        do {
            _ = try await repository.fetchUsers()
            XCTFail("Expected empty response error")
        } catch let error as DomainError {
            XCTAssertEqual(error.errorDescription, "사용자 응답이 비어 있습니다.")
        }
    }
}
