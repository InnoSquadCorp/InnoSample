@testable import Domain
import SettingsFeatureInterface
@testable import SettingsFeatureLogic
@testable import SettingsFeatureRouter
import SettingsFeatureTesting
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
    func testModelLoadsTodos() async {
        let model = SettingsFeatureModel {
            SettingsFeatureFixtures.todos
        }
        SettingsFeatureTestRetainer.retain(model)

        model.loadIfNeeded()
        await waitUntil("todos are loaded") {
            model.todos == SettingsFeatureFixtures.todos && model.isLoading == false
        }

        XCTAssertEqual(model.todos, SettingsFeatureFixtures.todos)
        XCTAssertFalse(model.isLoading)
    }

    func testCoordinatorClearsSelectionAfterNavigationSync() {
        let coordinator = SettingsFeatureCoordinator(
            input: SettingsFeatureInput(
                fetchTodosUseCase: FetchTodosUseCase(repository: StubTodoRepository())
            )
        )
        SettingsFeatureTestRetainer.retain(coordinator)

        coordinator.select(SettingsFeatureFixtures.todos[0])
        coordinator.syncNavigationFromSelection()

        XCTAssertNil(coordinator.selectedTodoID)
        XCTAssertEqual(coordinator.flowStore.path, [.push(.detail(SettingsFeatureFixtures.todos[0]))])
    }

    func testCoordinatorPresentsDigestThroughFlowStore() async {
        let coordinator = SettingsFeatureCoordinator(
            input: SettingsFeatureInput(
                fetchTodosUseCase: FetchTodosUseCase(repository: StubTodoRepository())
            )
        )
        SettingsFeatureTestRetainer.retain(coordinator)

        coordinator.model.loadIfNeeded()
        await waitUntil("todos are loaded before presenting digest") {
            coordinator.model.todos == SettingsFeatureFixtures.todos
        }
        coordinator.showDigest()
        coordinator.syncModalPresentation()

        XCTAssertEqual(
            coordinator.flowStore.currentModalRoute,
            .digest(completed: 0, total: SettingsFeatureFixtures.todos.count)
        )
    }

    func testCoordinatorEmitsOneShotPeopleRequest() {
        let coordinator = SettingsFeatureCoordinator(
            input: SettingsFeatureInput(
                fetchTodosUseCase: FetchTodosUseCase(repository: StubTodoRepository())
            )
        )
        SettingsFeatureTestRetainer.retain(coordinator)

        coordinator.openPeople(for: OpenPeopleRequest(userID: 1))

        XCTAssertEqual(coordinator.pendingPeopleRequestID != nil, true)
        XCTAssertEqual(coordinator.consumePeopleRequest(), OpenPeopleRequest(userID: 1))
        XCTAssertNil(coordinator.consumePeopleRequest())
    }
}

private struct StubTodoRepository: TodoRepositoryProtocol {
    func fetchTodos() async throws -> [TodoSummary] {
        SettingsFeatureFixtures.todos
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

@MainActor
private enum SettingsFeatureTestRetainer {
    static var retainedObjects: [AnyObject] = []

    static func retain(_ object: AnyObject) {
        retainedObjects.append(object)
    }
}
