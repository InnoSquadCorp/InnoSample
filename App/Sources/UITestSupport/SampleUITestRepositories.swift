#if DEBUG
import Domain

/// Deterministic app-boundary fixtures; all feature/reducer/router wiring stays live.
struct SampleUITestRepositories: RepositoryContaining {
    var userRepository: any UserRepositoryProtocol { SampleUITestUserRepository() }
    var postRepository: any PostRepositoryProtocol { SampleUITestPostRepository() }
    var todoRepository: any TodoRepositoryProtocol { SampleUITestTodoRepository() }
}

private struct SampleUITestUserRepository: UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserSummary] {
        [.init(id: 1, name: "Alex Sample", username: "alex", email: "alex@example.com",
               phone: "010-0000-0001", website: "example.com", company: "InnoSquad", city: "Seoul")]
    }
}

private struct SampleUITestPostRepository: PostRepositoryProtocol {
    func fetchPosts() async throws -> [PostSummary] {
        [.init(id: 1, title: "Sample post", body: "Deterministic routing fixture", authorID: 1)]
    }
}

private struct SampleUITestTodoRepository: TodoRepositoryProtocol {
    func fetchTodos() async throws -> [TodoSummary] {
        [.init(id: 1, title: "Verify navigation", completed: false, assigneeID: 1),
         .init(id: 2, title: "Verify filtering", completed: true, assigneeID: 1)]
    }
}
#endif
