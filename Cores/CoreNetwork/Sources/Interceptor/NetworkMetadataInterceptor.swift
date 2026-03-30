import Foundation
import InnoNetwork

struct NetworkMetadataInterceptor: RequestInterceptor {
    private let environment: NetworkEnvironment

    init(environment: NetworkEnvironment) {
        self.environment = environment
    }

    func adapt(_ urlRequest: URLRequest) async throws -> URLRequest {
        var request = urlRequest
        let policy = HeaderPolicy(
            rawValue: request.value(forHTTPHeaderField: HeaderPolicyMarker.headerName) ?? ""
        ) ?? .appDefault

        request.setValue(nil, forHTTPHeaderField: HeaderPolicyMarker.headerName)

        environment.resolvedHeaders(for: policy).forEach { key, value in
            if request.value(forHTTPHeaderField: key) == nil {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if request.value(forHTTPHeaderField: "X-Request-ID") == nil {
            request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        }

        return request
    }
}
