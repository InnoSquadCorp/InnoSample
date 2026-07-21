import InnoRouter
import SettingsFeatureUI
import SwiftUI

public struct SettingsFeatureRouteHost: View {
    let coordinator: SettingsFeatureCoordinator

    public init(coordinator: SettingsFeatureCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        RouterHost(SettingsRoute.self) {
            SettingsFeatureRoot()
        }
        .environment(coordinator)
    }
}

private struct SettingsFeatureRoot: View {
    @Environment(SettingsFeatureCoordinator.self) private var coordinator
    @EnvironmentRouter(SettingsRoute.self) private var router

    var body: some View {
        SettingsScreen(
            model: coordinator.model,
            onSelect: coordinator.select,
            onShowDigest: coordinator.showDigest
        )
        .onChange(of: coordinator.selectedTodoID, initial: true) { _, _ in
            guard let selectedTodo = coordinator.model.consumeSelectedTodo() else { return }
            router.send(flow: .replaceStack([.detail(selectedTodo)]))
        }
        .onChange(of: coordinator.pendingDigestToken, initial: false) { _, _ in
            guard let request = coordinator.model.consumeDigestRequest() else { return }
            router.sheet(.digest(completed: request.completed, total: request.total))
        }
    }
}
