import InnoRouter
import PostsFeatureUI
import PostsFeatureInterface
import SwiftUI

public struct PostsFeatureRouteHost: View {
    let coordinator: PostsFeatureCoordinator

    public init(coordinator: PostsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        host
            .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(watchOS)
            .onChange(of: navigationRevision, initial: true) { _, _ in
                if case .success(let navigation) = coordinator.navigationSetup {
                    Task { await navigation.resumeAdaptationIfPossible() }
                }
            }
#endif
            .environment(coordinator)
    }

#if !os(watchOS)
    private var navigationRevision: UInt64? {
        guard case .success(let navigation) = coordinator.navigationSetup else { return nil }
        return navigation.store.revision
    }
#endif

    @ViewBuilder
    private var host: some View {
#if os(watchOS)
        RouterHost(PostsRoute.self) {
            PostsFeatureRoot()
        }
#else
        switch coordinator.navigationSetup {
        case .success(let navigation):
            if navigation.mode == .compact {
                RouterHost(store: navigation.store, rootDeclarationID: "posts.list") {
                    PostsFeatureRoot(onNavigate: { post in
                        Task { await navigation.showDetail(post) }
                    })
                }
            } else {
                PostsSplitRouteHost(navigation: navigation)
            }
        case .failure:
            ContentUnavailableView("Navigation unavailable", systemImage: "exclamationmark.triangle")
        }
#endif
    }
}

private struct PostsDetailPlaceholder: View {
    var body: some View {
        Text("Select a post")
            .font(.title3)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PostsSplitRouteHost: View {
    private let setup: Result<RouterSplitHost<PostsRoute, PostsFeatureRoot, PostsDetailPlaceholder>, Error>

    init(navigation: PostsSplitNavigation) {
        setup = Result {
            try RouterSplitHost(
                store: navigation.store,
                layout: navigation.layout,
                sidebarDeclarationID: "posts.list",
                detailDeclarationID: "posts.detail"
            ) {
                PostsFeatureRoot(onNavigate: { post in
                    Task { await navigation.showDetail(post) }
                })
            } root: {
                PostsDetailPlaceholder()
            }
        }
    }

    var body: some View {
        switch setup {
        case .success(let host): host
        case .failure:
            ContentUnavailableView("Navigation unavailable", systemImage: "exclamationmark.triangle")
        }
    }
}

private struct PostsFeatureRoot: View {
    @Environment(PostsFeatureCoordinator.self) private var coordinator
    @EnvironmentRouter(PostsRoute.self) private var router
    var onNavigate: ((FeaturePost) -> Void)? = nil

    var body: some View {
        PostsScreen(
            model: coordinator.model,
            onSelect: coordinator.select,
            onShowHighlights: coordinator.showHighlights
        )
        .onChange(of: coordinator.selectedPostID, initial: true) { _, _ in
            guard let selectedPost = coordinator.model.consumeSelectedPost() else { return }
            if let onNavigate {
                onNavigate(selectedPost)
            } else {
                router.go(.detail(selectedPost))
            }
        }
        .onChange(of: coordinator.pendingHighlightsToken, initial: false) { _, _ in
            guard let posts = coordinator.model.consumeHighlightsPosts() else { return }
            router.sheet(.highlights(posts))
        }
    }
}
