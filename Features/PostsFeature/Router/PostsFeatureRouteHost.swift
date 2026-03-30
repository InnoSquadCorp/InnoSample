import InnoRouter
import PostsFeatureUI
import SwiftUI

public struct PostsFeatureRouteHost: View {
    let coordinator: PostsFeatureCoordinator

    public init(coordinator: PostsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        ModalHost(store: coordinator.modalStore) { route in
            switch route {
            case .highlights(let posts):
                PostHighlightsSheet(posts: posts) {
                    coordinator.modalStore.send(.dismiss)
                }
            }
        } content: {
            NavigationHost(store: coordinator.navigationStore) { route in
                switch route {
                case .detail(let post):
                    PostDetailScreen(post: post)
                }
            } root: {
                PostsScreen(
                    model: coordinator.model,
                    onSelect: coordinator.select,
                    onShowHighlights: coordinator.showHighlights
                )
            }
        }
        .onChange(of: coordinator.selectedPostID, initial: false) { _, _ in
            coordinator.syncNavigationFromSelection()
        }
        .onChange(of: coordinator.pendingHighlightsToken, initial: false) { _, _ in
            coordinator.syncModalPresentation()
        }
    }
}
