import InnoNetwork

protocol RemoteRequest {
    var featureName: String { get }
}

extension RemoteRequest where Self: APIDefinition {
    var headers: HTTPHeaders {
        var headers = HTTPHeaders.default
        headers[.sampleFeature] = featureName
        return headers
    }

    var logger: NetworkLogger {
        RemoteRequestLogger()
    }
}
