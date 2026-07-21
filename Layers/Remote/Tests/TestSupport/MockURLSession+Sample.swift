import Foundation
import InnoNetworkTestSupport

extension MockURLSessionResponse {
    init(
        statusCode: Int = 200,
        data: Data = Data(),
        headers: [String: String] = [:]
    ) {
        self = .http(statusCode: statusCode, data: data, headers: headers)
    }
}

extension MockURLSession {
    convenience init(sequences: [String: [MockURLSessionResponse]]) {
        self.init()
        precondition(sequences.count == 1, "Each sample test session scripts one endpoint path.")
        setScriptedResponses(sequences.values.first ?? [])
    }

    var requestsByPath: [String: [URLRequest]] {
        Dictionary(grouping: capturedRequestsInOrder) { request in
            request.url?.path ?? "unknown"
        }
    }

    func callCount(forPath path: String) -> Int {
        requestsByPath[path]?.count ?? 0
    }
}
