import InnoRouter
import InnoRouterMacros
import PeopleFeatureInterface

@Routable
enum PeopleRoute {
    case detail(PeopleUser)
}
