import Data

public actor JSONPlaceholderUserRemoteDataSource: UserRemoteDataSourceProtocol {
    private let transport: RemoteTransport

    init(transport: RemoteTransport) {
        self.transport = transport
    }

    public func fetchUsers() async throws -> [UserRemoteModel] {
        try await transport.send(FetchUsersRequest())
    }
}
