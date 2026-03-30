public struct TodoRemoteModel: Decodable, Sendable {
    public let id: Int
    public let assigneeID: Int
    public let title: String
    public let completed: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case assigneeID = "userId"
        case title
        case completed
    }
}
