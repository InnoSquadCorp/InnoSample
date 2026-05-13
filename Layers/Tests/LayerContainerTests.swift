import Domain
import Foundation
@testable import Layers
import XCTest

final class LayerContainerTests: XCTestCase {
    @MainActor
    func testLayerContainerExposesFeatureUseCaseSurface() {
        let container = LayerContainer(baseURL: URL(string: "https://example.com")!)

        _ = container.featureUseCases
        XCTAssertTrue(type(of: container.fetchPeopleUseCase) == FetchPeopleUseCase.self)
        XCTAssertTrue(type(of: container.fetchPostsUseCase) == FetchPostsUseCase.self)
        XCTAssertTrue(type(of: container.fetchTodosUseCase) == FetchTodosUseCase.self)
    }
}
