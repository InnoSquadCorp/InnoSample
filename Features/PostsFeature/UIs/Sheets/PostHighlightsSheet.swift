import PostsFeatureInterface
import SwiftUI

public struct PostHighlightsSheet: View {
    let posts: [FeaturePost]
    let onClose: () -> Void

    public init(posts: [FeaturePost], onClose: @escaping () -> Void) {
        self.posts = posts
        self.onClose = onClose
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feed Highlights")
                .font(.title2.weight(.bold))
                .accessibilityIdentifier("posts-highlights-title")
            ForEach(Array(posts.prefix(3))) { post in
                VStack(alignment: .leading, spacing: 6) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .padding(12)
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 14))
            }
            Button("Close") {
                onClose()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
#if os(macOS)
        .frame(minWidth: 460)
#endif
    }
}
