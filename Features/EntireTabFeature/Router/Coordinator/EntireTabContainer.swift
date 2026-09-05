import InnoDI
import PeopleFeatureRouter
import PostsFeatureRouter
import SettingsFeatureRouter

@DIContainerRole(role: ContainerRole.component, mainActor: true)
public struct EntireTabContainer {
    @Input
    public var peopleCoordinator: PeopleFeatureCoordinator

    @Input
    public var postsCoordinator: PostsFeatureCoordinator

    @Input
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
