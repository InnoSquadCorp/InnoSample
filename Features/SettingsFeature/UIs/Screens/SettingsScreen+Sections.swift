import SampleDesignSupport
import SwiftUI

extension SettingsScreen {
    @ViewBuilder
    var screenContent: some View {
        Group {
            if model.isLoading && model.todos.isEmpty {
                SampleLoadingStateView(message: "설정 샘플 데이터를 불러오는 중입니다.")
            } else if let errorMessage = model.errorMessage, model.todos.isEmpty {
                SampleErrorStateView(
                    title: "Settings API Error",
                    message: errorMessage,
                    retryTitle: "Retry"
                ) {
                    model.refresh()
                }
            } else {
                contentList
            }
        }
        .navigationTitle("Settings")
        .task {
            model.loadIfNeeded()
        }
        .toolbar {
            Button("Refresh") {
                model.refresh()
            }
            .disabled(model.isLoading)

            Button("Digest") {
                onShowDigest()
            }
            .disabled(model.todos.isEmpty)
        }
    }

    var contentList: some View {
        List {
            healthCheckSection
            preferencesQueueSection
            flowLogSection
        }
        .accessibilityIdentifier("settings-list")
        .overlay(alignment: .bottomTrailing) {
            if model.isLoading {
                ProgressView()
                    .padding(12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding()
            }
        }
    }

    var healthCheckSection: some View {
        Section("Health Check") {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    SampleMetricCard(
                        title: "Completed",
                        value: "\(completedCount)",
                        subtitle: "done toggles",
                        tint: .green
                    )
                    SampleMetricCard(
                        title: "Remaining",
                        value: "\(max(model.todos.count - completedCount, 0))",
                        subtitle: "attention items",
                        tint: .red
                    )
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
        }
    }

    var preferencesQueueSection: some View {
        Section("Preferences Queue") {
            Toggle(
                "Show completed only",
                isOn: Binding(
                    get: { model.showsCompletedOnly },
                    set: { model.setShowsCompletedOnly($0) }
                )
            )
            .accessibilityIdentifier("settings-shows-completed-only")

            ForEach(model.showsCompletedOnly ? model.todos.filter(\.completed) : model.todos) { todo in
                Button {
                    onSelect(todo)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(todo.completed ? .green : .secondary)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(todo.title.capitalized)
                                .font(.headline)
                            Text("Owner #\(todo.assigneeID)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        SampleStatusPill(
                            text: todo.completed ? "Done" : "Pending",
                            tint: todo.completed ? .green : .orange
                        )
                    }
                    .padding(.vertical, 6)
                }
                .accessibilityIdentifier("settings-row-\(todo.id)")
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
