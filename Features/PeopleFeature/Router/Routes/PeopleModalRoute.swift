import InnoRouter
import InnoRouterMacros
import PeopleFeatureInterface

@Routable
enum PeopleModalRoute {
    case overview([PeopleUser])
}
