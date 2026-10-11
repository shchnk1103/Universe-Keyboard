import Foundation
import XCTest

#if DEBUG && KEYBOARD_QUERY_COST_PROBE && KEYBOARD_QUERY_COST_PROBE_TESTING
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
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("TypoRecallJournal-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: rootURL) }

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

        runtime.requestFlush()
        let snapshot = try await waitForMeasuredQueryEvents(
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
        at rootURL: URL,
        expectedCount: Int
    ) async throws -> DiagnosticsJournalSnapshot {
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
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
