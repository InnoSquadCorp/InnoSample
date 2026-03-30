import CoreNetwork
import Data

public actor JSONPlaceholderPostRemoteDataSource: PostRemoteDataSourceProtocol {
    private let transport: NetworkTransport

    public init(transport: NetworkTransport) {
        self.transport = transport
    }

    public func fetchPosts() async throws -> [PostRemoteModel] {
        try await transport.send(FetchPostsRequest())
    }
}
