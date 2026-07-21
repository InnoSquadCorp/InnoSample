import InnoRouter
import PostsFeatureInterface
import PostsFeatureUI
import SwiftUI

@Router
enum PostsRoute {
    case detail(FeaturePost)
    case highlights([FeaturePost])

    var destination: some View {
        switch self {
        case .detail(let post):
            PostDetailScreen(post: post)
        case .highlights(let posts):
            PostHighlightsDestination(posts: posts)
        }
    }
}

private struct PostHighlightsDestination: View {
    @EnvironmentRouter(PostsRoute.self) private var router

    let posts: [FeaturePost]

    var body: some View {
        PostHighlightsSheet(posts: posts) {
            router.dismiss()
        }
    }
}
