import InnoRouter
import PeopleFeatureUI
import SwiftUI

public struct PeopleFeatureRouteHost: View {
    let coordinator: PeopleFeatureCoordinator

    public init(coordinator: PeopleFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        ModalHost(store: coordinator.modalStore) { route in
            switch route {
            case .overview(let users):
                PeopleOverviewSheet(users: users) {
                    coordinator.modalStore.send(.dismiss)
                }
            }
        } content: {
            NavigationHost(store: coordinator.navigationStore) { route in
                switch route {
                case .detail(let user):
                    PeopleDetailScreen(user: user, onOpenSettings: coordinator.openSettings)
                }
            } root: {
                PeopleScreen(
                    model: coordinator.model,
                    onSelect: coordinator.select,
                    onShowOverview: coordinator.showOverview
                )
            }
        }
        .onChange(of: coordinator.selectedUserID, initial: false) { _, _ in
            coordinator.syncNavigationFromSelection()
        }
        .onChange(of: coordinator.pendingOverviewToken, initial: false) { _, _ in
            coordinator.syncModalPresentation()
        }
    }
}
