import InnoRouter
import InnoRouterMacros
import PeopleFeatureInterface

/// Unified route enum consumed by `FlowStore<PeopleRoute>`. The previous
/// split between `PeopleRoute` (push destinations) and `PeopleModalRoute`
/// (sheet destinations) is collapsed here because `FlowStore` represents
/// push + modal progression on a single typed array. The intent
/// (`.push` vs `.presentSheet`) decides whether each case is rendered
/// inline or as a modal at runtime; the enum itself just identifies
/// what to show.
@Routable
enum PeopleRoute {
    case detail(PeopleUser)
    case overview([PeopleUser])
}
