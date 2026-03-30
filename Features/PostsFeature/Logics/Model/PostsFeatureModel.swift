import Domain
import InnoFlow
import Observation

@MainActor
@Observable
public final class PostsFeatureModel {
    private let store: Store<PostsFeatureReducer>

    public init(loadPosts: @escaping @Sendable () async throws -> [PostSummary]) {
        self.store = Store(
            reducer: PostsFeatureReducer(
                dependencies: .init(loadPosts: loadPosts)
            )
        )
    }

    public var posts: [PostSummary] { store.posts }
    public var isLoading: Bool { store.isLoading }
    public var errorMessage: String? { store.errorMessage }
    public var activityLog: [String] { store.activityLog }
    public var selectedPostID: Int? { store.selectedPost?.id }
    public var pendingHighlightsToken: UUID? { store.pendingHighlightsRequest?.id }

    public func loadIfNeeded() { store.send(.onAppear) }
    public func refresh() { store.send(.refresh) }
    public func select(_ post: PostSummary) { store.send(.select(post)) }
    public func showHighlights() { store.send(.showHighlights) }

    public func consumeSelectedPost() -> PostSummary? {
        let selectedPost = store.selectedPost
        guard let selectedPost else { return nil }
        store.send(.clearSelection)
        return selectedPost
    }

    public func consumeHighlightsPosts() -> [PostSummary]? {
        let posts = store.pendingHighlightsRequest?.posts
        guard let posts else { return nil }
        store.send(.clearHighlightsRequest)
        return posts
    }
}
