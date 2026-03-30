import Domain

enum UserRepositoryFactory {
    static func make(remoteContainer: any RemoteDataSourceContaining) -> any UserRepositoryProtocol {
        DefaultUserRepository(remoteDataSource: remoteContainer.userRemoteDataSource)
    }
}
