import Foundation
import Synchronization
import XCTest
@testable import KeyboardCore

@available(macOS 15.0, *)
private struct SpikeFakeRimeEngineFactory: ThreadAffineRimeSpikeEngineFactory {
    func makeEngineOnOwnerThread() -> any RimeEngine {
        FakeRimeEngine()
    }
}

@available(macOS 15.0, *)
private final class SpikeEngineLifecycleRecorder: Sendable {
    struct Facts: Sendable {
        var initThread: Int?
        var processThreads: [Int] = []
        var deinitThread: Int?
    }

    private let facts = Mutex(Facts())
    private let destroyed = DispatchSemaphore(value: 0)

    func recordInit() {
        facts.withLock { $0.initThread = Self.currentThreadIdentity }
    }

    func recordProcess() {
        facts.withLock { $0.processThreads.append(Self.currentThreadIdentity) }
    }

    func recordDeinit() {
        facts.withLock { $0.deinitThread = Self.currentThreadIdentity }
        destroyed.signal()
    }

    func snapshot() -> Facts {
        facts.withLock { $0 }
    }

    func waitForDeinit(timeout: DispatchTime = .now() + 2) -> Bool {
        destroyed.wait(timeout: timeout) == .success
    }

    private static var currentThreadIdentity: Int {
        ObjectIdentifier(Thread.current).hashValue
    }
}

@available(macOS 15.0, *)
private final class SpikeLifecycleProbeRimeEngine: RimeEngine {
    private let delegate = FakeRimeEngine()
    private let recorder: SpikeEngineLifecycleRecorder
    private let processEntered: DispatchSemaphore?
    private let releaseFirstProcess: DispatchSemaphore?
    private var didBlockFirstProcess = false

    init(
        recorder: SpikeEngineLifecycleRecorder,
        processEntered: DispatchSemaphore? = nil,
        releaseFirstProcess: DispatchSemaphore? = nil
    ) {
        self.recorder = recorder
        self.processEntered = processEntered
        self.releaseFirstProcess = releaseFirstProcess
        recorder.recordInit()
    }

    deinit {
        recorder.recordDeinit()
    }

    func processKey(_ key: String) -> RimeOutput {
        recorder.recordProcess()
        if !didBlockFirstProcess, let processEntered, let releaseFirstProcess {
            didBlockFirstProcess = true
            processEntered.signal()
            releaseFirstProcess.wait()
        }
        return delegate.processKey(key)
    }

    func selectCandidate(at index: Int) -> RimeOutput {
        delegate.selectCandidate(at: index)
    }

    func selectCandidate(globalIndex index: Int) -> RimeOutput {
        delegate.selectCandidate(globalIndex: index)
    }

    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        delegate.candidateWindow(from: globalIndex, limit: limit)
    }

    func deleteBackward() -> RimeOutput {
        delegate.deleteBackward()
    }

    func replaceInput(_ input: String) -> RimeOutput {
        delegate.replaceInput(input)
    }

    func resetSession() {
        delegate.resetSession()
    }

    func recoverSession() {
        delegate.recoverSession()
    }

    func suspendForVisibilityChange() {
        delegate.suspendForVisibilityChange()
    }

    func resumeAfterVisibilityChange() {
        delegate.resumeAfterVisibilityChange()
    }

    var runtimeSelection: RimeRuntimeSelection? {
        delegate.runtimeSelection
    }

    var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
        delegate.diagnosticSessionSnapshot
    }

    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { delegate.onRuntimeSelectionChanged }
        set { delegate.onRuntimeSelectionChanged = newValue }
    }

    func isComposing() -> Bool {
        delegate.isComposing()
    }

    func pageUp() -> RimeOutput {
        delegate.pageUp()
    }

    func pageDown() -> RimeOutput {
        delegate.pageDown()
    }
}

@available(macOS 15.0, *)
private struct SpikeLifecycleProbeEngineFactory: ThreadAffineRimeSpikeEngineFactory {
    let recorder: SpikeEngineLifecycleRecorder
    let processEntered: DispatchSemaphore?
    let releaseFirstProcess: DispatchSemaphore?

    init(
        recorder: SpikeEngineLifecycleRecorder,
        processEntered: DispatchSemaphore? = nil,
        releaseFirstProcess: DispatchSemaphore? = nil
    ) {
        self.recorder = recorder
        self.processEntered = processEntered
        self.releaseFirstProcess = releaseFirstProcess
    }

    func makeEngineOnOwnerThread() -> any RimeEngine {
        SpikeLifecycleProbeRimeEngine(
            recorder: recorder,
            processEntered: processEntered,
            releaseFirstProcess: releaseFirstProcess
        )
    }
}

