import Domain
import Foundation

struct PeopleOverviewRequest: Equatable, Sendable, Identifiable {
    let id: UUID
    let users: [UserSummary]

    init(users: [UserSummary]) {
        self.id = UUID()
        self.users = users
    }
}
