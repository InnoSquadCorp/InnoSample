public protocol RepositoryContaining {
    var userRepository: any UserRepositoryProtocol { get }
    var postRepository: any PostRepositoryProtocol { get }
    var todoRepository: any TodoRepositoryProtocol { get }
}
