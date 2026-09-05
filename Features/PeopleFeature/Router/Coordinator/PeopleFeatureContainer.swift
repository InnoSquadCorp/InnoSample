import InnoDI
import PeopleFeatureInterface

@DIContainerRole(role: ContainerRole.local, mainActor: true)
public struct PeopleFeatureContainer {
    @Input
    public var input: PeopleFeatureInput

    @SubContainerFactory(
        PeopleDetailContainer.self,
        bindings: [
            (
                child: \PeopleDetailContainer.input,
                parent: \PeopleFeatureContainer.input
            ),
        ]
    )
    var detailFactory: PeopleDetailContainer.AssistedFactory

    @Provide(.transient, factory: {
        (
            input: PeopleFeatureInput,
            detailFactory: PeopleDetailContainer.AssistedFactory
        ) in
        PeopleFeatureCoordinator(
            input: input,
            detailFactory: detailFactory
        )
    })
    public var coordinator: PeopleFeatureCoordinator
}
