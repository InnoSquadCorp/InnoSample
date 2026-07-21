import InnoDI
import PeopleFeatureInterface

@DIContainer(mainActor: true)
public struct PeopleFeatureContainer {
    @Provide(.input)
    public var input: PeopleFeatureInput

    @Provide(.transient, PeopleFeatureCoordinator.self, with: [\Self.input])
    public var coordinator: PeopleFeatureCoordinator
}
