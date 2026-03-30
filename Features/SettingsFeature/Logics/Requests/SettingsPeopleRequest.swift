import Foundation
import SettingsFeatureInterface

struct SettingsPeopleRequest: Equatable, Sendable, Identifiable {
    let id: UUID
    let request: OpenPeopleRequest

    init(request: OpenPeopleRequest) {
        self.id = UUID()
        self.request = request
    }
}
