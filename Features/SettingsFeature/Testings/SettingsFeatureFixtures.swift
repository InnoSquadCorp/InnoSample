import Domain

public enum SettingsFeatureFixtures {
    public static let todos: [TodoSummary] = [
        TodoSummary(
            id: 1,
            title: "follow up with QA",
            completed: false,
            assigneeID: 1
        )
    ]
}
