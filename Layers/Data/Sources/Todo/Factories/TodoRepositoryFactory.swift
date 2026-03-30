import Domain

enum TodoRepositoryFactory {
    static func make(remoteContainer: any RemoteDataSourceContaining) -> any TodoRepositoryProtocol {
        DefaultTodoRepository(remoteDataSource: remoteContainer.todoRemoteDataSource)
    }
}
