import Foundation
import Observation
import PeopleFeatureRouter
import PostsFeatureRouter
import SettingsFeatureRouter

@MainActor
@Observable
public final class EntireTabCoordinator {
    let peopleCoordinator: PeopleFeatureCoordinator
    let postsCoordinator: PostsFeatureCoordinator
    let settingsCoordinator: SettingsFeatureCoordinator

    init(
        peopleCoordinator: PeopleFeatureCoordinator,
        postsCoordinator: PostsFeatureCoordinator,
        settingsCoordinator: SettingsFeatureCoordinator
    ) {
        self.peopleCoordinator = peopleCoordinator
        self.postsCoordinator = postsCoordinator
        self.settingsCoordinator = settingsCoordinator
    }

    func consumeCrossFeatureNavigationFromPeople() -> SampleTab? {
        guard let request = peopleCoordinator.consumeSettingsRequest() else { return nil }
        settingsCoordinator.showDetail(assigneeID: request.assigneeID)
        return .settings
    }

    func consumeCrossFeatureNavigationFromSettings() -> SampleTab? {
        guard let request = settingsCoordinator.consumePeopleRequest() else { return nil }
        peopleCoordinator.showDetail(userID: request.userID)
        return .people
    }

    public func handleDeepLink(_ url: URL) -> SampleTab? {
        guard let link = SampleDeepLink.resolveDeepLink(url) else { return nil }
        return dispatch(link)
    }

    func dispatch(_ link: SampleDeepLink) -> SampleTab {
        switch link {
        case .peopleDetail(let userID):
            peopleCoordinator.showDetail(userID: userID)
            return .people

        case .settingsDetail(let assigneeID):
            settingsCoordinator.showDetail(assigneeID: assigneeID)
            return .settings
        }
    }
}
