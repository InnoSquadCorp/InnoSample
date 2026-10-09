import Domain
import Foundation
import InnoFlow
import PeopleFeatureInterface

@InnoFlow(phaseManaged: true, strictPhaseTotality: true)
struct PeopleFeatureReducer {
    struct Dependencies: Sendable {
        let loadPeople: @Sendable () async throws -> [UserSummary]
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
        var people: IdentifiedArrayOf<UserSummary> = IdentifiedArrayOf<UserSummary>()
        var errorMessage: String?
        var selectedUser: UserSummary?
        var pendingOverviewRequest: PeopleOverviewRequest?
        var pendingExternalUserID: Int?
        var activityLog: [String] = []

        init() {}
    }

    enum Action: Equatable, Sendable {
        case onAppear
        case refresh
        case peopleLoaded([UserSummary])
        case peopleFailed(String)
        case select(UserSummary)
        case showOverview
        case openSettings(OpenSettingsRequest)
        case openUserDetail(Int)
        case clearSelection
        case clearOverviewRequest
    }

    enum Output: Equatable, Sendable {
        case openSettings(OpenSettingsRequest)
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
                On(Action.peopleLoadedCasePath, to: .loaded)
                On(Action.peopleFailedCasePath, to: .failed)
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
                state.activityLog.append("initial people load")
                return loadPeople()

            case .refresh:
                state.isLoading = true
                state.errorMessage = nil
                state.activityLog.append("manual people refresh")
                return loadPeople()

            case .peopleLoaded(let people):
                state.isLoading = false
                state.hasLoaded = true
                state.people = IdentifiedArrayOf(uniqueElements: people)
                state.activityLog.append("loaded \(people.count) people")
                if let pendingExternalUserID = state.pendingExternalUserID,
                   let user = state.people[id: pendingExternalUserID] {
                    state.selectedUser = user
                    state.pendingExternalUserID = nil
                    state.activityLog.append("resolved queued external navigation for user #\(pendingExternalUserID)")
                }
                return .none

            case .peopleFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                state.activityLog.append("people load failed: \(message)")
                return .none

            case .select(let user):
                state.selectedUser = user
                state.activityLog.append("push requested for @\(user.username)")
                return .none

            case .showOverview:
                guard !state.people.isEmpty else { return .none }
                state.pendingOverviewRequest = PeopleOverviewRequest(users: state.people.values)
                state.activityLog.append("overview modal requested")
                return .none

            case .openSettings(let request):
                state.activityLog.append("cross-feature request to settings for user #\(request.assigneeID)")
                return Self.output(.openSettings(request))

            case .openUserDetail(let userID):
                if let user = state.people[id: userID] {
                    state.selectedUser = user
                    state.pendingExternalUserID = nil
                    state.activityLog.append("external navigation applied for user #\(userID)")
                } else {
                    state.pendingExternalUserID = userID
                    state.activityLog.append("queued external navigation for user #\(userID)")
                }
                return .none

            case .clearSelection:
                state.selectedUser = nil
                return .none

            case .clearOverviewRequest:
                state.pendingOverviewRequest = nil
                return .none
            }
        }
    }

    private func loadPeople() -> ReducerEffect<Action, Output> {
        let loadPeople = dependencies.loadPeople

        return .perform(
            operation: { try await loadPeople() },
            success: Action.peopleLoaded,
            failure: { error in
                .peopleFailed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            }
        )
        .cancellable("people-feature-load", cancelInFlight: true)
    }
}
