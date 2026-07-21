@testable import Domain
import InnoFlowTesting
import InnoRouterTesting
import PostsFeatureInterface
@testable import PostsFeatureLogic
@testable import PostsFeatureRouter
import PostsFeatureTesting
import Testing

@Suite("Posts feature")
@MainActor
struct PostsFeatureTests {
    @Test("phase-managed load is deterministic")
    func reducerLoadsPosts() async {
        let posts = PostsFeatureFixtures.posts
        let store = TestStore(
            reducer: PostsFeatureReducer(
                dependencies: .init(loadPosts: { posts })
            )
        )

        await store.send(.onAppear, through: PostsFeatureReducer.phaseMap) {
            $0.phase = .loading
            $0.isLoading = true
            $0.activityLog = ["initial posts load"]
        }
        await store.receive(.postsLoaded(posts), through: PostsFeatureReducer.phaseMap) {
            $0.phase = .loaded
            $0.isLoading = false
            $0.hasLoaded = true
            $0.posts = posts
            $0.activityLog.append("loaded \(posts.count) posts")
        }
        await store.finish()
    }

    @Test("selection is consumed once at the routing boundary")
    func coordinatorConsumesSelection() {
        let coordinator = makeCoordinator()
        let post = PostsFeatureFixtures.posts[0]

        coordinator.select(post)

        #expect(coordinator.model.consumeSelectedPost() == post)
        #expect(coordinator.selectedPostID == nil)
        #expect(coordinator.model.consumeSelectedPost() == nil)
    }

    @Test("router flow emits split-detail and sheet events without a host")
    func routerFlowIsDeterministic() {
        let post = PostsFeatureFixtures.posts[0]
        let navigation = FlowTestStore<PostsRoute>()

        navigation.send(.push(.detail(post)))
        navigation.receiveNavigationChanged { from, to in
            from.path.isEmpty && to.path == [.detail(post)]
        }
        navigation.receivePathChanged { old, new in
            old.isEmpty && new == [.push(.detail(post))]
        }
        navigation.finish()

        let modal = FlowTestStore<PostsRoute>()
        modal.send(.presentSheet(.highlights([post])))
        modal.receiveModalPresented { presentation in
            presentation.route == .highlights([post]) && presentation.style == .sheet
        }
        modal.receiveModalCommandIntercepted()
        modal.receivePathChanged { old, new in
            old.isEmpty && new == [.sheet(.highlights([post]))]
        }
        modal.finish()
    }

    private func makeCoordinator() -> PostsFeatureCoordinator {
        PostsFeatureCoordinator(
            input: PostsFeatureInput(
                fetchPostsUseCase: FetchPostsUseCase(repository: StubPostRepository())
            )
        )
    }
}

private struct StubPostRepository: PostRepositoryProtocol {
    func fetchPosts() async throws -> [PostSummary] {
        PostsFeatureFixtures.posts
    }
}
