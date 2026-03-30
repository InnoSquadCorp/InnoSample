import Domain
@testable import Data
import XCTest

final class DefaultPostRepositoryTests: XCTestCase {
    @MainActor
    func testFetchPostsCuratesAndMapsRemoteModels() async throws {
        let repository = DefaultPostRepository(
            remoteDataSource: StubPostRemoteDataSource(
                posts: try makePostRemoteModels(),
                error: nil,
                counter: nil
            )
        )

        let posts = try await repository.fetchPosts()

        XCTAssertEqual(posts.count, 18)
        XCTAssertEqual(posts.first?.title, "Post 1")
        XCTAssertEqual(posts.first?.authorID, 2)
        XCTAssertEqual(posts.last?.id, 18)
    }

    @MainActor
    func testFetchPostsThrowsEmptyResponseWhenRemoteReturnsNoPosts() async throws {
        let repository = DefaultPostRepository(
            remoteDataSource: StubPostRemoteDataSource(posts: [], error: nil, counter: nil)
        )

        do {
            _ = try await repository.fetchPosts()
            XCTFail("Expected empty response error")
        } catch let error as DomainError {
            XCTAssertEqual(error.errorDescription, "포스트 응답이 비어 있습니다.")
        }
    }
}
