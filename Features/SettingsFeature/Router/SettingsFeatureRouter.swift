import Foundation
import InnoRouter
import Observation
import SettingsFeatureInterface
import SettingsFeatureLogic

@MainActor
@Observable
public final class SettingsFeatureCoordinator {
    let navigationStore = NavigationStore<SettingsRoute>()
    let modalStore = ModalStore<SettingsModalRoute>()
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
        if !syncNavigationFromSelection() {
            awaitDeferredSelection()
        }
    }

    @discardableResult
    func syncNavigationFromSelection() -> Bool {
        guard let selectedTodo = model.consumeSelectedTodo() else { return false }
        navigationStore.send(.replaceStack([SettingsRoute.detail(selectedTodo)]))
        return true
    }

    func syncModalPresentation() {
        guard let request = model.consumeDigestRequest() else { return }
        modalStore.send(
            .present(
                .digest(completed: request.completed, total: request.total),
                style: .sheet
            )
        )
    }

    public func consumePeopleRequest() -> OpenPeopleRequest? {
        model.consumePeopleRequest()
    }

    private var deferredSelectionTask: Task<Void, Never>?

    private func awaitDeferredSelection() {
        deferredSelectionTask?.cancel()
        deferredSelectionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled, self.model.selectedTodoID == nil {
                await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                    withObservationTracking {
                        _ = self.model.selectedTodoID
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
