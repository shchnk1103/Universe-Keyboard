import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalFlushWaitTests: XCTestCase {
    func testWriterFactoryCanInspectPendingState() async throws {
        let gate = FlushGate()
        await gate.setBlocking(false)
        let rig = makeIngress(gate: gate, mainApp: false)
        let ingress = rig.ingress
        ingress.installBatchWriterFactoryForTesting { [weak ingress] _ in
            _ = ingress?.testingSnapshotForTesting()
            return gate
        }
        ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        try await requireFlush(gate) { await ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 1)
    }

    func testEmptyQueueReturnsWithoutAppending() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, missingRoot: true)
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 0)
    }

    func testWaitStaysIncompleteUntilAppendIsReleased() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let finished = Mutex(false)
        let task = Task {
            try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
            finished.withLock { $0 = true }
        }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        XCTAssertFalse(finished.withLock { $0 })
        await gate.releaseOne()
        try await requireGate(gate) { try await task.value }
        XCTAssertTrue(finished.withLock { $0 })
        let count = await gate.appendCount
        XCTAssertEqual(count, 1)
    }

    func testFilteredEventsFinishWithoutAppending() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, enabled: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 0)
    }

    func testMissingRootFinishesWithoutAppending() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, missingRoot: true)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 0)
    }

    func testPrepareFailureFinishesTheWait() async throws {
        let gate = FlushGate()
        await gate.setPrepareFailure(true)
        let rig = makeIngress(gate: gate, mainApp: true)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 0)
    }

    func testAppendFailureFinishesTheWait() async throws {
        let gate = FlushGate()
        await gate.setFailure(.io)
        await gate.setBlocking(false)
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let ticket = try XCTUnwrap(rig.ingress.testingSnapshotForTesting().queuedTickets.first)
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 1)
        let snapshot = rig.ingress.testingSnapshotForTesting()
        XCTAssertEqual(snapshot.dropped, 1)
        XCTAssertEqual(snapshot.lifecycleCancelled, 0)
        XCTAssertEqual(snapshot.ticketOutcomes[ticket], .failed)
        XCTAssertTrue(snapshot.queuedTickets.isEmpty)
        XCTAssertTrue(snapshot.inFlightTickets.isEmpty)
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let laterCount = await gate.appendCount
        XCTAssertEqual(laterCount, 1)
    }

    func testLifecycleCancellationFinishesTheWait() async throws {
        let gate = FlushGate()
        await gate.setFailure(.lifecycle)
        await gate.setBlocking(false)
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
    }

    func testSuspendBeforeAdmissionFinishesWithoutAFile() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let task = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        rig.ingress.suspendForExtensionLifecycle()
        try await requireGate(gate) { try await task.value }
        await gate.releaseOne()
    }

    func testSuspendAfterAdmissionDoesNotFinishUntilAppendReturns() async throws {
        let gate = FlushGate()
        await gate.setAdmitBeforeBlock(true)
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let finished = Mutex(false)
        let task = Task {
            try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
            finished.withLock { $0 = true }
        }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        rig.ingress.suspendForExtensionLifecycle()
        XCTAssertFalse(finished.withLock { $0 })
        await gate.releaseOne()
        try await requireGate(gate) { try await task.value }
        XCTAssertTrue(finished.withLock { $0 })
    }

    func testReclaimKeepsTheOriginalTicketUntilTheRetryFinishes() async throws {
        let gate = FlushGate()
        await gate.setFailure(.reclaimOnce)
        await gate.setBlocking(false)
        let rig = makeIngress(gate: gate, mainApp: false)
        let observed = Mutex<[DiagnosticsJournalIngress.FlushWaitTestingSnapshot]>([])
        await gate.setAppendStarted { _ in
            let snapshot = rig.ingress.testingSnapshotForTesting()
            observed.withLock { $0.append(snapshot) }
        }
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let ticket = try XCTUnwrap(rig.ingress.testingSnapshotForTesting().queuedTickets.first)
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 2)
        let snapshots = observed.withLock { $0 }
        XCTAssertEqual(snapshots.count, 2)
        for snapshot in snapshots {
            XCTAssertEqual(snapshot.inFlightTickets, [ticket])
            XCTAssertNil(snapshot.ticketOutcomes[ticket])
        }
        XCTAssertEqual(rig.ingress.testingSnapshotForTesting().ticketOutcomes[ticket], .appended)
    }

    func testReclaimCannotRequeueAnOlderLifecycleAfterResume() async throws {
        let gate = FlushGate()
        await gate.setFailure(.reclaimOnce)
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let task = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        rig.ingress.suspendForExtensionLifecycle()
        XCTAssertEqual(rig.ingress.resumeForExtensionLifecycle(), 1)
        await gate.setBlocking(false)
        await gate.releaseOne()
        try await requireGate(gate) { try await task.value }
        rig.ingress.record(makeEvent(sequence: 2, processInstanceID: rig.processID))
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let snapshot = rig.ingress.testingSnapshotForTesting()
        XCTAssertEqual(snapshot.lifecycleCancelled, 1)
        XCTAssertTrue(snapshot.queuedTickets.isEmpty)
        let count = await gate.appendCount
        XCTAssertEqual(count, 2)
        let batches = await gate.submittedSequences
        XCTAssertEqual(batches, [[1], [2]])
    }

    func testCloseAfterReclaimDropsOriginalTicketBeforeRetry() async throws {
        let reached = expectation(description: "identity rotation started")
        let writer = ReclaimRotationGate(started: reached)
        defer { Task { await writer.release() } }
        let id = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp, processInstanceID: id, isMainAppWriter: false,
            rootURL: { URL(fileURLWithPath: "/unused-journal-test") },
            isCategoryEnabled: { _ in true }, flushDelay: 60
        )
        ingress.installBatchWriterFactoryForTesting { _ in writer }
        ingress.record(makeEvent(sequence: 1, processInstanceID: id))
        ingress.requestFlush()
        await fulfillment(of: [reached], timeout: 5)
        XCTAssertEqual(ingress.testingSnapshotForTesting().inFlightTickets, [1])
        ingress.suspendForExtensionLifecycle()
        XCTAssertEqual(ingress.resumeForExtensionLifecycle(), 1)
        ingress.record(makeEvent(sequence: 2, processInstanceID: id))
        await writer.release()
        let completed = expectation(description: "retry completed")
        let task = Task {
            await ingress.flushAndWaitForTesting()
            completed.fulfill()
        }
        await fulfillment(of: [completed], timeout: 5)
        task.cancel()
        let batches = await writer.batches
        XCTAssertEqual(batches, [[1], [2]])
        let snapshot = ingress.testingSnapshotForTesting()
        XCTAssertEqual(snapshot.lifecycleCancelled, 1)
        XCTAssertEqual(snapshot.appended, 1)
    }

    func testRequeueDropsTicketsThatDoNotFit() async throws {
        let gate = FlushGate()
        await gate.setFailure(.reclaimOnce)
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 0, processInstanceID: rig.processID))
        let task = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        for sequence in 1...DiagnosticsJournalIngress.maximumPendingEventCount {
            rig.ingress.record(makeEvent(sequence: UInt64(sequence), processInstanceID: rig.processID))
        }
        await gate.releaseOne()
        try await requireGate(gate) { try await task.value }
        try await requireGate(gate) { await gate.waitUntilAppendCount(1) }
    }

    func testLaterEventsDoNotDelayAnEarlierWaiter() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let firstFinished = Mutex(false)
        let secondFinished = Mutex(false)
        let first = Task {
            try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
            firstFinished.withLock { $0 = true }
        }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        rig.ingress.record(makeEvent(sequence: 2, processInstanceID: rig.processID))
        let second = Task {
            try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
            secondFinished.withLock { $0 = true }
        }
        await gate.releaseOne()
        try await requireGate(gate) { try await first.value }
        XCTAssertTrue(firstFinished.withLock { $0 })
        XCTAssertFalse(secondFinished.withLock { $0 })
        await gate.releaseOne()
        try await requireGate(gate) { try await second.value }
        XCTAssertTrue(secondFinished.withLock { $0 })
    }

    func testConcurrentWaitersBothFinishOnce() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let first = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        let second = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        await gate.releaseOne()
        try await requireGate(gate) { try await first.value }
        try await requireGate(gate) { try await second.value }
        let count = await gate.appendCount
        XCTAssertEqual(count, 1)
    }

    func testCancellationUnregistersTheWaiterAndLetsTheWriterFinish() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let task = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        task.cancel()
        try await requireGate(gate) { try await task.value }
        await gate.releaseOne()
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
    }

    func testCancellationRacesCompletionAndResumesOnce() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let completions = Mutex(0)
        let task = Task {
            try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
            completions.withLock { $0 += 1 }
        }
        await gate.setBeforeReturn { _ in
            task.cancel()
        }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        await gate.releaseOne()
        try await requireGate(gate) { try await task.value }
        let snapshot = rig.ingress.testingSnapshotForTesting()
        XCTAssertEqual(completions.withLock { $0 }, 1)
        XCTAssertEqual(snapshot.waiterCount, 0)
        XCTAssertEqual(snapshot.exclusiveResumeCount, 1)
    }

    func testFullRequeueDropsOnlyTheOverflowAndKeepsOriginalTickets() async throws {
        let gate = FlushGate()
        await gate.setFailure(.reclaimOnce)
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 0, processInstanceID: rig.processID))
        let task = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        let retryStarted = Latch()
        await gate.setAppendStarted { count in
            guard count == 2 else { return }
            Task { await retryStarted.fire() }
        }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        for sequence in 1...DiagnosticsJournalIngress.maximumPendingEventCount {
            rig.ingress.record(makeEvent(sequence: UInt64(sequence), processInstanceID: rig.processID))
        }
        await gate.releaseOne()
        try await requireGate(gate) { try await task.value }
        try await requireGate(gate) { await retryStarted.wait() }
        let snapshot = rig.ingress.testingSnapshotForTesting()
        XCTAssertEqual(snapshot.droppedWhileQueueFull, 1)
        XCTAssertEqual(snapshot.inFlightTickets, Array(UInt64(2)...UInt64(257)))
        await gate.releaseOne()
    }

    func testSecondRegisteredWaiterDoesNotLetLaterEventsDelayTheFirst() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let firstFinished = Mutex(false)
        let secondFinished = Mutex(false)
        let first = Task {
            try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
            firstFinished.withLock { $0 = true }
        }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        XCTAssertEqual(rig.ingress.testingSnapshotForTesting().waiterCount, 1)
        rig.ingress.record(makeEvent(sequence: 2, processInstanceID: rig.processID))
        let registered = Latch()
        rig.ingress.testingObserveWaiterCountForTesting { count in
            guard count == 2 else { return }
            Task { await registered.fire() }
        }
        let second = Task {
            try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
            secondFinished.withLock { $0 = true }
        }
        try await requireGate(gate) { await registered.wait() }
        rig.ingress.record(makeEvent(sequence: 3, processInstanceID: rig.processID))
        await gate.releaseOne()
        try await requireGate(gate) { try await first.value }
        XCTAssertTrue(firstFinished.withLock { $0 })
        XCTAssertFalse(secondFinished.withLock { $0 })
        await gate.releaseOne()
        try await requireGate(gate) { try await second.value }
        XCTAssertTrue(secondFinished.withLock { $0 })
        await gate.releaseOne()
    }

    func testTicketOverflowRejectsTheEventInsteadOfWrapping() async throws {
        let gate = FlushGate()
        await gate.setBlocking(false)
        let rig = makeIngress(gate: gate, mainApp: false)
        rig.ingress.testingSetNextTicketForTesting(UInt64.max)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() }
        let count = await gate.appendCount
        XCTAssertEqual(count, 0)
    }

    func testFlushDelayDoesNotDelayTheTestingBarrier() async throws {
        let gate = FlushGate()
        let rig = makeIngress(gate: gate, mainApp: false, flushDelay: 30)
        rig.ingress.record(makeEvent(sequence: 1, processInstanceID: rig.processID))
        let task = Task { try await requireFlush(gate) { await rig.ingress.flushAndWaitForTesting() } }
        try await requireGate(gate) { await gate.waitUntilStarted() }
        await gate.releaseOne()
        try await requireGate(gate) { try await task.value }
    }

    private func requireGate(
        _ gate: FlushGate,
        milliseconds: Int = 1000,
        _ body: @escaping @Sendable () async throws -> Void
    ) async throws {
        do {
            _ = try await flushBarrierValue(milliseconds: milliseconds) { _ in
                try await body()
                return true
            }
        } catch {
            await gate.unblockAfterTimeout()
            throw error
        }
    }

    func testHungBarrierFailsInsideBudgetAndPoisonsLaterAppends() async throws {
        let gate = FlushGate()
        let live = Mutex(0)
        let event = makeEvent(sequence: 1, processInstanceID: UUID())
        do {
            try await requireGate(gate, milliseconds: 1000) {
                live.withLock { $0 += 1 }
                defer { live.withLock { $0 -= 1 } }
                try await gate.append([event]) { true }
            }
            XCTFail("a hung barrier must fail inside the existing 1000ms budget")
        } catch is FlushBarrierBudgetExceeded {
        }
        // 协作式取消仍应清掉 live。helper 不再等待 body，所以这里单独等它退出。
        let cleanupStarted = DispatchTime.now()
        while live.withLock({ $0 }) != 0 {
            await Task.yield()
            if flushBarrierElapsedMilliseconds(since: cleanupStarted) > 1000 {
                break
            }
        }
        XCTAssertEqual(live.withLock { $0 }, 0)
        let abandoned = await gate.isAbandoned
        XCTAssertTrue(abandoned)
        let blockedBefore = await gate.blockedAppendCount
        try await gate.append([event]) { true }
        let blockedAfter = await gate.blockedAppendCount
        XCTAssertEqual(blockedAfter, blockedBefore)
    }

    private func makeIngress(
        gate: FlushGate,
        missingRoot: Bool = false,
        enabled: Bool = true,
        mainApp: Bool = false,
        flushDelay: TimeInterval = 0.25
    ) -> (ingress: DiagnosticsJournalIngress, processID: UUID) {
        let processID = UUID()
        let resolved: URL? = missingRoot ? nil : makeTemporaryDirectory()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: mainApp,
            rootURL: { resolved },
            isCategoryEnabled: { _ in enabled },
            flushDelay: flushDelay
        )
        ingress.installBatchWriterFactoryForTesting { _ in gate }
        return (ingress, processID)
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func makeEvent(sequence: UInt64, processInstanceID: UUID) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: Date(),
            monotonicNanoseconds: sequence,
            origin: .mainApp,
            processInstanceID: processInstanceID,
            localSequence: sequence,
            code: .journalStarted,
            level: .info,
            category: .general
        )
    }

    func testFlushBarrierTimeoutReportsActualBarrierStageWithoutWaiting() async throws {
        try await proveFlushBarrierTimeoutReportsBarrierStage()
    }

    func testFlushBarrierTimeoutDuringReadReportsReadStage() async throws {
        try await proveFlushBarrierTimeoutReportsReadStage()
    }

    func testRequireFlushAbandonsTheGateBeforeReturning() async throws {
        let gate = FlushGate()
        let hold = UncancellableHold()
        let started = DispatchTime.now()
        do {
            try await requireFlush(gate, milliseconds: 1000) {
                await hold.wait()
            }
            XCTFail("requireFlush must surface the existing budget error")
        } catch is FlushBarrierBudgetExceeded {
        }
        let elapsed = flushBarrierElapsedMilliseconds(since: started)
        XCTAssertGreaterThanOrEqual(elapsed, 1000)
        XCTAssertLessThan(elapsed, 1000 + flushBarrierSchedulingSlackMilliseconds)
        let abandoned = await gate.isAbandoned
        XCTAssertTrue(abandoned)
        let waiting = await hold.isWaiting
        XCTAssertTrue(waiting)
        await hold.release()
    }

    func testWaitUntilAppendCountReturnsWhenCancelled() async throws {
        let gate = FlushGate()
        let task = Task { await gate.waitUntilAppendCount(1) }
        try await Task.sleep(for: .milliseconds(20))
        task.cancel()
        let started = DispatchTime.now()
        _ = try await flushBarrierValue(milliseconds: 1000) { _ in
            await task.value
            return true
        }
        let elapsed = flushBarrierElapsedMilliseconds(since: started)
        XCTAssertLessThan(elapsed, 1000 + flushBarrierSchedulingSlackMilliseconds)
    }

}

