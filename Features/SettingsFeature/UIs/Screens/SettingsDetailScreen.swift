import SampleDesignSupport
import SettingsFeatureInterface
import SwiftUI

public struct SettingsDetailScreen: View {
    let todo: FeatureTodo
    let onOpenPeople: (OpenPeopleRequest) -> Void

    public init(todo: FeatureTodo, onOpenPeople: @escaping (OpenPeopleRequest) -> Void) {
        self.todo = todo
        self.onOpenPeople = onOpenPeople
    }

    public var body: some View {
        List {
            Section("Item") {
                LabeledContent("Identifier", value: "#\(todo.id)")
                LabeledContent("Owner", value: "#\(todo.assigneeID)")
                LabeledContent("Status", value: todo.completed ? "Completed" : "Pending")
            }

            Section("Title") {
                Text(todo.title.capitalized)
            }

            Section("Signal") {
                SampleMetricCard(
                    title: "Completion",
                    value: todo.completed ? "100%" : "42%",
                    subtitle: todo.completed ? "ready for release" : "needs follow-up",
                    tint: todo.completed ? .green : .orange
                )
            }

            Section("Cross-Feature Demo") {
                Button("Go to People") {
                    onOpenPeople(.init(userID: todo.assigneeID))
                }
                .accessibilityIdentifier("settings-open-people")
            }
        }
        .accessibilityIdentifier("settings-detail")
        .navigationTitle("Todo #\(todo.id)")
    }
}
