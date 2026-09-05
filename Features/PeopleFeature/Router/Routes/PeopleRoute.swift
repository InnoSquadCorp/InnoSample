import InnoDISwiftUI
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
    private let factory: PeopleDetailContainer.AssistedFactory
    private let user: PeopleUser
    private let onOpenSettings: (OpenSettingsRequest) -> Void

    init(
        factory: PeopleDetailContainer.AssistedFactory,
        user: PeopleUser,
        onOpenSettings: @escaping (OpenSettingsRequest) -> Void
    ) {
        self.factory = factory
        self.user = user
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        DIContainerHost(
            identity: user,
            factory: { user in factory(user: user) },
            content: { container, _ in
                PeopleDetailScreen(
                    user: container.session.user,
                    onOpenSettings: onOpenSettings
                )
            },
            loading: {
                ProgressView()
            },
            failure: { _, lifecycle in
                ContentUnavailableView {
                    Label("사용자 화면을 열 수 없습니다", systemImage: "person.crop.circle.badge.exclamationmark")
                } actions: {
                    Button("다시 시도") {
                        lifecycle.retry()
                    }
                }
            }
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
