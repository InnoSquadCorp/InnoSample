import Foundation
import InnoNetwork

enum StubURLSessionError: Error {
    case missingFixture(path: String)
}

actor StubURLSession: URLSessionProtocol {
    private let fixtures: [String: Data]
    private let statusCode: Int
    private(set) var lastRequest: URLRequest?

    init(
        fixtures: [String: Data],
        statusCode: Int = 200
    ) {
        self.fixtures = fixtures
        self.statusCode = statusCode
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        let path = request.url?.path ?? "unknown"
        guard let data = fixtures[path] else {
            throw StubURLSessionError.missingFixture(path: path)
        }
        let url = URL(string: "https://example.com\(path)")!
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
