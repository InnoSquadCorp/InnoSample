public struct FetchPostsUseCase: Sendable {
    private let repository: any PostRepositoryProtocol

    init(repository: any PostRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> [PostSummary] {
        try await repository.fetchPosts()
    }
}
