import XCTest
@testable import KeyboardCore

/// R1 matrix for `ResponsiveRimePipeline` with controllable Fake RIME delay.
///
/// Production `KeyboardController` / `RimeEngineImpl` are intentionally not
/// wired here; Release default behavior remains the synchronous path.
final class ResponsiveRimePipelineTests: XCTestCase {

    /// Frozen product fixture spelling (not logged by production diagnostics).
    private let fixtureSpelling = "jintiandetianqizhenbucuowomenchuquwanba"
    private let fixtureID = "T9RESP-FIX-001"

    // MARK: - Accept does not wait for RIME

    func testAcceptReceivesAllKeysWithoutCallingEngine() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        let keys = Array(fixtureSpelling)
        var receipts: [ResponsiveRimeAcceptReceipt] = []
        for (index, character) in keys.enumerated() {
            let receipt = pipeline.accept(
                .processKey(String(character)),
                actionID: "k\(index)"
            )
            receipts.append(receipt)
        }

        XCTAssertEqual(receipts.count, fixtureSpelling.count)
        XCTAssertEqual(pipeline.acceptedActionIDs.count, fixtureSpelling.count)
        XCTAssertEqual(engine.processKeyCallCount, 0, "accept must not call RIME")
        XCTAssertEqual(pipeline.diagnostics.pendingDepth, fixtureSpelling.count)
        XCTAssertEqual(pipeline.diagnostics.maxPendingDepth, fixtureSpelling.count)
        XCTAssertTrue(receipts.allSatisfy { $0.executedSynchronously == false })
        XCTAssertEqual(receipts.map(\.revision), Array(1...UInt64(fixtureSpelling.count)))
    }

    func testAcceptWallTimeStaysLowWhileDrainPaysSimulatedEngineCost() {
        let engine = FakeRimeEngine()
        // Use 20ms × 8 keys so the suite stays fast while still proving the split.
        let delayMS: UInt64 = 20
        let keyCount = 8
        let clock = SleepingResponsiveRimeClock(milliseconds: delayMS)
        let pipeline = ResponsiveRimePipeline(
            engine: engine,
            clock: clock,
            fixtureID: fixtureID
        )

        let acceptStarted = DispatchTime.now().uptimeNanoseconds
        for index in 0..<keyCount {
            pipeline.accept(.processKey("a"), actionID: "a\(index)")
        }
        let acceptElapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- acceptStarted) / 1_000_000.0

        XCTAssertEqual(engine.processKeyCallCount, 0)
        // Accept of 8 keys should be far below one simulated engine call.
        XCTAssertLessThan(acceptElapsedMS, Double(delayMS), "accept must not wait for clock/engine")

        let drainStarted = DispatchTime.now().uptimeNanoseconds
        XCTAssertEqual(pipeline.drain(), keyCount)
        let drainElapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- drainStarted) / 1_000_000.0

        XCTAssertEqual(engine.processKeyCallCount, keyCount)
        let expectedMinMS = Double(delayMS * UInt64(keyCount)) * 0.7
        XCTAssertGreaterThan(
            drainElapsedMS,
            expectedMinMS,
            "drain should accumulate simulated engine waits"
        )
        XCTAssertGreaterThan(pipeline.diagnostics.engineWaitNanoseconds, 0)
    }

    func testSimulatedOneHundredFiftyMillisecondClockHonorsDelayBudget() {
        let engine = FakeRimeEngine()
        let clock = SleepingResponsiveRimeClock(milliseconds: 150)
        let pipeline = ResponsiveRimePipeline(
            engine: engine,
            clock: clock,
            fixtureID: fixtureID
        )

        let acceptStarted = DispatchTime.now().uptimeNanoseconds
        pipeline.accept(.processKey("n"), actionID: "n0")
        pipeline.accept(.processKey("i"), actionID: "i1")
        let acceptElapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- acceptStarted) / 1_000_000.0
        XCTAssertLessThan(acceptElapsedMS, 50)

        let drainStarted = DispatchTime.now().uptimeNanoseconds
        XCTAssertEqual(pipeline.drain(), 2)
        let drainElapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- drainStarted) / 1_000_000.0
        XCTAssertGreaterThan(drainElapsedMS, 150 * 2 * 0.7)
        XCTAssertEqual(engine.processKeyCallCount, 2)
    }

    // MARK: - Order / no drop / no dup

    func testDrainPreservesOrderWithoutDropOrDuplicate() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)
        let keys = Array(fixtureSpelling)

        for (index, character) in keys.enumerated() {
            pipeline.accept(.processKey(String(character)), actionID: "k\(index)")
        }
        XCTAssertEqual(pipeline.drain(), keys.count)

        XCTAssertEqual(pipeline.acceptedActionIDs, pipeline.executedActionIDs)
        XCTAssertEqual(pipeline.executedActionIDs.count, keys.count)
        XCTAssertEqual(Set(pipeline.executedActionIDs).count, keys.count, "no duplicates")
        XCTAssertEqual(engine.sessionComposition, fixtureSpelling)
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, fixtureSpelling)
    }

    // MARK: - Revision / epoch

    func testOlderRevisionCannotOverwriteNewerPublishedSnapshot() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        XCTAssertEqual(pipeline.drain(), 2)
        XCTAssertEqual(pipeline.lastPublished?.revision, 2)

        let stale = ResponsiveRimeSnapshot(
            sessionEpoch: 1,
            revision: 1,
            actionID: "stale",
            output: RimeOutput(
                rawInput: "n",
                composition: RimeComposition(preeditText: "n", cursorPosition: 1),
                candidates: [],
                highlightedIndex: -1
            )
        )
        XCTAssertFalse(pipeline.tryApplyExternalSnapshot(stale))
        XCTAssertEqual(pipeline.lastPublished?.revision, 2)
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "ni")
        XCTAssertEqual(pipeline.diagnostics.discardedStaleResultCount, 1)
    }

    func testSessionEpochBumpClearsPendingAndInvalidatesOldResults() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        XCTAssertEqual(pipeline.diagnostics.pendingDepth, 2)

        pipeline.bumpSessionEpoch()
        XCTAssertEqual(pipeline.diagnostics.sessionEpoch, 2)
        XCTAssertEqual(pipeline.diagnostics.pendingDepth, 0)
        XCTAssertEqual(pipeline.drain(), 0, "pending cleared; nothing to drain")
        XCTAssertEqual(engine.processKeyCallCount, 0)
        XCTAssertEqual(engine.sessionComposition, "")
        XCTAssertNil(pipeline.lastPublished)

        pipeline.accept(.processKey("w"), actionID: "w")
        XCTAssertEqual(pipeline.drain(), 1)
        XCTAssertEqual(pipeline.lastPublished?.sessionEpoch, 2)
        XCTAssertEqual(pipeline.lastPublished?.revision, 1)
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "w")
    }

    // MARK: - UI coalesce

    func testLatestOnlyPublishSkipsIntermediateSnapshots() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(
            engine: engine,
            publishPolicy: .latestOnly,
            fixtureID: fixtureID
        )

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        pipeline.accept(.processKey("h"), actionID: "h")
        pipeline.accept(.processKey("a"), actionID: "a")
        pipeline.accept(.processKey("o"), actionID: "o")

        XCTAssertEqual(pipeline.drain(), 5)
        XCTAssertEqual(engine.processKeyCallCount, 5, "engine still executes every key")
        XCTAssertEqual(pipeline.executedActionIDs.count, 5)
        // Only the final settle should publish under latestOnly.
        XCTAssertEqual(pipeline.publishedHistory.count, 1)
        XCTAssertEqual(pipeline.lastPublished?.revision, 5)
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "nihao")
    }

    func testEveryResultPublishKeepsFullHistory() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(
            engine: engine,
            publishPolicy: .everyResult,
            fixtureID: fixtureID
        )
        for (index, character) in ["n", "i", "h"].enumerated() {
            pipeline.accept(.processKey(character), actionID: "k\(index)")
        }
        XCTAssertEqual(pipeline.drain(), 3)
        XCTAssertEqual(pipeline.publishedHistory.count, 3)
        XCTAssertEqual(pipeline.publishedHistory.map(\.output.rawInput), ["n", "ni", "nih"])
    }

    // MARK: - Delete / candidate / Path / reset order

    func testDeleteRunsInOrderAfterPendingKeys() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        pipeline.accept(.deleteBackward, actionID: "del")
        XCTAssertEqual(pipeline.drain(), 3)

        XCTAssertEqual(pipeline.executedActionIDs, ["n", "i", "del"])
        XCTAssertEqual(engine.sessionComposition, "n")
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "n")
    }

    func testStaleCandidateSelectionFailsClosed() {
        let engine = FakeRimeEngine(dictionary: ["ni": ["你", "呢"]])
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        XCTAssertEqual(pipeline.drain(), 2)
        let live = pipeline.lastPublished!
        XCTAssertEqual(live.output.candidates.map(\.text), ["你", "呢"])

        // Newer keys advance published revision before the stale tap executes.
        pipeline.accept(.processKey("h"), actionID: "h")
        pipeline.accept(
            .selectCandidate(
                pageIndex: 0,
                boundEpoch: live.sessionEpoch,
                boundRevision: live.revision
            ),
            actionID: "sel-stale"
        )
        XCTAssertEqual(pipeline.drain(), 2)

        XCTAssertEqual(engine.sessionComposition, "nih")
        XCTAssertNil(pipeline.lastPublished?.output.committedText)
        XCTAssertGreaterThanOrEqual(pipeline.diagnostics.discardedStaleSelectionCount, 1)
        XCTAssertFalse(pipeline.executedActionIDs.contains("sel-stale"))
    }

    func testFreshCandidateSelectionCommits() {
        let engine = FakeRimeEngine(dictionary: ["ni": ["你", "呢"]])
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        XCTAssertEqual(pipeline.drain(), 2)
        let live = pipeline.lastPublished!

        pipeline.accept(
            .selectCandidate(
                pageIndex: 0,
                boundEpoch: live.sessionEpoch,
                boundRevision: live.revision
            ),
            actionID: "sel"
        )
        XCTAssertEqual(pipeline.drain(), 1)
        XCTAssertEqual(pipeline.lastPublished?.output.committedText, "你")
        XCTAssertEqual(engine.sessionComposition, "")
    }

    func testPathReplaceInputBoundToSnapshotFailsWhenStale() {
        let engine = FakeRimeEngine()
        engine.appendDigitsToComposition = true
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("6"), actionID: "d6")
        pipeline.accept(.processKey("4"), actionID: "d4")
        XCTAssertEqual(pipeline.drain(), 2)
        let live = pipeline.lastPublished!

        pipeline.accept(.processKey("4"), actionID: "d4b")
        pipeline.accept(
            .replaceInput(
                "ni",
                boundEpoch: live.sessionEpoch,
                boundRevision: live.revision
            ),
            actionID: "path-stale"
        )
        XCTAssertEqual(pipeline.drain(), 2)

        XCTAssertEqual(engine.sessionComposition, "644")
        XCTAssertFalse(pipeline.executedActionIDs.contains("path-stale"))
        XCTAssertGreaterThanOrEqual(pipeline.diagnostics.discardedStaleSelectionCount, 1)
    }

    func testPathReplaceInputWithFreshBindingApplies() {
        let engine = FakeRimeEngine()
        engine.appendDigitsToComposition = true
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("6"), actionID: "d6")
        pipeline.accept(.processKey("4"), actionID: "d4")
        XCTAssertEqual(pipeline.drain(), 2)
        let live = pipeline.lastPublished!

        pipeline.accept(
            .replaceInput(
                "ni",
                boundEpoch: live.sessionEpoch,
                boundRevision: live.revision
            ),
            actionID: "path"
        )
        XCTAssertEqual(pipeline.drain(), 1)
        XCTAssertEqual(engine.sessionComposition, "ni")
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "ni")
    }

    func testResetClearsCompositionInOrder() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        pipeline.accept(.resetSession, actionID: "reset")
        XCTAssertEqual(pipeline.drain(), 3)

        XCTAssertEqual(engine.sessionComposition, "")
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertNil(pipeline.lastPublished?.output.composition)
    }

    // MARK: - Host digit safety boundary note

    func testPipelinePassesThroughDigitRawWithoutHostProjectionClaim() {
        // Host-facing digit stripping remains KeyboardController / T9PreeditResolver
        // responsibility (covered by T9HostPreeditSafetyTests). R1 pipeline only
        // guarantees ordered engine I/O and versioned publish of engine output.
        let engine = FakeRimeEngine()
        engine.appendDigitsToComposition = true
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("6"), actionID: "d6")
        pipeline.accept(.processKey("4"), actionID: "d4")
        XCTAssertEqual(pipeline.drain(), 2)
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "64")
        // Diagnostics stay content-free at the fixture-ID level.
        XCTAssertEqual(pipeline.diagnostics.fixtureID, fixtureID)
        XCTAssertFalse(pipeline.diagnostics.fixtureID.contains("64"))
    }

    // MARK: - Release default isolation

    @MainActor
    func testPipelineDoesNotMutateControllerDefaultRimePath() {
        // R1 must not change KeyboardController's synchronous default behavior.
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: ["ni": ["你"]])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))

        XCTAssertEqual(engine.processKeyCallCount, 2, "controller still calls RIME synchronously")
        XCTAssertEqual(engine.sessionComposition, "ni")
    }

    // MARK: - validateSelection helper

    func testValidateSelectionRejectsEpochMismatch() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)
        pipeline.accept(.processKey("n"), actionID: "n")
        XCTAssertEqual(pipeline.drain(), 1)

        let decision = pipeline.validateSelection(boundEpoch: 99, boundRevision: 1)
        XCTAssertEqual(decision, .rejectedEpochMismatch)
    }

    // MARK: - P1-1: applied vs published under latestOnly

    func testLatestOnlySelectionBoundToPublishedFailsWhenEngineAlreadyAdvanced() {
        // Architecture P1-1 counter-example:
        // publish/settle at "ni", then enqueue "h" + select(bound: ni).
        // Under latestOnly, "h" applies without publishing; select must fail closed
        // because lastApplied has moved past the bound revision.
        let engine = FakeRimeEngine(dictionary: [
            "ni": ["你", "呢"],
            "nih": ["逆"],
        ])
        let pipeline = ResponsiveRimePipeline(
            engine: engine,
            publishPolicy: .latestOnly,
            fixtureID: fixtureID
        )

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        XCTAssertEqual(pipeline.drain(), 2)
        let live = pipeline.lastPublished!
        XCTAssertEqual(live.revision, 2)
        XCTAssertEqual(live.output.rawInput, "ni")
        XCTAssertEqual(pipeline.diagnostics.lastAppliedRevision, 2)

        pipeline.accept(.processKey("h"), actionID: "h")
        pipeline.accept(
            .selectCandidate(
                pageIndex: 0,
                boundEpoch: live.sessionEpoch,
                boundRevision: live.revision
            ),
            actionID: "sel-stale-after-apply"
        )
        XCTAssertEqual(pipeline.drain(), 2)

        XCTAssertEqual(engine.sessionComposition, "nih", "key must apply; select must not commit")
        XCTAssertNil(pipeline.lastPublished?.output.committedText)
        XCTAssertFalse(pipeline.executedActionIDs.contains("sel-stale-after-apply"))
        XCTAssertGreaterThanOrEqual(pipeline.diagnostics.discardedStaleSelectionCount, 1)
        // Catch-up after skip: applied "h" must become published when queue empties.
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "nih")
        XCTAssertEqual(pipeline.diagnostics.lastAppliedRevision, 3)
        XCTAssertEqual(pipeline.diagnostics.lastPublishedRevision, 3)
    }

    func testLatestOnlyCatchUpPublishWhenTrailingWorkIsSkipped() {
        let engine = FakeRimeEngine(dictionary: ["ni": ["你"]])
        let pipeline = ResponsiveRimePipeline(
            engine: engine,
            publishPolicy: .latestOnly,
            fixtureID: fixtureID
        )

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        XCTAssertEqual(pipeline.drain(), 2)
        let live = pipeline.lastPublished!

        // Applied-only intermediate + trailing stale select (skipped).
        pipeline.accept(.processKey("h"), actionID: "h")
        pipeline.accept(
            .selectCandidate(
                pageIndex: 0,
                boundEpoch: live.sessionEpoch,
                boundRevision: live.revision
            ),
            actionID: "sel-skip"
        )
        XCTAssertEqual(pipeline.drain(), 2)

        XCTAssertEqual(pipeline.lastPublished?.actionID, "h")
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "nih")
        XCTAssertGreaterThan(pipeline.diagnostics.coalescedSkipCount, 0)
    }

    func testSelectionRequiresAppliedEqualsPublished() {
        let engine = FakeRimeEngine(dictionary: ["ni": ["你"]])
        let pipeline = ResponsiveRimePipeline(
            engine: engine,
            publishPolicy: .latestOnly,
            fixtureID: fixtureID
        )
        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.processKey("i"), actionID: "i")
        XCTAssertEqual(pipeline.drain(), 2)
        XCTAssertEqual(
            pipeline.validateSelection(boundEpoch: 1, boundRevision: 2),
            .accepted
        )

        // Apply without publishing yet (partial drain under latestOnly with more pending).
        pipeline.accept(.processKey("h"), actionID: "h")
        pipeline.accept(.processKey("a"), actionID: "a")
        XCTAssertTrue(pipeline.processNext()) // applies "h", still pending "a"
        XCTAssertEqual(pipeline.diagnostics.lastAppliedRevision, 3)
        XCTAssertEqual(pipeline.diagnostics.lastPublishedRevision, 2)
        XCTAssertEqual(
            pipeline.validateSelection(boundEpoch: 1, boundRevision: 2),
            .rejectedStaleSnapshot,
            "published ni is stale once engine applied h"
        )
        XCTAssertEqual(
            pipeline.validateSelection(boundEpoch: 1, boundRevision: 3),
            .rejectedStaleSnapshot,
            "applied-but-unpublished revision is not selectable"
        )
    }

    // MARK: - P1-3: reset/recover bump epoch

    func testEnqueuedResetAdvancesEpochAndInvalidatesTrailingPending() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)

        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.resetSession, actionID: "reset")
        pipeline.accept(.processKey("i"), actionID: "i-after-reset")
        XCTAssertEqual(pipeline.drain(), 3)

        XCTAssertEqual(pipeline.diagnostics.sessionEpoch, 2)
        XCTAssertEqual(engine.sessionComposition, "", "trailing key discarded by epoch")
        XCTAssertFalse(pipeline.executedActionIDs.contains("i-after-reset"))
        XCTAssertGreaterThanOrEqual(pipeline.diagnostics.discardedStaleResultCount, 1)
    }

    func testEnqueuedRecoverAdvancesEpoch() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)
        pipeline.accept(.processKey("n"), actionID: "n")
        pipeline.accept(.recoverSession, actionID: "recover")
        XCTAssertEqual(pipeline.drain(), 2)
        XCTAssertEqual(pipeline.diagnostics.sessionEpoch, 2)
        XCTAssertEqual(engine.sessionRecoveryCount, 1)
    }

    func testOldEpochSnapshotCannotPublishAfterBump() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, fixtureID: fixtureID)
        pipeline.accept(.processKey("n"), actionID: "n")
        XCTAssertEqual(pipeline.drain(), 1)
        let old = pipeline.lastPublished!

        pipeline.bumpSessionEpoch()
        XCTAssertFalse(pipeline.tryApplyExternalSnapshot(old))
        XCTAssertNil(pipeline.lastPublished)
        XCTAssertEqual(pipeline.diagnostics.sessionEpoch, 2)
    }
}
