import InnoRouter
import PeopleFeatureUI
import SwiftUI

public struct PeopleFeatureRouteHost: View {
    let coordinator: PeopleFeatureCoordinator

    public init(coordinator: PeopleFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        RouterHost(PeopleRoute.self) {
            PeopleFeatureRoot()
        }
        .environment(coordinator)
    }
}

private struct PeopleFeatureRoot: View {
    @Environment(PeopleFeatureCoordinator.self) private var coordinator
    @EnvironmentRouter(PeopleRoute.self) private var router

    var body: some View {
        PeopleScreen(
            model: coordinator.model,
            onSelect: coordinator.select,
            onShowOverview: coordinator.showOverview
        )
        .onChange(of: coordinator.selectedUserID, initial: true) { _, _ in
            guard let selectedUser = coordinator.model.consumeSelectedUser() else { return }
            router.send(flow: .replaceStack([.detail(selectedUser)]))
        }
        .onChange(of: coordinator.pendingOverviewToken, initial: false) { _, _ in
            guard let users = coordinator.model.consumeOverviewUsers() else { return }
            router.sheet(.overview(users))
        }
    }
}
