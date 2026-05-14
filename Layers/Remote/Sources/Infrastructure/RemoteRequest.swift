import InnoNetwork

protocol RemoteRequest: APIDefinition {
    var featureName: String { get }
}

extension RemoteRequest {
    var method: HTTPMethod { .get }

    var headers: HTTPHeaders {
        var headers = HTTPHeaders.default
        headers[.sampleFeature] = featureName
        return headers
    }

    var logger: NetworkLogger {
        RemoteRequestLogger()
    }
}
