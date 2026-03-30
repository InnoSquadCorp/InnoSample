import PeopleFeatureInterface
import SampleDesignSupport
import SwiftUI

public struct PeopleOverviewSheet: View {
    let users: [PeopleUser]
    let onClose: () -> Void

    public init(users: [PeopleUser], onClose: @escaping () -> Void) {
        self.users = users
        self.onClose = onClose
    }

    private var mostCommonCity: String {
        Dictionary(grouping: users, by: \.city)
            .max(by: { $0.value.count < $1.value.count })?
            .key ?? "-"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("People Overview")
                .font(.title2.weight(.bold))
                .accessibilityIdentifier("people-overview-title")
            SampleMetricCard(
                title: "Most Active City",
                value: mostCommonCity,
                subtitle: "\(users.count) people synced",
                tint: .blue
            )
            Text("이 탭은 `/users` API를 호출하고, 선택 시 push detail, 요약 버튼으로 modal sheet를 띄웁니다.")
                .foregroundStyle(.secondary)
            Button("Close") {
                onClose()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
#if os(iOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
#endif
#if os(macOS)
        .frame(minWidth: 420)
#endif
    }
}
