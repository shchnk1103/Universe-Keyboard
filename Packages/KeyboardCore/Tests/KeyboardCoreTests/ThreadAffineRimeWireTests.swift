import Foundation
import XCTest
@testable import KeyboardCore

/// R4-Wire: dual-gate controller wiring for the thread-affine owner.
@MainActor
final class ThreadAffineRimeWireTests: XCTestCase {

    private struct FakeBootstrap: ThreadAffineRimeEngineBootstrap {
        let processEntered: DispatchSemaphore?
        let releaseFirst: DispatchSemaphore?

        init(
            processEntered: DispatchSemaphore? = nil,
            releaseFirst: DispatchSemaphore? = nil
        ) {
            self.processEntered = processEntered
            self.releaseFirst = releaseFirst
        }

        func makeEngineOnOwnerThread() -> any RimeEngine {
            if let processEntered, let releaseFirst {
                return BlockingFirstProcessFakeEngine(
                    processEntered: processEntered,
                    releaseFirst: releaseFirst
                )
            }
            return FakeRimeEngine(dictionary: ["ni": ["你"], "n": ["你"]])
        }
    }

    private final class BlockingFirstProcessFakeEngine: RimeEngine {
        private let delegate = FakeRimeEngine(dictionary: ["ni": ["你"], "n": ["你"], "nih": ["你"], "niha": ["你"], "nihao": ["你好"]])
        private let processEntered: DispatchSemaphore
        private let releaseFirst: DispatchSemaphore
        private var blocked = false

        init(processEntered: DispatchSemaphore, releaseFirst: DispatchSemaphore) {
            self.processEntered = processEntered
            self.releaseFirst = releaseFirst
        }

        func processKey(_ key: String) -> RimeOutput {
            if !blocked {
                blocked = true
                processEntered.signal()
                releaseFirst.wait()
            }
            return delegate.processKey(key)
        }

