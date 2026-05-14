import InnoRouter
import PostsFeatureUI
import SwiftUI

public struct PostsFeatureRouteHost: View {
    let coordinator: PostsFeatureCoordinator

    public init(coordinator: PostsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        // PostsFeature uses `NavigationSplitHost` rather than
        // `NavigationHost` because Posts is a long list-detail surface that
        // benefits from sidebar + detail on iPad / macOS. SwiftUI collapses
        // `NavigationSplitView` to a stack on horizontally-compact iPhone
        // automatically, so the same host renders correctly on phones with
        // the existing "tap row → push detail" interaction. PeopleFeature
        // stays on `FlowHost` and SettingsFeature on `NavigationHost` so
        // the sample documents all three shapes side by side; see
        // `Docs/ArchitectureReview.md` for the adoption guidance.
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
