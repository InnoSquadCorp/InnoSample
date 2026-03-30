import Foundation
@testable import Data

enum StubRemoteDataSourceError: Error, Sendable {
    case forced
}

actor StubCallCounter {
    private(set) var count = 0

    func increment() {
        count += 1
    }

    func value() -> Int {
        count
    }
}

struct StubRemoteContainer: RemoteDataSourceContaining, Sendable {
    let userRemoteDataSource: any UserRemoteDataSourceProtocol
    let postRemoteDataSource: any PostRemoteDataSourceProtocol
    let todoRemoteDataSource: any TodoRemoteDataSourceProtocol
}

struct StubUserRemoteDataSource: UserRemoteDataSourceProtocol, Sendable {
    let users: [UserRemoteModel]
    let error: StubRemoteDataSourceError?
    let counter: StubCallCounter?

    @MainActor
    func fetchUsers() async throws -> [UserRemoteModel] {
        await counter?.increment()
        if let error {
            throw error
        }
        return users
    }
}

struct StubPostRemoteDataSource: PostRemoteDataSourceProtocol, Sendable {
    let posts: [PostRemoteModel]
    let error: StubRemoteDataSourceError?
    let counter: StubCallCounter?

    @MainActor
    func fetchPosts() async throws -> [PostRemoteModel] {
        await counter?.increment()
        if let error {
            throw error
        }
        return posts
    }
}

struct StubTodoRemoteDataSource: TodoRemoteDataSourceProtocol, Sendable {
    let todos: [TodoRemoteModel]
    let error: StubRemoteDataSourceError?
    let counter: StubCallCounter?

    @MainActor
    func fetchTodos() async throws -> [TodoRemoteModel] {
        await counter?.increment()
        if let error {
            throw error
        }
        return todos
    }
}

func makeUserRemoteModels(count: Int = 2) throws -> [UserRemoteModel] {
    let json = """
    [
    \( (1...count).map { index in
        """
          {
            "id": \(index),
            "name": "User \(index)",
            "username": "user\(index)",
            "email": "user\(index)@example.com",
            "phone": "010-0000-000\(index)",
            "website": "user\(index).dev",
            "address": { "city": "City \(index)" },
            "company": { "name": "Company \(index)" }
          }
        """
    }.joined(separator: ",\n") )
    ]
    """

    return try JSONDecoder().decode([UserRemoteModel].self, from: Foundation.Data(json.utf8))
}

func makePostRemoteModels(count: Int = 25) throws -> [PostRemoteModel] {
    let json = """
    [
    \( (1...count).map { index in
        """
          {
            "id": \(index),
            "userId": \(index % 3 + 1),
            "title": "post \(index)",
            "body": "Body \(index)"
          }
        """
    }.joined(separator: ",\n") )
    ]
    """

    return try JSONDecoder().decode([PostRemoteModel].self, from: Foundation.Data(json.utf8))
}

func makeTodoRemoteModels(count: Int = 23) throws -> [TodoRemoteModel] {
    let json = """
    [
    \( (1...count).map { index in
        """
          {
            "id": \(index),
            "userId": \(index % 4 + 1),
            "title": "Todo \(index)",
            "completed": \(index.isMultiple(of: 2) ? "true" : "false")
          }
        """
    }.joined(separator: ",\n") )
    ]
    """

    return try JSONDecoder().decode([TodoRemoteModel].self, from: Foundation.Data(json.utf8))
}
