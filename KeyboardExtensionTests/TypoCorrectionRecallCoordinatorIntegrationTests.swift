import Foundation
import Synchronization
import XCTest

#if DEBUG
    @testable import KeyboardCore
#else
    import KeyboardCore
#endif

nonisolated final class TypoCorrectionRecallCoordinatorIntegrationTests: XCTestCase {
    @MainActor
    func testReadyEmptyResultsRecordOneTypedEventAcrossBothStages() async {
        let input = "wimenjintianquhongyuan"
        let readyEmpty = TypoCorrectionCandidateQueryResult(
            readiness: .ready,
            state: .candidatesReturned,
            candidates: []
        )
        let expectedStages = readyEmptyDriverStageTrace(for: input)
        let rig = makeCoordinatorRig(input: input, result: readyEmpty)

        XCTAssertFalse(rig.coordinator.testingHooksAreInstalled)
        rig.coordinator.installTestingHooks(testingHooks(for: rig.recorder))
        rig.coordinator.startOperationForTesting(expectedComposition: input)
        resumeAllYieldedTurns(rig.recorder)

        XCTAssertEqual(rig.query.invocationCount, rig.recorder.payloads.count)
        XCTAssertEqual(rig.query.invocationCount, expectedStages.count)
        XCTAssertEqual(rig.recorder.payloads.map(\.stage), expectedStages)
        XCTAssertTrue(expectedStages.contains(.stageOne))
        XCTAssertTrue(expectedStages.contains(.stageTwo))
        XCTAssertTrue(
            rig.recorder.payloads.allSatisfy {
                $0.readiness == .ready
                    && $0.resultState == .candidatesReturned
                    && $0.returnedCandidateBucket == .zero
            }
        )
        XCTAssertEqual(Set(rig.recorder.payloads.map(\.operationOrdinal)).count, 1)
        XCTAssertEqual(
            rig.recorder.codes.filter { $0 == .typoRecallQueryMeasured }.count,
            rig.query.invocationCount
        )
        XCTAssertFalse(rig.recorder.codes.contains(.typoRecallQueryBegin))
        XCTAssertFalse(rig.recorder.codes.contains(.typoRecallQueryOutcome))
    }

    @MainActor
    func testHostCallbackPersistsMeasuredQueriesThroughTypedJournalRuntime() async throws {
        let input = "wimenjintianquhongyuan"
        let expectedStages = readyEmptyDriverStageTrace(for: input)
        let rootURL = journalTemporaryBase()
            .appendingPathComponent("TypoRecallJournal-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        defer { cleanupJournalRoot(rootURL) }

        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()

        let runtime = DiagnosticsJournalRuntime(
            origin: .keyboardExtension,
            isMainAppWriter: false,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )
        let rig = makeCoordinatorRig(
            input: input,
            result: readyEmptyResult,
            diagnosticsRuntime: runtime
        )
        rig.coordinator.installTestingHooks(
            testingHooks(for: rig.recorder, includeMeasuredHook: false)
        )

        rig.coordinator.startOperationForTesting(expectedComposition: input)
        resumeAllYieldedTurns(rig.recorder)

        XCTAssertEqual(rig.query.invocationCount, expectedStages.count)
        XCTAssertTrue(rig.recorder.payloads.isEmpty, "the coordinator hook must remain unset")
        XCTAssertEqual(rig.host.measuredPayloads.map(\.stage), expectedStages)
        XCTAssertEqual(rig.host.measuredPayloads.count, rig.query.invocationCount)

        let snapshot = try await waitForMeasuredQueryEvents(
            runtime: runtime,
            at: rootURL,
            expectedCount: rig.query.invocationCount
        )
        let queryEvents = snapshot.events
            .filter { $0.code == .typoRecallQueryMeasured }
            .sorted { $0.localSequence < $1.localSequence }
        let journalPayloads = queryEvents.compactMap { event -> DiagnosticEvent.TypoRecallQueryPayload? in
            guard event.fields.count == 1,
                case .typoRecallQuery(let payload) = event.fields[0]
            else {
                return nil
            }
            return payload
        }

        XCTAssertEqual(queryEvents.count, rig.query.invocationCount)
        XCTAssertEqual(journalPayloads, rig.host.measuredPayloads)
        XCTAssertEqual(journalPayloads.map(\.stage), expectedStages)
        XCTAssertFalse(
            snapshot.events.contains {
                $0.code == .typoRecallQueryBegin || $0.code == .typoRecallQueryOutcome
            }
        )
    }

    @MainActor
    func testPreCallInvalidationSkipsFacadeAndMeasuredEvent() async {
        let rig = makeCoordinatorRig(
            input: "wimenjintianquhongyuan",
            result: readyEmptyResult
        )
        var hooks = testingHooks(for: rig.recorder)
        hooks.beforeQueryFenceCheck = { [coordinator = rig.coordinator] in
            coordinator.invalidateTypoCorrectionRecall()
        }
        rig.coordinator.installTestingHooks(hooks)

        rig.coordinator.startOperationForTesting(expectedComposition: "wimenjintianquhongyuan")

        XCTAssertEqual(rig.query.invocationCount, 0)
        XCTAssertTrue(rig.recorder.payloads.isEmpty)
        XCTAssertFalse(rig.recorder.codes.contains(.typoRecallQueryMeasured))
        XCTAssertTrue(rig.recorder.codes.contains(.typoRecallFenceDiscarded))
        XCTAssertTrue(rig.recorder.pendingTurns.isEmpty)
    }

    @MainActor
    func testPostCallInvalidationRecordsOneDiscardedFacadeEvent() async {
        let rig = makeCoordinatorRig(
            input: "wimenjintianquhongyuan",
            result: readyEmptyResult
        )
        let coordinator = rig.coordinator
        rig.query.onInvocation = {
            coordinator.invalidateTypoCorrectionRecall()
        }
        defer { rig.query.onInvocation = nil }
        rig.coordinator.installTestingHooks(testingHooks(for: rig.recorder))

        rig.coordinator.startOperationForTesting(expectedComposition: "wimenjintianquhongyuan")
        resumeAllYieldedTurns(rig.recorder)

        XCTAssertEqual(rig.query.invocationCount, 1)
        XCTAssertEqual(rig.recorder.payloads.count, 1)
        XCTAssertEqual(rig.recorder.payloads.first?.disposition, .discardedAfterFacade)
        XCTAssertEqual(
            rig.recorder.codes.filter { $0 == .typoRecallQueryMeasured }.count,
            1
        )
        XCTAssertTrue(rig.recorder.pendingTurns.isEmpty)
    }

    @MainActor
    func testRefreshHookKeepsCandidateBarOutsideTheTestRuntime() async {
        let candidateResult = TypoCorrectionCandidateQueryResult(
            readiness: .ready,
            state: .candidatesReturned,
            candidates: [RimeCandidate(text: "synthetic")]
        )
        let input = "wimenjintianquhongyuan"
        let rig = makeCoordinatorRig(input: input, result: candidateResult)
        rig.coordinator.installTestingHooks(testingHooks(for: rig.recorder))

        rig.coordinator.startOperationForTesting(expectedComposition: input)
        resumeAllYieldedTurns(rig.recorder)

        XCTAssertEqual(rig.recorder.refreshCount, 1)
        XCTAssertTrue(rig.query.invocationCount > 0)
    }

    #if DEBUG && KEYBOARD_QUERY_COST_PROBE && KEYBOARD_QUERY_COST_PROBE_TESTING
        @MainActor func testMemoryProbeRecordsEveryRealFacadeCallWithoutChangingStageTrace() async throws {
            let input = "wimenjintianquhongyuan"
            let rig = makeCoordinatorRig(input: input, result: readyEmptyResult)
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting(now: { 100 })
            XCTAssertTrue(rig.coordinator.installSyntheticQueryCostProbeForTesting(probe))
            XCTAssertEqual(
                probe.arm(
                    .init(
                        coordinatorOrdinal: rig.coordinator.probeCoordinatorOrdinal,
                        facade: try XCTUnwrap(rig.host.queryCostDebugFacadeScope()), fullAccess: true), eligible: true),
                .armed)
            XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true))
            rig.coordinator.installTestingHooks(testingHooks(for: rig.recorder))
            rig.coordinator.startOperationForTesting(expectedComposition: input)
            XCTAssertFalse(rig.coordinator.queryCostCallbacksQuiescent)
            resumeAllYieldedTurns(rig.recorder)
            XCTAssertTrue(rig.coordinator.queryCostCallbacksQuiescent)
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertFalse(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.queryCount, UInt64(rig.query.invocationCount))
            XCTAssertEqual(rig.recorder.payloads.map(\.stage), readyEmptyDriverStageTrace(for: input))
            XCTAssertEqual(snapshot.words[23...25], [1, 1, 0])
            let decoded = snapshot.withUnsafeBytes { QueryCostMemoryProbe.decode(Array($0)) }
            XCTAssertEqual(decoded, snapshot)
        }
        @MainActor func testMemoryPreFenceAndPostFenceKeepActualFacadeCounts() async throws {
            for preFence in [true, false] {
                let input = "wimenjintianquhongyuan"
                let rig = makeCoordinatorRig(input: input, result: readyEmptyResult)
                let probe = QueryCostMemoryProbe.makeSyntheticForTesting(now: { 100 })
                XCTAssertTrue(rig.coordinator.installSyntheticQueryCostProbeForTesting(probe))
                XCTAssertEqual(
                    probe.arm(
                        .init(
                            coordinatorOrdinal: rig.coordinator.probeCoordinatorOrdinal,
                            facade: try XCTUnwrap(rig.host.queryCostDebugFacadeScope()), fullAccess: true),
                        eligible: true),
                    .armed)
                XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true))
                var hooks = testingHooks(for: rig.recorder)
                if preFence {
                    hooks.beforeQueryFenceCheck = { rig.coordinator.invalidateTypoCorrectionRecall() }
                } else {
                    rig.query.onInvocation = { rig.coordinator.invalidateTypoCorrectionRecall() }
                }
                rig.coordinator.installTestingHooks(hooks)
                rig.coordinator.startOperationForTesting(expectedComposition: input)
                resumeAllYieldedTurns(rig.recorder)
                rig.query.onInvocation = nil
                XCTAssertTrue(probe.endSequence(eligible: true))
                let snapshot = try XCTUnwrap(probe.freeze())
                XCTAssertEqual(snapshot.queryCount, preFence ? 0 : 1)
                XCTAssertEqual(snapshot.queryCount, UInt64(rig.query.invocationCount))
                XCTAssertEqual(rig.recorder.payloads.count, rig.query.invocationCount)
                XCTAssertEqual(snapshot.words[25], 0)
            }
        }
        @MainActor func testReentrantAEndsBEndsThenAOuterCleanupHasExactlyTwoTerminals() throws {
            let input = "wimenjintianquhongyuan"
            let rig = makeCoordinatorRig(input: input, result: readyEmptyResult)
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting(now: { 100 })
            XCTAssertTrue(rig.coordinator.installSyntheticQueryCostProbeForTesting(probe))
            XCTAssertEqual(
                probe.arm(
                    .init(
                        coordinatorOrdinal: rig.coordinator.probeCoordinatorOrdinal,
                        facade: try XCTUnwrap(rig.host.queryCostDebugFacadeScope()), fullAccess: true), eligible: true),
                .armed)
            XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true))
            rig.coordinator.installTestingHooks(testingHooks(for: rig.recorder))
            rig.query.onInvocation = {
                // A is still inside its synchronous fake facade. End A, finish all
                // of B, then return to A's stale post-fence cleanup without recursion.
                rig.query.onInvocation = nil
                rig.coordinator.invalidateTypoCorrectionRecall()
                rig.coordinator.startOperationForTesting(expectedComposition: input)
                self.resumeAllYieldedTurns(rig.recorder)
            }
            rig.coordinator.startOperationForTesting(expectedComposition: input)
            XCTAssertTrue(rig.coordinator.queryCostCallbacksQuiescent)
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertFalse(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[23...25], [2, 2, 0])
            XCTAssertEqual(snapshot.queryCount, UInt64(rig.query.invocationCount))
            let terminals = stride(from: 32, to: snapshot.words.count, by: 20).filter {
                snapshot.words[$0] == 4
            }
            XCTAssertEqual(terminals.map { snapshot.words[$0 + 6] }, [1, 2])
            XCTAssertEqual(terminals.map { snapshot.words[$0 + 15] }, [2, 1])
            XCTAssertEqual(snapshot.withUnsafeBytes { QueryCostMemoryProbe.decode(Array($0)) }, snapshot)
        }
        @MainActor func testProductionProbeCannotBeInjectedThroughTheSyntheticTestSeam() {
            let rig = makeCoordinatorRig(input: "nihao", result: readyEmptyResult)
            XCTAssertTrue(rig.coordinator.queryCostProbe === QueryCostMemoryProbe.shared)
            XCTAssertFalse(rig.coordinator.installSyntheticQueryCostProbeForTesting(.shared))
            XCTAssertTrue(rig.coordinator.queryCostProbe === QueryCostMemoryProbe.shared)
        }
        @MainActor func testInvalidatedYieldRemainsPendingUntilItsNaturalStaleBodyReturns() async throws {
            let input = "wimenjintianquhongyuan"
            let rig = makeCoordinatorRig(input: input, result: readyEmptyResult)
            rig.coordinator.installTestingHooks(testingHooks(for: rig.recorder))
            rig.coordinator.startOperationForTesting(expectedComposition: input)
            XCTAssertFalse(rig.recorder.pendingTurns.isEmpty)
            rig.coordinator.invalidateTypoCorrectionRecall()
            XCTAssertFalse(rig.coordinator.queryCostCallbacksQuiescent)
            let count = rig.query.invocationCount
            resumeAllYieldedTurns(rig.recorder)
            XCTAssertEqual(rig.query.invocationCount, count)
            XCTAssertTrue(rig.coordinator.queryCostCallbacksQuiescent)
        }
    #endif

    @MainActor
    private var readyEmptyResult: TypoCorrectionCandidateQueryResult {
        TypoCorrectionCandidateQueryResult(
            readiness: .ready,
            state: .candidatesReturned,
            candidates: []
        )
    }

    @MainActor
    private func makeCoordinatorRig(
        input: String,
        result: TypoCorrectionCandidateQueryResult,
        diagnosticsRuntime: DiagnosticsJournalRuntime? = nil
    ) -> CoordinatorRig {
        let host = TestRecallHost(
            controller: KeyboardController(state: KeyboardState(currentComposition: input)),
            diagnosticsRuntime: diagnosticsRuntime
        )
        let query = RecordingQuery(result: result)
        let owner = InstalledTypoCorrectionSidecarOwner(query: query)
        host.controller.typoCorrectionCandidateQuery = owner

        let coordinator = TypoCorrectionRecallCoordinator(host: host)
        owner.recallInvalidation = coordinator
        return CoordinatorRig(
            host: host,
            coordinator: coordinator,
            query: query,
            recorder: CoordinatorRecorder()
        )
    }

    @MainActor
    private func testingHooks(
        for recorder: CoordinatorRecorder,
        includeMeasuredHook: Bool = true
    ) -> TypoCorrectionRecallCoordinator.TestingHooks {
        let recordQueryMeasured: (@MainActor (DiagnosticEvent.TypoRecallQueryPayload) -> Void)?
        if includeMeasuredHook {
            recordQueryMeasured = { payload in
                recorder.payloads.append(payload)
                recorder.codes.append(.typoRecallQueryMeasured)
            }
        } else {
            recordQueryMeasured = nil
        }

        return TypoCorrectionRecallCoordinator.TestingHooks(
            recordQueryMeasured: recordQueryMeasured,
            recordMarker: { code in
                recorder.codes.append(code)
            },
            scheduleYieldedTurn: { continuation in
                recorder.pendingTurns.append(continuation)
            },
            refreshCandidateBar: {
                recorder.refreshCount += 1
            }
        )
    }

    @MainActor
    private func readyEmptyDriverStageTrace(for input: String) -> [TypoCorrectionRecallStage] {
        let controller = KeyboardController(state: KeyboardState(currentComposition: input))
        let token = TypoCorrectionRecallFenceSnapshot(
            recallEpoch: 1,
            compositionRevision: 1,
            operationOrdinal: 1,
            normalizedComposition: input.lowercased(),
            page: .letters,
            inputMode: .chinese,
            routeLocalOwnerEpoch: nil
        )
        let hypotheses = controller.typoCorrectionStageOneHypotheses(
            for: token.normalizedComposition,
            includingContextual: true
        )
        var driver = TypoCorrectionRecallDriver(token: token, stageOneHypotheses: hypotheses)
        var stages: [TypoCorrectionRecallStage] = []
        var event = driver.nextEvent(currentFence: token)

        // Include coverage assessment and terminal apply events after the query stages.
        for _ in 0..<34 {
            switch event {
            case .query(let query):
                stages.append(query.stage)
                guard case .waitForYield = driver.finishQuery(currentFence: token, candidates: []) else {
                    XCTFail("ready-empty driver query must yield")
                    return stages
                }
                guard driver.acknowledgeYield(currentFence: token) else {
                    XCTFail("ready-empty driver yield must be acknowledged")
                    return stages
                }
                event = driver.nextEvent(currentFence: token)
            case .waitForYield:
                guard driver.acknowledgeYield(currentFence: token) else {
                    XCTFail("ready-empty driver must have a pending yield")
                    return stages
                }
                event = driver.nextEvent(currentFence: token)
            case .assessCoverage:
                event = driver.completeCoverageAssessment(
                    currentFence: token,
                    acceptedDisplayCount: 0
                )
            case .readyToApply:
                return stages
            case .discarded:
                XCTFail("unchanged ready-empty driver fence must not be discarded")
                return stages
            }
        }

        XCTFail("ready-empty driver trace must stay bounded")
        return stages
    }

    @MainActor
    private func waitForMeasuredQueryEvents(
        runtime: DiagnosticsJournalRuntime,
        at rootURL: URL,
        expectedCount: Int
    ) async throws -> DiagnosticsJournalSnapshot {
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        #if DEBUG
            let started = DispatchTime.now()
            return try await flushBarrierValue(milliseconds: 1000, rootURL: rootURL) { stage in
                let before = runtime.testingFlushSnapshotForTesting()
                await runtime.flushAndWaitForTesting()
                let after = runtime.testingFlushSnapshotForTesting()
                print(
                    "R4_DIAG accepted=\(before.accepted) appended=\(after.appended) filtered=\(after.filtered) dropped=\(after.dropped) lifecycle=\(after.lifecycleCancelled)"
                )
                stage.markBarrierReturned()
                stage.markReadStarted()
                return try await readAndCheckMeasuredCount(
                    started: started, expectedCount: expectedCount,
                    diagnostics:
                        "accepted=\(before.accepted) appended=\(after.appended) filtered=\(after.filtered) dropped=\(after.dropped) lifecycle=\(after.lifecycleCancelled)"
                ) {
                    let snapshot = try await reader.latest()
                    let count = snapshot.events.filter { $0.code == .typoRecallQueryMeasured }.count
                    print("R4_READ eventCount=\(count)")
                    return (snapshot, count)
                }
            }
        #else
            for _ in 0..<50 {
                let snapshot = try await reader.latest()
                let measuredCount = snapshot.events.filter { $0.code == .typoRecallQueryMeasured }.count
                if measuredCount == expectedCount {
                    return snapshot
                }
                try await Task.sleep(for: .milliseconds(20))
            }
            XCTFail("timed out waiting for typed query-measured journal events")
            return try await reader.latest()
        #endif
    }

    @MainActor
    private func resumeAllYieldedTurns(_ recorder: CoordinatorRecorder) {
        var turnCount = 0
        while !recorder.pendingTurns.isEmpty {
            turnCount += 1
            XCTAssertLessThanOrEqual(turnCount, 32, "the controlled driver must remain bounded")
            recorder.pendingTurns.removeFirst()()
        }
    }

    func testMismatchElapsedIncludesDelayedRead() async throws {
        let started = DispatchTime.now()
        do {
            _ = try await readAndCheckMeasuredCount(started: started, expectedCount: 1, diagnostics: "fixture") {
                try await Task.sleep(for: .milliseconds(100))
                return (true, 0)
            }
            XCTFail("数量不符应抛错")
        } catch let error as JournalObservationMismatch {
            XCTAssertGreaterThanOrEqual(error.elapsedMilliseconds, 100)
        }
    }

    func testAbandonedBodyRetainsRootAndSuccessCleansRoot() async throws {
        let base = journalTemporaryBase()
        let retained = base.appendingPathComponent("flush-r5-retained-\(UUID().uuidString)")
        let cleaned = base.appendingPathComponent("flush-r5-cleaned-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: retained, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: cleaned, withIntermediateDirectories: true)
        let hold = UncancellableHold()
        do {
            _ = try await flushBarrierValue(milliseconds: 1000, rootURL: retained) { _ in
                await hold.wait()
                return true
            }
            XCTFail("不可取消的读取应触发截止")
        } catch let error as FlushBarrierBudgetExceeded {
            XCTAssertEqual(error.retainedDirectory, retained.path)
            XCTAssertTrue(error.description.contains(retained.path))
        }
        cleanupJournalRoot(retained)
        XCTAssertTrue(FileManager.default.fileExists(atPath: retained.path))
        cleanupJournalRoot(cleaned)
        XCTAssertFalse(FileManager.default.fileExists(atPath: cleaned.path))
        await hold.release()
        try FileManager.default.removeItem(at: retained)
    }

    func testFlushBarrierTimeoutReportsActualBarrierStageWithoutWaiting() async throws {
        try await proveFlushBarrierTimeoutReportsBarrierStage()
    }

    func testFlushBarrierTimeoutDuringReadReportsReadStage() async throws {
        try await proveFlushBarrierTimeoutReportsReadStage()
    }
}