        func selectCandidate(at index: Int) -> RimeOutput { delegate.selectCandidate(at: index) }
        func selectCandidate(globalIndex index: Int) -> RimeOutput { delegate.selectCandidate(globalIndex: index) }
        func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
            delegate.candidateWindow(from: globalIndex, limit: limit)
        }
        func deleteBackward() -> RimeOutput { delegate.deleteBackward() }
        func replaceInput(_ input: String) -> RimeOutput { delegate.replaceInput(input) }
        func resetSession() { delegate.resetSession() }
        func recoverSession() { delegate.recoverSession() }
        func suspendForVisibilityChange() { delegate.suspendForVisibilityChange() }
        func resumeAfterVisibilityChange() { delegate.resumeAfterVisibilityChange() }
        var runtimeSelection: RimeRuntimeSelection? { delegate.runtimeSelection }
        var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? { delegate.diagnosticSessionSnapshot }
        var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
            get { delegate.onRuntimeSelectionChanged }
            set { delegate.onRuntimeSelectionChanged = newValue }
        }
        func isComposing() -> Bool { delegate.isComposing() }
        func pageUp() -> RimeOutput { delegate.pageUp() }
        func pageDown() -> RimeOutput { delegate.pageDown() }
    }

    func testDualGatesDefaultOff() {
        let controller = KeyboardController()
        XCTAssertFalse(controller.isResponsiveRimePipelineEnabled)
        XCTAssertFalse(controller.isThreadAffineRimeOwnerEnabled)
        XCTAssertNil(controller.threadAffineRimeCoordinator)
        XCTAssertNil(controller.responsiveRimeCoordinator)
    }

    func testThreadAffineWireAcceptsWithoutWaitingForBlockedEngine() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let presented = expectation(description: "presentation")
        presented.expectedFulfillmentCount = 1

        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap(processEntered: entered, releaseFirst: release)
        )
        controller.onResponsivePresentationNeeded = { _ in
            presented.fulfill()
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        XCTAssertNotNil(controller.threadAffineRimeCoordinator)
        XCTAssertNil(controller.responsiveRimeCoordinator)
        XCTAssertTrue(controller.rimeEngine is ThreadAffineRimeEngineBridge)

        let started = DispatchTime.now().uptimeNanoseconds
        _ = controller.handle(.insertKey("n"))
        let elapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000
        XCTAssertLessThan(elapsedMS, 50, "handle must not wait on owner engine")

        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        release.signal()
        await fulfillment(of: [presented], timeout: 2)

        controller.suspendRimeForVisibilityChange()
        XCTAssertEqual(controller.threadAffineRimeCoordinator?.diagnostics.pendingWorkDepth ?? -1, 0)
    }

    func testGateOffStillSynchronousWhenThreadAffineFlagAloneIsTrue() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(FakeBootstrap())
        // Responsive still off → ADR 0004 sync path.
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertNil(controller.threadAffineRimeCoordinator)
        XCTAssertNil(controller.responsiveRimeCoordinator)
    }

    func testResponsiveOnlyWithoutThreadAffineKeepsMainActorBridge() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = false
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        XCTAssertNotNil(controller.responsiveRimeCoordinator)
        XCTAssertNil(controller.threadAffineRimeCoordinator)
        XCTAssertTrue(controller.rimeEngine is ResponsiveRimeEngineBridge)
    }

    func testThreadAffineBridgeIsInstalledForDualGate() {
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(FakeBootstrap())
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        XCTAssertTrue(controller.rimeEngine is ThreadAffineRimeEngineBridge)
        XCTAssertNil(controller.underlyingRimeEngine)
        XCTAssertNotNil(controller.threadAffineRimeCoordinator)
        // Visibility suspend must not crash / hang (explicit lifecycle).
        controller.suspendRimeForVisibilityChange()
        controller.resumeRimeAfterVisibilityChange()
    }

    /// Arch P1-1: abandon during dual-gate backlog must not paint abandoned composition.
    func testDualGateAbandonDropsDeferredCoalescedPresentation() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        var paintCount = 0
        var lastComposition = ""

        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap(processEntered: entered, releaseFirst: release)
        )
        controller.onResponsivePresentationNeeded = { _ in
            paintCount += 1
            lastComposition = controller.state.currentComposition
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        for key in ["n", "i", "h", "a", "o"] {
            _ = controller.handle(.insertKey(String(key)))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)

        // Visibility abandon while owner still blocked / backlog present.
        _ = controller.abandonCompositionForVisibilityChange()
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)

        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        let settle = expectation(description: "coalesce-settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { settle.fulfill() }
        await fulfillment(of: [settle], timeout: 1)

        XCTAssertEqual(
            controller.state.currentComposition,
            "",
            "abandoned composition must stay empty after deferred coalesce Task"
        )
        XCTAssertNil(controller.state.lastRimeOutput)
        // Any paint after abandon must not restore pre-abandon composition.
        XCTAssertFalse(lastComposition.contains("n") && lastComposition.count > 1)
        controller.suspendRimeForVisibilityChange()
    }

    /// R5-Rem-2: blocked multi-key accept must not paint once per key while backlog exists.
    func testDualGateCoalescesPresentationUnderOwnerBacklog() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        var paintCount = 0
        let painted = expectation(description: "at least one paint")
        painted.assertForOverFulfill = false

        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap(processEntered: entered, releaseFirst: release)
        )
        controller.onResponsivePresentationNeeded = { _ in
            paintCount += 1
            painted.fulfill()
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        // Burst keys while first processKey is blocked → pending depth rises.
        for key in ["n", "i", "h", "a", "o"] {
            _ = controller.handle(.insertKey(String(key)))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        // Allow MainActor coalesce tasks to schedule before releasing owner.
        await Task.yield()
        await Task.yield()
        release.signal()
        await fulfillment(of: [painted], timeout: 3)
        // Drain remaining owner work.
        controller.threadAffineRimeCoordinator?.flushPending()
        // Give coalesce loop a moment to flush latest.
        let settle = expectation(description: "settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { settle.fulfill() }
        await fulfillment(of: [settle], timeout: 1)

        XCTAssertLessThan(
            paintCount,
            5,
            "UI paints must coalesce under dual-gate backlog (got \(paintCount))"
        )
        XCTAssertGreaterThanOrEqual(paintCount, 1)
        controller.suspendRimeForVisibilityChange()
    }
}