/// 截止后先放弃 writer，再把错误抛回调用方。
/// flushBarrierValue 不再等待 body，所以这次放弃不会被卡住的写入挡住。
private func requireFlush(
    _ gate: FlushGate,
    milliseconds: Int = 1000,
    _ body: @escaping @Sendable () async -> Void
) async throws {
    do {
        _ = try await flushBarrierValue(milliseconds: milliseconds) { _ in
            await body()
            return true
        }
    } catch {
        await gate.unblockAfterTimeout()
        throw error
    }
}

private actor ReclaimRotationGate: DiagnosticsJournalBatchWriting {
    private let started: XCTestExpectation
    private var continuation: CheckedContinuation<Void, Never>?
    private var released = false
    private(set) var batches: [[UInt64]] = []

    init(started: XCTestExpectation) { self.started = started }
    func prepareRootIfOwnedByMainApp() async throws {}
    func append(_ events: [DiagnosticEvent], isWritePermitted: @escaping @Sendable () -> Bool) async throws {
        batches.append(events.map(\.localSequence))
        if batches.count == 1 { throw DiagnosticsJournalError.writerReclaimed }
        guard isWritePermitted() else { throw DiagnosticsJournalError.lifecycleCancelled }
    }
    func rotateIdentityAfterReclaim() async {
        await withCheckedContinuation { continuation in
            if released {
                continuation.resume()
            } else {
                self.continuation = continuation
                started.fulfill()
            }
        }
    }
    func release() {
        released = true
        continuation?.resume()
        continuation = nil
    }
}

