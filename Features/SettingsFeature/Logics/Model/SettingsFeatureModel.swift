import Domain
import InnoFlow
import Observation
import SettingsFeatureInterface

@MainActor
@Observable
public final class SettingsFeatureModel {
    private let store: Store<SettingsFeatureReducer>

    public init(loadTodos: @escaping @Sendable () async throws -> [TodoSummary]) {
        self.store = Store(
            reducer: SettingsFeatureReducer(
                dependencies: .init(loadTodos: loadTodos)
            )
        )
    }

    public var todos: [TodoSummary] { store.todos }
    public var isLoading: Bool { store.isLoading }
    public var errorMessage: String? { store.errorMessage }
    public var activityLog: [String] { store.activityLog }
    public var selectedTodoID: Int? { store.selectedTodo?.id }
    public var pendingDigestToken: UUID? { store.pendingDigestRequest?.id }
    private var pendingPeopleRequest: SettingsPeopleRequest?
    public var pendingPeopleRequestID: UUID? { pendingPeopleRequest?.id }
    public var showsCompletedOnly: Bool {
        get { store.showsCompletedOnly }
        set { setShowsCompletedOnly(newValue) }
    }

    public func loadIfNeeded() { store.send(.onAppear) }
    public func setShowsCompletedOnly(_ value: Bool) {
        store.send(.setShowsCompletedOnly(value))
    }
    public func refresh() { store.send(.refresh) }
    public func select(_ todo: TodoSummary) { store.send(.select(todo)) }
    public func showDigest() { store.send(.showDigest) }
    public func acknowledgeDigest() { store.send(.acknowledgeDigest) }
    public func openPeople(userID: Int) async {
        let dispatch = store.send(.openPeople(.init(userID: userID)), capturingOutputs: .bufferingNewest(1))
        for await output in dispatch.outputs {
            switch output {
            case .openPeople(let request):
                pendingPeopleRequest = SettingsPeopleRequest(request: request)
            }
        }
        await dispatch.finish()
    }
    public func openTodoDetail(forAssigneeID assigneeID: Int) {
        store.send(.openTodoDetailForAssignee(assigneeID))
    }

    public func consumeSelectedTodo() -> TodoSummary? {
        let selectedTodo = store.selectedTodo
        guard let selectedTodo else { return nil }
        store.send(.clearSelection)
        return selectedTodo
    }

    public func consumeDigestRequest() -> (completed: Int, total: Int)? {
        let request = store.pendingDigestRequest
        guard let request else { return nil }
        store.send(.clearDigestRequest)
        return (request.completedCount, request.totalCount)
    }

    public func consumePeopleRequest() -> OpenPeopleRequest? {
        let request = pendingPeopleRequest?.request
        guard let request else { return nil }
        pendingPeopleRequest = nil
        return request
    }
}