@MainActor
private struct CoordinatorRig {
    let host: TestRecallHost
    let coordinator: TypoCorrectionRecallCoordinator
    let query: RecordingQuery
    let recorder: CoordinatorRecorder
}

@MainActor
private final class TestRecallHost: TypoCorrectionRecallCoordinatorHost {
    let controller: KeyboardController!
    var contextualTypoCorrectionWorkItem: DispatchWorkItem?
    var recallEpoch: UInt64 = 0
    var recallCompositionRevision: UInt64 = 0
    let isHighFidelityDiagnosticsActive = true
    let diagnosticsAppearanceID: UUID? = UUID()
    #if DEBUG && KEYBOARD_QUERY_COST_PROBE && KEYBOARD_QUERY_COST_PROBE_TESTING
        var queryCostDebugFullAccess: Bool { true }
        func queryCostDebugFacadeScope() -> QueryCostMemoryProbe.FacadeScope? {
            .init(kind: .nativeCorrectionSession, facadeOrdinal: 1, lifetimeOrdinal: 1, schema: .lunaPinyin)
        }
    #endif
    private let diagnosticsRuntime: DiagnosticsJournalRuntime?
    private(set) var measuredPayloads: [DiagnosticEvent.TypoRecallQueryPayload] = []

    init(
        controller: KeyboardController,
        diagnosticsRuntime: DiagnosticsJournalRuntime? = nil
    ) {
        self.controller = controller
        self.diagnosticsRuntime = diagnosticsRuntime
    }

