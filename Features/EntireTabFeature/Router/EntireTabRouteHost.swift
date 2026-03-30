import EntireTabFeatureUI
import InnoRouter
import SwiftUI

public struct EntireTabRouteHost: View {
    @State private var coordinator: EntireTabCoordinator

    public init(coordinator: EntireTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    public var body: some View {
#if os(macOS)
        TabCoordinatorView(coordinator: coordinator)
            .background(EntireTabBackgroundView(selectedTab: coordinator.selectedTab))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minWidth: 1080, minHeight: 720)
            .onChange(of: coordinator.peopleCoordinator.pendingSettingsRequestID, initial: false) { _, _ in
                coordinator.syncCrossFeatureNavigationFromPeople()
            }
            .onChange(of: coordinator.settingsCoordinator.pendingPeopleRequestID, initial: false) { _, _ in
                coordinator.syncCrossFeatureNavigationFromSettings()
            }
#else
        TabCoordinatorView(coordinator: coordinator)
            .background(EntireTabBackgroundView(selectedTab: coordinator.selectedTab))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: coordinator.peopleCoordinator.pendingSettingsRequestID, initial: false) { _, _ in
                coordinator.syncCrossFeatureNavigationFromPeople()
            }
            .onChange(of: coordinator.settingsCoordinator.pendingPeopleRequestID, initial: false) { _, _ in
                coordinator.syncCrossFeatureNavigationFromSettings()
            }
#endif
    }
}
