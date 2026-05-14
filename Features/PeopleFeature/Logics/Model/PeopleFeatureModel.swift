import Domain
import InnoFlow
import Observation
import PeopleFeatureInterface
import os

@MainActor
@Observable
public final class PeopleFeatureModel {
    private let store: Store<PeopleFeatureReducer>

    public init(loadPeople: @escaping @Sendable () async throws -> [UserSummary]) {
        self.store = Store(
            reducer: PeopleFeatureReducer(
                dependencies: .init(loadPeople: loadPeople)
            ),
            instrumentation: Self.makeInstrumentation()
        )
    }

    private static func makeInstrumentation() -> StoreInstrumentation<PeopleFeatureReducer.Action> {
        #if DEBUG
        let logger = Logger(subsystem: "com.innosquad.InnoSample", category: "PeopleFeature")
        let signposter = OSSignposter(subsystem: "com.innosquad.InnoSample", category: "PeopleFeature")
        return .combined(
            .osLog(logger: logger, includeActions: true),
            .signpost(signposter: signposter, name: "PeopleFeature.run", includeActions: true)
        )
        #else
        return .disabled
        #endif
    }

    public var people: IdentifiedArrayOf<UserSummary> { store.people }
    public var isLoading: Bool { store.isLoading }
    public var errorMessage: String? { store.errorMessage }
    public var activityLog: [String] { store.activityLog }
    public var selectedUserID: Int? { store.selectedUser?.id }
    public var pendingOverviewToken: UUID? { store.pendingOverviewRequest?.id }
    public var pendingSettingsRequestID: UUID? { store.pendingSettingsRequest?.id }

    public func loadIfNeeded() { store.send(.onAppear) }
    public func refresh() { store.send(.refresh) }
    public func select(_ user: UserSummary) { store.send(.select(user)) }
    public func showOverview() { store.send(.showOverview) }
    public func openSettings(forAssigneeID assigneeID: Int) {
        store.send(.openSettings(.init(assigneeID: assigneeID)))
    }
    public func openUserDetail(userID: Int) {
        store.send(.openUserDetail(userID))
    }

    public func consumeSelectedUser() -> UserSummary? {
        let selectedUser = store.selectedUser
        guard let selectedUser else { return nil }
        store.send(.clearSelection)
        return selectedUser
    }

    public func consumeOverviewUsers() -> [UserSummary]? {
        let users = store.pendingOverviewRequest?.users
        guard let users else { return nil }
        store.send(.clearOverviewRequest)
        return users
    }

    public func consumeSettingsRequest() -> OpenSettingsRequest? {
        let request = store.pendingSettingsRequest?.request
        guard let request else { return nil }
        store.send(.clearSettingsRequest)
        return request
    }
}
