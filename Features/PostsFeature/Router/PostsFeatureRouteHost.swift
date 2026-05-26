import InnoRouter
import PostsFeatureUI
import SwiftUI

public struct PostsFeatureRouteHost: View {
    let coordinator: PostsFeatureCoordinator

    public init(coordinator: PostsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        // PostsFeature is the split-view sample: NavigationSplitHost is the
        // canonical InnoRouter surface for long list-detail features.
        ModalHost(store: coordinator.modalStore) { route in
            switch route {
            case .highlights(let posts):
                PostHighlightsSheet(posts: posts) {
                    coordinator.modalStore.send(.dismiss)
                }
            }
        } content: {
            NavigationSplitHost(store: coordinator.navigationStore) {
                PostsScreen(
                    model: coordinator.model,
                    onSelect: coordinator.select,
                    onShowHighlights: coordinator.showHighlights
                )
            } destination: { route in
                switch route {
                case .detail(let post):
                    PostDetailScreen(post: post)
                }
            } root: {
                Text("Select a post")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
