import Foundation
import Observation
import SettingsFeatureInterface
import SettingsFeatureLogic

@MainActor
@Observable
public final class SettingsFeatureCoordinator {
    let model: SettingsFeatureModel

    init(input: SettingsFeatureInput) {
        self.model = SettingsFeatureModel(loadTodos: input.fetchTodosUseCase.callAsFunction)
    }

    var selectedTodoID: Int? { model.selectedTodoID }
    var pendingDigestToken: UUID? { model.pendingDigestToken }
    public var pendingPeopleRequestID: UUID? { model.pendingPeopleRequestID }

    func select(_ todo: FeatureTodo) {
        model.select(todo)
    }

    func showDigest() {
        model.showDigest()
    }

    func openPeople(for request: OpenPeopleRequest) {
        model.openPeople(userID: request.userID)
    }

    public func showDetail(assigneeID: Int) {
        model.openTodoDetail(forAssigneeID: assigneeID)
        model.loadIfNeeded()
    }

    public func consumePeopleRequest() -> OpenPeopleRequest? {
        model.consumePeopleRequest()
    }
}
