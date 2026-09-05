import Data
import Domain
import Foundation
import InnoDI
import Remote

@DIContainer
public struct LayerContainer {
    @Input
    public var baseURL: URL

    @Provide(.shared, RemoteContainer.self, with: [\Self.baseURL])
    var remoteContainer: RemoteContainer

    @Provide(.shared, factory: { (remoteContainer: RemoteContainer) in
        remoteContainer as any RemoteDataSourceContaining
    })
    var remoteDataSources: any RemoteDataSourceContaining

    @Provide(.shared, factory: { (remoteDataSources: any RemoteDataSourceContaining) in
        DataContainer(remoteContainer: remoteDataSources)
    })
    var dataContainer: DataContainer

    @Provide(.shared, factory: { (dataContainer: DataContainer) in
        dataContainer as any RepositoryContaining
    })
    var repositories: any RepositoryContaining

    @Provide(.shared, factory: { (repositories: any RepositoryContaining) in
        DomainContainer(dataContainer: repositories)
    })
    var domainContainer: DomainContainer

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
