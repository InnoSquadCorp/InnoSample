import InnoDI
import PeopleFeatureRouter
import PostsFeatureRouter
import SettingsFeatureRouter

@MainActor
@DIContainer
public struct EntireTabContainer {
    @Provide(.input)
    public var peopleCoordinator: PeopleFeatureCoordinator

    @Provide(.input)
    public var postsCoordinator: PostsFeatureCoordinator

    @Provide(.input)
    public var settingsCoordinator: SettingsFeatureCoordinator

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
