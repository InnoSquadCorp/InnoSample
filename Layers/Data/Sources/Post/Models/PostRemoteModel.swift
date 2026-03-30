public struct PostRemoteModel: Decodable, Sendable {
    public let id: Int
    public let authorID: Int
    public let title: String
    public let body: String

    private enum CodingKeys: String, CodingKey {
        case id
        case authorID = "userId"
        case title
        case body
    }
}
