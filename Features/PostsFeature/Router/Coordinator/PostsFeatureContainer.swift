import InnoDI
import PostsFeatureInterface

@MainActor
@DIContainer
public struct PostsFeatureContainer {
    @Provide(.input)
    var input: PostsFeatureInput

    @Provide(.transient, factory: { (input: PostsFeatureInput) in
        PostsFeatureCoordinator(input: input)
    }, concrete: true)
    public var coordinator: PostsFeatureCoordinator
}
