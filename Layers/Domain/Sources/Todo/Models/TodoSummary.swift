import Foundation

public struct TodoSummary: Codable, Hashable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let completed: Bool
    public let assigneeID: Int

    public init(
        id: Int,
        title: String,
        completed: Bool,
        assigneeID: Int
    ) {
        self.id = id
        self.title = title
        self.completed = completed
        self.assigneeID = assigneeID
    }
}
