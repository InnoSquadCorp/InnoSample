import CoreNetwork
import Data

enum UserRemoteFactory {
    static func make(networkTransport: NetworkTransport) -> any UserRemoteDataSourceProtocol {
        JSONPlaceholderUserRemoteDataSource(
            transport: networkTransport
        ) as any UserRemoteDataSourceProtocol
    }
}
