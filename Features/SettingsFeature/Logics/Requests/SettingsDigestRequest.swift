import Foundation

struct SettingsDigestRequest: Equatable, Sendable, Identifiable {
    let id: UUID
    let completedCount: Int
    let totalCount: Int

    init(completedCount: Int, totalCount: Int) {
        self.id = UUID()
        self.completedCount = completedCount
        self.totalCount = totalCount
    }
}
