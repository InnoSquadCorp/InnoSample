import PeopleFeatureInterface
import SampleDesignSupport
import SwiftUI

extension PeopleScreen {
    @ViewBuilder
    var screenContent: some View {
        Group {
            if model.isLoading && model.people.isEmpty {
                SampleLoadingStateView(message: "사람 목록을 불러오는 중입니다.")
            } else if let errorMessage = model.errorMessage, model.people.isEmpty {
                SampleErrorStateView(
                    title: "People API Error",
                    message: errorMessage,
                    retryTitle: "Retry"
                ) {
                    model.refresh()
                }
            } else {
                contentList
            }
        }
        .navigationTitle("People")
        .task {
            model.loadIfNeeded()
        }
        .toolbar {
            Button("Refresh") {
                model.refresh()
            }
            .disabled(model.isLoading)

            Button("Overview") {
                onShowOverview()
            }
            .disabled(model.people.isEmpty)
        }
    }

    var contentList: some View {
        List {
            snapshotSection
            directorySection
            flowLogSection
        }
        .accessibilityIdentifier("people-list")
        .overlay(alignment: .bottomTrailing) {
            if model.isLoading {
                ProgressView()
                    .padding(12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding()
            }
        }
    }

    var snapshotSection: some View {
        Section("Snapshot") {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    SampleMetricCard(
                        title: "People",
                        value: "\(model.people.count)",
                        subtitle: "JSONPlaceholder users",
                        tint: .blue
                    )
                    SampleMetricCard(
                        title: "Cities",
                        value: "\(uniqueCities)",
                        subtitle: "covered regions",
                        tint: .mint
                    )
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
        }
    }

    var directorySection: some View {
        Section("Directory") {
            ForEach(model.people) { user in
                Button {
                    onSelect(user)
                } label: {
                    PeopleRow(user: user)
                }
                .accessibilityIdentifier("people-row-\(user.id)")
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
