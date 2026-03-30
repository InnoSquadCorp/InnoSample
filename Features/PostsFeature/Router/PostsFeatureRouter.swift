import Foundation
import InnoRouter
import Observation
import PostsFeatureInterface
import PostsFeatureLogic

@MainActor
@Observable
public final class PostsFeatureCoordinator {
    let navigationStore = NavigationStore<PostsRoute>()
    let modalStore = ModalStore<PostsModalRoute>()
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

    func syncNavigationFromSelection() {
        guard let selectedPost = model.consumeSelectedPost() else { return }
        navigationStore.send(.go(.detail(selectedPost)))
    }

    func syncModalPresentation() {
        guard let posts = model.consumeHighlightsPosts() else { return }
        modalStore.send(.present(.highlights(posts), style: .sheet))
    }
}
