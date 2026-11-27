import XCTest

@testable import KeyboardCore

final class QuickMenuSessionPipelineTests: XCTestCase {
    private struct Bootstrap: ThreadAffineRimeEngineBootstrap {
        func makeEngineOnOwnerThread() -> any RimeEngine { FakeRimeEngine() }
    }

    @MainActor
    func testCoordinatorAcceptsSessionCommandWithoutWaitingAndPublishesItsIdentity() async throws {
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(Bootstrap())
        )
        defer { coordinator.shutdown() }
        // Ordered work establishes that construction on the owner has completed.
        XCTAssertNotNil(coordinator.performOrderedNow(.getOption("ready")))
        let delivered = expectation(description: "command publication")
        var published: ResponsiveRimeSnapshot?
        coordinator.setPublishHandler { snapshot in
            guard snapshot?.actionID.hasPrefix("command-") == true else { return }
            published = snapshot
            delivered.fulfill()
        }
        XCTAssertNil(coordinator.scheduleSessionCommand(.processKey("n")))
        let receipt = try XCTUnwrap(coordinator.scheduleSessionCommand(.setOption("test", value: true)))
        XCTAssertFalse(receipt.executedSynchronously)
        await fulfillment(of: [delivered], timeout: 5)
        XCTAssertEqual(published?.actionID, receipt.actionID)
        XCTAssertEqual(published?.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(published?.optionResult, .confirmed(true))
    }

    func testSerialSessionCommandQueuesBehindInputAndPublishesReplay() throws {
        let engine = FakeRimeEngine()
        let coordinator = ResponsiveRimeSessionCoordinator(engine: engine, publishPolicy: .everyResult)
        var publications: [ResponsiveRimeSnapshot] = []
        coordinator.setPublishHandler { if let snapshot = $0 { publications.append(snapshot) } }
        coordinator.scheduleProcessKey("n")
        XCTAssertNil(coordinator.scheduleSessionCommand(.processKey("x")))
        let receipt = try XCTUnwrap(coordinator.scheduleSessionCommand(.setOption("test", value: true)))
        XCTAssertTrue(engine.replaceInputArguments.isEmpty)
        XCTAssertNil(engine.optionValues["test"])

        coordinator.flushPending()

        XCTAssertEqual(publications.last?.actionID, receipt.actionID)
        XCTAssertEqual(publications.last?.optionResult, .confirmed(true))
        XCTAssertEqual(publications.last?.output.rawInput, "n")
        XCTAssertEqual(engine.replaceInputArguments, ["n"])
    }

    func testThreadAffineOwnerForwardsOptionAndReplaysInput() {
        let delivered = expectation(description: "option result")
        let owner = ThreadAffineRimeSpikeOwner(bootstrap: Bootstrap()) { result in
            if result.snapshot.actionID == "set" {
                XCTAssertEqual(result.snapshot.optionResult, .confirmed(true))
                XCTAssertEqual(result.snapshot.output.rawInput, "ni")
                XCTAssertTrue(result.engineCallStayedOnCreationThread)
                delivered.fulfill()
            }
        }
        defer { owner.shutdown() }
        XCTAssertNotNil(owner.accept(.replaceInput("ni", boundEpoch: nil, boundRevision: nil), actionID: "input"))
        XCTAssertNotNil(owner.accept(.setOption("test", value: true), actionID: "set"))
        wait(for: [delivered], timeout: 5)
    }

