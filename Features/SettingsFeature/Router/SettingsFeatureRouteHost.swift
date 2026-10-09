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
    @EnvironmentRouterState(SettingsRoute.self) private var routerState
    @State private var presentationFailed = false

    var body: some View {
        SettingsScreen(
            model: coordinator.model,
            onSelect: coordinator.select,
            onShowDigest: {
                guard routerState.presentationFamily == nil else { return }
                coordinator.showDigest()
            }
        )
        .onChange(of: coordinator.selectedTodoID, initial: true) { _, _ in
            guard let selectedTodo = coordinator.model.consumeSelectedTodo() else { return }
            router.dispatch(.replaceStack([.detail(selectedTodo)]))
        }
        .onChange(of: coordinator.pendingDigestToken, initial: false) { _, _ in
            guard let request = coordinator.model.consumeDigestRequest() else { return }
            Task {
                let result = await router.present(
                    SettingsRoute.Presentation.digest(completed: request.completed, total: request.total)
                )
                switch result {
                case .value(true): coordinator.model.acknowledgeDigest()
                case .value(false), .dismissed, .cancelled: break
                case .rejected: presentationFailed = true
                }
            }
        }
        .alert("Summary unavailable", isPresented: $presentationFailed) {
            Button("OK", role: .cancel) {}
        }
    }
}
