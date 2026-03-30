@testable import Domain
import XCTest

final class FetchPostsUseCaseTests: XCTestCase {
    func testCallAsFunctionForwardsPostsFromRepository() async throws {
        let expectedPosts = [
            PostSummary(
                id: 100,
                title: "Post",
                body: "Body",
                authorID: 1
            )
        ]
        let useCase = FetchPostsUseCase(repository: StubPostRepository(posts: expectedPosts))

        let posts = try await useCase()

        XCTAssertEqual(posts, expectedPosts)
    }

    func testCallAsFunctionPropagatesRepositoryError() async {
        let useCase = FetchPostsUseCase(repository: StubPostRepository(error: .forced))

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
