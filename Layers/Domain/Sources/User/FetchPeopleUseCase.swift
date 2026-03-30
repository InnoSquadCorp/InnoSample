public struct FetchPeopleUseCase: Sendable {
    private let repository: any UserRepositoryProtocol

    init(repository: any UserRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> [UserSummary] {
        try await repository.fetchUsers()
    }
}
