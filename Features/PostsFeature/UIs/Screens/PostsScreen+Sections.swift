import PostsFeatureInterface
import SampleDesignSupport
import SwiftUI

extension PostsScreen {
    @ViewBuilder
    var screenContent: some View {
        Group {
            if model.isLoading && model.posts.isEmpty {
                SampleLoadingStateView(message: "포스트를 불러오는 중입니다.")
            } else if let errorMessage = model.errorMessage, model.posts.isEmpty {
                SampleErrorStateView(
                    title: "Posts API Error",
                    message: errorMessage,
                    retryTitle: "Retry"
                ) {
                    model.refresh()
                }
            } else {
                contentList
            }
        }
        .navigationTitle("Posts")
        .task {
            model.loadIfNeeded()
        }
        .toolbar {
            Button("Refresh") {
                model.refresh()
            }
            .disabled(model.isLoading)

            Button("Highlights") {
                onShowHighlights()
            }
            .disabled(model.posts.isEmpty)
        }
    }

    var contentList: some View {
        List {
            feedPulseSection
            storiesSection
            flowLogSection
        }
        .accessibilityIdentifier("posts-list")
        .overlay(alignment: .bottomTrailing) {
            if model.isLoading {
                ProgressView()
                    .padding(12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding()
            }
        }
    }

    var feedPulseSection: some View {
        Section("Feed Pulse") {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    SampleMetricCard(
                        title: "Posts",
                        value: "\(model.posts.count)",
                        subtitle: "fetched from /posts",
                        tint: .orange
                    )
                    SampleMetricCard(
                        title: "Authors",
                        value: "\(authorCount)",
                        subtitle: "active contributors",
                        tint: .pink
                    )
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
        }
    }

    var storiesSection: some View {
        Section("Stories") {
            ForEach(model.posts) { post in
                Button {
                    onSelect(post)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.title)
                            .font(.headline)
                        Text(post.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text("Author #\(post.authorID)")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 6)
                }
                .accessibilityIdentifier("posts-row-\(post.id)")
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    var flowLogSection: some View {
        if !model.activityLog.isEmpty {
            Section("Flow Log") {
                ForEach(Array(model.activityLog.enumerated()), id: \.offset) { _, entry in
                    Text(entry)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
