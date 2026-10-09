import Domain
import InnoDI
import InnoDITesting

enum StubRepositoryError: Error, Sendable { case forced }

@GenerateMock
protocol UserRepositoryFixture: Sendable {
    func fetchUsers() async throws -> [UserSummary]
}

extension UserRepositoryFixtureMock: UserRepositoryProtocol {}

func makeStubUserRepository(
    users: [UserSummary] = [], error: StubRepositoryError? = nil
) -> UserRepositoryFixtureMock {
    let mock = UserRepositoryFixtureMock()
    mock.fetchUsersResult = error.map { .failure($0) } ?? .success(users)
    return mock
}

@GenerateMock
protocol PostRepositoryFixture: Sendable {
    func fetchPosts() async throws -> [PostSummary]
}

extension PostRepositoryFixtureMock: PostRepositoryProtocol {}

func makeStubPostRepository(
    posts: [PostSummary] = [], error: StubRepositoryError? = nil
) -> PostRepositoryFixtureMock {
    let mock = PostRepositoryFixtureMock()
    mock.fetchPostsResult = error.map { .failure($0) } ?? .success(posts)
    return mock
}

@GenerateMock
protocol TodoRepositoryFixture: Sendable {
    func fetchTodos() async throws -> [TodoSummary]
}

extension TodoRepositoryFixtureMock: TodoRepositoryProtocol {}

func makeStubTodoRepository(
    todos: [TodoSummary] = [], error: StubRepositoryError? = nil
) -> TodoRepositoryFixtureMock {
    let mock = TodoRepositoryFixtureMock()
    mock.fetchTodosResult = error.map { .failure($0) } ?? .success(todos)
    return mock
}
