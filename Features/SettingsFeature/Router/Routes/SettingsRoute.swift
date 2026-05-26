import InnoRouter
import InnoRouterMacros
import SettingsFeatureInterface

@Routable
enum SettingsRoute {
    case detail(FeatureTodo)
    case digest(completed: Int, total: Int)
}
