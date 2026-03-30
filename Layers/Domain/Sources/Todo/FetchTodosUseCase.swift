public struct FetchTodosUseCase: Sendable {
    private let repository: any TodoRepositoryProtocol

    init(repository: any TodoRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> [TodoSummary] {
        try await repository.fetchTodos()
    }
}
