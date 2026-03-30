import Domain

@MainActor
public extension FeatureContainer {
    static func make(useCases: any FeatureUseCaseContaining) -> FeatureContainer {
        FeatureContainer(useCases: useCases)
    }
}
