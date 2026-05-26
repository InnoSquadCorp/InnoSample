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

        return request
    }
}
