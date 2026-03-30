import Domain

public typealias FeatureTodo = TodoSummary

public struct SettingsFeatureInput: Sendable {
    public let fetchTodosUseCase: FetchTodosUseCase

    public init(fetchTodosUseCase: FetchTodosUseCase) {
        self.fetchTodosUseCase = fetchTodosUseCase
    }
}
