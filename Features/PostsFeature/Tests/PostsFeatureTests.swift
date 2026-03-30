@testable import Domain
import PostsFeatureInterface
@testable import PostsFeatureLogic
@testable import PostsFeatureRouter
import PostsFeatureTesting
import XCTest

@MainActor
final class PostsFeatureTests: XCTestCase {
    func testModelLoadsPosts() async {
        let model = PostsFeatureModel {
            PostsFeatureFixtures.posts
        }
        PostsFeatureTestRetainer.retain(model)

        model.loadIfNeeded()
        await waitUntil("posts are loaded") {
            model.posts == PostsFeatureFixtures.posts && model.isLoading == false
        }

        XCTAssertEqual(model.posts, PostsFeatureFixtures.posts)
        XCTAssertFalse(model.isLoading)
    }

    func testCoordinatorClearsSelectionAfterNavigationSync() {
        let coordinator = PostsFeatureCoordinator(
            input: PostsFeatureInput(
                fetchPostsUseCase: FetchPostsUseCase(repository: StubPostRepository())
            )
        )
        PostsFeatureTestRetainer.retain(coordinator)

        coordinator.select(PostsFeatureFixtures.posts[0])
        coordinator.syncNavigationFromSelection()

        XCTAssertNil(coordinator.selectedPostID)
    }
}

private struct StubPostRepository: PostRepositoryProtocol {
    func fetchPosts() async throws -> [PostSummary] {
        PostsFeatureFixtures.posts
    }
}

@MainActor
private func waitUntil(
    _ description: String,
    timeoutNanoseconds: UInt64 = 1_000_000_000,
    pollNanoseconds: UInt64 = 10_000_000,
    condition: @escaping @MainActor () -> Bool
) async {
    let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

    while condition() == false, DispatchTime.now().uptimeNanoseconds < deadline {
        await Task.yield()
        try? await Task.sleep(nanoseconds: pollNanoseconds)
    }

    XCTAssertTrue(condition(), description)
}

@MainActor
private enum PostsFeatureTestRetainer {
    static var retainedObjects: [AnyObject] = []

    static func retain(_ object: AnyObject) {
        retainedObjects.append(object)
    }
}
