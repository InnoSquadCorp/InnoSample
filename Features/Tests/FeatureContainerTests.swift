@testable import Domain
@testable import EntireTabFeatureRouter
import Features
@testable import PeopleFeatureRouter
@testable import PostsFeatureRouter
@testable import SettingsFeatureRouter
import Testing

@Suite("Feature container")
@MainActor
struct FeatureContainerTests {
    @Test("DIComponent exposes its generated dependency contract")
    func generatedComponentDependenciesConstructTheContainer() {
        let dependencies = StubFeatureContainerDependencies(
            useCases: StubFeatureUseCases(
                users: Self.users,
                posts: Self.posts,
                todos: Self.todos
            )
        )

        let container = FeatureContainer(dependencies: dependencies)

        #expect(type(of: container.coordinator) == EntireTabCoordinator.self)
    }

    @Test("root composition queues typed people navigation")
    func rootCompositionCreatesPeopleCoordinator() {
        let coordinator = makeContainer().coordinator

        coordinator.peopleCoordinator.showDetail(userID: 1)

        #expect(
            coordinator.peopleCoordinator.model.activityLog.contains(
                "queued external navigation for user #1"
            )
        )
    }

    @Test("root composition creates the posts coordinator")
    func rootCompositionCreatesPostsCoordinator() {
        let coordinator = makeContainer().coordinator

        #expect(coordinator.postsCoordinator.model.posts.isEmpty)
    }

    @Test("root composition mediates people to settings with a typed tab")
    func mediatesPeopleToSettingsNavigation() {
        let coordinator = makeContainer().coordinator

        coordinator.peopleCoordinator.openSettings(for: .init(assigneeID: 1))

        #expect(coordinator.consumeCrossFeatureNavigationFromPeople() == .settings)
        #expect(
            coordinator.settingsCoordinator.model.activityLog.contains(
                "queued external navigation for assignee #1"
            )
        )
    }

    @Test("root composition mediates settings to people with a typed tab")
    func mediatesSettingsToPeopleNavigation() {
        let coordinator = makeContainer().coordinator

        coordinator.settingsCoordinator.openPeople(for: .init(userID: 1))

        #expect(coordinator.consumeCrossFeatureNavigationFromSettings() == .people)
        #expect(
            coordinator.peopleCoordinator.model.activityLog.contains(
                "queued external navigation for user #1"
            )
        )
    }

    private func makeContainer() -> FeatureContainer {
        FeatureContainer(
            useCases: StubFeatureUseCases(
                users: Self.users,
                posts: Self.posts,
                todos: Self.todos
            )
        )
    }

    private static let users: [UserSummary] = [
        .init(
            id: 1,
            name: "Leanne Graham",
            username: "Bret",
            email: "leanne@example.com",
            phone: "010-0000-0001",
            website: "leanne.dev",
            company: "InnoSquad",
            city: "Seoul"
        )
    ]

    private static let posts: [PostSummary] = [
        .init(id: 100, title: "Post", body: "Body", authorID: 1)
    ]

    private static let todos: [TodoSummary] = [
        .init(id: 200, title: "Todo for Leanne", completed: false, assigneeID: 1)
    ]
}

@MainActor
private struct StubFeatureContainerDependencies: FeatureContainerDependencies {
    let useCases: any FeatureUseCaseContaining
}

private struct StubFeatureUseCases: FeatureUseCaseContaining {
    let fetchPeopleUseCase: FetchPeopleUseCase
    let fetchPostsUseCase: FetchPostsUseCase
    let fetchTodosUseCase: FetchTodosUseCase

    init(users: [UserSummary], posts: [PostSummary], todos: [TodoSummary]) {
        self.fetchPeopleUseCase = FetchPeopleUseCase(repository: StubUserRepository(users: users))
        self.fetchPostsUseCase = FetchPostsUseCase(repository: StubPostRepository(posts: posts))
        self.fetchTodosUseCase = FetchTodosUseCase(repository: StubTodoRepository(todos: todos))
    }
}

private struct StubUserRepository: UserRepositoryProtocol {
    let users: [UserSummary]
    func fetchUsers() async throws -> [UserSummary] { users }
}

private struct StubPostRepository: PostRepositoryProtocol {
    let posts: [PostSummary]
    func fetchPosts() async throws -> [PostSummary] { posts }
}

private struct StubTodoRepository: TodoRepositoryProtocol {
    let todos: [TodoSummary]
    func fetchTodos() async throws -> [TodoSummary] { todos }
}
