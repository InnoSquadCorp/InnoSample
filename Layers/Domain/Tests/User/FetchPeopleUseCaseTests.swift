@testable import Domain
import XCTest

final class FetchPeopleUseCaseTests: XCTestCase {
    func testCallAsFunctionForwardsUsersFromRepository() async throws {
        let expectedUsers = [
            UserSummary(
                id: 1,
                name: "Leanne Graham",
                username: "Bret",
                email: "leanne@example.com",
                phone: "010-0000-0001",
                website: "leanne.dev",
                company: "InnoSquad",
                city: "Seoul"
            )
        ]
        let useCase = FetchPeopleUseCase(repository: StubUserRepository(users: expectedUsers))

        let users = try await useCase()

        XCTAssertEqual(users, expectedUsers)
    }

    func testCallAsFunctionPropagatesRepositoryError() async {
        let useCase = FetchPeopleUseCase(repository: StubUserRepository(error: .forced))

        do {
            _ = try await useCase()
            XCTFail("Expected repository error")
        } catch let error as StubRepositoryError {
            XCTAssertEqual(error, .forced)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
