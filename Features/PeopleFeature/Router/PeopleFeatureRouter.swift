import Foundation
import InnoRouter
import Observation
import PeopleFeatureInterface
import PeopleFeatureLogic

/// PeopleFeature uses `FlowStore<PeopleRoute>` instead of separate
/// `NavigationStore` + `ModalStore` instances. `FlowStore` exposes a
/// unified `path: [RouteStep<PeopleRoute>]` projection plus a single
/// `send(FlowIntent<PeopleRoute>)` dispatch entry, so push (`.detail`) and
/// sheet (`.overview`) intents flow through one call site. Posts and
/// Settings document the current split-view and flow surfaces; see
/// `Docs/ArchitectureReview.md` for the adoption guidance.
@MainActor
@Observable
public final class PeopleFeatureCoordinator {
    let flowStore = FlowStore<PeopleRoute>()
    let model: PeopleFeatureModel

    init(input: PeopleFeatureInput) {
        self.model = PeopleFeatureModel(loadPeople: input.fetchPeopleUseCase.callAsFunction)
    }

    isolated deinit {
        deferredSelectionTask?.cancel()
    }

    var selectedUserID: Int? { model.selectedUserID }
    var pendingOverviewToken: UUID? { model.pendingOverviewToken }
    public var pendingSettingsRequestID: UUID? { model.pendingSettingsRequestID }

    func select(_ user: PeopleUser) {
        model.select(user)
    }

    func showOverview() {
        model.showOverview()
    }

    func openSettings(for request: OpenSettingsRequest) {
        model.openSettings(forAssigneeID: request.assigneeID)
    }

    public func showDetail(userID: Int) {
        model.openUserDetail(userID: userID)
        model.loadIfNeeded()
        if !syncNavigationFromSelection() {
            awaitDeferredSelection()
        }
    }

    @discardableResult
    func syncNavigationFromSelection() -> Bool {
        guard let selectedUser = model.consumeSelectedUser() else { return false }
        flowStore.send(.replaceStack([.detail(selectedUser)]))
        return true
    }

    func syncModalPresentation() {
        guard let users = model.consumeOverviewUsers() else { return }
        flowStore.send(.presentSheet(.overview(users)))
    }

    public func consumeSettingsRequest() -> OpenSettingsRequest? {
        model.consumeSettingsRequest()
    }

    private var deferredSelectionTask: Task<Void, Never>?

    private func awaitDeferredSelection() {
        deferredSelectionTask?.cancel()
        deferredSelectionTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard self != nil else { return }
                guard self?.selectedUserID == nil else { break }
                await Self.waitForSelectionChange {
                    [weak self] in self?.selectedUserID
                }
            }
            if !Task.isCancelled, let self {
                _ = self.syncNavigationFromSelection()
            }
        }
    }

    private static func waitForSelectionChange(
        _ readSelection: @escaping @MainActor () -> Int?
    ) async {
        let waiter = DeferredObservationWaiter()
        await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                waiter.install(continuation)
                withObservationTracking {
                    _ = readSelection()
                } onChange: {
                    waiter.resume()
                }
                if Task.isCancelled {
                    waiter.resume()
                }
            }
        } onCancel: {
            waiter.resume()
        }
    }
}

private final class DeferredObservationWaiter: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Never>?
    private var isResolved = false

    func install(_ continuation: CheckedContinuation<Void, Never>) {
        let shouldResume: Bool
        lock.lock()
        if isResolved {
            shouldResume = true
        } else {
            self.continuation = continuation
            shouldResume = false
        }
        lock.unlock()

        if shouldResume {
            continuation.resume()
        }
    }

    func resume() {
        let continuation: CheckedContinuation<Void, Never>?
        lock.lock()
        if isResolved {
            continuation = nil
        } else {
            isResolved = true
            continuation = self.continuation
            self.continuation = nil
        }
        lock.unlock()

        continuation?.resume()
    }
}
