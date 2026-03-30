import Foundation

public struct UserSummary: Codable, Hashable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let username: String
    public let email: String
    public let phone: String
    public let website: String
    public let company: String
    public let city: String

    public init(
        id: Int,
        name: String,
        username: String,
        email: String,
        phone: String,
        website: String,
        company: String,
        city: String
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.phone = phone
        self.website = website
        self.company = company
        self.city = city
    }
}
