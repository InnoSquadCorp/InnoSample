import Foundation
import InnoRouter
import Observation
import PeopleFeatureInterface
import PeopleFeatureLogic

@MainActor
@Observable
public final class PeopleFeatureCoordinator {
    let navigationStore = NavigationStore<PeopleRoute>()
    let modalStore = ModalStore<PeopleModalRoute>()
    let model: PeopleFeatureModel

    init(input: PeopleFeatureInput) {
        self.model = PeopleFeatureModel(loadPeople: input.fetchPeopleUseCase.callAsFunction)
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
        syncNavigationFromSelection()
        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.syncDeferredNavigation()
        }
    }

    func syncNavigationFromSelection() {
        guard let selectedUser = model.consumeSelectedUser() else { return }
        navigationStore.send(.resetTo([.detail(selectedUser)]))
    }

    func syncModalPresentation() {
        guard let users = model.consumeOverviewUsers() else { return }
        modalStore.send(.present(.overview(users), style: .sheet))
    }

    public func consumeSettingsRequest() -> OpenSettingsRequest? {
        model.consumeSettingsRequest()
    }

    private func syncDeferredNavigation() async {
        for _ in 0..<50 {
            if selectedUserID != nil {
                syncNavigationFromSelection()
                return
            }

            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        syncNavigationFromSelection()
    }
}
