import Foundation
import InnoNetwork

struct RemoteMetadataInterceptor: RequestInterceptor {
    private let environment: RemoteEnvironment

    init(environment: RemoteEnvironment) {
        self.environment = environment
    }

    func adapt(_ urlRequest: URLRequest) async throws -> URLRequest {
        var request = urlRequest

        environment.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if request.value(forHTTPHeaderField: "X-Request-ID") == nil {
            request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        }

        return request
    }
}
