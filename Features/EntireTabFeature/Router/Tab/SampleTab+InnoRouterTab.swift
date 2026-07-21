import InnoRouter
import PeopleFeatureRouter
import PostsFeatureRouter
import SettingsFeatureRouter
import SwiftUI

@Router
public enum SampleTab {
    @TabItem("People", systemImage: "person.2")
    case people

    @TabItem("Posts", systemImage: "doc.text")
    case posts

    @TabItem("Settings", systemImage: "gearshape")
    case settings

    public var destination: some View {
        switch self {
        case .people:
            PeopleTabDestination()
        case .posts:
            PostsTabDestination()
        case .settings:
            SettingsTabDestination()
        }
    }
}

private struct PeopleTabDestination: View {
    @Environment(EntireTabCoordinator.self) private var coordinator

    var body: some View {
        PeopleFeatureRouteHost(coordinator: coordinator.peopleCoordinator)
            .modifier(SampleTabRoutingBridge())
    }
}

private struct PostsTabDestination: View {
    @Environment(EntireTabCoordinator.self) private var coordinator

    var body: some View {
        PostsFeatureRouteHost(coordinator: coordinator.postsCoordinator)
            .modifier(SampleTabRoutingBridge())
    }
}

private struct SettingsTabDestination: View {
    @Environment(EntireTabCoordinator.self) private var coordinator

    var body: some View {
        SettingsFeatureRouteHost(coordinator: coordinator.settingsCoordinator)
            .modifier(SampleTabRoutingBridge())
    }
}

private struct SampleTabRoutingBridge: ViewModifier {
    @Environment(EntireTabCoordinator.self) private var coordinator
    @EnvironmentRouter(SampleTab.self) private var tabRouter

    func body(content: Content) -> some View {
        content
            .onChange(
                of: coordinator.peopleCoordinator.pendingSettingsRequestID,
                initial: false
            ) { _, _ in
                guard let tab = coordinator.consumeCrossFeatureNavigationFromPeople() else {
                    return
                }
                tabRouter.select(tab)
            }
            .onChange(
                of: coordinator.settingsCoordinator.pendingPeopleRequestID,
                initial: false
            ) { _, _ in
                guard let tab = coordinator.consumeCrossFeatureNavigationFromSettings() else {
                    return
                }
                tabRouter.select(tab)
            }
            .onOpenURL { url in
                guard let tab = coordinator.handleDeepLink(url) else { return }
                tabRouter.select(tab)
            }
    }
}
