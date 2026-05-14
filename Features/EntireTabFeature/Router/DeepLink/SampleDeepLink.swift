import InnoRouter
import InnoRouterMacros

/// App-level deep-link target. The pipeline resolves `innosample://...`
/// URLs to one of these cases and `EntireTabCoordinator.handleDeepLink(_:)`
/// translates them into tab + leaf coordinator intents. The enum is `Route`
/// (via `@Routable`) so it can flow through `DeepLinkMatcher`, but the
/// runtime navigation is performed by leaf coordinators rather than a flat
/// `NavigationStore<SampleDeepLink>`.
@Routable
public enum SampleDeepLink: Hashable, Sendable {
    case peopleDetail(userID: Int)
    case settingsDetail(assigneeID: Int)
}
