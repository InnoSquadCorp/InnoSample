import EntireTabFeatureUI
import EntireTabFeatureLogic
import InnoRouter
import SwiftUI

public struct EntireTabRouteHost: View {
    @State private var coordinator: EntireTabCoordinator

    public init(coordinator: EntireTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    public var body: some View {
        @Bindable var coordinator = self.coordinator
        // Each feature already owns its native stack/split host. A tab-level
        // NavigationStack would nest hosts and reset child paths on tab changes.
        return TabView(selection: $coordinator.selectedTab) {
            ForEach(SampleTab.routerTabs) { descriptor in
                Tab(value: descriptor.tab) {
                    SampleTab.destination(for: descriptor.root)
                } label: {
                    Label(descriptor.tab.title, systemImage: descriptor.tab.systemImage)
                }
#if !os(tvOS) && !os(watchOS)
                .badge(badge(for: descriptor.tab))
#endif
            }
        }
        .environment(coordinator)
        .environment(coordinator.peopleCoordinator)
        .environment(coordinator.postsCoordinator)
        .environment(coordinator.settingsCoordinator)
        .background(EntireTabBackgroundView())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(watchOS)
        // The tab viewport remains mounted while a native detail destination
        // obscures its root. Observe width here instead of in that root.
        .onGeometryChange(for: Bool.self) { geometry in
            geometry.size.width >= 800
        } action: { isWide in
            Task { await coordinator.updateLayout(isWide: isWide) }
        }
#endif
#if os(macOS)
        .frame(minWidth: 1080, minHeight: 720)
#endif
    }

    private func badge(for tab: SampleTab.Tab) -> Int {
        switch tab {
        case .people: 0
        case .posts: EntireTabFeatureDefaults.postsBadge
        case .settings: EntireTabFeatureDefaults.settingsBadge
        }
    }
}
