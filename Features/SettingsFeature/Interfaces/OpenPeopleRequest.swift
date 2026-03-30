public struct OpenPeopleRequest: Sendable, Equatable {
    public let userID: Int

    public init(userID: Int) {
        self.userID = userID
    }
}
