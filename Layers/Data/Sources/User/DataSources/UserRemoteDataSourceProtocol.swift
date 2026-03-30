public protocol UserRemoteDataSourceProtocol: Sendable {
    func fetchUsers() async throws -> [UserRemoteModel]
}
