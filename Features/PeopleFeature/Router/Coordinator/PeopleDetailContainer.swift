import InnoDI
import PeopleFeatureInterface

@DIContainer(mainActor: true)
public struct PeopleDetailContainer {
    @Input
    public var input: PeopleFeatureInput

    @Input(.assisted)
    public var user: PeopleUser

    @Provide(.shared, factory: {
        (input: PeopleFeatureInput, user: PeopleUser) in
        PeopleDetailSession(input: input, user: user)
    })
    var session: PeopleDetailSession

    @AssistedFactory(
        PeopleDetailContainer.self,
        static: [\PeopleDetailContainer.input],
        assisted: [\PeopleDetailContainer.user]
    )
    public struct AssistedFactory {}
}

@MainActor
public final class PeopleDetailSession {
    let input: PeopleFeatureInput
    let user: PeopleUser

    init(input: PeopleFeatureInput, user: PeopleUser) {
        self.input = input
        self.user = user
    }
}
