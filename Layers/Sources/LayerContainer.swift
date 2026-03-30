import CoreNetwork
import Data
import Domain
import Remote

public struct LayerContainer {
    private let remoteContainer: RemoteContainer
    private let dataContainer: DataContainer
    private let domainContainer: DomainContainer

    public init(networkTransport: NetworkTransport) {
        self.remoteContainer = RemoteContainer(networkTransport: networkTransport)
        self.dataContainer = DataContainer(remoteContainer: remoteContainer)
        self.domainContainer = DomainContainer(dataContainer: dataContainer)
    }

    // MARK: - Feature Surface
    // Layers is a composition-only boundary. App/Features only see the feature-facing use case surface.

    public var featureUseCases: any FeatureUseCaseContaining {
        domainContainer
    }

    public var fetchPeopleUseCase: FetchPeopleUseCase {
        domainContainer.fetchPeopleUseCase
    }

    public var fetchPostsUseCase: FetchPostsUseCase {
        domainContainer.fetchPostsUseCase
    }

    public var fetchTodosUseCase: FetchTodosUseCase {
        domainContainer.fetchTodosUseCase
    }
}
