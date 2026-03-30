import CoreNetwork
import Data
import InnoDI

@DIContainer
public struct RemoteContainer {
    @Provide(.input)
    public var networkTransport: NetworkTransport

    // Remote owns transport-backed data sources for every domain.
    // This is the composition entry that assembles domain-specific factories into a data source surface.
    // They are shared because they may encapsulate stateful infrastructure later.

    @Provide(.shared, factory: { (networkTransport: NetworkTransport) in
        UserRemoteFactory.make(networkTransport: networkTransport)
    })
    public var userRemoteDataSource: any UserRemoteDataSourceProtocol

    @Provide(.shared, factory: { (networkTransport: NetworkTransport) in
        PostRemoteFactory.make(networkTransport: networkTransport)
    })
    public var postRemoteDataSource: any PostRemoteDataSourceProtocol

    @Provide(.shared, factory: { (networkTransport: NetworkTransport) in
        TodoRemoteFactory.make(networkTransport: networkTransport)
    })
    public var todoRemoteDataSource: any TodoRemoteDataSourceProtocol
}

extension RemoteContainer: RemoteDataSourceContaining {}
