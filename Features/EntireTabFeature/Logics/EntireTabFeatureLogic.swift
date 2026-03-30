import EntireTabFeatureInterface
import Observation

@MainActor
@Observable
public final class EntireTabFeatureModel {
    public var selectedTab: SampleTab = .people
    public var tabBadges: [SampleTab: Int] = [
        .posts: 3,
        .settings: 1
    ]

    public init() {}
}
