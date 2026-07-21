@testable import Domain
import InnoFlowTesting
import InnoRouterTesting
import PeopleFeatureInterface
@testable import PeopleFeatureLogic
@testable import PeopleFeatureRouter
import PeopleFeatureTesting
import Testing

@Suite("People feature")
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

        await store.send(.onAppear, through: PeopleFeatureReducer.phaseMap) {
            $0.phase = .loading
            $0.isLoading = true
            $0.activityLog = ["initial people load"]
        }
        await store.receive(.peopleLoaded(users), through: PeopleFeatureReducer.phaseMap) {
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
    func coordinatorEmitsOneShotSettingsRequest() {
        let coordinator = makeCoordinator()
        let request = OpenSettingsRequest(assigneeID: 1)

        coordinator.openSettings(for: request)

        #expect(coordinator.pendingSettingsRequestID != nil)
        #expect(coordinator.consumeSettingsRequest() == request)
        #expect(coordinator.consumeSettingsRequest() == nil)
    }

    @Test("router flow emits stack and modal events without a host")
    func routerFlowIsDeterministic() {
        let user = PeopleFeatureFixtures.users[0]
        let navigation = FlowTestStore<PeopleRoute>()

        navigation.send(.push(.detail(user)))
        navigation.receiveNavigationChanged { from, to in
            from.path.isEmpty && to.path == [.detail(user)]
        }
        navigation.receivePathChanged { old, new in
            old.isEmpty && new == [.push(.detail(user))]
        }
        navigation.finish()

        let modal = FlowTestStore<PeopleRoute>()
        modal.send(.presentSheet(.overview([user])))
        modal.receiveModalPresented { presentation in
            presentation.route == .overview([user]) && presentation.style == .sheet
        }
        modal.receiveModalCommandIntercepted()
        modal.receivePathChanged { old, new in
            old.isEmpty && new == [.sheet(.overview([user]))]
        }
        modal.finish()
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

private struct ClockReducer: Reducer {
    struct State: Equatable, Sendable, DefaultInitializable {
        var isWaiting = false
        var didFinish = false

        init() {}
    }

    enum Action: Equatable, Sendable {
        case start
        case finished
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .start:
            state.isWaiting = true
            return .run { send, context in
                do {
                    try await context.sleep(for: .seconds(1))
                } catch {
                    return
                }
                await send(.finished)
            }
        case .finished:
            state.isWaiting = false
            state.didFinish = true
            return .none
        }
    }
}
