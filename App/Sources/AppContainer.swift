import Analytics
import AnalyticsInterface
import CoreNetwork
import Features
import Foundation
import InnoDI
import Layers

@MainActor
@DIContainer(root: true)
struct AppContainer {
    // MARK: - Inputs

    @Provide(.input)
    var baseURL: URL

    // MARK: - Infrastructure

    @Provide(.shared, factory: {
        AnalyticsClient(apiKey: "innosample-demo-key")
    }, concrete: true)
    var analyticsClient: AnalyticsClient

    @Provide(.shared, factory: { (baseURL: URL) in
        NetworkFactory.makeTransport(baseURL: baseURL)
    }, concrete: true)
    var networkTransport: NetworkTransport

    // MARK: - Layer Composition

    @Provide(.shared, factory: { (networkTransport: NetworkTransport) in
        LayerContainer.make(networkTransport: networkTransport)
    }, concrete: true)
    var layerContainer: LayerContainer

    // MARK: - Root Features

    @Provide(.shared, factory: { (layerContainer: LayerContainer) in
        FeatureContainer.make(useCases: layerContainer.featureUseCases)
    }, concrete: true)
    var featureContainer: FeatureContainer

    // MARK: - Lifecycle

    func trackAppLaunched() async {
        await analyticsClient.track(.appLaunched)
    }
}
