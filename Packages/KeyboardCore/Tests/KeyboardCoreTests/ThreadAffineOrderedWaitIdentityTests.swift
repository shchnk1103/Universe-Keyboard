import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

@MainActor
final class ThreadAffineOrderedWaitIdentityTests: XCTestCase {
    private final class Gate: Sendable {
        struct Facts: Sendable {
            var entered = false
            var completed = false
            var timedOut = false
            var windowReads = 0
        }
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        private let state = Mutex(Facts())

        func block() {
            state.withLock { $0.entered = true }
            entered.signal()
            let result = release.wait(timeout: .now() + 15)
            state.withLock { $0.timedOut = result == .timedOut }
        }
        func completed() { state.withLock { $0.completed = true } }
        func readWindow() { state.withLock { $0.windowReads += 1 } }
        func facts() -> Facts { state.withLock { $0 } }
    }

    private struct Bootstrap: ThreadAffineRimeEngineBootstrap {
        let gate: Gate
        func makeEngineOnOwnerThread() -> any RimeEngine { BlockingEngine(gate: gate) }
    }

    /// The engine stays on its production owner thread; only Sendable gate facts cross it.
    private final class BlockingEngine: RimeEngine {
        private let delegate = FakeRimeEngine()
        private let gate: Gate
        init(gate: Gate) { self.gate = gate }
        func processKey(_ key: String) -> RimeOutput {
            if key == "blocked" { gate.block() }
            let result = delegate.processKey(key)
            if key == "blocked" { gate.completed() }
            return result
        }
        func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
            gate.readWindow()
            return delegate.candidateWindow(from: globalIndex, limit: limit)
        }
        func selectCandidate(at index: Int) -> RimeOutput { delegate.selectCandidate(at: index) }
        func selectCandidate(globalIndex index: Int) -> RimeOutput { delegate.selectCandidate(globalIndex: index) }
        func deleteBackward() -> RimeOutput { delegate.deleteBackward() }
        func replaceInput(_ input: String) -> RimeOutput { delegate.replaceInput(input) }
        func resetSession() { delegate.resetSession() }
        func recoverSession() { delegate.recoverSession() }
        func isComposing() -> Bool { delegate.isComposing() }
        func pageUp() -> RimeOutput { delegate.pageUp() }
        func pageDown() -> RimeOutput { delegate.pageDown() }
        func suspendForVisibilityChange() { delegate.suspendForVisibilityChange() }
        func resumeAfterVisibilityChange() { delegate.resumeAfterVisibilityChange() }
        var runtimeSelection: RimeRuntimeSelection? { delegate.runtimeSelection }
        var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
            get { delegate.onRuntimeSelectionChanged }
            set { delegate.onRuntimeSelectionChanged = newValue }
        }
    }

    func testOrderedWaitDoesNotReturnOldEpochWhileRequestedWorkIsBlocked() throws {
        let gate = Gate()
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(Bootstrap(gate: gate)),
            fixtureID: "R72-ORDERED-IDENTITY"
        )
        defer {
            gate.release.signal()
            coordinator.shutdown()
        }
        let seed = try XCTUnwrap(coordinator.performOrderedNow(.processKey("n")))
        let reset = try XCTUnwrap(coordinator.performOrderedNow(.resetSession))
        // This real owner-thread control read is a serialization barrier after reset.
        // It does not clear sink history or manufacture an external epoch transition.
        _ = coordinator.candidateWindow(from: 0, limit: 1)
        XCTAssertEqual(gate.facts().windowReads, 1)
        XCTAssertEqual(coordinator.diagnostics.sessionEpoch, seed.sessionEpoch + 1)

        let returned = coordinator.performOrderedNow(.processKey("blocked"))
        let receipt = try XCTUnwrap(coordinator.lastAcceptReceipt)
        XCTAssertEqual(gate.entered.wait(timeout: .now() + 1), .success)
        let facts = gate.facts()
        let row: [String: Any] = [
            "seedEpoch": seed.sessionEpoch, "seedRevision": seed.revision,
            "resetEpoch": reset.sessionEpoch, "resetRevision": reset.revision,
            "receiptEpoch": receipt.sessionEpoch, "receiptRevision": receipt.revision,
            "returnedEpoch": returned.map { $0.sessionEpoch } as Any? ?? NSNull(),
            "returnedRevision": returned.map { $0.revision } as Any? ?? NSNull(),
            "engineEntered": facts.entered, "engineCompleted": facts.completed,
            "gateTimedOut": facts.timedOut,
        ]
        let data = try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys])
        print("R72_ORDERED_IDENTITY " + String(decoding: data, as: UTF8.self))
        XCTAssertEqual(receipt.sessionEpoch, seed.sessionEpoch + 1)
        XCTAssertEqual(receipt.revision, seed.revision, "The lifecycle reuses the numeric revision.")
        XCTAssertTrue(facts.entered)
        XCTAssertFalse(facts.completed)
        XCTAssertFalse(facts.timedOut)
        // Correct behavior waits until the ordinary five-second deadline and returns nil.
        // The target is never released until this return has been observed.
        XCTAssertNil(returned, "Undelivered work must not receive an old-epoch snapshot.")
    }
    func testOrderedResultMatchesReceiptAcrossResetAndRevisionReuse() throws {
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                makeEngineOnOwnerThread: { FakeRimeEngine() }
            )
        )
        defer { coordinator.shutdown() }
        func perform(_ work: ResponsiveRimeWork) throws -> ResponsiveRimeSnapshot {
            let result = try XCTUnwrap(coordinator.performOrderedNow(work))
            let receipt = try XCTUnwrap(coordinator.lastAcceptReceipt)
            XCTAssertEqual(result.actionID, receipt.actionID)
            XCTAssertEqual(result.sessionEpoch, receipt.sessionEpoch)
            XCTAssertEqual(result.revision, receipt.revision)
            return result
        }
        let first = try perform(.processKey("n"))
        _ = try perform(.processKey("i"))
        _ = try perform(.resetSession)
        _ = coordinator.candidateWindow(from: 0, limit: 1)
        let next = try perform(.processKey("n"))
        XCTAssertEqual(next.sessionEpoch, first.sessionEpoch + 1)
        XCTAssertEqual(next.revision, first.revision)
        XCTAssertNotEqual(next.actionID, first.actionID)
        XCTAssertEqual(next.output.rawInput, "n")
    }

    func testLateTimedOutDeliveryDoesNotSatisfyNextOrderedRequest() throws {
        let gate = Gate()
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(Bootstrap(gate: gate))
        )
        defer {
            gate.release.signal()
            coordinator.shutdown()
        }
        XCTAssertNil(coordinator.performOrderedNow(.processKey("blocked")))
        let timedOutReceipt = try XCTUnwrap(coordinator.lastAcceptReceipt)
        XCTAssertTrue(gate.facts().entered)
        XCTAssertFalse(gate.facts().completed)
        XCTAssertFalse(gate.facts().timedOut)

        gate.release.signal()
        // The owner control barrier proves late delivery actually finished.
        _ = coordinator.candidateWindow(from: 0, limit: 1)
        XCTAssertTrue(gate.facts().completed)
        XCTAssertEqual(coordinator.lastPublished?.actionID, timedOutReceipt.actionID)

        let next = try XCTUnwrap(coordinator.performOrderedNow(.processKey("n")))
        let receipt = try XCTUnwrap(coordinator.lastAcceptReceipt)
        XCTAssertNotEqual(next.actionID, timedOutReceipt.actionID)
        XCTAssertEqual(next.actionID, receipt.actionID)
        XCTAssertEqual(next.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(next.revision, receipt.revision)
        XCTAssertEqual(next.output.rawInput, "blockedn")
    }

    func testReplacementImmediatelyAfterRecoveryUsesNewSessionIdentity() throws {
        try assertReplacementAfterLifecycle(recover: true)
    }

    func testReplacementImmediatelyAfterResetUsesNewSessionIdentity() throws {
        try assertReplacementAfterLifecycle(recover: false)
    }

    private func assertReplacementAfterLifecycle(recover: Bool) throws {
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                makeEngineOnOwnerThread: { FakeRimeEngine() }
            )
        )
        defer { coordinator.shutdown() }
        let bridge = ThreadAffineRimeEngineBridge(coordinator: coordinator)
        let seed = bridge.processKey("n")
        XCTAssertEqual(seed.rawInput, "n")
        let prior = try XCTUnwrap(coordinator.lastPublished)
        if recover { bridge.recoverSession() } else { bridge.resetSession() }
        // No candidate-window barrier: returning from the lifecycle operation
        // must itself make immediate replacement safe in the new session.
        let lifecycle = try XCTUnwrap(coordinator.lastAcceptReceipt)
        XCTAssertEqual(lifecycle.sessionEpoch, prior.sessionEpoch)
        XCTAssertEqual(coordinator.diagnostics.sessionEpoch, prior.sessionEpoch + 1)
        let cachedEpoch = coordinator.lastPublished?.sessionEpoch
        let output = bridge.replaceInput("ni")
        let receipt = try XCTUnwrap(coordinator.lastAcceptReceipt)
        let row: [String: Any] = [
            "recover": recover, "lifecycleReceiptEpoch": lifecycle.sessionEpoch,
            "cachedEpochBeforeReplace": cachedEpoch.map { $0 as Any } ?? NSNull(),
            "replaceReceiptEpoch": receipt.sessionEpoch,
            "outputRaw": output.rawInput ?? "",
            "liveEpoch": coordinator.diagnostics.sessionEpoch,
        ]
        print(
            "AFFINE_LIFECYCLE_REPLACE "
                + String(
                    decoding: try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys]), as: UTF8.self))
        XCTAssertNil(cachedEpoch, "Lifecycle completion must not remain an editable old-session snapshot.")
        XCTAssertEqual(receipt.sessionEpoch, prior.sessionEpoch + 1)
        XCTAssertEqual(output.rawInput, "ni")
        XCTAssertEqual(coordinator.lastPublished?.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(coordinator.lastPublished?.revision, receipt.revision)
    }

    func testRetiredCoordinatorCleanupDoesNotRemoveSuccessorRoute() async throws {
        for attempt in 0..<4 {
            func makeCoordinator() -> ThreadAffineRimeSessionCoordinator {
                ThreadAffineRimeSessionCoordinator(
                    bootstrap: AnyThreadAffineRimeEngineBootstrap(
                        makeEngineOnOwnerThread: { FakeRimeEngine() }))
            }
            var retired: ThreadAffineRimeSessionCoordinator? = makeCoordinator()
            retired?.setPublishHandler { _ in }
            let retiredIdentity = try XCTUnwrap(retired?.publishRouteIdentityForTesting)
            retired?.shutdown()
            // Release before making the successor, without giving the asynchronous
            // MainActor unregister task a turn. This is the observed teardown order.
            retired = nil
            let successor = makeCoordinator()
            defer { successor.shutdown() }
            var delivered: [String] = []
            successor.setPublishHandler { snapshot in
                if let raw = snapshot?.output.rawInput { delivered.append(raw) }
            }
            let identityReused = retiredIdentity == successor.publishRouteIdentityForTesting
            let installedBeforeYield = successor.isPublishRouteRegisteredForTesting
            try await Task.sleep(nanoseconds: 20_000_000)
            let installedAfterYield = successor.isPublishRouteRegisteredForTesting
            let output = try XCTUnwrap(successor.performOrderedNow(.processKey("n")))
            try await Task.sleep(nanoseconds: 20_000_000)
            let row: [String: Any] = [
                "attempt": attempt, "routeIdentityReused": identityReused,
                "registeredBeforeRetiredCleanup": installedBeforeYield,
                "registeredAfterRetiredCleanup": installedAfterYield,
                "ownerOutputRaw": output.output.rawInput ?? "",
                "sinkOutputRaw": successor.lastPublished?.output.rawInput ?? "",
                "deliveredRaw": delivered,
            ]
            print(
                "AFFINE_SUCCESSOR_ROUTE "
                    + String(
                        decoding: try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys]), as: UTF8.self
                    ))
            XCTAssertTrue(installedBeforeYield)
            XCTAssertTrue(installedAfterYield, "Retired cleanup must not unregister the successor.")
            XCTAssertEqual(output.output.rawInput, "n")
            XCTAssertEqual(successor.lastPublished?.output.rawInput, "n")
            XCTAssertEqual(delivered, ["n"])
            guard self.testRun?.failureCount == 0 else { return }
        }
    }

    func testRejectedOrderedAcceptanceDoesNotReturnLastPublication() throws {
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                makeEngineOnOwnerThread: { FakeRimeEngine() }
            )
        )
        let prior = try XCTUnwrap(coordinator.performOrderedNow(.processKey("n")))
        coordinator.shutdown()
        // Retained diagnostic publication is not a completion of rejected work.
        XCTAssertEqual(coordinator.lastPublished?.actionID, prior.actionID)
        XCTAssertNil(coordinator.performOrderedNow(.processKey("i")))
        XCTAssertNil(coordinator.performOrderedNow(.processKey("h")))
    }

}
