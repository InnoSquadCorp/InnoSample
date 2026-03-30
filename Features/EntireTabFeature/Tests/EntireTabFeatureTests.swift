@testable import Domain
import EntireTabFeatureInterface
@testable import EntireTabFeatureRouter
import PeopleFeatureInterface
@testable import PeopleFeatureRouter
import PostsFeatureInterface
@testable import PostsFeatureRouter
import SettingsFeatureInterface
@testable import SettingsFeatureRouter
import EntireTabFeatureTesting
import XCTest

@MainActor
final class EntireTabFeatureTests: XCTestCase {
    func testCoordinatorStartsOnPeopleTab() {
        let coordinator = EntireTabCoordinator(
            peopleCoordinator: .init(
                input: .init(fetchPeopleUseCase: FetchPeopleUseCase(repository: StubUserRepository(users: Self.users)))
            ),
            postsCoordinator: .init(
                input: .init(fetchPostsUseCase: FetchPostsUseCase(repository: StubPostRepository(posts: Self.posts)))
            ),
            settingsCoordinator: .init(
                input: .init(fetchTodosUseCase: FetchTodosUseCase(repository: StubTodoRepository(todos: Self.todos)))
            )
        )
        EntireTabFeatureTestRetainer.retain(coordinator)

        XCTAssertEqual(coordinator.selectedTab, SampleTab.people)
        XCTAssertEqual(EntireTabFeatureFixtures.allTabs.count, 3)
    }

    func testCoordinatorMediatesPeopleToSettingsNavigation() async {
        let coordinator = EntireTabCoordinator(
            peopleCoordinator: .init(
                input: .init(fetchPeopleUseCase: FetchPeopleUseCase(repository: StubUserRepository(users: Self.users)))
            ),
            postsCoordinator: .init(
                input: .init(fetchPostsUseCase: FetchPostsUseCase(repository: StubPostRepository(posts: Self.posts)))
            ),
            settingsCoordinator: .init(
                input: .init(fetchTodosUseCase: FetchTodosUseCase(repository: StubTodoRepository(todos: Self.todos)))
            )
        )
        EntireTabFeatureTestRetainer.retain(coordinator)

        coordinator.peopleCoordinator.openSettings(for: .init(assigneeID: 1))
        coordinator.syncCrossFeatureNavigationFromPeople()

        await waitUntil("settings detail is shown") {
            coordinator.settingsCoordinator.navigationStore.state.path == [SettingsRoute.detail(Self.todos[0])]
        }

        XCTAssertEqual(coordinator.selectedTab, SampleTab.settings)
        XCTAssertEqual(
            coordinator.settingsCoordinator.navigationStore.state.path,
            [SettingsRoute.detail(Self.todos[0])]
        )
    }

    func testCoordinatorMediatesSettingsToPeopleNavigation() async {
        let coordinator = EntireTabCoordinator(
            peopleCoordinator: .init(
                input: .init(fetchPeopleUseCase: FetchPeopleUseCase(repository: StubUserRepository(users: Self.users)))
            ),
            postsCoordinator: .init(
                input: .init(fetchPostsUseCase: FetchPostsUseCase(repository: StubPostRepository(posts: Self.posts)))
            ),
            settingsCoordinator: .init(
                input: .init(fetchTodosUseCase: FetchTodosUseCase(repository: StubTodoRepository(todos: Self.todos)))
            )
        )
        EntireTabFeatureTestRetainer.retain(coordinator)

        coordinator.settingsCoordinator.openPeople(for: .init(userID: 1))
        coordinator.syncCrossFeatureNavigationFromSettings()

        await waitUntil("people detail is shown") {
            coordinator.peopleCoordinator.navigationStore.state.path == [PeopleRoute.detail(Self.users[0])]
        }

        XCTAssertEqual(coordinator.selectedTab, SampleTab.people)
        XCTAssertEqual(
            coordinator.peopleCoordinator.navigationStore.state.path,
            [PeopleRoute.detail(Self.users[0])]
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

@MainActor
private enum EntireTabFeatureTestRetainer {
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
