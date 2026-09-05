import InnoDI

@DIContainer
public struct DomainContainer: FeatureUseCaseContaining {
    @Input
    public var dataContainer: any RepositoryContaining

    // Domain composes stateless use cases over shared repositories.
    // This container stays actor-agnostic; main-actor composition happens above this layer.
    // Use cases stay as computed values in per-domain extensions.
}
