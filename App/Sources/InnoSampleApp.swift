import Features
import SwiftUI

@main
struct InnoSampleApp: App {
    private let container = SampleAppContainerFactory.make()

    init() {
        let appContainer = container

        Task { @MainActor in
            await appContainer.trackAppLaunched()
        }
    }

    var body: some Scene {
        WindowGroup {
            container.featureContainerRootView()
        }
    }
}
