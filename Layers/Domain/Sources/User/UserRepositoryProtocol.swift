public protocol UserRepositoryProtocol: Sendable {
    func fetchUsers() async throws -> [UserSummary]
}
