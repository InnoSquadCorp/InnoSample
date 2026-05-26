import Foundation
import InnoRouter
import Observation
import SettingsFeatureInterface
import SettingsFeatureLogic

@MainActor
@Observable
public final class SettingsFeatureCoordinator {
    /// SettingsFeature uses `FlowStore` as its single routing authority.
    /// Push detail and digest sheet routes are projected through the same
    /// flow path so tests and telemetry can read one current surface.
    let flowStore = FlowStore<SettingsRoute>()
    let model: SettingsFeatureModel

    init(input: SettingsFeatureInput) {
        self.model = SettingsFeatureModel(loadTodos: input.fetchTodosUseCase.callAsFunction)
    }

    isolated deinit {
        deferredSelectionTask?.cancel()
    }

    var selectedTodoID: Int? { model.selectedTodoID }
    var pendingDigestToken: UUID? { model.pendingDigestToken }
    public var pendingPeopleRequestID: UUID? { model.pendingPeopleRequestID }

    func select(_ todo: FeatureTodo) {
        model.select(todo)
    }

    func showDigest() {
        model.showDigest()
    }

    func openPeople(for request: OpenPeopleRequest) {
        model.openPeople(userID: request.userID)
    }

    public func showDetail(assigneeID: Int) {
        model.openTodoDetail(forAssigneeID: assigneeID)
        model.loadIfNeeded()
        if !syncNavigationFromSelection() {
            awaitDeferredSelection()
        }
    }

    @discardableResult
    func syncNavigationFromSelection() -> Bool {
        guard let selectedTodo = model.consumeSelectedTodo() else { return false }
        flowStore.send(.replaceStack([.detail(selectedTodo)]))
        return true
    }

    func syncModalPresentation() {
        guard let request = model.consumeDigestRequest() else { return }
        flowStore.send(.presentSheet(.digest(completed: request.completed, total: request.total)))
    }

    public func consumePeopleRequest() -> OpenPeopleRequest? {
        model.consumePeopleRequest()
    }

    private var deferredSelectionTask: Task<Void, Never>?

    private func awaitDeferredSelection() {
        deferredSelectionTask?.cancel()
        deferredSelectionTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard self != nil else { return }
                guard self?.selectedTodoID == nil else { break }
                await Self.waitForSelectionChange {
                    [weak self] in self?.selectedTodoID
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
