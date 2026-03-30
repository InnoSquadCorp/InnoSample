import EntireTabFeatureRouter
import SwiftUI

public struct FeatureRootScene: View {
    @State private var coordinator: EntireTabCoordinator

    public init(coordinator: EntireTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    public var body: some View {
        EntireTabRouteHost(coordinator: coordinator)
    }
}
