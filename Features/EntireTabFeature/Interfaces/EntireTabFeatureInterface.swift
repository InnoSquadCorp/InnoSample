public enum SampleTab: String, Sendable, CaseIterable {
    case people
    case posts
    case settings

    public var icon: String {
        switch self {
        case .people:
            "person.3"
        case .posts:
            "text.bubble"
        case .settings:
            "gearshape"
        }
    }

    public var title: String {
        switch self {
        case .people:
            "People"
        case .posts:
            "Posts"
        case .settings:
            "Settings"
        }
    }
}
