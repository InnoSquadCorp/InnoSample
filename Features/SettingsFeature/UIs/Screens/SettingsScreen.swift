import SettingsFeatureInterface
import SettingsFeatureLogic
import SwiftUI

public struct SettingsScreen: View {
    let model: SettingsFeatureModel
    let onSelect: (FeatureTodo) -> Void
    let onShowDigest: () -> Void

    public init(
        model: SettingsFeatureModel,
        onSelect: @escaping (FeatureTodo) -> Void,
        onShowDigest: @escaping () -> Void
    ) {
        self.model = model
        self.onSelect = onSelect
        self.onShowDigest = onShowDigest
    }

    var completedCount: Int {
        model.todos.filter(\.completed).count
    }

    public var body: some View {
        screenContent
    }
}
