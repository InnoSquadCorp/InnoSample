extension DomainContainer {
    // Use cases stay as stateless concrete values here; the repository is the real cross-layer contract.
    public var fetchTodosUseCase: FetchTodosUseCase {
        FetchTodosUseCase(repository: dataContainer.todoRepository)
    }
}
