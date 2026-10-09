@testable import Domain
import InnoFlowTesting
import InnoRouter
import InnoRouterTesting
import SettingsFeatureInterface
@testable import SettingsFeatureLogic
@testable import SettingsFeatureRouter
import SettingsFeatureTesting
import Testing

@Suite("Settings feature", .timeLimit(.minutes(1)))
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

        await store.send(.onAppear) {
            $0.phase = .loading
            $0.isLoading = true
            $0.activityLog = ["initial settings load"]
        }
        await store.receive(.todosLoaded(todos)) {
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
    func coordinatorEmitsOneShotPeopleRequest() async {
        let coordinator = makeCoordinator()
        let request = OpenPeopleRequest(userID: 1)

        await coordinator.openPeople(for: request)

        #expect(coordinator.pendingPeopleRequestID != nil)
        #expect(coordinator.consumePeopleRequest() == request)
        #expect(coordinator.consumePeopleRequest() == nil)
    }

    @Test("router transitions commit stack and sheet state exhaustively")
    func routerFlowIsDeterministic() async {
        let todo = SettingsFeatureFixtures.todos[0]
        let navigation = RouterTestStore<SettingsRoute>()

        await navigation.send(.push(.detail(todo)))
        navigation.receiveStarted()
        navigation.receiveCommitted { $0 == .rootStack(path: [.detail(todo)]) && $1 == 1 }
        await navigation.send(.pop(count: 1))
        navigation.receiveStarted()
        navigation.receiveCommitted { $0 == .rootStack && $1 == 2 }
        await navigation.finish()

        let completed = SettingsFeatureFixtures.todos.filter(\.completed).count
        let total = SettingsFeatureFixtures.todos.count
        let modal = RouterTestStore<SettingsRoute>()
        await modal.send(.present(.init(route: .digest(completed: completed, total: total), style: .sheet)))
        modal.receiveStarted()
        modal.receiveCommitted { state, revision in
            guard case .stack(let stack) = state.root else { return false }
            return stack.presentation?.route == .digest(completed: completed, total: total)
                && stack.presentation?.style == .sheet && revision == 1
        }
        await modal.send(.dismissPresentation)
        modal.receiveStarted()
        modal.receiveCommitted { $0 == .rootStack && $1 == 2 }
        await modal.finish()
    }

    @Test("cross-feature output is captured and asserted separately from state")
    func typedOutputIsExhaustive() async {
        let request = OpenPeopleRequest(userID: 1)
        let store = TestStore(reducer: SettingsFeatureReducer(dependencies: .init(loadTodos: { [] })))
        await store.send(.openPeople(request)) {
            $0.activityLog.append("cross-feature request to people for user #1")
        }
        await store.receiveOutput(.openPeople(request))
        await store.finish()
    }

    @Test("appearance after a failed refresh does not restart a completed initial load")
    func appearancePreservesFailedRefreshPhase() async {
        var initial = SettingsFeatureReducer.State()
        initial.phase = .failed
        initial.hasLoaded = true
        initial.errorMessage = "unavailable"
        let store = TestStore(
            reducer: SettingsFeatureReducer(dependencies: .init(loadTodos: { [] })),
            initialState: initial
        )
        await store.send(.onAppear)
        await store.finish()
    }

    @Test("the generated digest request completes with a typed value")
    func digestReturnsAcknowledgement() async throws {
        let router = SettingsRoute.makeRouterStore()
        let request = SettingsRoute.Presentation.digest(completed: 1, total: 2)
        var events = router.events.makeAsyncIterator()
        let pending = Task { await router.present(request) }
        defer { pending.cancel() }
        while let event = await events.next() {
            if case .committed = event { break }
        }
        try await router.finishPresentation(request, returning: true)
        #expect(await pending.value == .value(true))
        #expect(router.state == .rootStack)
        #expect(router.revision == 2)
    }

    @Test("cancelling the caller retires its typed presentation waiter")
    func digestCallerCancellationIsDistinct() async {
        let router = SettingsRoute.makeRouterStore()
        let request = SettingsRoute.Presentation.digest(completed: 1, total: 2)
        var events = router.events.makeAsyncIterator()
        let pending = Task { await router.present(request) }
        while let event = await events.next() {
            if case .committed = event { break }
        }
        pending.cancel()
        #expect(await pending.value == .cancelled)
        #expect(router.presentationHandle() == nil)
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
