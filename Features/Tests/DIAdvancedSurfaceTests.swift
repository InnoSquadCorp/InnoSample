import InnoDI
import Testing

@Suite("Generated DI lifetime contracts", .timeLimit(.minutes(1)))
@MainActor
struct DIAdvancedSurfaceTests {
    @Test("typed prewarm is selective and copies share the deferred cache")
    func prewarmSharesConstruction() {
        let count = DeferredConstructionCount()
        let container = DeferredSampleServices(count: count)
        let copy = container
        #expect(count.value == 0)
        container.prewarm(.label)
        #expect(copy.label == "sample")
        #expect(container.label == "sample")
        #expect(count.value == 1)
        #expect(container.labels == ["first", "second"])
    }

    @Test("an explicit optional nil override bypasses the live factory")
    func optionalNilOverrideSkipsConstruction() {
        let count = DeferredConstructionCount()
        let container = DeferredSampleServices(count: count) { overrides in
            overrides.set(\.label, to: nil)
        }
        container.prewarm(.label)
        #expect(container.label == nil)
        #expect(count.value == 0)
    }

    @Test("owned readiness failure requires explicit retry and close revokes reads")
    func ownedReadinessRetryAndClose() async throws {
        let probe = SamplePreparationProbe(failFirst: true)
        let owner = try await PreparedSampleServices.makeOwned(probe: probe)
        #expect(await probe.attempts == 0)
        let report = try await owner.prepare(.session)
        #expect(!report.isReady)
        try await owner.retryAndRequireReady(.session)
        #expect(try await owner.container.session == 42)
        #expect(await probe.attempts == 2)
        await owner.close()
        await owner.close()
        await #expect(throws: DIAsyncScopeError.self) { try await owner.container.session }
    }

    @Test("owned value overrides are ready without starting an async factory")
    func ownedOverrideSkipsPreparation() async throws {
        let probe = SamplePreparationProbe(failFirst: false)
        let owner = try await PreparedSampleServices.makeOwnedWithOverrides(probe: probe) {
            $0.session = 99
        }
        try await owner.requireReady(.session)
        #expect(try await owner.container.session == 99)
        #expect(await probe.attempts == 0)
        await owner.close()
    }
}

@MainActor
fileprivate final class DeferredConstructionCount {
    var value = 0
    func makeLabel() -> String? {
        value += 1
        return "sample"
    }
}

@DIContainerRole(role: ContainerRole.local, mainActor: true)
fileprivate struct DeferredSampleServices {
    @Input var count: DeferredConstructionCount
    @Provide(.shared, initialization: .onDemand, factory: { (count: DeferredConstructionCount) in
        count.makeLabel()
    })
    var label: String?
    @Provide(.shared, factory: "first") var first: String
    @Provide(.transient, factory: "second") var second: String
    @Multibinding([\Self.first, \Self.second]) var labels: [String]
}

private enum SamplePreparationFailure: Error { case unavailable }

fileprivate actor SamplePreparationProbe {
    private let failFirst: Bool
    private(set) var attempts = 0
    init(failFirst: Bool) { self.failFirst = failFirst }
    func open() async throws -> Int {
        attempts += 1
        if failFirst && attempts == 1 { throw SamplePreparationFailure.unavailable }
        return 42
    }
}

@DIContainerRole(role: ContainerRole.local, mainActor: true, generateOwned: true)
fileprivate struct PreparedSampleServices {
    @Input var probe: SamplePreparationProbe
    @Provide(.shared, initialization: .onDemand, asyncFactory: { (probe: SamplePreparationProbe) async throws in
        try await probe.open()
    })
    var session: Int
}
