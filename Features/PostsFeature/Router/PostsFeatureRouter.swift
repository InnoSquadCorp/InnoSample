import Foundation
import Observation
import PostsFeatureInterface
import PostsFeatureLogic

@MainActor
@Observable
public final class PostsFeatureCoordinator {
    let model: PostsFeatureModel
#if !os(watchOS)
    let navigationSetup: Result<PostsSplitNavigation, Error>
#endif

    init(input: PostsFeatureInput) {
        self.model = PostsFeatureModel(loadPosts: input.fetchPostsUseCase.callAsFunction)
#if !os(watchOS)
        navigationSetup = Result { try PostsSplitNavigation(mode: .compact) }
#endif
    }

    public func updateLayout(isWide: Bool) async {
#if !os(watchOS)
        if case .success(let navigation) = navigationSetup {
            await navigation.adapt(to: isWide ? .split : .compact)
        }
#endif
    }

    var selectedPostID: Int? { model.selectedPostID }
    var pendingHighlightsToken: UUID? { model.pendingHighlightsToken }

    func select(_ post: FeaturePost) {
        model.select(post)
    }

    func showHighlights() {
        model.showHighlights()
    }

}
