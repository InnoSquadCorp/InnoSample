import Domain
@testable import Data
import XCTest

final class DefaultTodoRepositoryTests: XCTestCase {
    @MainActor
    func testFetchTodosCuratesAndMapsRemoteModels() async throws {
        let repository = DefaultTodoRepository(
            remoteDataSource: StubTodoRemoteDataSource(
                todos: try makeTodoRemoteModels(),
                error: nil,
                counter: nil
            )
        )

        let todos = try await repository.fetchTodos()

        XCTAssertEqual(todos.count, 20)
        XCTAssertEqual(todos.first?.title, "Todo 1")
        XCTAssertEqual(todos.first?.assigneeID, 2)
        XCTAssertEqual(todos.first?.completed, false)
        XCTAssertEqual(todos.last?.id, 20)
    }

    @MainActor
    func testFetchTodosThrowsEmptyResponseWhenRemoteReturnsNoTodos() async throws {
        let repository = DefaultTodoRepository(
            remoteDataSource: StubTodoRemoteDataSource(todos: [], error: nil, counter: nil)
        )

        do {
            _ = try await repository.fetchTodos()
            XCTFail("Expected empty response error")
        } catch let error as DomainError {
            XCTAssertEqual(error.errorDescription, "할 일 응답이 비어 있습니다.")
        }
    }
}
