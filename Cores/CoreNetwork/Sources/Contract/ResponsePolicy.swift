import Foundation

public enum ResponsePolicy: Sendable, Equatable {
    case json
    case jsonAllowingEmptyBody(fallback: Data = Data("{}".utf8))
}
