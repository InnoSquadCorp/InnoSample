import Data
import InnoNetwork

enum TodoRemoteFactory {
    static func make(networkClient: any NetworkClient) -> any TodoRemoteDataSourceProtocol {
        JSONPlaceholderTodoRemoteDataSource(
            transport: RemoteTransport(client: networkClient)
        ) as any TodoRemoteDataSourceProtocol
    }
}
