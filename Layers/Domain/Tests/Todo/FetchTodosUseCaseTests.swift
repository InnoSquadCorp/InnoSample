@testable import Domain
import XCTest

final class FetchTodosUseCaseTests: XCTestCase {
    func testCallAsFunctionForwardsTodosFromRepository() async throws {
        let expectedTodos = [
            TodoSummary(
                id: 200,
                title: "Todo",
                completed: false,
                assigneeID: 1
            )
        ]
        let useCase = FetchTodosUseCase(repository: StubTodoRepository(todos: expectedTodos))

        let todos = try await useCase()

        XCTAssertEqual(todos, expectedTodos)
    }

    func testCallAsFunctionPropagatesRepositoryError() async {
        let useCase = FetchTodosUseCase(repository: StubTodoRepository(error: .forced))

        do {
            _ = try await useCase()
            XCTFail("Expected repository error")
        } catch let error as StubRepositoryError {
            XCTAssertEqual(error, .forced)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
