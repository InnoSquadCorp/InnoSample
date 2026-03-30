import Domain
import InnoDI

@DIContainer
public struct DataContainer {
    @Provide(.input)
    public var remoteContainer: any RemoteDataSourceContaining

    // Data owns repositories and keeps them shared.
    // Repositories are the right place for cache/state, not use cases.

    @Provide(.shared, factory: { (remoteContainer: any RemoteDataSourceContaining) in
        UserRepositoryFactory.make(remoteContainer: remoteContainer)
    })
    public var userRepository: any UserRepositoryProtocol

    @Provide(.shared, factory: { (remoteContainer: any RemoteDataSourceContaining) in
        PostRepositoryFactory.make(remoteContainer: remoteContainer)
    })
    public var postRepository: any PostRepositoryProtocol

    @Provide(.shared, factory: { (remoteContainer: any RemoteDataSourceContaining) in
        TodoRepositoryFactory.make(remoteContainer: remoteContainer)
    })
    public var todoRepository: any TodoRepositoryProtocol
}
