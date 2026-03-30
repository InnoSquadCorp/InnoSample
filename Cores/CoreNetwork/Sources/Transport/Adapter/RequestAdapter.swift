import Foundation
import InnoNetwork

struct RequestAdapter<Request: RequestDefinition>: NetworkAPI {
    typealias APIResponse = Request.ResponseBody

    let request: Request
    let apiDefaults: APIDefaults

    var method: HTTPMethod {
        request.method.httpMethod
    }

    var path: String {
        request.path
    }

    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(.contentType("\(request.contentType.rawValue); charset=UTF-8"))
        headers.add(name: HeaderPolicyMarker.headerName, value: request.headerPolicy.rawValue)
        headers.add(name: "X-Sample-Feature", value: request.featureName)
        request.additionalHeaders.forEach { key, value in
            headers.add(name: key, value: value)
        }
        return headers
    }

    func makePayload() throws -> RequestPayload {
        guard request.queryItems.isEmpty || request.body == .none else {
            throw NetworkError.invalidRequestConfiguration(
                "A request cannot declare both queryItems and body at the same time."
            )
        }

        if !request.queryItems.isEmpty {
            return .queryItems(request.queryItems)
        }

        switch request.body {
        case .none:
            return .none
        case .json(let data), .raw(let data):
            return .data(data)
        }
    }

    func decode(data: Data, response: Response) throws -> Request.ResponseBody {
        if Request.ResponseBody.self == Data.self, let raw = data as? Request.ResponseBody {
            return raw
        }

        let responseData: Data
        switch request.responsePolicy {
        case .json:
            responseData = data
        case .jsonAllowingEmptyBody(let fallback):
            responseData = data.isEmpty ? fallback : data
        }

        do {
            return try request.decoder.decode(Request.ResponseBody.self, from: responseData)
        } catch {
            throw NetworkError.objectMapping(SendableUnderlyingError(error), response)
        }
    }
}