@available(macOS 15.0, *)
@MainActor
final class ThreadAffineRimeSpikeTests: XCTestCase {

    func testMainActorAcceptsWhileOwnerEngineCallIsBlocked() async {
        let engineEntered = DispatchSemaphore(value: 0)
        let releaseEngine = DispatchSemaphore(value: 0)
        let allResults = expectation(description: "all results")
        allResults.expectedFulfillmentCount = 4
        let gate = ThreadAffineRimeSpikeApplyGate()
        let lifecycle = SpikeEngineLifecycleRecorder()

        let owner = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeLifecycleProbeEngineFactory(
                recorder: lifecycle,
                processEntered: engineEntered,
                releaseFirstProcess: releaseEngine
            ),
            resultHandler: { result in
                _ = gate.apply(result)
                allResults.fulfill()
            }
        )

        XCTAssertNotNil(owner.accept(.processKey("n"), actionID: "k0"))
        XCTAssertEqual(engineEntered.wait(timeout: .now() + 1), .success)

        let blockedAt = DispatchTime.now().uptimeNanoseconds
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.18) {
            releaseEngine.signal()
        }
        let started = DispatchTime.now().uptimeNanoseconds
        for (index, key) in ["i", "h", "a"].enumerated() {
            let receipt = owner.accept(.processKey(key), actionID: "k\(index + 1)")
            XCTAssertNotNil(receipt)
            XCTAssertEqual(receipt?.executedSynchronously, false)
        }
        let elapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000
        XCTAssertLessThan(elapsedMS, 50, "MainActor accept must not wait on blocked engine")

        await fulfillment(of: [allResults], timeout: 2)
        let blockedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- blockedAt) / 1_000_000
        XCTAssertGreaterThanOrEqual(blockedMS, 150, "proof must cover a 150ms+ owner stall")

        XCTAssertEqual(gate.appliedSnapshots.map(\.actionID), ["k0", "k1", "k2", "k3"])
        XCTAssertEqual(gate.appliedSnapshots.last?.output.rawInput, "niha")
        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
        XCTAssertTrue(lifecycle.waitForDeinit())
        assertSingleOwnerThread(lifecycle.snapshot(), expectedProcessCount: 4)
    }

    func testDedicatedOwnerPreservesOrderWithoutDropOrDuplicate() async {
        let keyCount = 12
        let allResults = expectation(description: "ordered results")
        allResults.expectedFulfillmentCount = keyCount
        let gate = ThreadAffineRimeSpikeApplyGate()
        var affinityFacts: [(offMain: Bool, sameThread: Bool)] = []

        let owner = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeFakeRimeEngineFactory(),
            resultHandler: { result in
                affinityFacts.append(
                    (result.engineCreatedOffMainThread, result.engineCallStayedOnCreationThread)
                )
                _ = gate.apply(result)
                allResults.fulfill()
            }
        )

        for index in 0..<keyCount {
            XCTAssertNotNil(
                owner.accept(.processKey("n"), actionID: "k\(index)")
            )
        }
        await fulfillment(of: [allResults], timeout: 2)

        XCTAssertEqual(
            gate.appliedSnapshots.map(\.revision),
            Array(1...UInt64(keyCount))
        )
        XCTAssertEqual(
            gate.appliedSnapshots.map(\.actionID),
            (0..<keyCount).map { "k\($0)" }
        )
        XCTAssertEqual(Set(gate.appliedSnapshots.map(\.actionID)).count, keyCount)
        XCTAssertTrue(affinityFacts.allSatisfy(\.offMain))
        XCTAssertTrue(affinityFacts.allSatisfy(\.sameThread))
        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
    }

    func testOldEpochResultIsRejectedAndNewEpochRunsAfterResetBarrier() async throws {
        let firstEngineEntered = DispatchSemaphore(value: 0)
        let releaseFirstEngineCall = DispatchSemaphore(value: 0)
        let deliveries = expectation(description: "old and new delivered")
        deliveries.expectedFulfillmentCount = 2
        let gate = ThreadAffineRimeSpikeApplyGate()
        let lifecycle = SpikeEngineLifecycleRecorder()

        let owner = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeLifecycleProbeEngineFactory(
                recorder: lifecycle,
                processEntered: firstEngineEntered,
                releaseFirstProcess: releaseFirstEngineCall
            ),
            resultHandler: { result in
                _ = gate.apply(result)
                deliveries.fulfill()
            }
        )

        XCTAssertNotNil(owner.accept(.processKey("n"), actionID: "old"))
        XCTAssertEqual(firstEngineEntered.wait(timeout: .now() + 1), .success)

        let newEpoch = try XCTUnwrap(owner.advanceSessionEpoch())
        gate.advanceSessionEpoch(to: newEpoch)
        XCTAssertNotNil(owner.accept(.processKey("w"), actionID: "new"))
        releaseFirstEngineCall.signal()

        await fulfillment(of: [deliveries], timeout: 2)
        XCTAssertEqual(gate.discardedResultCount, 1)
        XCTAssertEqual(gate.appliedSnapshots.map(\.actionID), ["new"])
        XCTAssertEqual(gate.appliedSnapshots.last?.output.rawInput, "w")
        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
        XCTAssertTrue(lifecycle.waitForDeinit())
        assertSingleOwnerThread(lifecycle.snapshot(), expectedProcessCount: 2)
    }

    func testExplicitShutdownDestroysEngineOnItsOwnerThread() async {
        let lifecycle = SpikeEngineLifecycleRecorder()
        let delivered = expectation(description: "result delivered")
        let owner = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeLifecycleProbeEngineFactory(recorder: lifecycle),
            resultHandler: { _ in delivered.fulfill() }
        )

        XCTAssertNotNil(owner.accept(.processKey("n"), actionID: "k0"))
        await fulfillment(of: [delivered], timeout: 1)
        owner.shutdown()

        XCTAssertTrue(owner.waitUntilStopped())
        XCTAssertTrue(lifecycle.waitForDeinit())
        assertSingleOwnerThread(lifecycle.snapshot(), expectedProcessCount: 1)
    }

    func testOwnerDeinitStopsThreadAndDestroysEngineWhenShutdownIsOmitted() {
        let lifecycle = SpikeEngineLifecycleRecorder()
        var owner: ThreadAffineRimeSpikeOwner? = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeLifecycleProbeEngineFactory(recorder: lifecycle),
            resultHandler: { _ in }
        )

        XCTAssertNotNil(owner)
        owner = nil

        XCTAssertTrue(
            lifecycle.waitForDeinit(),
            "deinit fallback must stop the thread and release its local engine"
        )
        let facts = lifecycle.snapshot()
        XCTAssertNotNil(facts.initThread)
        XCTAssertEqual(facts.deinitThread, facts.initThread)
        XCTAssertTrue(facts.processThreads.isEmpty)
    }

    func testApplyGateRejectsOlderRevisionDeliveredAfterNewerRevision() {
        let gate = ThreadAffineRimeSpikeApplyGate()
        let newer = makeResult(epoch: 1, revision: 2, actionID: "new")
        let older = makeResult(epoch: 1, revision: 1, actionID: "old")

        XCTAssertTrue(gate.apply(newer))
        XCTAssertFalse(gate.apply(older))
        XCTAssertEqual(gate.appliedSnapshots.map(\.actionID), ["new"])
        XCTAssertEqual(gate.discardedResultCount, 1)
    }

    func testSpikeIsNotWiredAndGateOffRemainsSynchronous() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine

        XCTAssertFalse(controller.isResponsiveRimePipelineEnabled)
        _ = controller.handle(.insertKey("n"))

        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
        XCTAssertNil(controller.responsiveRimeCoordinator)
    }

    // MARK: - R4-Owner (D1–D3)

    func testRefuseAtBoundDoesNotDropAcceptedWork() async {
        let engineEntered = DispatchSemaphore(value: 0)
        let releaseEngine = DispatchSemaphore(value: 0)
        let lifecycle = SpikeEngineLifecycleRecorder()
        let delivered = expectation(description: "accepted work delivered")
        // max=1: after first is dequeued+blocked, second fills the bound, third refuses.
        delivered.expectedFulfillmentCount = 2

        let owner = ThreadAffineRimeSpikeOwner(
            bootstrap: SpikeLifecycleProbeEngineFactory(
                recorder: lifecycle,
                processEntered: engineEntered,
                releaseFirstProcess: releaseEngine
            ),
            configuration: ThreadAffineRimeOwnerConfiguration(maxPendingWorkDepth: 1),
            resultHandler: { _ in delivered.fulfill() }
        )

        XCTAssertNotNil(owner.accept(.processKey("a"), actionID: "k0"))
        XCTAssertEqual(engineEntered.wait(timeout: .now() + 1), .success)
        XCTAssertNotNil(owner.accept(.processKey("b"), actionID: "k1"))
        XCTAssertNil(owner.accept(.processKey("c"), actionID: "k2"), "third accept must refuse at bound")
        XCTAssertEqual(owner.diagnostics().rejectedAtBoundCount, 1)

        releaseEngine.signal()
        await fulfillment(of: [delivered], timeout: 2)

        let diagnostics = owner.diagnostics()
        XCTAssertEqual(diagnostics.rejectedAtBoundCount, 1)
        XCTAssertEqual(diagnostics.deliveredCount, 2)

        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
        XCTAssertTrue(owner.waitUntilDeliveryDrained())
        XCTAssertTrue(owner.diagnostics().isDeliveryTerminal)
        XCTAssertTrue(lifecycle.waitForDeinit())
    }

    func testOrderedDeliveryAndTerminalBarrierAfterStop() async {
        let count = 8
        var deliveryOrder: [String] = []
        let allDelivered = expectation(description: "ordered delivery")
        allDelivered.expectedFulfillmentCount = count

        let owner = ThreadAffineRimeSpikeOwner(
            bootstrap: SpikeFakeRimeEngineFactory(),
            resultHandler: { result in
                deliveryOrder.append(result.snapshot.actionID)
                allDelivered.fulfill()
            }
        )

        for index in 0..<count {
            XCTAssertNotNil(owner.accept(.processKey("n"), actionID: "k\(index)"))
        }
        await fulfillment(of: [allDelivered], timeout: 2)
        XCTAssertEqual(deliveryOrder, (0..<count).map { "k\($0)" })

        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
        XCTAssertTrue(owner.waitUntilDeliveryDrained())
        XCTAssertTrue(owner.diagnostics().isDeliveryTerminal)
        XCTAssertEqual(owner.diagnostics().deliveredCount, count)
    }

    func testControlPriorityStopIsNotBuriedBehindWorkBacklog() async {
        let engineEntered = DispatchSemaphore(value: 0)
        let releaseEngine = DispatchSemaphore(value: 0)
        let lifecycle = SpikeEngineLifecycleRecorder()
        let firstDelivered = expectation(description: "in-flight first key")

        let owner = ThreadAffineRimeSpikeOwner(
            bootstrap: SpikeLifecycleProbeEngineFactory(
                recorder: lifecycle,
                processEntered: engineEntered,
                releaseFirstProcess: releaseEngine
            ),
            configuration: ThreadAffineRimeOwnerConfiguration(maxPendingWorkDepth: 32),
            resultHandler: { result in
                if result.snapshot.actionID == "k0" {
                    firstDelivered.fulfill()
                }
            }
        )

        XCTAssertNotNil(owner.accept(.processKey("a"), actionID: "k0"))
        XCTAssertEqual(engineEntered.wait(timeout: .now() + 1), .success)

        for index in 1..<16 {
            XCTAssertNotNil(owner.accept(.processKey("n"), actionID: "k\(index)"))
        }

        // Stop must be control-priority and complete without draining the whole backlog.
        owner.shutdown()
        releaseEngine.signal()

        await fulfillment(of: [firstDelivered], timeout: 2)
        XCTAssertTrue(
            owner.waitUntilStopped(timeout: .now() + 1),
            "stop must not wait to execute the entire work backlog"
        )
        XCTAssertTrue(owner.waitUntilDeliveryDrained())
        let diagnostics = owner.diagnostics()
        XCTAssertGreaterThan(diagnostics.abandonedAtStopCount, 0)
        XCTAssertTrue(lifecycle.waitForDeinit())
        // Only the in-flight first key should have executed processKey.
        assertSingleOwnerThread(lifecycle.snapshot(), expectedProcessCount: 1)
    }

    private func makeResult(
        epoch: UInt64,
        revision: UInt64,
        actionID: String
    ) -> ThreadAffineRimeSpikeResult {
        ThreadAffineRimeSpikeResult(
            snapshot: ResponsiveRimeSnapshot(
                sessionEpoch: epoch,
                revision: revision,
                actionID: actionID,
                output: RimeOutput(rawInput: actionID)
            ),
            engineCreatedOffMainThread: true,
            engineCallStayedOnCreationThread: true
        )
    }

    private func assertSingleOwnerThread(
        _ facts: SpikeEngineLifecycleRecorder.Facts,
        expectedProcessCount: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNotNil(facts.initThread, file: file, line: line)
        XCTAssertEqual(facts.processThreads.count, expectedProcessCount, file: file, line: line)
        XCTAssertTrue(
            facts.processThreads.allSatisfy { $0 == facts.initThread },
            file: file,
            line: line
        )
        XCTAssertEqual(facts.deinitThread, facts.initThread, file: file, line: line)
    }
}
