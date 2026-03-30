public protocol PostRepositoryProtocol: Sendable {
    func fetchPosts() async throws -> [PostSummary]
}
