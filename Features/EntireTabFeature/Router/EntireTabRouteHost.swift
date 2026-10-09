import EntireTabFeatureUI
import EntireTabFeatureLogic
import InnoRouter
import SwiftUI

public struct EntireTabRouteHost: View {
    @State private var coordinator: EntireTabCoordinator
    private let setup: Result<RouterTabHost<SampleTab>, Error>

    public init(coordinator: EntireTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
        setup = Result {
            try RouterTabHost(
                SampleTab.self,
                initial: .people,
                badges: [
                    .posts: EntireTabFeatureDefaults.postsBadge,
                    .settings: EntireTabFeatureDefaults.settingsBadge
                ]
            )
        }
    }

    public var body: some View {
        Group {
            switch setup {
            case .success(let host): host
            case .failure:
                ContentUnavailableView("Navigation unavailable", systemImage: "exclamationmark.triangle")
            }
        }
        .environment(coordinator)
        .environment(coordinator.peopleCoordinator)
        .environment(coordinator.postsCoordinator)
        .environment(coordinator.settingsCoordinator)
        .background(EntireTabBackgroundView())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(macOS)
        .frame(minWidth: 1080, minHeight: 720)
#endif
    }
}
