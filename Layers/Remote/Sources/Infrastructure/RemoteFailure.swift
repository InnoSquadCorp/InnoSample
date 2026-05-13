import Foundation
import InnoNetwork

enum RemoteFailure: Error, Sendable, Equatable {
    case invalidRequestConfiguration(String)
    case invalidStatus(code: Int, data: Data?, request: URLRequest?)
    case decoding(SendableUnderlyingError, data: Data?, request: URLRequest?)
    case transport(SendableUnderlyingError, request: URLRequest?)
    case cancelled(request: URLRequest?)
    case invalidResponse(request: URLRequest?)

    init(networkError: NetworkError) {
        switch networkError {
        case .configuration(reason: let reason):
            switch reason {
            case .invalidRequest(let message), .offline(let message):
                self = .invalidRequestConfiguration(message)
            case .invalidBaseURL(let string):
                self = .transport(
                    SendableUnderlyingError(
                        domain: "com.innosquad.remote",
                        code: NetworkErrorCode.configurationInvalidBaseURL.rawValue,
                        message: "Invalid base URL: \(string)"
                    ),
                    request: nil
                )
            }
        case .statusCode(let response):
            self = .invalidStatus(
                code: response.statusCode,
                data: response.data,
                request: response.request
            )
        case .decoding(_, let error, let response):
            self = .decoding(
                error,
                data: response.data,
                request: response.request
            )
        case .underlying(let error, let response):
            if error.code == NetworkErrorCode.nonHTTPResponse.rawValue {
                self = .invalidResponse(request: response?.request)
            } else {
                self = .transport(error, request: response?.request)
            }
        case .reachability(_, let error, let response):
            self = .transport(error, request: response?.request)
        case .cancelled:
            self = .cancelled(request: nil)
        case .timeout(_, let underlying):
            self = .transport(
                underlying ?? SendableUnderlyingError(
                    domain: "com.innosquad.remote",
                    code: NetworkErrorCode.timeout.rawValue,
                    message: "Request timed out."
                ),
                request: nil
            )
        case .trustEvaluationFailed(let reason):
            self = .transport(
                SendableUnderlyingError(
                    domain: "com.innosquad.remote",
                    code: NetworkErrorCode.trustEvaluationFailed.rawValue,
                    message: String(describing: reason)
                ),
                request: nil
            )
        @unknown default:
            self = .transport(
                SendableUnderlyingError(
                    domain: "com.innosquad.remote",
                    code: -1,
                    message: "Undefined remote failure."
                ),
                request: nil
            )
        }
    }

    var isCancelled: Bool {
        if case .cancelled = self {
            return true
        }
        return false
    }
}

extension RemoteFailure {
    static func == (lhs: RemoteFailure, rhs: RemoteFailure) -> Bool {
        switch (lhs, rhs) {
        case let (.invalidRequestConfiguration(lhsMessage), .invalidRequestConfiguration(rhsMessage)):
            return lhsMessage == rhsMessage
        case let (.invalidStatus(lhsCode, lhsData, lhsRequest), .invalidStatus(rhsCode, rhsData, rhsRequest)):
            return lhsCode == rhsCode
                && lhsData == rhsData
                && requestsEqual(lhsRequest, rhsRequest)
        case let (.decoding(lhsError, lhsData, lhsRequest), .decoding(rhsError, rhsData, rhsRequest)):
            return lhsError == rhsError
                && lhsData == rhsData
                && requestsEqual(lhsRequest, rhsRequest)
        case let (.transport(lhsError, lhsRequest), .transport(rhsError, rhsRequest)):
            return lhsError == rhsError
                && requestsEqual(lhsRequest, rhsRequest)
        case let (.cancelled(lhsRequest), .cancelled(rhsRequest)):
            return requestsEqual(lhsRequest, rhsRequest)
        case let (.invalidResponse(lhsRequest), .invalidResponse(rhsRequest)):
            return requestsEqual(lhsRequest, rhsRequest)
        default:
            return false
        }
    }

    private static func requestsEqual(_ lhs: URLRequest?, _ rhs: URLRequest?) -> Bool {
        lhs?.url == rhs?.url && lhs?.httpMethod == rhs?.httpMethod
    }
}

extension RemoteFailure: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidRequestConfiguration(let message):
            return "Invalid remote request configuration: \(message)"
        case .invalidStatus(let code, _, _):
            return "Unexpected remote status code: \(code)"
        case .decoding(let error, _, _):
            return "Failed to decode remote response: \(error.message)"
        case .transport(let error, _):
            return error.message
        case .cancelled:
            return "Remote request was cancelled"
        case .invalidResponse:
            return "Received a non-HTTP remote response."
        }
    }
}
