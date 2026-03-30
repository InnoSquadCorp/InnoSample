@testable import Domain
@testable import EntireTabFeatureRouter
import Features
@testable import PeopleFeatureRouter
@testable import PostsFeatureRouter
@testable import SettingsFeatureRouter
import XCTest

@MainActor
final class FeatureContainerTests: XCTestCase {
    func testFeatureContainerCreatesRootCoordinator() {
        let container = makeContainer()
        let coordinator = container.coordinator
        FeatureTestRetainer.retain(coordinator)

        XCTAssertEqual(coordinator.selectedTab, .people)
    }

    func testFeatureContainerLoadsPeopleCoordinatorFromInjectedUseCase() async {
        let container = makeContainer()
        let coordinator = container.coordinator
        FeatureTestRetainer.retain(coordinator)

        coordinator.peopleCoordinator.showDetail(userID: 1)

        await waitUntil("people detail is shown from root composition") {
            coordinator.peopleCoordinator.navigationStore.state.path == [.detail(Self.users[0])]
        }

        XCTAssertEqual(coordinator.selectedTab, .people)
    }

    func testFeatureContainerLoadsPostsCoordinatorFromInjectedUseCase() async {
        let container = makeContainer()
        let coordinator = container.coordinator
        FeatureTestRetainer.retain(coordinator)

        coordinator.postsCoordinator.model.loadIfNeeded()
        await waitUntil("posts load for highlights modal") {
            coordinator.postsCoordinator.model.posts == Self.posts
        }

        coordinator.postsCoordinator.showHighlights()
        coordinator.postsCoordinator.syncModalPresentation()

        XCTAssertEqual(
            coordinator.postsCoordinator.modalStore.currentPresentation?.route,
            .highlights(Self.posts)
        )
    }

    func testFeatureContainerMediatesPeopleToSettingsNavigation() async {
        let container = makeContainer()
        let coordinator = container.coordinator
        FeatureTestRetainer.retain(coordinator)

        coordinator.peopleCoordinator.openSettings(for: .init(assigneeID: 1))
        coordinator.syncCrossFeatureNavigationFromPeople()

        await waitUntil("settings detail is shown through root mediation") {
            coordinator.settingsCoordinator.navigationStore.state.path == [.detail(Self.todos[0])]
        }

        XCTAssertEqual(coordinator.selectedTab, .settings)
    }

    func testFeatureContainerMediatesSettingsToPeopleNavigation() async {
        let container = makeContainer()
        let coordinator = container.coordinator
        FeatureTestRetainer.retain(coordinator)

        coordinator.settingsCoordinator.openPeople(for: .init(userID: 1))
        coordinator.syncCrossFeatureNavigationFromSettings()

        await waitUntil("people detail is shown through root mediation") {
            coordinator.peopleCoordinator.navigationStore.state.path == [.detail(Self.users[0])]
        }

        XCTAssertEqual(coordinator.selectedTab, .people)
    }

    private func makeContainer() -> FeatureContainer {
        FeatureContainer(useCases: StubFeatureUseCases(users: Self.users, posts: Self.posts, todos: Self.todos))
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
        .init(
            id: 100,
            title: "Post",
            body: "Body",
            authorID: 1
        )
    ]

    private static let todos: [TodoSummary] = [
        .init(
            id: 200,
            title: "Todo for Leanne",
            completed: false,
            assigneeID: 1
        )
    ]
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

    init(users: [UserSummary] = []) {
        self.users = users
    }

    func fetchUsers() async throws -> [UserSummary] { users }
}

private struct StubPostRepository: PostRepositoryProtocol {
    let posts: [PostSummary]

    init(posts: [PostSummary] = []) {
        self.posts = posts
    }

    func fetchPosts() async throws -> [PostSummary] { posts }
}

private struct StubTodoRepository: TodoRepositoryProtocol {
    let todos: [TodoSummary]

    init(todos: [TodoSummary] = []) {
        self.todos = todos
    }

    func fetchTodos() async throws -> [TodoSummary] { todos }
}

@MainActor
private enum FeatureTestRetainer {
    static var retainedObjects: [AnyObject] = []

    static func retain(_ object: AnyObject) {
        retainedObjects.append(object)
    }
}

@MainActor
private func waitUntil(
    _ description: String,
    timeoutNanoseconds: UInt64 = 1_000_000_000,
    pollNanoseconds: UInt64 = 10_000_000,
    condition: @escaping @MainActor () -> Bool
) async {
    let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

    while condition() == false, DispatchTime.now().uptimeNanoseconds < deadline {
        await Task.yield()
        try? await Task.sleep(nanoseconds: pollNanoseconds)
    }

    XCTAssertTrue(condition(), description)
}
