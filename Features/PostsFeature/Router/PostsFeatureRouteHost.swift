import InnoRouter
import PostsFeatureUI
import PostsFeatureInterface
import SwiftUI

public struct PostsFeatureRouteHost: View {
    let coordinator: PostsFeatureCoordinator
#if !os(watchOS)
    @State private var setup: Result<PostsSplitNavigation, Error>
#endif

    public init(coordinator: PostsFeatureCoordinator) {
        self.coordinator = coordinator
#if !os(watchOS)
        _setup = State(initialValue: Result { try PostsSplitNavigation(mode: .compact) })
#endif
    }

    public var body: some View {
        GeometryReader { geometry in
            host
                .task(id: geometry.size.width >= 800) {
#if !os(watchOS)
                    if case .success(let navigation) = setup {
                        await navigation.adapt(to: geometry.size.width >= 800 ? .split : .compact)
                    }
#endif
                }
        }
        .environment(coordinator)
    }

    @ViewBuilder
    private var host: some View {
#if os(watchOS)
        RouterHost(PostsRoute.self) {
            PostsFeatureRoot()
        }
#else
        switch setup {
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
