import InnoDI
import PeopleFeatureRouter
import PostsFeatureRouter
import SettingsFeatureRouter

@DIComponent
@DIContainer(mainActor: true)
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
    })
    public var coordinator: EntireTabCoordinator
}
