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
        let started = DispatchTime.now().uptimeNanoseconds
        coordinator.scheduleProcessKey("n") { snapshot in
            XCTAssertEqual(snapshot?.output.rawInput, "n")
            published.fulfill()
        }
        let scheduleElapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000.0

        // schedule must not wait for the 40ms engine clock.
        XCTAssertLessThan(scheduleElapsedMS, 20)
        XCTAssertEqual(engine.processKeyCallCount, 0, "drain deferred to next main turn")
        XCTAssertEqual(coordinator.lastAcceptReceipt?.executedSynchronously, false)

        wait(for: [published], timeout: 2)
        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testOrderedKeysPreserveCompositionUnderGate() {
        let engine = FakeRimeEngine()
        let coordinator = ResponsiveRimeSessionCoordinator(
            engine: engine,
            publishPolicy: .latestOnly
        )
        let done = expectation(description: "both keys")
        done.expectedFulfillmentCount = 2

        coordinator.scheduleProcessKey("n") { _ in done.fulfill() }
        coordinator.scheduleProcessKey("i") { snapshot in
            XCTAssertEqual(snapshot?.output.rawInput, "ni")
            done.fulfill()
        }

        wait(for: [done], timeout: 2)
        XCTAssertEqual(engine.sessionComposition, "ni")
        XCTAssertEqual(engine.processKeyCallCount, 2)
    }

    func testControllerGateEnablesDeferredProcessKey() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: ["ni": ["你"]])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        XCTAssertNotNil(controller.responsiveRimeCoordinator)

        let started = DispatchTime.now().uptimeNanoseconds
        _ = controller.handle(.insertKey("n"))
        let elapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000.0

        // handle returns before deferred drain (no sleep clock → still async turn).
        XCTAssertEqual(engine.processKeyCallCount, 0)
        XCTAssertLessThan(elapsedMS, 50)

        let exp = expectation(description: "drain")
        DispatchQueue.main.async {
            // After at least one drain turn composition should land.
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        // Allow nested drain async hops.
        let settle = expectation(description: "settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            settle.fulfill()
        }
        wait(for: [settle], timeout: 1)

        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testEpochBumpInvalidatesInFlightGeneration() {
        let engine = FakeRimeEngine()
        let coordinator = ResponsiveRimeSessionCoordinator(engine: engine)
        coordinator.scheduleProcessKey("n") { _ in }
        coordinator.bumpSessionEpoch()
        XCTAssertEqual(coordinator.diagnostics.sessionEpoch, 2)
        XCTAssertEqual(coordinator.diagnostics.pendingDepth, 0)
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
}
