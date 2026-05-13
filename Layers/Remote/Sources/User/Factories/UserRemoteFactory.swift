import Data
import InnoNetwork

enum UserRemoteFactory {
    static func make(networkClient: any NetworkClient) -> any UserRemoteDataSourceProtocol {
        JSONPlaceholderUserRemoteDataSource(
            transport: RemoteTransport(client: networkClient)
        ) as any UserRemoteDataSourceProtocol
    }
}
