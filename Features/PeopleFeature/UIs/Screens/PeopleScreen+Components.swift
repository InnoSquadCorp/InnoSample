import PeopleFeatureInterface
import SampleDesignSupport
import SwiftUI

struct PeopleRow: View {
    let user: PeopleUser

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(user.name)
                    .font(.headline)
                Spacer()
                SampleStatusPill(text: user.city, tint: .blue)
            }

            Text("@\(user.username) • \(user.email)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(user.company, systemImage: "building.2")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
