import PeopleFeatureInterface
import PeopleFeatureLogic
import SwiftUI

public struct PeopleScreen: View {
    let model: PeopleFeatureModel
    let onSelect: (PeopleUser) -> Void
    let onShowOverview: () -> Void

    public init(
        model: PeopleFeatureModel,
        onSelect: @escaping (PeopleUser) -> Void,
        onShowOverview: @escaping () -> Void
    ) {
        self.model = model
        self.onSelect = onSelect
        self.onShowOverview = onShowOverview
    }

    var uniqueCities: Int {
        Set(model.people.map(\.city)).count
    }

    public var body: some View {
        screenContent
    }
}
