import Domain
import Foundation

struct PostHighlightsRequest: Equatable, Sendable, Identifiable {
    let id: UUID
    let posts: [PostSummary]

    init(posts: [PostSummary]) {
        self.id = UUID()
        self.posts = posts
    }
}
