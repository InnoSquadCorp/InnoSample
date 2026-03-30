import Foundation
import PeopleFeatureInterface

struct PeopleSettingsRequest: Equatable, Sendable, Identifiable {
    let id: UUID
    let request: OpenSettingsRequest

    init(request: OpenSettingsRequest) {
        self.id = UUID()
        self.request = request
    }
}
