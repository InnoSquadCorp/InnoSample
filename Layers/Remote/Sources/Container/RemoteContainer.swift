import Data
import Foundation
import InnoDI
import InnoNetwork

@DIContainer
public struct RemoteContainer {
    @Provide(.input)
    public var baseURL: URL

    @Provide(.shared, factory: { (baseURL: URL) in
        RemoteClientFactory.makeClient(
            baseURL: baseURL,
            responseCache: RemotePersistentCacheFactory.make()
        )
    })
    var networkClient: any NetworkClient

    // Remote owns transport-backed data sources for every domain.
    // This is the composition entry that assembles domain-specific factories into a data source surface.
    // They are shared because they may encapsulate stateful infrastructure later.

    @Provide(.shared, factory: { (networkClient: any NetworkClient) in
        UserRemoteFactory.make(networkClient: networkClient)
    })
    public var userRemoteDataSource: any UserRemoteDataSourceProtocol

    @Provide(.shared, factory: { (networkClient: any NetworkClient) in
        PostRemoteFactory.make(networkClient: networkClient)
    })
    public var postRemoteDataSource: any PostRemoteDataSourceProtocol

    @Provide(.shared, factory: { (networkClient: any NetworkClient) in
        TodoRemoteFactory.make(networkClient: networkClient)
    })
    public var todoRemoteDataSource: any TodoRemoteDataSourceProtocol
}

extension RemoteContainer: RemoteDataSourceContaining {}
