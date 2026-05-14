import EntireTabFeatureInterface
import EntireTabFeatureLogic
import InnoRouter
import Observation
import PeopleFeatureRouter
import PostsFeatureRouter
import SettingsFeatureRouter
import SwiftUI

@MainActor
@Observable
public final class EntireTabCoordinator: TabCoordinator {
    public typealias TabType = SampleTab
    public typealias TabContent = AnyView

    let model: EntireTabFeatureModel
    let peopleCoordinator: PeopleFeatureCoordinator
    let postsCoordinator: PostsFeatureCoordinator
    let settingsCoordinator: SettingsFeatureCoordinator

    init(
        peopleCoordinator: PeopleFeatureCoordinator,
        postsCoordinator: PostsFeatureCoordinator,
        settingsCoordinator: SettingsFeatureCoordinator
    ) {
        self.model = EntireTabFeatureModel()
        self.peopleCoordinator = peopleCoordinator
        self.postsCoordinator = postsCoordinator
        self.settingsCoordinator = settingsCoordinator
    }

    public var selectedTab: SampleTab {
        get { model.selectedTab }
        set { model.selectedTab = newValue }
    }

    public var tabBadges: [SampleTab: Int] {
        get { model.tabBadges }
        set { model.tabBadges = newValue }
    }

    func syncCrossFeatureNavigationFromPeople() {
        guard let request = peopleCoordinator.consumeSettingsRequest() else { return }
        selectedTab = .settings
        settingsCoordinator.showDetail(assigneeID: request.assigneeID)
    }

    func syncCrossFeatureNavigationFromSettings() {
        guard let request = settingsCoordinator.consumePeopleRequest() else { return }
        selectedTab = .people
        peopleCoordinator.showDetail(userID: request.userID)
    }

    @discardableResult
    public func handleDeepLink(_ url: URL) -> Bool {
        guard url.scheme == SampleDeepLinkMatcherFactory.allowedScheme else { return false }
        guard let link = SampleDeepLinkMatcherFactory.make().match(url) else { return false }
        dispatch(link)
        return true
    }

    func dispatch(_ link: SampleDeepLink) {
        switch link {
        case .peopleDetail(let userID):
            selectedTab = .people
            peopleCoordinator.showDetail(userID: userID)

        case .settingsDetail(let assigneeID):
            selectedTab = .settings
            settingsCoordinator.showDetail(assigneeID: assigneeID)
        }
    }

    public func content(for tab: SampleTab) -> AnyView {
        switch tab {
        case .people:
            return AnyView(PeopleFeatureRouteHost(coordinator: peopleCoordinator))
        case .posts:
            return AnyView(PostsFeatureRouteHost(coordinator: postsCoordinator))
        case .settings:
            return AnyView(SettingsFeatureRouteHost(coordinator: settingsCoordinator))
        }
    }
}
