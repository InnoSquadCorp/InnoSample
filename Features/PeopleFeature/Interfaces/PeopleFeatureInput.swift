import Domain

public typealias PeopleUser = UserSummary

public struct PeopleFeatureInput: Sendable {
    public let fetchPeopleUseCase: FetchPeopleUseCase

    public init(fetchPeopleUseCase: FetchPeopleUseCase) {
        self.fetchPeopleUseCase = fetchPeopleUseCase
    }
}