    func testOptionResultsAndReplayArePublishedInSameEpoch() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine)
        pipeline.accept(.replaceInput("ni", boundEpoch: nil, boundRevision: nil), actionID: "input")
        pipeline.drain()
        let receipt = pipeline.accept(.setOption("test", value: true), actionID: "set")
        pipeline.drain()
        XCTAssertEqual(pipeline.lastPublished?.optionResult, .confirmed(true))
        XCTAssertEqual(pipeline.lastPublished?.output.rawInput, "ni")
        XCTAssertEqual(pipeline.lastPublished?.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(engine.replaceInputArguments, ["ni", "ni"])
        pipeline.accept(.getOption("test"), actionID: "get")
        pipeline.drain()
        XCTAssertEqual(pipeline.lastPublished?.optionResult, .confirmed(true))
        engine.optionResult = .sessionInvalid
        pipeline.accept(.setOption("test", value: false), actionID: "failed")
        pipeline.drain()
        XCTAssertEqual(pipeline.lastPublished?.optionResult, .sessionInvalid)
        XCTAssertEqual(engine.replaceInputArguments, ["ni", "ni"])
        engine.optionResult = .bridgeError
        pipeline.accept(.getOption("test"), actionID: "error")
        pipeline.drain()
        XCTAssertEqual(pipeline.lastPublished?.optionResult, .bridgeError)
        engine.optionResult = .confirmed(false)
        pipeline.accept(.getOption("missing"), actionID: "false")
        pipeline.drain()
        XCTAssertEqual(pipeline.lastPublished?.optionResult, .confirmed(false))
    }

    func testReselectionPublishesAtAcceptedEpochBeforeAdvancing() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine)
        let receipt = pipeline.accept(.reselectSchema("luna_pinyin"), actionID: "schema")

        pipeline.drain()

        XCTAssertEqual(pipeline.publishedHistory.last?.sessionEpoch, receipt.sessionEpoch)
        XCTAssertGreaterThan(pipeline.diagnostics.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(engine.selectedSchemaID, "luna_pinyin")
    }

    func testReselectionPublishesBeforeDiscardingPendingOldEpochWork() {
        let engine = FakeRimeEngine()
        let pipeline = ResponsiveRimePipeline(engine: engine, publishPolicy: .latestOnly)
        let receipt = pipeline.accept(.reselectSchema("luna_pinyin"), actionID: "schema")
        pipeline.accept(.replaceInput("ni", boundEpoch: nil, boundRevision: nil), actionID: "old-input")

        pipeline.drain()

        XCTAssertEqual(pipeline.publishedHistory.last?.actionID, "schema")
        XCTAssertEqual(pipeline.publishedHistory.last?.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(pipeline.diagnostics.discardedStaleResultCount, 1)
    }

    func testFailedReselectionDoesNotAdvanceEpochOrPublishSuccess() {
        let engine = FakeRimeEngine()
        engine.schemaSelectionSucceeds = false
        let pipeline = ResponsiveRimePipeline(engine: engine)
        let receipt = pipeline.accept(.reselectSchema("missing"), actionID: "schema")

        pipeline.drain()

        XCTAssertEqual(pipeline.diagnostics.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(pipeline.lastPublished?.schemaSelectionSucceeded, false)
        XCTAssertEqual(pipeline.lastPublished?.actionID, "schema")
        XCTAssertEqual(pipeline.diagnostics.discardedStaleSelectionCount, 0)
        XCTAssertNil(engine.selectedSchemaID)
    }

    /// PB-016 r4 regression: a successful schema reselect commits its completion
    /// snapshot and then advances the session epoch, which clears `lastPublished`.
    /// The serial coordinator must still deliver the completion snapshot to the
    /// publish bridge (so the controller can hand it to the quick-menu command
    /// consumer) — and stale/reset-recover authority must stay cleared.
    func testSerialCoordinatorDeliversSchemaCompletionSnapshotAfterEpochAdvance() throws {
        let engine = FakeRimeEngine()
        let coordinator = ResponsiveRimeSessionCoordinator(engine: engine, publishPolicy: .everyResult)
        var publications: [ResponsiveRimeSnapshot] = []
        coordinator.setPublishHandler { if let snapshot = $0 { publications.append(snapshot) } }
        let receipt = try XCTUnwrap(
            coordinator.scheduleSessionCommand(.reselectSchema("luna_pinyin"))
        )

        coordinator.flushPending()

        let delivered = try XCTUnwrap(
            publications.last,
            "the schema completion must reach the publish bridge after the epoch advance"
        )
        XCTAssertEqual(delivered.actionID, receipt.actionID)
        XCTAssertEqual(delivered.sessionEpoch, receipt.sessionEpoch)
        XCTAssertTrue(delivered.schemaSelectionSucceeded == true)
        XCTAssertEqual(engine.selectedSchemaID, "luna_pinyin")
        // Lifecycle barrier semantics are unchanged: the epoch advanced and the
        // published authority for the old epoch is gone (fail-closed stale).
        XCTAssertNotEqual(coordinator.diagnostics.sessionEpoch, receipt.sessionEpoch)
        XCTAssertNil(coordinator.sessionOwner.lastPublished)
    }

    // MARK: - PB-016 §3.3: MainActor command consumption with presentation epoch

    @MainActor
    func testControllerDeliversCommandSnapshotsToConsumerBeforePresentationGating() {
        let controller = KeyboardController()
        controller.isResponsiveRimePipelineEnabled = true
        let consumer = RecordingCommandConsumer()
        controller.quickMenuSessionCommandConsumer = consumer

        controller.applyResponsivePublishedSnapshot(
            ResponsiveRimeSnapshot(
                sessionEpoch: 7, revision: 1, actionID: "command-schema", output: RimeOutput()
            )
        )

        XCTAssertEqual(consumer.snapshots.map(\.actionID), ["command-schema"])
        // Delivery happens before any paint: the presentation epoch handed to
        // the consumer is the pre-paint value.
        XCTAssertEqual(consumer.presentationEpochs, [0])

        // Ordinary (non-command) snapshots never reach the consumer.
        controller.applyResponsivePublishedSnapshot(
            ResponsiveRimeSnapshot(
                sessionEpoch: 7, revision: 2, actionID: "pk-1", output: RimeOutput()
            )
        )
        XCTAssertEqual(consumer.snapshots.count, 1)
        XCTAssertEqual(controller.currentPresentationEpochForTesting, 7)
    }

    @MainActor
    func testControllerConsumerIsOptionalForCommandSnapshots() {
        let controller = KeyboardController()
        controller.isResponsiveRimePipelineEnabled = true

        // No consumer installed (fail-closed / pre-install): delivery is a
        // no-op, presentation keeps its existing gating behavior.
        controller.applyResponsivePublishedSnapshot(
            ResponsiveRimeSnapshot(
                sessionEpoch: 3, revision: 1, actionID: "command-option", output: RimeOutput()
            )
        )
        XCTAssertEqual(controller.currentPresentationEpochForTesting, 3)
    }
}

/// PB-016 §3.3: records command deliveries with the presentation epoch the
/// controller handed over, exactly as the Extension gateway consumes them.
@MainActor
private final class RecordingCommandConsumer: RimeSessionCommandConsuming {
    private(set) var snapshots: [ResponsiveRimeSnapshot] = []
    private(set) var presentationEpochs: [UInt64] = []
    private(set) var abandonCount = 0

    func consumeCommandResult(_ snapshot: ResponsiveRimeSnapshot, presentationEpoch: UInt64) {
        snapshots.append(snapshot)
        presentationEpochs.append(presentationEpoch)
    }

    func abandonInFlightSelection() {
        abandonCount &+= 1
    }
}
