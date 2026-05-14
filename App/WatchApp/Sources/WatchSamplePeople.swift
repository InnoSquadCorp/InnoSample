import Domain
import Foundation

/// Hard-coded snapshot of People used by the watch companion.
///
/// A production app would replace this with `WatchConnectivity` or a
/// shared SwiftData container (via App Group) so the watch mirrors the
/// iPhone's last-loaded People page. The sample stops at a static
/// fixture because the focus here is platform shape (single-target
/// SwiftUI watchOS app reaching into `Domain`), not transport.
enum WatchSamplePeople {
    static let snapshot: [UserSummary] = [
        UserSummary(
            id: 1,
            name: "Leanne Graham",
            username: "Bret",
            email: "leanne@example.com",
            phone: "010-1111-0001",
            website: "leanne.dev",
            company: "InnoSquad",
            city: "Seoul"
        ),
        UserSummary(
            id: 2,
            name: "Ervin Howell",
            username: "Antonette",
            email: "ervin@example.com",
            phone: "010-1111-0002",
            website: "ervin.dev",
            company: "InnoSquad",
            city: "Busan"
        ),
        UserSummary(
            id: 3,
            name: "Clementine Bauch",
            username: "Samantha",
            email: "clementine@example.com",
            phone: "010-1111-0003",
            website: "clementine.dev",
            company: "InnoSquad",
            city: "Incheon"
        ),
    ]
}
