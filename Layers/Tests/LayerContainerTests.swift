import CoreNetwork
import Domain
import InnoNetwork
@testable import Layers
import XCTest

final class LayerContainerTests: XCTestCase {
    @MainActor
    func testLayerContainerProvidesMappedPeopleUseCase() async throws {
        let container = makeLayerContainer()

        let users = try await container.fetchPeopleUseCase()

        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users.first?.city, "Seoul")
        XCTAssertEqual(users.first?.company, "InnoSquad")
    }

    @MainActor
    func testLayerContainerProvidesCuratedPostsUseCase() async throws {
        let container = makeLayerContainer()

        let posts = try await container.fetchPostsUseCase()

        XCTAssertEqual(posts.count, 18)
        XCTAssertEqual(posts.first?.authorID, 2)
        XCTAssertEqual(posts.last?.id, 18)
    }

    @MainActor
    func testLayerContainerProvidesCuratedTodosUseCase() async throws {
        let container = makeLayerContainer()

        let todos = try await container.fetchTodosUseCase()

        XCTAssertEqual(todos.count, 20)
        XCTAssertEqual(todos.first?.assigneeID, 2)
        XCTAssertEqual(todos.last?.id, 20)
    }

    @MainActor
    private func makeLayerContainer() -> LayerContainer {
        let environment = NetworkEnvironment(baseURL: URL(string: "https://example.com")!)
        let transport = NetworkFactory.makeTransport(
            environment: environment,
            session: StubURLSession(fixtures: [
                "/users": Self.usersFixture,
                "/posts": Self.postsFixture,
                "/todos": Self.todosFixture,
            ])
        )
        return LayerContainer(networkTransport: transport)
    }

    private static let usersFixture = Data(
        """
        [
          {
            "id": 1,
            "name": "Alex",
            "username": "alex",
            "email": "alex@example.com",
            "phone": "010-1111-2222",
            "website": "alex.dev",
            "address": { "city": "Seoul" },
            "company": { "name": "InnoSquad" }
          },
          {
            "id": 2,
            "name": "Bella",
            "username": "bella",
            "email": "bella@example.com",
            "phone": "010-3333-4444",
            "website": "bella.dev",
            "address": { "city": "Busan" },
            "company": { "name": "Platform Team" }
          }
        ]
        """.utf8
    )

    private static let postsFixture = Data(
        """
        [
        \(makePostsJSON(count: 25))
        ]
        """.utf8
    )

    private static let todosFixture = Data(
        """
        [
        \(makeTodosJSON(count: 23))
        ]
        """.utf8
    )

    private static func makePostsJSON(count: Int) -> String {
        (1...count).map { index in
            """
              {
                "id": \(index),
                "userId": \(index % 3 + 1),
                "title": "Post \(index)",
                "body": "Body \(index)"
              }
            """
        }.joined(separator: ",\n")
    }

    private static func makeTodosJSON(count: Int) -> String {
        (1...count).map { index in
            """
              {
                "id": \(index),
                "userId": \(index % 4 + 1),
                "title": "Todo \(index)",
                "completed": \(index.isMultiple(of: 2) ? "true" : "false")
              }
            """
        }.joined(separator: ",\n")
    }
}

private actor StubURLSession: URLSessionProtocol {
    let fixtures: [String: Data]

    init(fixtures: [String: Data]) {
        self.fixtures = fixtures
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let path = request.url?.path, let data = fixtures[path] else {
            throw StubError.missingFixture(request.url?.path ?? "unknown")
        }

        let url = URL(string: "https://example.com\(path)")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}

private enum StubError: Error {
    case missingFixture(String)
}
