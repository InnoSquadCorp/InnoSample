import InnoRouter
import InnoRouterMacros
import PostsFeatureInterface

@Routable
enum PostsRoute {
    case detail(FeaturePost)
}
