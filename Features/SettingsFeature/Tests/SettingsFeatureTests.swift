@testable import Domain
import InnoFlowTesting
import InnoRouterTesting
import SettingsFeatureInterface
@testable import SettingsFeatureLogic
@testable import SettingsFeatureRouter
import SettingsFeatureTesting
import Testing

@Suite("Settings feature")
@MainActor
struct SettingsFeatureTests {
    @Test("phase-managed load is deterministic")
    func reducerLoadsTodos() async {
        let todos = SettingsFeatureFixtures.todos
        let store = TestStore(
            reducer: SettingsFeatureReducer(
                dependencies: .init(loadTodos: { todos })
            )
        )

        await store.send(.onAppear, through: SettingsFeatureReducer.phaseMap) {
            $0.phase = .loading
            $0.isLoading = true
            $0.activityLog = ["initial settings load"]
        }
        await store.receive(.todosLoaded(todos), through: SettingsFeatureReducer.phaseMap) {
            $0.phase = .loaded
            $0.isLoading = false
            $0.hasLoaded = true
            $0.todos = todos
            $0.activityLog.append("loaded \(todos.count) todos")
        }
        await store.finish()
    }

    @Test("selection is consumed once at the routing boundary")
    func coordinatorConsumesSelection() {
        let coordinator = makeCoordinator()
        let todo = SettingsFeatureFixtures.todos[0]

        coordinator.select(todo)

        #expect(coordinator.model.consumeSelectedTodo() == todo)
        #expect(coordinator.selectedTodoID == nil)
        #expect(coordinator.model.consumeSelectedTodo() == nil)
    }

    @Test("digest intent derives summary state in the reducer")
    func reducerBuildsDigestRequest() async {
        let todos = SettingsFeatureFixtures.todos
        var initialState = SettingsFeatureReducer.State()
        initialState.phase = .loaded
        initialState.hasLoaded = true
        initialState.todos = todos
        let store = TestStore(
            reducer: SettingsFeatureReducer(
                dependencies: .init(loadTodos: { todos })
            ),
            initialState: initialState
        )

        await store.send(.showDigest) {
            $0.pendingDigestRequest = store.state.pendingDigestRequest
            $0.activityLog.append("digest modal requested")
        }
        #expect(store.state.pendingDigestRequest?.completedCount == todos.filter(\.completed).count)
        #expect(store.state.pendingDigestRequest?.totalCount == todos.count)
        #expect(store.state.activityLog.last == "digest modal requested")
        await store.finish()
    }

    @Test("cross-feature requests are one-shot values")
    func coordinatorEmitsOneShotPeopleRequest() {
        let coordinator = makeCoordinator()
        let request = OpenPeopleRequest(userID: 1)

        coordinator.openPeople(for: request)

        #expect(coordinator.pendingPeopleRequestID != nil)
        #expect(coordinator.consumePeopleRequest() == request)
        #expect(coordinator.consumePeopleRequest() == nil)
    }

    @Test("router flow emits stack and modal events without a host")
    func routerFlowIsDeterministic() {
        let todo = SettingsFeatureFixtures.todos[0]
        let navigation = FlowTestStore<SettingsRoute>()

        navigation.send(.push(.detail(todo)))
        navigation.receiveNavigationChanged { from, to in
            from.path.isEmpty && to.path == [.detail(todo)]
        }
        navigation.receivePathChanged { old, new in
            old.isEmpty && new == [.push(.detail(todo))]
        }
        navigation.finish()

        let completed = SettingsFeatureFixtures.todos.filter(\.completed).count
        let total = SettingsFeatureFixtures.todos.count
        let modal = FlowTestStore<SettingsRoute>()
        modal.send(.presentSheet(.digest(completed: completed, total: total)))
        modal.receiveModalPresented { presentation in
            presentation.route == .digest(completed: completed, total: total)
                && presentation.style == .sheet
        }
        modal.receiveModalCommandIntercepted()
        modal.receivePathChanged { old, new in
            old.isEmpty && new == [.sheet(.digest(completed: completed, total: total))]
        }
        modal.finish()
    }

    private func makeCoordinator() -> SettingsFeatureCoordinator {
        SettingsFeatureCoordinator(
            input: SettingsFeatureInput(
                fetchTodosUseCase: FetchTodosUseCase(repository: StubTodoRepository())
            )
        )
    }
}

private struct StubTodoRepository: TodoRepositoryProtocol {
    func fetchTodos() async throws -> [TodoSummary] {
        SettingsFeatureFixtures.todos
    }
}
