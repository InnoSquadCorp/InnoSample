import Foundation
import InnoNetwork

/// `URLSessionProtocol` stub that returns a queued sequence of HTTP responses
/// per path, so tests can simulate retry recovery, exhaustion, and
/// non-retryable failures with deterministic call counts.
///
/// The last response in the queue is replayed when call count exceeds the
/// queue size, so a single-response queue behaves like a fixed stub.
actor SequencedStubURLSession: URLSessionProtocol {
    struct Response: Sendable {
        let statusCode: Int
        let data: Data
        let headers: [String: String]

        init(statusCode: Int = 200, data: Data = Data(), headers: [String: String] = [:]) {
            self.statusCode = statusCode
            self.data = data
            self.headers = headers
        }
    }

    private let responsesByPath: [String: [Response]]
    private(set) var requestsByPath: [String: [URLRequest]] = [:]

    init(sequences: [String: [Response]]) {
        self.responsesByPath = sequences
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let path = request.url?.path ?? "unknown"
        requestsByPath[path, default: []].append(request)

        guard let queue = responsesByPath[path], !queue.isEmpty else {
            throw StubURLSessionError.missingFixture(path: path)
        }

        let count = requestsByPath[path]?.count ?? 0
        let index = min(count - 1, queue.count - 1)
        let response = queue[index]

        let url = URL(string: "https://example.com\(path)")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: response.statusCode,
            httpVersion: nil,
            headerFields: response.headers
        )!
        return (response.data, httpResponse)
    }

    func callCount(forPath path: String) -> Int {
        requestsByPath[path]?.count ?? 0
    }
}
