import InnoDI
import PeopleFeatureInterface

@MainActor
@DIContainer
public struct PeopleFeatureContainer {
    @Provide(.input)
    public var input: PeopleFeatureInput

    @Provide(.transient, factory: { (input: PeopleFeatureInput) in
        PeopleFeatureCoordinator(input: input)
    }, concrete: true)
    public var coordinator: PeopleFeatureCoordinator
}
