public protocol FeatureUseCaseContaining {
    var fetchPeopleUseCase: FetchPeopleUseCase { get }
    var fetchPostsUseCase: FetchPostsUseCase { get }
    var fetchTodosUseCase: FetchTodosUseCase { get }
}
