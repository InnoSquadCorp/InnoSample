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
        PeopleDetailScreen(user: user, onOpenSettings: coordinator.openSettings)
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
