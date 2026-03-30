import Domain
import Foundation
import InnoFlow

@InnoFlow
struct PostsFeatureReducer {
    struct Dependencies: Sendable {
        let loadPosts: @Sendable () async throws -> [PostSummary]
    }

    struct State: Equatable, Sendable, DefaultInitializable {
        var isLoading = false
        var hasLoaded = false
        var posts: [PostSummary] = []
        var errorMessage: String?
        var selectedPost: PostSummary?
        var pendingHighlightsRequest: PostHighlightsRequest?
        var activityLog: [String] = []

        init() {}
    }

    enum Action: Equatable, Sendable {
        case onAppear
        case refresh
        case postsLoaded([PostSummary])
        case postsFailed(String)
        case select(PostSummary)
        case showHighlights
        case clearSelection
        case clearHighlightsRequest
    }

    let dependencies: Dependencies

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoaded else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                state.activityLog.append("initial posts load")
                return loadPosts()

            case .refresh:
                state.isLoading = true
                state.errorMessage = nil
                state.activityLog.append("manual posts refresh")
                return loadPosts()

            case .postsLoaded(let posts):
                state.isLoading = false
                state.hasLoaded = true
                state.posts = posts
                state.activityLog.append("loaded \(posts.count) posts")
                return .none

            case .postsFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                state.activityLog.append("posts load failed: \(message)")
                return .none

            case .select(let post):
                state.selectedPost = post
                state.activityLog.append("push requested for post #\(post.id)")
                return .none

            case .showHighlights:
                guard !state.posts.isEmpty else { return .none }
                state.pendingHighlightsRequest = PostHighlightsRequest(posts: state.posts)
                state.activityLog.append("highlights modal requested")
                return .none

            case .clearSelection:
                state.selectedPost = nil
                return .none

            case .clearHighlightsRequest:
                state.pendingHighlightsRequest = nil
                return .none
            }
        }
    }

    private func loadPosts() -> EffectTask<Action> {
        let loadPosts = dependencies.loadPosts

        return .run { send, _ in
            do {
                let posts = try await loadPosts()
                await send(.postsLoaded(posts))
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                await send(.postsFailed(message))
            }
        }
        .cancellable("posts-feature-load", cancelInFlight: true)
    }
}
