import InnoRouter
import InnoRouterMacros
import PostsFeatureInterface

@Routable
enum PostsModalRoute {
    case highlights([FeaturePost])
}
