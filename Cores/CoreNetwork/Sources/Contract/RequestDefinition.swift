import Foundation
import InnoNetwork

public protocol RequestDefinition: Sendable {
    associatedtype ResponseBody: Decodable & Sendable

    var featureName: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var queryItems: [URLQueryItem] { get }
    var body: RequestBody { get }
    var contentType: ContentType { get }
    var headerPolicy: HeaderPolicy { get }
    var additionalHeaders: [String: String] { get }
    var decoder: JSONDecoder { get }
    var responsePolicy: ResponsePolicy { get }
}

public extension RequestDefinition {
    var method: RequestMethod { .get }
    var queryItems: [URLQueryItem] { [] }
    var body: RequestBody { .none }
    var contentType: ContentType { .json }
    var headerPolicy: HeaderPolicy { .appDefault }
    var additionalHeaders: [String: String] { [:] }
    var decoder: JSONDecoder { JSONDecoder() }
    var responsePolicy: ResponsePolicy { .json }
}
