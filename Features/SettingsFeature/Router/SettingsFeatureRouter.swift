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
        syncNavigationFromSelection()
        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.syncDeferredNavigation()
        }
    }

    func syncNavigationFromSelection() {
        guard let selectedTodo = model.consumeSelectedTodo() else { return }
        navigationStore.send(.replaceStack([SettingsRoute.detail(selectedTodo)]))
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

    private func syncDeferredNavigation() async {
        for _ in 0..<50 {
            if selectedTodoID != nil {
                syncNavigationFromSelection()
                return
            }

            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        syncNavigationFromSelection()
    }
}
