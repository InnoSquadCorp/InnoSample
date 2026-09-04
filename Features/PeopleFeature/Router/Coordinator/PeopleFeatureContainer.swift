@_spi(Experimental) import InnoDI
import PeopleFeatureInterface

@DIContainer(mainActor: true)
public struct PeopleFeatureContainer {
    @Provide(.input)
    public var input: PeopleFeatureInput

    @Provide(.transient, factory: { (input: PeopleFeatureInput) in
        PeopleFeatureCoordinator(
            input: input,
            detailFactory: PeopleDetailFactoryPilot(input: input)
        )
    })
    public var coordinator: PeopleFeatureCoordinator
}
