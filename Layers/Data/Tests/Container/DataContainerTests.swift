import Domain
@testable import Data
import XCTest

final class DataContainerTests: XCTestCase {
    @MainActor
    func testDataContainerProvidesRepositoriesBackedByRemoteDataSources() async throws {
        let container = DataContainer(
            remoteContainer: StubRemoteContainer(
                userRemoteDataSource: StubUserRemoteDataSource(
                    users: try makeUserRemoteModels(),
                    error: nil,
                    counter: nil
                ),
                postRemoteDataSource: StubPostRemoteDataSource(
                    posts: try makePostRemoteModels(),
                    error: nil,
                    counter: nil
                ),
                todoRemoteDataSource: StubTodoRemoteDataSource(
                    todos: try makeTodoRemoteModels(),
                    error: nil,
                    counter: nil
                )
            )
        )

        let users = try await container.userRepository.fetchUsers()
        let posts = try await container.postRepository.fetchPosts()
        let todos = try await container.todoRepository.fetchTodos()

        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(posts.count, 18)
        XCTAssertEqual(todos.count, 20)
    }

    @MainActor
    func testDataContainerRepositoriesRemainUsableAcrossRepeatedAccess() async throws {
        let userCounter = StubCallCounter()
        let container = DataContainer(
            remoteContainer: StubRemoteContainer(
                userRemoteDataSource: StubUserRemoteDataSource(
                    users: try makeUserRemoteModels(),
                    error: nil,
                    counter: userCounter
                ),
                postRemoteDataSource: StubPostRemoteDataSource(posts: [], error: nil, counter: nil),
                todoRemoteDataSource: StubTodoRemoteDataSource(todos: [], error: nil, counter: nil)
            )
        )

        let firstUsers = try await container.userRepository.fetchUsers()
        let secondUsers = try await container.userRepository.fetchUsers()
        let callCount = await userCounter.value()

        XCTAssertEqual(firstUsers.map(\.id), secondUsers.map(\.id))
        XCTAssertEqual(callCount, 2)
    }
}
