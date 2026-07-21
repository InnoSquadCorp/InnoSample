import EntireTabFeatureRouter
import SwiftUI

public struct FeatureRootScene: View {
    @State private var coordinator: EntireTabCoordinator

    public init(container: FeatureContainer) {
        self.init(coordinator: container.coordinator)
    }

    public init(coordinator: EntireTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    public var body: some View {
        EntireTabRouteHost(coordinator: coordinator)
    }
}
