import Data
import InnoNetwork

enum PostRemoteFactory {
    static func make(networkClient: any NetworkClient) -> any PostRemoteDataSourceProtocol {
        JSONPlaceholderPostRemoteDataSource(
            transport: RemoteTransport(client: networkClient)
        ) as any PostRemoteDataSourceProtocol
    }
}
