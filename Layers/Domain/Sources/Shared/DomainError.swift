import Foundation

public enum DomainError: LocalizedError, Sendable {
    case emptyResponse(String)

    public var errorDescription: String? {
        switch self {
        case .emptyResponse(let resource):
            return "\(resource) 응답이 비어 있습니다."
        }
    }
}
