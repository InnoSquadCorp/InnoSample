import Domain

enum PostRepositoryFactory {
    static func make(remoteContainer: any RemoteDataSourceContaining) -> any PostRepositoryProtocol {
        DefaultPostRepository(remoteDataSource: remoteContainer.postRemoteDataSource)
    }
}
