import InnoDI
import PeopleFeatureRouter
import PostsFeatureRouter
import SettingsFeatureRouter

@MainActor
@DIContainer
public struct EntireTabContainer {
    @Provide(.input)
    var peopleCoordinator: PeopleFeatureCoordinator

    @Provide(.input)
    var postsCoordinator: PostsFeatureCoordinator

    @Provide(.input)
    var settingsCoordinator: SettingsFeatureCoordinator

    @Provide(.transient, factory: {
        (
            peopleCoordinator: PeopleFeatureCoordinator,
            postsCoordinator: PostsFeatureCoordinator,
            settingsCoordinator: SettingsFeatureCoordinator
        ) in
        EntireTabCoordinator(
            peopleCoordinator: peopleCoordinator,
            postsCoordinator: postsCoordinator,
            settingsCoordinator: settingsCoordinator
        )
    }, concrete: true)
    public var coordinator: EntireTabCoordinator
}
