import PeopleFeatureInterface
import SampleDesignSupport
import SwiftUI

public struct PeopleDetailScreen: View {
    let user: PeopleUser
    let onOpenSettings: (OpenSettingsRequest) -> Void

    public init(user: PeopleUser, onOpenSettings: @escaping (OpenSettingsRequest) -> Void) {
        self.user = user
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Name", value: user.name)
                LabeledContent("Username", value: "@\(user.username)")
                LabeledContent("Email", value: user.email)
            }

            Section("Reach") {
                LabeledContent("Phone", value: user.phone)
                LabeledContent("Website", value: user.website)
                LabeledContent("Company", value: user.company)
                LabeledContent("City", value: user.city)
            }

            Section("Quick Facts") {
                SampleMetricCard(
                    title: "Handle",
                    value: "@\(user.username)",
                    subtitle: user.company,
                    tint: .indigo
                )
            }

            Section("Cross-Feature Demo") {
                Button("Go to Settings") {
                    onOpenSettings(.init(assigneeID: user.id))
                }
                .accessibilityIdentifier("people-open-settings")
            }
        }
        .accessibilityIdentifier("people-detail")
        .navigationTitle(user.name)
    }
}
