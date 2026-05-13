import InnoRouter
import InnoRouterMacros

@Routable
enum SettingsModalRoute {
    case digest(completed: Int, total: Int)
}
