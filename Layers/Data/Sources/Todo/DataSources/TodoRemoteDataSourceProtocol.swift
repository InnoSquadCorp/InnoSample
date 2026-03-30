public protocol TodoRemoteDataSourceProtocol: Sendable {
    func fetchTodos() async throws -> [TodoRemoteModel]
}
