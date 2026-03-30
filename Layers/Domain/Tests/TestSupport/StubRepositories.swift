import Domain

enum StubRepositoryError: Error, Sendable {
    case forced
}

struct StubUserRepository: UserRepositoryProtocol {
    let users: [UserSummary]
    let error: StubRepositoryError?

    init(users: [UserSummary] = [], error: StubRepositoryError? = nil) {
        self.users = users
        self.error = error
    }

    func fetchUsers() async throws -> [UserSummary] {
        if let error {
            throw error
        }
        return users
    }
}

struct StubPostRepository: PostRepositoryProtocol {
    let posts: [PostSummary]
    let error: StubRepositoryError?

    init(posts: [PostSummary] = [], error: StubRepositoryError? = nil) {
        self.posts = posts
        self.error = error
    }

    func fetchPosts() async throws -> [PostSummary] {
        if let error {
            throw error
        }
        return posts
    }
}

struct StubTodoRepository: TodoRepositoryProtocol {
    let todos: [TodoSummary]
    let error: StubRepositoryError?

    init(todos: [TodoSummary] = [], error: StubRepositoryError? = nil) {
        self.todos = todos
        self.error = error
    }

    func fetchTodos() async throws -> [TodoSummary] {
        if let error {
            throw error
        }
        return todos
    }
}
