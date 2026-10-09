import Domain
import Foundation
import InnoFlow
import SettingsFeatureInterface

@InnoFlow(phaseManaged: true, strictPhaseTotality: true)
struct SettingsFeatureReducer {
    struct Dependencies: Sendable {
        let loadTodos: @Sendable () async throws -> [TodoSummary]
    }

    struct State: Equatable, Sendable, DefaultInitializable {
        enum Phase: Hashable, Sendable {
            case idle
            case loading
            case loaded
            case failed
        }

        var phase: Phase = .idle
        var isLoading = false
        var hasLoaded = false
        var todos: [TodoSummary] = []
        var errorMessage: String?
        var selectedTodo: TodoSummary?
        var pendingDigestRequest: SettingsDigestRequest?
        var pendingExternalAssigneeID: Int?
        var activityLog: [String] = []
        @BindableField var showsCompletedOnly = false

        init() {}
    }

    enum Action: Equatable, Sendable {
        case onAppear
        case refresh
        case todosLoaded([TodoSummary])
        case todosFailed(String)
        case select(TodoSummary)
        case showDigest
        case acknowledgeDigest
        case openPeople(OpenPeopleRequest)
        case openTodoDetailForAssignee(Int)
        case clearSelection
        case clearDigestRequest
        case setShowsCompletedOnly(Bool)
    }

    enum Output: Equatable, Sendable {
        case openPeople(OpenPeopleRequest)
    }

    let dependencies: Dependencies

    static var phaseMap: PhaseMap<State, Action, State.Phase> {
        PhaseMap(\State.phase) {
            From(.idle) {
                On(.onAppear, targets: [.loading]) { state in
                    state.isLoading ? .loading : nil
                }
                On(.refresh, to: .loading)
            }
            From(.loading) {
                On(Action.todosLoadedCasePath, to: .loaded)
                On(Action.todosFailedCasePath, to: .failed)
            }
            From(.loaded) {
                On(.refresh, to: .loading)
            }
            From(.failed) {
                On(.onAppear, targets: [.loading]) { state in
                    state.isLoading ? .loading : nil
                }
                On(.refresh, to: .loading)
            }
        }
    }

    static var phaseGraph: PhaseTransitionGraph<State.Phase> {
        phaseMap.derivedGraph
    }

    var body: some Reducer<State, Action, Output> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoaded && !state.isLoading else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                state.activityLog.append("initial settings load")
                return loadTodos()

            case .refresh:
                state.isLoading = true
                state.errorMessage = nil
                state.activityLog.append("manual settings refresh")
                return loadTodos()

            case .todosLoaded(let todos):
                state.isLoading = false
                state.hasLoaded = true
                state.todos = todos
                state.activityLog.append("loaded \(todos.count) todos")
                if let pendingExternalAssigneeID = state.pendingExternalAssigneeID,
                   let todo = todos.first(where: { $0.assigneeID == pendingExternalAssigneeID }) {
                    state.selectedTodo = todo
                    state.pendingExternalAssigneeID = nil
                    state.activityLog.append("resolved queued external navigation for assignee #\(pendingExternalAssigneeID)")
                }
                return .none

            case .todosFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                state.activityLog.append("settings load failed: \(message)")
                return .none

            case .select(let todo):
                state.selectedTodo = todo
                state.activityLog.append("push requested for todo #\(todo.id)")
                return .none

            case .showDigest:
                guard !state.todos.isEmpty else { return .none }
                state.pendingDigestRequest = SettingsDigestRequest(
                    completedCount: state.todos.filter(\.completed).count,
                    totalCount: state.todos.count
                )
                state.activityLog.append("digest modal requested")
                return .none

            case .openPeople(let request):
                state.activityLog.append("cross-feature request to people for user #\(request.userID)")
                return Self.output(.openPeople(request))

            case .openTodoDetailForAssignee(let assigneeID):
                if let todo = state.todos.first(where: { $0.assigneeID == assigneeID }) {
                    state.selectedTodo = todo
                    state.pendingExternalAssigneeID = nil
                    state.activityLog.append("external navigation applied for assignee #\(assigneeID)")
                } else {
                    state.pendingExternalAssigneeID = assigneeID
                    state.activityLog.append("queued external navigation for assignee #\(assigneeID)")
                }
                return .none

            case .clearSelection:
                state.selectedTodo = nil
                return .none

            case .acknowledgeDigest:
                state.activityLog.append("digest acknowledged")
                return .none

            case .clearDigestRequest:
                state.pendingDigestRequest = nil
                return .none

            case .setShowsCompletedOnly(let value):
                state.showsCompletedOnly = value
                state.activityLog.append("completed filter set to \(value)")
                return .none
            }
        }
    }

    private func loadTodos() -> ReducerEffect<Action, Output> {
        let loadTodos = dependencies.loadTodos

        return .perform(
            operation: { try await loadTodos() },
            success: Action.todosLoaded,
            failure: { error in
                .todosFailed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            }
        )
        .cancellable("settings-feature-load", cancelInFlight: true)
    }
}
