import Foundation
import InnoNetwork

public enum NetworkFailure: Error, Sendable, Equatable {
    case invalidRequestConfiguration(String)
    case invalidStatus(code: Int, data: Data?, request: URLRequest?)
    case decoding(SendableUnderlyingError, data: Data?, request: URLRequest?)
    case transport(SendableUnderlyingError, request: URLRequest?)
    case cancelled(request: URLRequest?)
    case invalidResponse(request: URLRequest?)

    init(networkError: NetworkError) {
        switch networkError {
        case .invalidRequestConfiguration(let message):
            self = .invalidRequestConfiguration(message)
        case .statusCode(let response):
            self = .invalidStatus(
                code: response.statusCode,
                data: response.data,
                request: response.request
            )
        case .objectMapping(let error, let response):
            self = .decoding(
                error,
                data: response.data,
                request: response.request
            )
        case .underlying(let error, let response):
            self = .transport(
                error,
                request: response?.request
            )
        case .nonHTTPResponse:
            self = .invalidResponse(request: nil)
        case .cancelled:
            self = .cancelled(request: nil)
        case .jsonMapping(let response):
            self = .transport(
                SendableUnderlyingError(
                    domain: "com.innosquad.corenetwork",
                    code: response.statusCode,
                    message: "JSON mapping failed."
                ),
                request: response.request
            )
        case .invalidBaseURL(let string):
            self = .transport(
                SendableUnderlyingError(
                    domain: "com.innosquad.corenetwork",
                    code: -1,
                    message: "Invalid base URL: \(string)"
                ),
                request: nil
            )
        case .trustEvaluationFailed(let reason):
            self = .transport(
                SendableUnderlyingError(
                    domain: "com.innosquad.corenetwork",
                    code: -1,
                    message: String(describing: reason)
                ),
                request: nil
            )
        case .undefined:
            self = .transport(
                SendableUnderlyingError(
                    domain: "com.innosquad.corenetwork",
                    code: -1,
                    message: "Undefined network failure."
                ),
                request: nil
            )
        }
    }

    public var isCancelled: Bool {
        if case .cancelled = self {
            return true
        }
        return false
    }
}

extension NetworkFailure {
    public static func == (lhs: NetworkFailure, rhs: NetworkFailure) -> Bool {
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

extension NetworkFailure: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidRequestConfiguration(let message):
            return "Invalid request configuration: \(message)"
        case .invalidStatus(let code, _, _):
            return "Unexpected status code: \(code)"
        case .decoding(let error, _, _):
            return "Failed to decode response: \(error.message)"
        case .transport(let error, _):
            return error.message
        case .cancelled:
            return "Request was cancelled"
        case .invalidResponse:
            return "Received a non-HTTP response."
        }
    }
}
