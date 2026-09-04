import InnoRouter
import PeopleFeatureInterface
import PeopleFeatureUI
import SwiftUI

@Router
enum PeopleRoute {
    case detail(PeopleUser)
    case overview([PeopleUser])

    var destination: some View {
        switch self {
        case .detail(let user):
            PeopleDetailDestination(user: user)
        case .overview(let users):
            PeopleOverviewDestination(users: users)
        }
    }
}

private struct PeopleDetailDestination: View {
    @Environment(PeopleFeatureCoordinator.self) private var coordinator

    let user: PeopleUser

    var body: some View {
        PeopleDetailFeature(
            factory: coordinator.detailFactory,
            user: user,
            onOpenSettings: coordinator.openSettings
        )
    }
}

private struct PeopleDetailFeature: View {
    @State private var container: PeopleDetailContainer

    private let onOpenSettings: (OpenSettingsRequest) -> Void

    init(
        factory: PeopleDetailContainer.AssistedFactory,
        user: PeopleUser,
        onOpenSettings: @escaping (OpenSettingsRequest) -> Void
    ) {
        _container = State(initialValue: factory(user: user))
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        PeopleDetailScreen(
            user: container.session.user,
            onOpenSettings: onOpenSettings
        )
    }
}

private struct PeopleOverviewDestination: View {
    @EnvironmentRouter(PeopleRoute.self) private var router

    let users: [PeopleUser]

    var body: some View {
        PeopleOverviewSheet(users: users) {
            router.dismiss()
        }
    }
}
