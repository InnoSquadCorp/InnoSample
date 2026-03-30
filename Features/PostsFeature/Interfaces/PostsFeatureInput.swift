import Domain

public typealias FeaturePost = PostSummary

public struct PostsFeatureInput: Sendable {
    public let fetchPostsUseCase: FetchPostsUseCase

    public init(fetchPostsUseCase: FetchPostsUseCase) {
        self.fetchPostsUseCase = fetchPostsUseCase
    }
}
