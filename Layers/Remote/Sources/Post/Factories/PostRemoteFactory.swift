import CoreNetwork
import Data

enum PostRemoteFactory {
    static func make(networkTransport: NetworkTransport) -> any PostRemoteDataSourceProtocol {
        JSONPlaceholderPostRemoteDataSource(
            transport: networkTransport
        ) as any PostRemoteDataSourceProtocol
    }
}
