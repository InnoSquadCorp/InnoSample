import InnoRouter
import SettingsFeatureUI
import SwiftUI

public struct SettingsFeatureRouteHost: View {
    let coordinator: SettingsFeatureCoordinator

    public init(coordinator: SettingsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        FlowHost(store: coordinator.flowStore) { route in
            switch route {
            case .detail(let todo):
                SettingsDetailScreen(todo: todo, onOpenPeople: coordinator.openPeople)
            case .digest(let completed, let total):
                SettingsDigestSheet(completed: completed, total: total) {
                    coordinator.flowStore.send(.dismiss)
                }
            }
        } root: {
            SettingsScreen(
                model: coordinator.model,
                onSelect: coordinator.select,
                onShowDigest: coordinator.showDigest
            )
        }
        .onChange(of: coordinator.selectedTodoID, initial: true) { _, _ in
            coordinator.syncNavigationFromSelection()
        }
        .onChange(of: coordinator.pendingDigestToken, initial: false) { _, _ in
            coordinator.syncModalPresentation()
        }
    }
}
