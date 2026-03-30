import Foundation

public struct PostSummary: Codable, Hashable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let body: String
    public let authorID: Int

    public init(
        id: Int,
        title: String,
        body: String,
        authorID: Int
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.authorID = authorID
    }
}
