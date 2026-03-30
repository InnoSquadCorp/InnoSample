import CoreNetwork
import Data

enum TodoRemoteFactory {
    static func make(networkTransport: NetworkTransport) -> any TodoRemoteDataSourceProtocol {
        JSONPlaceholderTodoRemoteDataSource(
            transport: networkTransport
        ) as any TodoRemoteDataSourceProtocol
    }
}
