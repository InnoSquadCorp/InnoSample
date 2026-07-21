import Analytics
import AnalyticsInterface
import Domain
import Features
import Foundation
import InnoDI
import InnoDISwiftUI
import Layers

@DIHierarchyRoot
@DIContainer(root: true, mainActor: true)
struct AppContainer {
    // MARK: - Inputs

    @Provide(.input)
    var baseURL: URL

    // MARK: - Infrastructure

    @Provide(.shared, factory: {
        AnalyticsClient(apiKey: "innosample-demo-key")
    })
    var analyticsClient: AnalyticsClient

    // MARK: - Layer Composition

    @Provide(.shared, LayerContainer.self, with: [\Self.baseURL])
    var layerContainer: LayerContainer

    // MARK: - Root Features

    @Provide(.shared, factory: { (layerContainer: LayerContainer) in
        layerContainer.featureUseCases
    })
    var featureUseCases: any FeatureUseCaseContaining

    @SubContainer(
        scope: .shared,
        bindings: [(child: \FeatureContainer.useCases, parent: \AppContainer.featureUseCases)],
        featureRoot: FeatureRootScene.self
    )
    var featureContainer: FeatureContainer

    // MARK: - Lifecycle

    @MainActor
    func trackAppLaunched() async {
        await analyticsClient.track(.appLaunched)
    }
}
