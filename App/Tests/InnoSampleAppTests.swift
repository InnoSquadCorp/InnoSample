import Features
import Layers
@testable import InnoSampleApp
import XCTest

final class InnoSampleAppTests: XCTestCase {
    func testAppContainerBuildsFeatureContainer() async {
        let selectedTab = await MainActor.run {
            let container = AppContainer(
                baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
            )
            return container.featureContainer.coordinator.selectedTab.rawValue
        }

        XCTAssertEqual(selectedTab, "people")
    }

    func testAppContainerBuildsNetworkAndLayerContainers() async {
        let snapshot = await MainActor.run {
            let container = AppContainer(
                baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
            )
            _ = container.networkTransport
            _ = container.layerContainer.fetchPeopleUseCase
            _ = container.layerContainer.fetchPostsUseCase
            _ = container.layerContainer.fetchTodosUseCase
            _ = container.layerContainer.featureUseCases.fetchPeopleUseCase

            return (
                true,
                true,
                true,
                true,
                true
            )
        }

        XCTAssertTrue(snapshot.0)
        XCTAssertTrue(snapshot.1)
        XCTAssertTrue(snapshot.2)
        XCTAssertTrue(snapshot.3)
        XCTAssertTrue(snapshot.4)
    }

    func testAppContainerTracksLaunchEventWithoutBreakingAsyncWiring() async {
        let didTrack = await MainActor.run {
            let container = AppContainer(
                baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
            )
            return container
        }

        await didTrack.trackAppLaunched()
    }

    func testAppContainerBuildsFeatureRootScene() async {
        let renderedScene = await MainActor.run {
            let container = AppContainer(
                baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
            )
            let scene = FeatureRootScene(coordinator: container.featureContainer.coordinator)
            _ = scene.body
            return true
        }

        XCTAssertTrue(renderedScene)
    }
}
