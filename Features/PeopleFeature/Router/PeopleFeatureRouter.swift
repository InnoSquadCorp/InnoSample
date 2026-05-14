import Foundation
import InnoRouter
import Observation
import PeopleFeatureInterface
import PeopleFeatureLogic

/// PeopleFeature uses `FlowStore<PeopleRoute>` instead of separate
/// `NavigationStore` + `ModalStore` instances. `FlowStore` exposes a
/// unified `path: [RouteStep<PeopleRoute>]` projection plus a single
/// `send(FlowIntent<PeopleRoute>)` dispatch entry, so push (`.detail`) and
/// sheet (`.overview`) intents flow through one call site. Posts and
/// Settings keep the two-store shape on purpose so the sample documents
/// both patterns side by side; see `Docs/ArchitectureReview.md` for the
/// adoption guidance.
@MainActor
@Observable
public final class PeopleFeatureCoordinator {
    let flowStore = FlowStore<PeopleRoute>()
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
        if !syncNavigationFromSelection() {
            awaitDeferredSelection()
        }
    }

    @discardableResult
    func syncNavigationFromSelection() -> Bool {
        guard let selectedUser = model.consumeSelectedUser() else { return false }
        flowStore.send(.replaceStack([.detail(selectedUser)]))
        return true
    }

    func syncModalPresentation() {
        guard let users = model.consumeOverviewUsers() else { return }
        flowStore.send(.presentSheet(.overview(users)))
    }

    public func consumeSettingsRequest() -> OpenSettingsRequest? {
        model.consumeSettingsRequest()
    }

    private var deferredSelectionTask: Task<Void, Never>?

    private func awaitDeferredSelection() {
        deferredSelectionTask?.cancel()
        deferredSelectionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled, self.model.selectedUserID == nil {
                await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                    withObservationTracking {
                        _ = self.model.selectedUserID
                    } onChange: {
                        Task { @MainActor in cont.resume() }
                    }
                }
            }
            if !Task.isCancelled {
                _ = self.syncNavigationFromSelection()
            }
        }
    }
}
