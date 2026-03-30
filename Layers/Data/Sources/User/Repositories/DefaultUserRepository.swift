import Domain

public struct DefaultUserRepository: UserRepositoryProtocol, Sendable {
    private let remoteDataSource: any UserRemoteDataSourceProtocol

    public init(remoteDataSource: any UserRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchUsers() async throws -> [UserSummary] {
        let users = try await remoteDataSource.fetchUsers()
        guard !users.isEmpty else {
            throw DomainError.emptyResponse("사용자")
        }
        return users.map(\.domainModel)
    }
}

private extension UserRemoteModel {
    var domainModel: UserSummary {
        UserSummary(
            id: id,
            name: name,
            username: username,
            email: email,
            phone: phone,
            website: website,
            company: companyName,
            city: city
        )
    }
}
