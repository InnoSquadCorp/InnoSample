import InnoRouter
import SettingsFeatureUI
import SwiftUI

public struct SettingsFeatureRouteHost: View {
    let coordinator: SettingsFeatureCoordinator

    public init(coordinator: SettingsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        ModalHost(store: coordinator.modalStore) { route in
            switch route {
            case .digest(let completed, let total):
                SettingsDigestSheet(completed: completed, total: total) {
                    coordinator.modalStore.send(.dismiss)
                }
            }
        } content: {
            NavigationHost(store: coordinator.navigationStore) { route in
                switch route {
                case .detail(let todo):
                    SettingsDetailScreen(todo: todo, onOpenPeople: coordinator.openPeople)
                }
            } root: {
                SettingsScreen(
                    model: coordinator.model,
                    onSelect: coordinator.select,
                    onShowDigest: coordinator.showDigest
                )
            }
        }
        .onChange(of: coordinator.selectedTodoID, initial: true) { _, _ in
            coordinator.syncNavigationFromSelection()
        }
        .onChange(of: coordinator.pendingDigestToken, initial: false) { _, _ in
            coordinator.syncModalPresentation()
        }
    }
}
