import InnoRouter
import PeopleFeatureUI
import SwiftUI

public struct PeopleFeatureRouteHost: View {
    let coordinator: PeopleFeatureCoordinator

    public init(coordinator: PeopleFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        FlowHost(store: coordinator.flowStore) { route in
            switch route {
            case .detail(let user):
                PeopleDetailScreen(user: user, onOpenSettings: coordinator.openSettings)
            case .overview(let users):
                PeopleOverviewSheet(users: users) {
                    coordinator.flowStore.send(.dismiss)
                }
            }
        } root: {
            PeopleScreen(
                model: coordinator.model,
                onSelect: coordinator.select,
                onShowOverview: coordinator.showOverview
            )
        }
        .onChange(of: coordinator.selectedUserID, initial: true) { _, _ in
            coordinator.syncNavigationFromSelection()
        }
        .onChange(of: coordinator.pendingOverviewToken, initial: false) { _, _ in
            coordinator.syncModalPresentation()
        }
    }
}
