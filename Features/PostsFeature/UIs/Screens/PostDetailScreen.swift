import PostsFeatureInterface
import SampleDesignSupport
import SwiftUI

public struct PostDetailScreen: View {
    let post: FeaturePost

    public init(post: FeaturePost) {
        self.post = post
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SampleMetricCard(
                    title: "Author",
                    value: "#\(post.authorID)",
                    subtitle: "post identifier \(post.id)",
                    tint: .orange
                )
                Text(post.title)
                    .font(.largeTitle.weight(.bold))
                Text(post.body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .accessibilityIdentifier("posts-detail")
        .navigationTitle("Post #\(post.id)")
    }
}