    func recordTypoRecallQueryMeasured(_ payload: DiagnosticEvent.TypoRecallQueryPayload) {
        measuredPayloads.append(payload)
        diagnosticsRuntime?.record(
            code: .typoRecallQueryMeasured,
            category: .performance,
            appearanceID: diagnosticsAppearanceID,
            fields: [.typoRecallQuery(payload)]
        )
    }

    func recordTypoRecallMarker(
        code: DiagnosticEvent.Code,
        recallEpoch: UInt64,
        compositionRevision: UInt64,
        operationOrdinal: UInt64,
        normalizedComposition: String
    ) {}

    func refreshCandidateBar() {}
}

@MainActor
private final class CoordinatorRecorder {
    var payloads: [DiagnosticEvent.TypoRecallQueryPayload] = []
    var codes: [DiagnosticEvent.Code] = []
    var pendingTurns: [@MainActor () -> Void] = []
    var refreshCount = 0
}

private final class RecordingQuery: TypoCorrectionCandidateQuerying {
    private let result: TypoCorrectionCandidateQueryResult
    private(set) var invocationCount = 0
    var onInvocation: (@MainActor () -> Void)?

    init(result: TypoCorrectionCandidateQueryResult) {
        self.result = result
    }

    func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        correctionQueryResult(for: input, limit: limit).candidates
    }

    func correctionQueryResult(for input: String, limit: Int) -> TypoCorrectionCandidateQueryResult {
        MainActor.assumeIsolated {
            invocationCount += 1
            onInvocation?()
            return result
        }
    }
}

