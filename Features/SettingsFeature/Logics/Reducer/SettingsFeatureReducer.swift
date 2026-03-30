import Domain
import Foundation
import InnoFlow
import SettingsFeatureInterface

@InnoFlow
struct SettingsFeatureReducer {
    struct Dependencies: Sendable {
        let loadTodos: @Sendable () async throws -> [TodoSummary]
    }

    struct State: Equatable, Sendable, DefaultInitializable {
        var isLoading = false
        var hasLoaded = false
        var todos: [TodoSummary] = []
        var errorMessage: String?
        var selectedTodo: TodoSummary?
        var pendingDigestRequest: SettingsDigestRequest?
        var pendingPeopleRequest: SettingsPeopleRequest?
        var pendingExternalAssigneeID: Int?
        var activityLog: [String] = []

        init() {}
    }

    enum Action: Equatable, Sendable {
        case onAppear
        case refresh
        case todosLoaded([TodoSummary])
        case todosFailed(String)
        case select(TodoSummary)
        case showDigest
        case openPeople(OpenPeopleRequest)
        case openTodoDetailForAssignee(Int)
        case clearSelection
        case clearDigestRequest
        case clearPeopleRequest
    }

    let dependencies: Dependencies

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoaded else { return .none }
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
                state.pendingPeopleRequest = SettingsPeopleRequest(request: request)
                state.activityLog.append("cross-feature request to people for user #\(request.userID)")
                return .none

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

            case .clearDigestRequest:
                state.pendingDigestRequest = nil
                return .none

            case .clearPeopleRequest:
                state.pendingPeopleRequest = nil
                return .none
            }
        }
    }

    private func loadTodos() -> EffectTask<Action> {
        let loadTodos = dependencies.loadTodos

        return .run { send, _ in
            do {
                let todos = try await loadTodos()
                await send(.todosLoaded(todos))
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                await send(.todosFailed(message))
            }
        }
        .cancellable("settings-feature-load", cancelInFlight: true)
    }
}
