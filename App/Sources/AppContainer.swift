import Analytics
import AnalyticsInterface
import Domain
import Features
import Foundation
import InnoDI
import InnoDISwiftUI
import Layers
import SwiftUI

@DIContainerRole(role: ContainerRole.root, mainActor: true)
struct AppContainer {
    // MARK: - Inputs

    @Input
    var baseURL: URL

    // MARK: - Infrastructure

    @Provide(.shared, initialization: .onDemand, effect: .sideEffect, factory: {
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
        bindings: [(child: \FeatureContainer.useCases, parent: \Self.featureUseCases)],
        featureRoot: FeatureRootScene.self
    )
    var featureContainer: FeatureContainer

    // MARK: - Lifecycle

    @MainActor
    func trackAppLaunched() async {
        await analyticsClient.track(.appLaunched)
    }
}
