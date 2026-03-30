import Domain
import Foundation
import InnoFlow
import PeopleFeatureInterface

@InnoFlow
struct PeopleFeatureReducer {
    struct Dependencies: Sendable {
        let loadPeople: @Sendable () async throws -> [UserSummary]
    }

    struct State: Equatable, Sendable, DefaultInitializable {
        var isLoading = false
        var hasLoaded = false
        var people: [UserSummary] = []
        var errorMessage: String?
        var selectedUser: UserSummary?
        var pendingOverviewRequest: PeopleOverviewRequest?
        var pendingSettingsRequest: PeopleSettingsRequest?
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
        case clearSettingsRequest
    }

    let dependencies: Dependencies

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoaded else { return .none }
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
                state.people = people
                state.activityLog.append("loaded \(people.count) people")
                if let pendingExternalUserID = state.pendingExternalUserID,
                   let user = people.first(where: { $0.id == pendingExternalUserID }) {
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
                state.pendingOverviewRequest = PeopleOverviewRequest(users: state.people)
                state.activityLog.append("overview modal requested")
                return .none

            case .openSettings(let request):
                state.pendingSettingsRequest = PeopleSettingsRequest(request: request)
                state.activityLog.append("cross-feature request to settings for user #\(request.assigneeID)")
                return .none

            case .openUserDetail(let userID):
                if let user = state.people.first(where: { $0.id == userID }) {
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

            case .clearSettingsRequest:
                state.pendingSettingsRequest = nil
                return .none
            }
        }
    }

    private func loadPeople() -> EffectTask<Action> {
        let loadPeople = dependencies.loadPeople

        return .run { send, _ in
            do {
                let people = try await loadPeople()
                await send(.peopleLoaded(people))
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                await send(.peopleFailed(message))
            }
        }
        .cancellable("people-feature-load", cancelInFlight: true)
    }
}
