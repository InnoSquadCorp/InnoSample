@testable import CoreNetwork
import Foundation
import InnoNetwork

struct TransportTestResponse: Codable, Equatable, Sendable {
    let value: String
}

struct TransportTestPayload: Codable, Equatable, Sendable {
    let name: String
}

struct TransportTestRequest: RequestDefinition {
    typealias ResponseBody = TransportTestResponse

    let featureName: String
    let path: String
    let method: RequestMethod
    let queryItems: [URLQueryItem]
    let body: RequestBody
    let headerPolicy: HeaderPolicy
    let additionalHeaders: [String: String]
    let responsePolicy: ResponsePolicy

    init(
        featureName: String = "People",
        path: String = "/users",
        method: RequestMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: RequestBody = .none,
        headerPolicy: HeaderPolicy = .appDefault,
        additionalHeaders: [String: String] = [:],
        responsePolicy: ResponsePolicy = .json
    ) {
        self.featureName = featureName
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headerPolicy = headerPolicy
        self.additionalHeaders = additionalHeaders
        self.responsePolicy = responsePolicy
    }
}

actor StubURLSession: URLSessionProtocol {
    private let handler: @Sendable (URLRequest) throws -> (Data, URLResponse)
    private(set) var lastRequest: URLRequest?

    init(
        fixtures: [String: Data] = ["/users": Data(#"{"value":"ok"}"#.utf8)],
        statusCode: Int = 200
    ) {
        self.handler = { request in
            guard let path = request.url?.path, let data = fixtures[path] else {
                throw StubSessionError.missingFixture(request.url?.path ?? "unknown")
            }

            let response = HTTPURLResponse(
                url: request.url ?? URL(string: "https://example.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        }
    }

    init(handler: @escaping @Sendable (URLRequest) throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        return try handler(request)
    }
}

enum StubSessionError: Error, Sendable, Equatable {
    case missingFixture(String)
    case explicit(String)
}
