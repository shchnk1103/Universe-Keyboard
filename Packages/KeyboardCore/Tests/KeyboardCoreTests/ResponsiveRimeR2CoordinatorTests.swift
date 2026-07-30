import XCTest
@testable import KeyboardCore

/// R2 gate + serial owner coordinator tests (default-off Release path untouched).
@MainActor
final class ResponsiveRimeR2CoordinatorTests: XCTestCase {

    func testGateDefaultIsOffAndControllerStaysSynchronous() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: ["ni": ["你"]])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        XCTAssertFalse(controller.isResponsiveRimePipelineEnabled)
        XCTAssertNil(controller.responsiveRimeCoordinator)

        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testScheduleProcessKeyReturnsBeforeEngineWhenDeferredDrain() {
        let engine = FakeRimeEngine()
        let clock = SleepingResponsiveRimeClock(milliseconds: 40)
        let coordinator = ResponsiveRimeSessionCoordinator(
            engine: engine,
            publishPolicy: .everyResult,
            clock: clock
        )

        let published = expectation(description: "published")
        coordinator.setPublishHandler { snapshot in
            XCTAssertEqual(snapshot?.output.rawInput, "n")
            published.fulfill()
        }

        let started = DispatchTime.now().uptimeNanoseconds
        coordinator.scheduleProcessKey("n")
        let scheduleElapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000.0

        XCTAssertLessThan(scheduleElapsedMS, 20)
        XCTAssertEqual(engine.processKeyCallCount, 0, "accept must not call engine")
        XCTAssertEqual(coordinator.lastAcceptReceipt?.executedSynchronously, false)

        // Explicit drain (controller uses Task yield + drainOneStep).
        XCTAssertTrue(coordinator.drainOneStep())
        wait(for: [published], timeout: 1)
        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testOrderedKeysShareSinglePublishHandler() {
        let engine = FakeRimeEngine()
        let coordinator = ResponsiveRimeSessionCoordinator(
            engine: engine,
            publishPolicy: .latestOnly
        )
        var publishedRaws: [String] = []
        coordinator.setPublishHandler { snapshot in
            if let raw = snapshot?.output.rawInput {
                publishedRaws.append(raw)
            }
        }

        coordinator.scheduleProcessKey("n")
        coordinator.scheduleProcessKey("i")
        coordinator.flushPending()

        XCTAssertEqual(engine.sessionComposition, "ni")
        XCTAssertEqual(engine.processKeyCallCount, 2)
        XCTAssertFalse(publishedRaws.isEmpty)
        XCTAssertEqual(publishedRaws.last, "ni")
    }

    func testControllerGateEnablesDeferredProcessKeyAndPresentationBridge() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: ["ni": ["你"]])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.isResponsiveRimePipelineEnabled = true

        var presentationEffects: [KeyboardEffect] = []
        let presented = expectation(description: "presentation")
        controller.onResponsivePresentationNeeded = { effects in
            presentationEffects.append(effects)
            presented.fulfill()
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        XCTAssertNotNil(controller.responsiveRimeCoordinator)
        XCTAssertTrue(controller.rimeEngine is ResponsiveRimeEngineBridge)

        let started = DispatchTime.now().uptimeNanoseconds
        _ = controller.handle(.insertKey("n"))
        let elapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000.0

        XCTAssertEqual(engine.processKeyCallCount, 0)
        XCTAssertLessThan(elapsedMS, 50)

        wait(for: [presented], timeout: 2)
        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
        XCTAssertTrue(presentationEffects.contains { $0.contains(.compositionChanged) })
    }

    func testDeleteThroughBridgeWaitsForPendingProcessKey() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        // Schedule keys (pending) then delete via bridge/rimeEngine path.
        controller.responsiveRimeCoordinator?.scheduleProcessKey("n")
        controller.responsiveRimeCoordinator?.scheduleProcessKey("i")
        // Sync delete through bridge must drain pending keys first.
        _ = controller.rimeEngine?.deleteBackward()

        XCTAssertEqual(engine.sessionComposition, "n")
        XCTAssertEqual(engine.processKeyCallCount, 2)
    }

    func testEpochBumpClearsPendingAccepts() {
        let engine = FakeRimeEngine()
        let coordinator = ResponsiveRimeSessionCoordinator(engine: engine)
        coordinator.scheduleProcessKey("n")
        XCTAssertEqual(coordinator.diagnostics.pendingDepth, 1)
        coordinator.bumpSessionEpoch()
        XCTAssertEqual(coordinator.diagnostics.sessionEpoch, 2)
        XCTAssertEqual(coordinator.diagnostics.pendingDepth, 0)
        XCTAssertFalse(coordinator.drainOneStep())
        XCTAssertEqual(engine.processKeyCallCount, 0)
    }

    func testPerformOrderedDeleteAfterKeys() {
        let engine = FakeRimeEngine()
        let coordinator = ResponsiveRimeSessionCoordinator(engine: engine)
        _ = coordinator.performOrderedNow(.processKey("n"))
        _ = coordinator.performOrderedNow(.processKey("i"))
        let afterDelete = coordinator.performOrderedNow(.deleteBackward)
        XCTAssertEqual(afterDelete?.output.rawInput, "n")
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testStaleSelectionFailsClosedOnOwner() {
        let engine = FakeRimeEngine(dictionary: ["ni": ["你"]])
        let coordinator = ResponsiveRimeSessionCoordinator(
            engine: engine,
            publishPolicy: .everyResult
        )
        _ = coordinator.performOrderedNow(.processKey("n"))
        _ = coordinator.performOrderedNow(.processKey("i"))
        let live = coordinator.sessionOwner.lastPublished!
        _ = coordinator.performOrderedNow(.processKey("h"))
        let decision = coordinator.validateSelection(
            boundEpoch: live.sessionEpoch,
            boundRevision: live.revision
        )
        XCTAssertEqual(decision, .rejectedStaleSnapshot)
    }

    func testBridgeSelectBindsToLastPublished() {
        let engine = FakeRimeEngine(dictionary: ["ni": ["你", "呢"]])
        let coordinator = ResponsiveRimeSessionCoordinator(
            engine: engine,
            publishPolicy: .everyResult
        )
        let bridge = ResponsiveRimeEngineBridge(
            underlyingEngine: engine,
            coordinator: coordinator
        )
        _ = bridge.processKey("n")
        _ = bridge.processKey("i")
        let committed = bridge.selectCandidate(at: 0)
        XCTAssertEqual(committed.committedText, "你")
        XCTAssertEqual(engine.sessionComposition, "")
    }

    func testGateOffAfterOnRestoresUnderlyingEngine() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        XCTAssertTrue(controller.rimeEngine is ResponsiveRimeEngineBridge)
        XCTAssertTrue(controller.underlyingRimeEngine === engine)

        controller.isResponsiveRimePipelineEnabled = false
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        XCTAssertTrue(controller.rimeEngine === engine)
        XCTAssertNil(controller.responsiveRimeCoordinator)
    }

    // MARK: - R3

    func testHandleKeyThenDeleteThroughBridgePreservesOrder() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        // Delete via controller path (bridge-backed rimeEngine).
        _ = controller.handle(.deleteBackward)

        // Wait for deferred drains then any ordered delete already flushed.
        let settle = expectation(description: "settle")
        DispatchQueue.main.async {
            // Drain any remaining deferred keys if delete didn't flush them all.
            controller.responsiveRimeCoordinator?.flushPending()
            settle.fulfill()
        }
        wait(for: [settle], timeout: 1)

        // After n,i then delete: composition should be "n" (or empty if delete
        // raced before drains — flushPending on delete path should force "n").
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testResponsiveApplyRunsPathRefreshContext() {
        let engine = FakeRimeEngine(dictionary: [
            "6": ["m", "n", "o"],
            "64": ["mi", "ni"],
        ])
        engine.appendDigitsToComposition = true
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.isResponsiveRimePipelineEnabled = true
        var pathEffects = 0
        controller.onResponsivePresentationNeeded = { effects in
            if effects.contains(.t9PinyinPathsChanged) {
                pathEffects += 1
            }
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        _ = controller.handle(.insertKey("6"))
        let settle = expectation(description: "drain")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            settle.fulfill()
        }
        wait(for: [settle], timeout: 1)
        controller.responsiveRimeCoordinator?.flushPending()

        XCTAssertEqual(engine.sessionComposition, "6")
        XCTAssertGreaterThanOrEqual(pathEffects, 1)
        XCTAssertTrue(controller.responsiveKeyApplyContexts.isEmpty)
    }
}
