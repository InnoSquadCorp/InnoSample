public struct OpenSettingsRequest: Sendable, Equatable {
    public let assigneeID: Int

    public init(assigneeID: Int) {
        self.assigneeID = assigneeID
    }
}
