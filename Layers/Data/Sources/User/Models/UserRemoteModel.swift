public struct UserRemoteModel: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let username: String
    public let email: String
    public let phone: String
    public let website: String
    public let companyName: String
    public let city: String

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address = try container.nestedContainer(keyedBy: AddressKeys.self, forKey: .address)
        let company = try container.nestedContainer(keyedBy: CompanyKeys.self, forKey: .company)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        website = try container.decode(String.self, forKey: .website)
        companyName = try company.decode(String.self, forKey: .name)
        city = try address.decode(String.self, forKey: .city)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case email
        case phone
        case website
        case address
        case company
    }

    private enum AddressKeys: String, CodingKey {
        case city
    }

    private enum CompanyKeys: String, CodingKey {
        case name
    }
}