private actor FlushGate: DiagnosticsJournalBatchWriting {
    enum Failure {
        case none
        case io
        case lifecycle
        case reclaimOnce
    }

    private var didStart = false
    private var abandoned = false
    private var startWaiters: [CheckedContinuation<Void, Never>] = []
    private var failure: Failure = .none
    private var blocking = true
    private var admitBeforeBlock = false
    private var prepareFailure = false
    private var blockers: [CheckedContinuation<Void, Never>] = []
    private(set) var appendCount = 0
    private(set) var submittedSequences: [[UInt64]] = []
    private(set) var blockedAppendCount = 0

    func setFailure(_ failure: Failure) {
        self.failure = failure
    }

    func setBlocking(_ blocking: Bool) {
        self.blocking = blocking
    }

    func setAdmitBeforeBlock(_ admitBeforeBlock: Bool) {
        self.admitBeforeBlock = admitBeforeBlock
    }

    func setPrepareFailure(_ prepareFailure: Bool) {
        self.prepareFailure = prepareFailure
    }

    var isAbandoned: Bool { abandoned }

    func waitUntilStarted() async {
        if didStart || abandoned { return }
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                Task { self.storeStartWaiter(continuation) }
            }
        } onCancel: {
            Task { await self.unblockAfterTimeout() }
        }
    }

    private func storeStartWaiter(_ continuation: CheckedContinuation<Void, Never>) {
        if didStart || abandoned {
            continuation.resume()
        } else {
            startWaiters.append(continuation)
        }
    }

    private var permits = 0
    private var appendStarted: (@Sendable (Int) -> Void)?
    private var beforeReturn: (@Sendable (Int) -> Void)?

    func setAppendStarted(_ probe: (@Sendable (Int) -> Void)?) {
        appendStarted = probe
    }

    func setBeforeReturn(_ probe: (@Sendable (Int) -> Void)?) {
        beforeReturn = probe
    }

    /// 超时失败时解开测试自己挂起的 continuation，避免 writer 一直占着测试进程。
    /// 放弃后释放当前等待者；之后的 append 不再进入阻塞。
    func unblockAfterTimeout() {
        abandoned = true
        didStart = true
        permits = 0
        let starts = startWaiters
        startWaiters.removeAll()
        starts.forEach { $0.resume() }
        let blocked = blockers
        blockers.removeAll()
        blocked.forEach { $0.resume() }
        let idle = idleWaiters
        idleWaiters.removeAll()
        idle.forEach { $0.resume() }
    }

    func releaseOne() {
        if abandoned { return }
        if blockers.isEmpty {
            // append 可能还没挂上 continuation。许可留到它开始等待时消费。
            permits += 1
        } else {
            blockers.removeFirst().resume()
        }
    }

    private func storeBlocker(_ continuation: CheckedContinuation<Void, Never>) {
        if abandoned || permits > 0 {
            if permits > 0 { permits -= 1 }
            continuation.resume()
        } else {
            blockers.append(continuation)
        }
    }

    private var idleWaiters: [CheckedContinuation<Void, Never>] = []

    func waitUntilAppendCount(_ count: Int) async {
        if appendCount >= count || abandoned { return }
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                Task { self.storeIdleWaiter(continuation, count: count) }
            }
        } onCancel: {
            Task { await self.unblockAfterTimeout() }
        }
    }

    /// 取消和登记撞在一起时，放弃标记让后到的 continuation 直接返回。
    private func storeIdleWaiter(_ continuation: CheckedContinuation<Void, Never>, count: Int) {
        if appendCount >= count || abandoned {
            continuation.resume()
        } else {
            idleWaiters.append(continuation)
        }
    }

    private func noteAppendFinished() {
        let waiters = idleWaiters
        idleWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }

    func prepareRootIfOwnedByMainApp() throws {
        if prepareFailure {
            throw DiagnosticsJournalError.ioFailure
        }
    }

    func rotateIdentityAfterReclaim() {}

    func append(
        _ events: [DiagnosticEvent],
        isWritePermitted: @escaping @Sendable () -> Bool
    ) async throws {
        appendCount += 1
        submittedSequences.append(events.map(\.localSequence))
        if abandoned {
            didStart = true
            noteAppendFinished()
            return
        }
        let started = appendStarted
        let count = appendCount
        defer { noteAppendFinished() }
        started?(count)
        if admitBeforeBlock {
            _ = isWritePermitted()
        }
        didStart = true
        let waiting = startWaiters
        startWaiters.removeAll()
        waiting.forEach { $0.resume() }
        if abandoned {
            return
        }
        if permits > 0 {
            permits -= 1
        } else if blocking {
            blockedAppendCount += 1
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    Task { self.storeBlocker(continuation) }
                }
            } onCancel: {
                Task { await self.unblockAfterTimeout() }
            }
        }
        if case .reclaimOnce = failure {
            failure = .none
            throw DiagnosticsJournalError.writerReclaimed
        }
        if !admitBeforeBlock {
            guard isWritePermitted() else {
                throw DiagnosticsJournalError.lifecycleCancelled
            }
        }
        let returning = beforeReturn
        returning?(count)
        switch failure {
        case .none:
            return
        case .io:
            throw DiagnosticsJournalError.ioFailure
        case .lifecycle:
            throw DiagnosticsJournalError.lifecycleCancelled
        case .reclaimOnce:
            failure = .none
            throw DiagnosticsJournalError.writerReclaimed
        }
    }
}

