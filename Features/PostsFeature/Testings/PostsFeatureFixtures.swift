import Domain

public enum PostsFeatureFixtures {
    public static let posts: [PostSummary] = [
        PostSummary(
            id: 1,
            title: "A sample post",
            body: "This is a sample body used for feature tests.",
            authorID: 99
        )
    ]
}
