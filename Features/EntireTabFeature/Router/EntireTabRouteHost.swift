import EntireTabFeatureUI
import EntireTabFeatureLogic
import InnoRouter
import SwiftUI

public struct EntireTabRouteHost: View {
    @State private var coordinator: EntireTabCoordinator

    public init(coordinator: EntireTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    public var body: some View {
        RouterTabHost(
            SampleTab.self,
            initial: .people,
            badges: [
                .posts: EntireTabFeatureDefaults.postsBadge,
                .settings: EntireTabFeatureDefaults.settingsBadge
            ]
        )
            .environment(coordinator)
            .background(EntireTabBackgroundView())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(macOS)
            .frame(minWidth: 1080, minHeight: 720)
#endif
    }
}
