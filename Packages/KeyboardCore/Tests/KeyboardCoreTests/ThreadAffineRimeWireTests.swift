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
}
