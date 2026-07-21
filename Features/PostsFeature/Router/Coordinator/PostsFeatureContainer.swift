import InnoDI
import PostsFeatureInterface

@DIContainer(mainActor: true)
public struct PostsFeatureContainer {
    @Provide(.input)
    public var input: PostsFeatureInput

    @Provide(.transient, PostsFeatureCoordinator.self, with: [\Self.input])
    public var coordinator: PostsFeatureCoordinator
}
