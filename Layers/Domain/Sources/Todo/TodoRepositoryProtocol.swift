public protocol TodoRepositoryProtocol: Sendable {
    func fetchTodos() async throws -> [TodoSummary]
}
