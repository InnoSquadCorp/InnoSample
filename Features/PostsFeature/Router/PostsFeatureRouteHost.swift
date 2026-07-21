import InnoRouter
import PostsFeatureUI
import SwiftUI

public struct PostsFeatureRouteHost: View {
    let coordinator: PostsFeatureCoordinator

    public init(coordinator: PostsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        host
            .environment(coordinator)
    }

    @ViewBuilder
    private var host: some View {
#if os(watchOS)
        RouterHost(PostsRoute.self) {
            PostsFeatureRoot()
        }
#else
        RouterSplitHost(PostsRoute.self) {
            PostsFeatureRoot()
        } root: {
            Text("Select a post")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
#endif
    }
}

private struct PostsFeatureRoot: View {
    @Environment(PostsFeatureCoordinator.self) private var coordinator
    @EnvironmentRouter(PostsRoute.self) private var router

    var body: some View {
        PostsScreen(
            model: coordinator.model,
            onSelect: coordinator.select,
            onShowHighlights: coordinator.showHighlights
        )
        .onChange(of: coordinator.selectedPostID, initial: false) { _, _ in
            guard let selectedPost = coordinator.model.consumeSelectedPost() else { return }
            router.go(.detail(selectedPost))
        }
        .onChange(of: coordinator.pendingHighlightsToken, initial: false) { _, _ in
            guard let posts = coordinator.model.consumeHighlightsPosts() else { return }
            router.sheet(.highlights(posts))
        }
    }
}
