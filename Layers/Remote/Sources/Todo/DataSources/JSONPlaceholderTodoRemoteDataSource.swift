import Data

public actor JSONPlaceholderTodoRemoteDataSource: TodoRemoteDataSourceProtocol {
    private let transport: RemoteTransport

    init(transport: RemoteTransport) {
        self.transport = transport
    }

    public func fetchTodos() async throws -> [TodoRemoteModel] {
        try await transport.send(FetchTodosRequest())
    }
}
