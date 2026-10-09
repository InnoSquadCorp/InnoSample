@testable import Domain
import InnoFlow
import InnoFlowTesting
import InnoRouter
import InnoRouterTesting
import PeopleFeatureInterface
@testable import PeopleFeatureLogic
@testable import PeopleFeatureRouter
import PeopleFeatureTesting
import Testing

@Suite("People feature", .timeLimit(.minutes(1)))
@MainActor
struct PeopleFeatureTests {
    @Test("phase-managed load is deterministic")
    func reducerLoadsPeople() async {
        let users = PeopleFeatureFixtures.users
        let store = TestStore(
            reducer: PeopleFeatureReducer(
                dependencies: .init(loadPeople: { users })
            )
        )

        await store.send(.onAppear) {
            $0.phase = .loading
            $0.isLoading = true
            $0.activityLog = ["initial people load"]
        }
        await store.receive(.peopleLoaded(users)) {
            $0.phase = .loaded
            $0.isLoading = false
            $0.hasLoaded = true
            $0.people = IdentifiedArrayOf(uniqueElements: users)
            $0.activityLog.append("loaded \(users.count) people")
        }
        await store.finish()
    }

    @Test("selection is consumed once at the routing boundary")
    func coordinatorConsumesSelection() {
        let coordinator = makeCoordinator()
        let user = PeopleFeatureFixtures.users[0]

        coordinator.select(user)

        #expect(coordinator.model.consumeSelectedUser() == user)
        #expect(coordinator.selectedUserID == nil)
        #expect(coordinator.model.consumeSelectedUser() == nil)
    }

    @Test("cross-feature requests are one-shot values")
    func coordinatorEmitsOneShotSettingsRequest() async {
        let coordinator = makeCoordinator()
        let request = OpenSettingsRequest(assigneeID: 1)

        await coordinator.openSettings(for: request)

        #expect(coordinator.pendingSettingsRequestID != nil)
        #expect(coordinator.consumeSettingsRequest() == request)
        #expect(coordinator.consumeSettingsRequest() == nil)
    }

    @Test("router transitions commit stack and sheet state exhaustively")
    func routerFlowIsDeterministic() async {
        let user = PeopleFeatureFixtures.users[0]
        let navigation = RouterTestStore<PeopleRoute>()

        await navigation.send(.push(.detail(user)))
        navigation.receiveStarted()
        navigation.receiveCommitted { $0 == .rootStack(path: [.detail(user)]) && $1 == 1 }
        await navigation.send(.pop(count: 1))
        navigation.receiveStarted()
        navigation.receiveCommitted { $0 == .rootStack && $1 == 2 }
        await navigation.finish()

        let modal = RouterTestStore<PeopleRoute>()
        await modal.send(.present(.init(route: .overview([user]), style: .sheet)))
        modal.receiveStarted()
        modal.receiveCommitted { state, revision in
            guard case .stack(let stack) = state.root else { return false }
            return stack.presentation?.route == .overview([user])
                && stack.presentation?.style == .sheet && revision == 1
        }
        await modal.send(.dismissPresentation)
        modal.receiveStarted()
        modal.receiveCommitted { $0 == .rootStack && $1 == 2 }
        await modal.finish()
    }

    @Test("manual clock advances a sleeping effect without polling")
    func manualClockControlsEffects() async throws {
        let clock = ManualTestClock()
        let store = TestStore(reducer: ClockReducer(), clock: clock)

        await store.send(.start) {
            $0.isWaiting = true
        }
        try await clock.advance(by: .seconds(1), onceSleepersReach: 1)
        await store.receive(.finished) {
            $0.isWaiting = false
            $0.didFinish = true
        }
        await store.finish()
    }

    @Test("cross-feature output is captured and asserted separately from state")
    func typedOutputIsExhaustive() async {
        let request = OpenSettingsRequest(assigneeID: 1)
        let store = TestStore(reducer: PeopleFeatureReducer(dependencies: .init(loadPeople: { [] })))
        await store.send(.openSettings(request)) {
            $0.activityLog.append("cross-feature request to settings for user #1")
        }
        await store.receiveOutput(.openSettings(request))
        await store.finish()
    }

    @Test("appearance after a failed refresh does not restart a completed initial load")
    func appearancePreservesFailedRefreshPhase() async {
        var initial = PeopleFeatureReducer.State()
        initial.phase = .failed
        initial.hasLoaded = true
        initial.errorMessage = "unavailable"
        let store = TestStore(
            reducer: PeopleFeatureReducer(dependencies: .init(loadPeople: { [] })),
            initialState: initial
        )
        await store.send(.onAppear)
        await store.finish()
    }

    @Test("Codable routes round-trip through the released snapshot codec")
    func routeSnapshotRoundTrip() async throws {
        let router = PeopleRoute.makeRouterStore()
        _ = await router.perform(.push(.detail(PeopleFeatureFixtures.users[0])))
        let codec = try RouterSnapshotCodec<PeopleRoute>(currentVersion: 1)
        let data = try await router.snapshot(using: codec)
        let restored = PeopleRoute.makeRouterStore()
        _ = try await restored.restore(from: data, using: codec)
        #expect(restored.state == router.state)
        #expect(restored.revision == 1)
    }

    @Test("a bounded plan rejects oversized state without mutating its source")
    func routeDraftRespectsBudget() throws {
        let original = RouterState<PeopleRoute>.rootStack
        var draft = RouterStateDraft(original)
        draft.root = .stack(path: [.detail(PeopleFeatureFixtures.users[0]), .detail(PeopleFeatureFixtures.users[0])])
        let budget = RouterResourceBudget(snapshot: try .init(maximumRoutes: 1))
        #expect(throws: RouterResourceLimitFailure.self) { try draft.build(resourceBudget: budget) }
        #expect(original == .rootStack)
    }

    private func makeCoordinator() -> PeopleFeatureCoordinator {
        PeopleFeatureCoordinator(
            input: PeopleFeatureInput(
                fetchPeopleUseCase: FetchPeopleUseCase(repository: StubUserRepository())
            )
        )
    }
}

private struct StubUserRepository: UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserSummary] {
        PeopleFeatureFixtures.users
    }
}

@InnoFlow
private struct ClockReducer {
    struct State: Equatable, Sendable, DefaultInitializable {
        var isWaiting = false
        var didFinish = false

        init() {}
    }

    enum Action: Equatable, Sendable {
        case start
        case finished
    }

    var body: some Reducer<State, Action, Never> {
        Reduce { state, action in
            switch action {
            case .start:
                state.isWaiting = true
                return .run { send, context in
                    do { try await context.sleep(for: .seconds(1)) }
                    catch { return }
                    await send(.finished)
                }
            case .finished:
                state.isWaiting = false
                state.didFinish = true
                return .none
            }
        }
    }
}
