@_spi(Experimental) import InnoDI
import PeopleFeatureInterface

@_InnoDIAssistedFactoryPrototype(assisted: ["user"])
@DIContainer(mainActor: true)
struct PeopleDetailContainer {
    @Provide(.input)
    var input: PeopleFeatureInput

    @Provide(.input)
    var user: PeopleUser

    @Provide(.shared, factory: {
        (input: PeopleFeatureInput, user: PeopleUser) in
        PeopleDetailSession(input: input, user: user)
    })
    var session: PeopleDetailSession
}

@MainActor
final class PeopleDetailSession {
    let input: PeopleFeatureInput
    let user: PeopleUser

    init(input: PeopleFeatureInput, user: PeopleUser) {
        self.input = input
        self.user = user
    }
}

@MainActor
struct PeopleDetailFactoryPilot {
    private let factory: PeopleDetailContainer._InnoDIAssistedFactoryPrototype

    init(input: PeopleFeatureInput) {
        self.factory = .init(input: input)
    }

    func callAsFunction(
        user: PeopleUser,
        replacingSession replacement: PeopleDetailSession? = nil
    ) -> PeopleDetailContainer {
        factory(user: user) { overrides in
            overrides.session = replacement
        }
    }
}
