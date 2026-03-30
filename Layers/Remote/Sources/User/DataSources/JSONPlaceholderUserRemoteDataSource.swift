import CoreNetwork
import Data

public actor JSONPlaceholderUserRemoteDataSource: UserRemoteDataSourceProtocol {
    private let transport: NetworkTransport

    public init(transport: NetworkTransport) {
        self.transport = transport
    }

    public func fetchUsers() async throws -> [UserRemoteModel] {
        try await transport.send(FetchUsersRequest())
    }
}
