import Foundation
import Observation
import PeopleFeatureInterface
import PeopleFeatureLogic

@MainActor
@Observable
public final class PeopleFeatureCoordinator {
    let model: PeopleFeatureModel
    let detailFactory: PeopleDetailFactoryPilot

    init(
        input: PeopleFeatureInput,
        detailFactory: PeopleDetailFactoryPilot
    ) {
        self.model = PeopleFeatureModel(loadPeople: input.fetchPeopleUseCase.callAsFunction)
        self.detailFactory = detailFactory
    }

    var selectedUserID: Int? { model.selectedUserID }
    var pendingOverviewToken: UUID? { model.pendingOverviewToken }
    public var pendingSettingsRequestID: UUID? { model.pendingSettingsRequestID }

    func select(_ user: PeopleUser) {
        model.select(user)
    }

    func showOverview() {
        model.showOverview()
    }

    func openSettings(for request: OpenSettingsRequest) {
        model.openSettings(forAssigneeID: request.assigneeID)
    }

    public func showDetail(userID: Int) {
        model.openUserDetail(userID: userID)
        model.loadIfNeeded()
    }

    public func consumeSettingsRequest() -> OpenSettingsRequest? {
        model.consumeSettingsRequest()
    }
}
