import Domain
import SwiftUI

struct WatchHomeView: View {
    private let people: [UserSummary] = WatchSamplePeople.snapshot

    var body: some View {
        NavigationStack {
            List(people) { user in
                NavigationLink(value: user) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name)
                            .font(.headline)
                        Text("@\(user.username)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("People")
            .navigationDestination(for: UserSummary.self) { user in
                WatchPersonDetailView(user: user)
            }
        }
    }
}

private struct WatchPersonDetailView: View {
    let user: UserSummary

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Name", value: user.name)
                LabeledContent("Username", value: "@\(user.username)")
            }
            Section("Reach") {
                LabeledContent("Company", value: user.company)
                LabeledContent("City", value: user.city)
            }
        }
        .navigationTitle(user.name)
    }
}
