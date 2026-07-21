import InnoRouter
import SettingsFeatureInterface
import SettingsFeatureUI
import SwiftUI

@Router
enum SettingsRoute {
    case detail(FeatureTodo)
    case digest(completed: Int, total: Int)

    var destination: some View {
        switch self {
        case .detail(let todo):
            SettingsDetailDestination(todo: todo)
        case .digest(let completed, let total):
            SettingsDigestDestination(completed: completed, total: total)
        }
    }
}

private struct SettingsDetailDestination: View {
    @Environment(SettingsFeatureCoordinator.self) private var coordinator

    let todo: FeatureTodo

    var body: some View {
        SettingsDetailScreen(todo: todo, onOpenPeople: coordinator.openPeople)
    }
}

private struct SettingsDigestDestination: View {
    @EnvironmentRouter(SettingsRoute.self) private var router

    let completed: Int
    let total: Int

    var body: some View {
        SettingsDigestSheet(completed: completed, total: total) {
            router.dismiss()
        }
    }
}
