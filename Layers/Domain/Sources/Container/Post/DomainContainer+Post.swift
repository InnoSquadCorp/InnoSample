extension DomainContainer {
    // Use cases stay as stateless concrete values here; the repository is the real cross-layer contract.
    public var fetchPostsUseCase: FetchPostsUseCase {
        FetchPostsUseCase(repository: dataContainer.postRepository)
    }
}
