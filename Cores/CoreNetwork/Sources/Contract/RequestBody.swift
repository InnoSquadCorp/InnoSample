import Foundation

public enum RequestBody: Sendable, Equatable {
    case none
    case json(Data)
    case raw(Data)

    public static func encodeJSON<Value: Encodable & Sendable>(
        _ value: Value,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> Self {
        .json(try encoder.encode(value))
    }
}