private struct FlushBarrierBudgetExceeded: Error, CustomStringConvertible {
    let stage: String
    let barrierReturned: Bool
    let readStarted: Bool
    let elapsedMilliseconds: Int
    let retainedDirectory: String?

    var description: String {
        "stage=\(stage) barrierReturned=\(barrierReturned) readStarted=\(readStarted) elapsedMilliseconds=\(elapsedMilliseconds) eventCount=unavailable retainedDirectory=\(retainedDirectory ?? "none")"
    }
}

private struct JournalObservationMismatch: Error, CustomStringConvertible {
    let stage: String
    let barrierReturned: Bool
    let elapsedMilliseconds: Int
    let eventCount: Int
    let diagnostics: String
    var description: String {
        "stage=\(stage) barrierReturned=\(barrierReturned) elapsedMilliseconds=\(elapsedMilliseconds) eventCount=\(eventCount) \(diagnostics); 正常完成只证明终结，取消不证明终结，reader 可见性不保证；快照非原子且非逐 ticket 或屏障上界，不能以总数相等推断覆盖；计数按首个终结原因归类，dropped 合并多种原因并非物理 I/O 审计；历史零条与合同相容但违反数量断言，根因 UNKNOWN"
    }
}

nonisolated private func readAndCheckMeasuredCount<T: Sendable>(
    started: DispatchTime, expectedCount: Int, diagnostics: String,
    read: @Sendable () async throws -> (T, Int)
) async throws -> T {
    let (value, count) = try await read()
    guard count == expectedCount else {
        throw makeQueryObservationMismatch(started: started, eventCount: count, diagnostics: diagnostics)
    }
    return value
}

