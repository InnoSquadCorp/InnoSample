import Data

public actor JSONPlaceholderPostRemoteDataSource: PostRemoteDataSourceProtocol {
    private let transport: RemoteTransport

    init(transport: RemoteTransport) {
        self.transport = transport
    }

    public func fetchPosts() async throws -> [PostRemoteModel] {
        try await transport.send(FetchPostsRequest())
    }
}
