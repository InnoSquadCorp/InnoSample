import Features
import SwiftUI

@main
struct InnoSampleApp: App {
    private let container = AppContainer(
        baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
    )

    init() {
        let appContainer = container

        Task { @MainActor in
            await appContainer.trackAppLaunched()
        }
    }

    var body: some Scene {
        WindowGroup {
            FeatureRootScene(coordinator: container.featureContainer.coordinator)
        }
    }
}
