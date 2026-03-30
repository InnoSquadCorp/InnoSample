import Domain
import EntireTabFeatureRouter
import PeopleFeatureInterface
import PeopleFeatureRouter
import PostsFeatureInterface
import PostsFeatureRouter
import SettingsFeatureInterface
import SettingsFeatureRouter

@MainActor
public struct FeatureContainer {
    let peopleFeatureContainer: PeopleFeatureContainer
    let postsFeatureContainer: PostsFeatureContainer
    let settingsFeatureContainer: SettingsFeatureContainer
    let entireTabContainer: EntireTabContainer

    public var coordinator: EntireTabCoordinator {
        entireTabContainer.coordinator
    }

    // Features only depend on the narrow domain use case surface, not the DomainContainer concrete type.
    public init(useCases: any FeatureUseCaseContaining) {
        let peopleFeatureContainer = PeopleFeatureContainer(
            input: PeopleFeatureInput(fetchPeopleUseCase: useCases.fetchPeopleUseCase)
        )
        let postsFeatureContainer = PostsFeatureContainer(
            input: PostsFeatureInput(fetchPostsUseCase: useCases.fetchPostsUseCase)
        )
        let settingsFeatureContainer = SettingsFeatureContainer(
            input: SettingsFeatureInput(fetchTodosUseCase: useCases.fetchTodosUseCase)
        )

        self.peopleFeatureContainer = peopleFeatureContainer
        self.postsFeatureContainer = postsFeatureContainer
        self.settingsFeatureContainer = settingsFeatureContainer
        self.entireTabContainer = EntireTabContainer(
            peopleCoordinator: peopleFeatureContainer.coordinator,
            postsCoordinator: postsFeatureContainer.coordinator,
            settingsCoordinator: settingsFeatureContainer.coordinator
        )
    }
}
