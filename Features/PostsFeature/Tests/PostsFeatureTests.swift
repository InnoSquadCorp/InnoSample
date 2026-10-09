@testable import Domain
import InnoFlowTesting
import InnoRouter
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

        await store.send(.onAppear) {
            $0.phase = .loading
            $0.isLoading = true
            $0.activityLog = ["initial posts load"]
        }
        await store.receive(.postsLoaded(posts)) {
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

    @Test("router transitions commit stack and sheet state exhaustively")
    func routerFlowIsDeterministic() async {
        let post = PostsFeatureFixtures.posts[0]
        let navigation = RouterTestStore<PostsRoute>()

        await navigation.send(.push(.detail(post)))
        navigation.receiveStarted()
        navigation.receiveCommitted { $0 == .rootStack(path: [.detail(post)]) && $1 == 1 }
        await navigation.send(.pop(count: 1))
        navigation.receiveStarted()
        navigation.receiveCommitted { $0 == .rootStack && $1 == 2 }
        await navigation.finish()

        let modal = RouterTestStore<PostsRoute>()
        await modal.send(.present(.init(route: .highlights([post]), style: .sheet)))
        modal.receiveStarted()
        modal.receiveCommitted { state, revision in
            guard case .stack(let stack) = state.root else { return false }
            return stack.presentation?.route == .highlights([post])
                && stack.presentation?.style == .sheet && revision == 1
        }
        await modal.send(.dismissPresentation)
        modal.receiveStarted()
        modal.receiveCommitted { $0 == .rootStack && $1 == 2 }
        await modal.finish()
    }

    @Test("appearance after a failed refresh preserves phase and cached data")
    func appearancePreservesFailedRefreshPhase() async {
        var initial = PostsFeatureReducer.State()
        initial.phase = .failed
        initial.hasLoaded = true
        initial.errorMessage = "unavailable"
        let store = TestStore(
            reducer: PostsFeatureReducer(dependencies: .init(loadPosts: { [] })),
            initialState: initial
        )
        await store.send(.onAppear)
        await store.finish()
    }

    @Test("compact split starts at the list and selection updates the detail scope")
    func splitSelectionUsesOneAuthority() async throws {
        let navigation = try PostsSplitNavigation()
        guard case .container(let initial) = navigation.store.state.root else {
            Issue.record("Expected split container"); return
        }
        #expect(initial.split?.preferredCompactColumn == .sidebar)
        let post = PostsFeatureFixtures.posts[0]
        await navigation.showDetail(post)
        #expect(navigation.store.state.node(at: .root.appending(navigation.layout.sidebarScopeID)) == .stack())
        #expect(navigation.store.state.node(at: .root.appending(navigation.layout.detailScopeID)) == .stack(path: [.detail(post)]))
        guard case .container(let selected) = navigation.store.state.root else {
            Issue.record("Expected retained split container"); return
        }
        #expect(selected.split?.preferredCompactColumn == .detail)
        _ = await navigation.store.perform(.setPreferredCompactColumn(.sidebar))
        await navigation.showDetail(post)
        guard case .container(let reopened) = navigation.store.state.root else {
            Issue.record("Expected retained split container"); return
        }
        #expect(reopened.split?.preferredCompactColumn == .detail)
    }

    @Test("changing host width preserves detail history in the same store")
    func adaptiveHostsPreserveHistory() async throws {
        let navigation = try PostsSplitNavigation(mode: .compact)
        let authority = navigation.store
        let post = PostsFeatureFixtures.posts[0]
        await navigation.showDetail(post)
        #expect(navigation.store.state == .rootStack(path: [.detail(post)]))
        await navigation.adapt(to: .split)
        #expect(navigation.mode == .split)
        #expect(navigation.store === authority)
        #expect(navigation.store.state.node(at: .root.appending(navigation.layout.detailScopeID)) == .stack(path: [.detail(post)]))
        await navigation.adapt(to: .compact)
        #expect(navigation.mode == .compact)
        #expect(navigation.store === authority)
        #expect(navigation.store.state == .rootStack(path: [.detail(post)]))
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