nonisolated private func makeQueryObservationMismatch(
    started: DispatchTime, eventCount: Int, diagnostics: String
) -> JournalObservationMismatch {
    JournalObservationMismatch(
        stage: "read-after-barrier", barrierReturned: true,
        elapsedMilliseconds: flushBarrierElapsedMilliseconds(since: started),
        eventCount: eventCount, diagnostics: diagnostics
    )
}

/// 调度余量只吸收 actor 跳转和机器负载，不改变调用方传入的截止预算。
/// body 在计时断言之后才被释放。helper 若仍等待 body，断言不会执行。
private let flushBarrierSchedulingSlackMilliseconds = 1000

nonisolated private func flushBarrierElapsedMilliseconds(since start: DispatchTime) -> Int {
    Int((DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000)
}

/// body 在返回前写下真实阶段。超时错误读这份状态，不写死屏障结果或预算。
private struct FlushBarrierStageState: Sendable {
    var barrierReturned = false
    var readStarted = false
}

nonisolated private final class FlushBarrierStageBox: Sendable {
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

nonisolated private struct FlushBarrierStageReporter: Sendable {
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
    rootURL: URL? = nil,
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
                    elapsedMilliseconds: flushBarrierElapsedMilliseconds(since: started),
                    retainedDirectory: rootURL?.path
                )
            )
        )
    }
    let outcome: Result<T, Error> = await withTaskCancellationHandler {
        await withCheckedContinuation { continuation in
            Task { await shot.store(continuation) }
        }
    } onCancel: {
        retainAbandonedJournalRoot(rootURL)
        bodyTask.cancel()
    }
    if case .failure(let error) = outcome, error is FlushBarrierBudgetExceeded {
        retainAbandonedJournalRoot(rootURL)
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

/// 截止或取消后，未响应取消的 body 可能仍访问目录；保留目录供人工清理。
nonisolated private let abandonedJournalRoots = Mutex<Set<String>>([])

nonisolated private func retainAbandonedJournalRoot(_ root: URL?) {
    guard let root else { return }
    abandonedJournalRoots.withLock { _ = $0.insert(root.path) }
}

nonisolated private func cleanupJournalRoot(_ root: URL) {
    if abandonedJournalRoots.withLock({ $0.contains(root.path) }) {
        print("保留可能仍在使用的测试目录：\(root.path)")
        return
    }
    guard FileManager.default.fileExists(atPath: root.path) else { return }
    do {
        try FileManager.default.removeItem(at: root)
    } catch {
        XCTFail("清理测试目录失败：\(root.path)，\(error)")
    }
}

/// 可由测试运行器指定夹具根目录；普通本地测试沿用系统临时目录。
nonisolated private func journalTemporaryBase() -> URL {
    if let path = ProcessInfo.processInfo.environment["DIAG_FLUSH_TEST_ROOT"], !path.isEmpty {
        return URL(fileURLWithPath: path, isDirectory: true)
    }
    return FileManager.default.temporaryDirectory
}
