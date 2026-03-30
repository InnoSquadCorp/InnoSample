import PostsFeatureInterface
import PostsFeatureLogic
import SwiftUI

public struct PostsScreen: View {
    let model: PostsFeatureModel
    let onSelect: (FeaturePost) -> Void
    let onShowHighlights: () -> Void

    public init(
        model: PostsFeatureModel,
        onSelect: @escaping (FeaturePost) -> Void,
        onShowHighlights: @escaping () -> Void
    ) {
        self.model = model
        self.onSelect = onSelect
        self.onShowHighlights = onShowHighlights
    }

    var authorCount: Int {
        Set(model.posts.map(\.authorID)).count
    }

    public var body: some View {
        screenContent
    }
}
