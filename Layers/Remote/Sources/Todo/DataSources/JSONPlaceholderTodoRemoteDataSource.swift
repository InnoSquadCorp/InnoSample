import CoreNetwork
import Data

public actor JSONPlaceholderTodoRemoteDataSource: TodoRemoteDataSourceProtocol {
    private let transport: NetworkTransport

    public init(transport: NetworkTransport) {
        self.transport = transport
    }

    public func fetchTodos() async throws -> [TodoRemoteModel] {
        try await transport.send(FetchTodosRequest())
    }
}
