import SampleDesignSupport
import SwiftUI

public struct SettingsDigestSheet: View {
    let completed: Int
    let total: Int
    let onClose: () -> Void

    public init(completed: Int, total: Int, onClose: @escaping () -> Void) {
        self.completed = completed
        self.total = total
        self.onClose = onClose
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings Digest")
                .font(.title2.weight(.bold))
                .accessibilityIdentifier("settings-digest-title")
            SampleMetricCard(
                title: "Coverage",
                value: "\(completed)/\(total)",
                subtitle: "tasks completed",
                tint: .green
            )
            Text("이 탭은 `/todos` API를 불러오고, 각 row는 push detail, Digest 버튼은 modal sheet를 띄웁니다.")
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
