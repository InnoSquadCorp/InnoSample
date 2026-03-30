import Domain

public struct DefaultTodoRepository: TodoRepositoryProtocol, Sendable {
    private let remoteDataSource: any TodoRemoteDataSourceProtocol

    public init(remoteDataSource: any TodoRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchTodos() async throws -> [TodoSummary] {
        let todos = try await remoteDataSource.fetchTodos()
        let curated = Array(todos.prefix(20))
        guard !curated.isEmpty else {
            throw DomainError.emptyResponse("할 일")
        }
        return curated.map(\.domainModel)
    }
}

private extension TodoRemoteModel {
    var domainModel: TodoSummary {
        TodoSummary(
            id: id,
            title: title,
            completed: completed,
            assigneeID: assigneeID
        )
    }
}
