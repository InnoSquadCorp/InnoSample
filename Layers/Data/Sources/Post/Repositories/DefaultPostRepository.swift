import Domain

public struct DefaultPostRepository: PostRepositoryProtocol, Sendable {
    private let remoteDataSource: any PostRemoteDataSourceProtocol

    public init(remoteDataSource: any PostRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchPosts() async throws -> [PostSummary] {
        let posts = try await remoteDataSource.fetchPosts()
        let curated = Array(posts.prefix(18))
        guard !curated.isEmpty else {
            throw DomainError.emptyResponse("포스트")
        }
        return curated.map(\.domainModel)
    }
}

private extension PostRemoteModel {
    var domainModel: PostSummary {
        PostSummary(
            id: id,
            title: title.capitalized,
            body: body,
            authorID: authorID
        )
    }
}
