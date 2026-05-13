import Domain
import EntireTabFeatureRouter
import InnoDI
import PeopleFeatureInterface
import PeopleFeatureRouter
import PostsFeatureInterface
import PostsFeatureRouter
import SettingsFeatureInterface
import SettingsFeatureRouter

@MainActor
@DIContainer(mainActor: true)
public struct FeatureContainer {
    // Features only depend on the narrow domain use case surface, not the DomainContainer concrete type.
    @Provide(.input)
    public var useCases: any FeatureUseCaseContaining

    @Provide(.shared, factory: { (useCases: any FeatureUseCaseContaining) in
        PeopleFeatureInput(fetchPeopleUseCase: useCases.fetchPeopleUseCase)
    }, concrete: true)
    var peopleInput: PeopleFeatureInput

    @Provide(.shared, factory: { (useCases: any FeatureUseCaseContaining) in
        PostsFeatureInput(fetchPostsUseCase: useCases.fetchPostsUseCase)
    }, concrete: true)
    var postsInput: PostsFeatureInput

    @Provide(.shared, factory: { (useCases: any FeatureUseCaseContaining) in
        SettingsFeatureInput(fetchTodosUseCase: useCases.fetchTodosUseCase)
    }, concrete: true)
    var settingsInput: SettingsFeatureInput

    @Provide(.shared, factory: { (peopleInput: PeopleFeatureInput) in
        PeopleFeatureContainer(input: peopleInput)
    }, concrete: true)
    var peopleFeatureContainer: PeopleFeatureContainer

    @Provide(.shared, factory: { (postsInput: PostsFeatureInput) in
        PostsFeatureContainer(input: postsInput)
    }, concrete: true)
    var postsFeatureContainer: PostsFeatureContainer

    @Provide(.shared, factory: { (settingsInput: SettingsFeatureInput) in
        SettingsFeatureContainer(input: settingsInput)
    }, concrete: true)
    var settingsFeatureContainer: SettingsFeatureContainer

    @Provide(.shared, factory: { (peopleFeatureContainer: PeopleFeatureContainer) in
        peopleFeatureContainer.coordinator
    }, concrete: true)
    var peopleCoordinator: PeopleFeatureCoordinator

    @Provide(.shared, factory: { (postsFeatureContainer: PostsFeatureContainer) in
        postsFeatureContainer.coordinator
    }, concrete: true)
    var postsCoordinator: PostsFeatureCoordinator

    @Provide(.shared, factory: { (settingsFeatureContainer: SettingsFeatureContainer) in
        settingsFeatureContainer.coordinator
    }, concrete: true)
    var settingsCoordinator: SettingsFeatureCoordinator

    @SubContainer(
        scope: .shared,
        bindings: [
            (child: \EntireTabContainer.peopleCoordinator, parent: \FeatureContainer.peopleCoordinator),
            (child: \EntireTabContainer.postsCoordinator, parent: \FeatureContainer.postsCoordinator),
            (child: \EntireTabContainer.settingsCoordinator, parent: \FeatureContainer.settingsCoordinator),
        ]
    )
    var entireTabContainer: EntireTabContainer

    public var coordinator: EntireTabCoordinator {
        entireTabContainer.coordinator
    }
}