private struct FlushBarrierBudgetExceeded: Error, CustomStringConvertible {
    let stage: String
    let barrierReturned: Bool
    let readStarted: Bool
    let elapsedMilliseconds: Int

    var description: String {
        "stage=\(stage) barrierReturned=\(barrierReturned) readStarted=\(readStarted) elapsedMilliseconds=\(elapsedMilliseconds) eventCount=unavailable"
    }
}

/// 调度余量只吸收 actor 跳转和机器负载，不改变调用方传入的截止预算。
/// body 在计时断言之后才被释放。helper 若仍等待 body，断言不会执行。
private let flushBarrierSchedulingSlackMilliseconds = 1000

private func flushBarrierElapsedMilliseconds(since start: DispatchTime) -> Int {
    Int((DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000)
}

/// body 在返回前写下真实阶段。超时错误读这份状态，不写死屏障结果或预算。
private struct FlushBarrierStageState: Sendable {
    var barrierReturned = false
    var readStarted = false
}

private final class FlushBarrierStageBox: Sendable {
    private let state = Mutex(FlushBarrierStageState())

    func markBarrierReturned() {
        state.withLock { $0.barrierReturned = true }
    }

    func markReadStarted() {
        state.withLock { $0.readStarted = true }
    }

    func snapshot() -> (barrierReturned: Bool, readStarted: Bool) {
        state.withLock { ($0.barrierReturned, $0.readStarted) }
    }
}

private struct FlushBarrierStageReporter: Sendable {
    fileprivate let box: FlushBarrierStageBox

    func markBarrierReturned() {
        box.markBarrierReturned()
    }

    func markReadStarted() {
        box.markReadStarted()
    }
}

/// 墙钟截止不依赖 body 协作。结果槽先到先得。
/// 超时一方胜出后立即抛错返回，并取消 body，但不等待它结束。
/// 放弃的代价：失败路径上可能残留一个已取消、仍停在不可取消操作上的任务。
/// 这只发生在这次等待已经失败之后，不能挡住调用方。测试要在断言后释放自己的信号。
private actor FlushBarrierOneShot<T: Sendable> {
    private var continuation: CheckedContinuation<Result<T, Error>, Never>?
    private var value: Result<T, Error>?

    func store(_ continuation: CheckedContinuation<Result<T, Error>, Never>) {
        if let value {
            continuation.resume(returning: value)
        } else {
            self.continuation = continuation
        }
    }

    func finish(_ value: Result<T, Error>) {
        guard self.value == nil else { return }
        self.value = value
        continuation?.resume(returning: value)
        continuation = nil
    }
}

private func flushBarrierValue<T: Sendable>(
    milliseconds: Int,
    _ body: @escaping @Sendable (FlushBarrierStageReporter) async throws -> T
) async throws -> T {
    let started = DispatchTime.now()
    let stage = FlushBarrierStageBox()
    let reporter = FlushBarrierStageReporter(box: stage)
    let shot = FlushBarrierOneShot<T>()
    let bodyTask = Task {
        do {
            let value = try await body(reporter)
            await shot.finish(.success(value))
        } catch {
            await shot.finish(.failure(error))
        }
    }
    let sleepTask = Task {
        do {
            try await Task.sleep(for: .milliseconds(milliseconds))
        } catch {
            // 调用方已经拿到结果后会取消睡眠。被取消时不能再写一个超时。
            return
        }
        let snapshot = stage.snapshot()
        let failureStage: String
        if snapshot.readStarted {
            failureStage = "read-timeout"
        } else if snapshot.barrierReturned {
            failureStage = "post-barrier-timeout"
        } else {
            failureStage = "barrier-timeout"
        }
        await shot.finish(
            .failure(
                FlushBarrierBudgetExceeded(
                    stage: failureStage,
                    barrierReturned: snapshot.barrierReturned,
                    readStarted: snapshot.readStarted,
                    elapsedMilliseconds: flushBarrierElapsedMilliseconds(since: started)
                )
            )
        )
    }
    let outcome: Result<T, Error> = await withTaskCancellationHandler {
        await withCheckedContinuation { continuation in
            Task { await shot.store(continuation) }
        }
    } onCancel: {
        bodyTask.cancel()
    }
    bodyTask.cancel()
    sleepTask.cancel()
    return try outcome.get()
}

/// 不观察取消。用来证明截止不取决于 body 自己退出。
private actor UncancellableHold {
    private var continuation: CheckedContinuation<Void, Never>?
    private var released = false

    var isWaiting: Bool {
        continuation != nil
    }

    func wait() async {
        if released { return }
        await withCheckedContinuation { continuation in
            Task { self.store(continuation) }
        }
    }

    func release() {
        released = true
        continuation?.resume()
        continuation = nil
    }

    private func store(_ continuation: CheckedContinuation<Void, Never>) {
        if released {
            continuation.resume()
        } else {
            self.continuation = continuation
        }
    }
}

private func proveFlushBarrierTimeoutReportsBarrierStage() async throws {
    let hold = UncancellableHold()
    let started = DispatchTime.now()
    do {
        _ = try await flushBarrierValue(milliseconds: 1000) { _ in
            await hold.wait()
            return 0
        }
        XCTFail("an uncancellable barrier must fail inside the existing 1000ms budget")
    } catch let error as FlushBarrierBudgetExceeded {
        let wall = flushBarrierElapsedMilliseconds(since: started)
        XCTAssertEqual(error.stage, "barrier-timeout")
        XCTAssertFalse(error.barrierReturned)
        XCTAssertFalse(error.readStarted)
        XCTAssertGreaterThanOrEqual(error.elapsedMilliseconds, 1000)
        XCTAssertGreaterThanOrEqual(wall, 1000)
        XCTAssertLessThan(wall, 1000 + flushBarrierSchedulingSlackMilliseconds)
        XCTAssertGreaterThanOrEqual(wall, error.elapsedMilliseconds)
    } catch {
        XCTFail("unexpected error \(error)")
    }
    let waiting = await hold.isWaiting
    XCTAssertTrue(waiting)
    await hold.release()
}

private func proveFlushBarrierTimeoutReportsReadStage() async throws {
    let hold = UncancellableHold()
    let started = DispatchTime.now()
    do {
        _ = try await flushBarrierValue(milliseconds: 1000) { stage in
            stage.markBarrierReturned()
            stage.markReadStarted()
            await hold.wait()
            return 0
        }
        XCTFail("a read that ignores cancellation must fail inside the existing 1000ms budget")
    } catch let error as FlushBarrierBudgetExceeded {
        let wall = flushBarrierElapsedMilliseconds(since: started)
        XCTAssertEqual(error.stage, "read-timeout")
        XCTAssertTrue(error.barrierReturned)
        XCTAssertTrue(error.readStarted)
        XCTAssertGreaterThanOrEqual(error.elapsedMilliseconds, 1000)
        XCTAssertGreaterThanOrEqual(wall, 1000)
        XCTAssertLessThan(wall, 1000 + flushBarrierSchedulingSlackMilliseconds)
        XCTAssertGreaterThanOrEqual(wall, error.elapsedMilliseconds)
    } catch {
        XCTFail("unexpected error \(error)")
    }
    let waiting = await hold.isWaiting
    XCTAssertTrue(waiting)
    await hold.release()
}

private actor Latch {
    private var continuation: CheckedContinuation<Void, Never>?
    private var fired = false

    func wait() async {
        if fired { return }
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                Task { self.store(continuation) }
            }
        } onCancel: {
            Task { await self.abandon() }
        }
    }

    private func store(_ continuation: CheckedContinuation<Void, Never>) {
        if fired {
            continuation.resume()
        } else {
            self.continuation = continuation
        }
    }

    func fire() {
        fired = true
        continuation?.resume()
        continuation = nil
    }

    func abandon() {
        fired = true
        continuation?.resume()
        continuation = nil
    }
}
