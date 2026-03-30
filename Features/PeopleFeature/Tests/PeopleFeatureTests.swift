@testable import Domain
import PeopleFeatureInterface
@testable import PeopleFeatureLogic
@testable import PeopleFeatureRouter
import PeopleFeatureTesting
import XCTest

@MainActor
final class PeopleFeatureTests: XCTestCase {
    func testModelLoadsPeople() async {
        let model = PeopleFeatureModel {
            PeopleFeatureFixtures.users
        }
        PeopleFeatureTestRetainer.retain(model)

        model.loadIfNeeded()
        await waitUntil("people are loaded") {
            model.people == PeopleFeatureFixtures.users && model.isLoading == false
        }

        XCTAssertEqual(model.people, PeopleFeatureFixtures.users)
        XCTAssertFalse(model.isLoading)
    }

    func testCoordinatorClearsSelectionAfterNavigationSync() {
        let coordinator = PeopleFeatureCoordinator(
            input: PeopleFeatureInput(
                fetchPeopleUseCase: FetchPeopleUseCase(repository: StubUserRepository())
            )
        )
        PeopleFeatureTestRetainer.retain(coordinator)

        coordinator.select(PeopleFeatureFixtures.users[0])
        coordinator.syncNavigationFromSelection()

        XCTAssertNil(coordinator.selectedUserID)
    }

    func testCoordinatorEmitsOneShotSettingsRequest() {
        let coordinator = PeopleFeatureCoordinator(
            input: PeopleFeatureInput(
                fetchPeopleUseCase: FetchPeopleUseCase(repository: StubUserRepository())
            )
        )
        PeopleFeatureTestRetainer.retain(coordinator)

        coordinator.openSettings(for: OpenSettingsRequest(assigneeID: 1))

        XCTAssertEqual(coordinator.pendingSettingsRequestID != nil, true)
        XCTAssertEqual(coordinator.consumeSettingsRequest(), OpenSettingsRequest(assigneeID: 1))
        XCTAssertNil(coordinator.consumeSettingsRequest())
    }
}

private struct StubUserRepository: UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserSummary] {
        PeopleFeatureFixtures.users
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
private enum PeopleFeatureTestRetainer {
    static var retainedObjects: [AnyObject] = []

    static func retain(_ object: AnyObject) {
        retainedObjects.append(object)
    }
}
