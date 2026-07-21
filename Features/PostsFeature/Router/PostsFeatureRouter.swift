import Foundation
import Observation
import PostsFeatureInterface
import PostsFeatureLogic

@MainActor
@Observable
public final class PostsFeatureCoordinator {
    let model: PostsFeatureModel

    init(input: PostsFeatureInput) {
        self.model = PostsFeatureModel(loadPosts: input.fetchPostsUseCase.callAsFunction)
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
