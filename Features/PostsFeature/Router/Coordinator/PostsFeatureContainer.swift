import InnoDI
import PostsFeatureInterface

@DIContainerRole(role: ContainerRole.local, mainActor: true)
public struct PostsFeatureContainer {
    @Input
    public var input: PostsFeatureInput

    @Provide(.transient, PostsFeatureCoordinator.self, with: [\Self.input])
    public var coordinator: PostsFeatureCoordinator
}
