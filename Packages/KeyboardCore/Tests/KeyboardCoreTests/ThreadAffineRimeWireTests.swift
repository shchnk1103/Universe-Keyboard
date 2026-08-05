import Foundation
import XCTest
@testable import KeyboardCore

/// R4-Wire: dual-gate controller wiring for the thread-affine owner.
@MainActor
final class ThreadAffineRimeWireTests: XCTestCase {

    /// Observe the UI completion point used by the active compilation mode.
    /// Internal canary builds intentionally replace the ordinary callback with
    /// a synchronous acknowledgement so PAINT evidence cannot be inferred.
    private func observePresentation(
        on controller: KeyboardController,
        _ observer: @escaping (KeyboardEffect) -> Void
    ) {
        #if T9_RESPONSIVE_CANARY_INTERNAL
        controller.onResponsiveCanaryPresentationNeeded = { effects in
            observer(effects)
            return true
        }
        #else
        controller.onResponsivePresentationNeeded = observer
        #endif
    }

    private struct FakeBootstrap: ThreadAffineRimeEngineBootstrap {
        let processEntered: DispatchSemaphore?
        let releaseFirst: DispatchSemaphore?
        let sessionSnapshot: RimeSessionDiagnosticSnapshot?
        let startupDelayNanoseconds: UInt64
        let blockedProcessCall: Int

        init(
            processEntered: DispatchSemaphore? = nil,
            releaseFirst: DispatchSemaphore? = nil,
            sessionSnapshot: RimeSessionDiagnosticSnapshot? = nil,
            startupDelayNanoseconds: UInt64 = 0,
            blockedProcessCall: Int = 1
        ) {
            self.processEntered = processEntered
            self.releaseFirst = releaseFirst
            self.sessionSnapshot = sessionSnapshot
            self.startupDelayNanoseconds = startupDelayNanoseconds
            self.blockedProcessCall = blockedProcessCall
        }

        func makeEngineOnOwnerThread() -> any RimeEngine {
            if startupDelayNanoseconds > 0 {
                Thread.sleep(
                    forTimeInterval: Double(startupDelayNanoseconds) / 1_000_000_000
                )
            }
            if let processEntered, let releaseFirst {
                return BlockingFirstProcessFakeEngine(
                    processEntered: processEntered,
                    releaseFirst: releaseFirst,
                    blockedProcessCall: blockedProcessCall
                )
            }
            let engine = FakeRimeEngine(dictionary: ["ni": ["你"], "n": ["你"]])
            engine.diagnosticSessionSnapshot = sessionSnapshot
            return engine
        }
    }

    private final class BlockingFirstProcessFakeEngine: RimeEngine {
        private let delegate = FakeRimeEngine(dictionary: ["ni": ["你"], "n": ["你"], "nih": ["你"], "niha": ["你"], "nihao": ["你好"]])
        private let processEntered: DispatchSemaphore
        private let releaseFirst: DispatchSemaphore
        private let blockedProcessCall: Int
        private var processCallCount = 0

        init(
            processEntered: DispatchSemaphore,
            releaseFirst: DispatchSemaphore,
            blockedProcessCall: Int
        ) {
            self.processEntered = processEntered
            self.releaseFirst = releaseFirst
            self.blockedProcessCall = blockedProcessCall
        }

        func processKey(_ key: String) -> RimeOutput {
            processCallCount += 1
            if processCallCount == blockedProcessCall {
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
        observePresentation(on: controller) { _ in
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

    func testPublicationKeepsOwnerCompletionBacklogDepth() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let delivered = expectation(description: "five publications")
        delivered.expectedFulfillmentCount = 5
        var pendingDepths: [Int] = []
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                FakeBootstrap(processEntered: entered, releaseFirst: release)
            )
        )
        coordinator.setPublicationHandler { publication in
            pendingDepths.append(publication.pendingWorkDepthAfterCompletion)
            delivered.fulfill()
        }

        for key in ["n", "i", "h", "a", "o"] {
            coordinator.scheduleProcessKey(key)
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        release.signal()
        await fulfillment(of: [delivered], timeout: 2)

        XCTAssertEqual(pendingDepths, [4, 3, 2, 1, 0])
        coordinator.shutdown()
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

    /// Visibility teardown must keep the coordinator epoch ahead of a stopped
    /// owner. Otherwise a late epoch-1 notification could pass the MainActor
    /// presentation gate after the replacement owner starts at epoch 1 again.
    func testVisibilityOwnerRestartPreservesEpochAndRejectsStaleSnapshot() async {
        var presentationCount = 0
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap()
        )
        observePresentation(on: controller) { _ in
            presentationCount += 1
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        // The abandon boundary advances the coordinator-owned epoch before
        // the dedicated owner is stopped.
        _ = controller.abandonCompositionForVisibilityChange()
        XCTAssertEqual(
            controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch,
            2
        )

        controller.suspendRimeForVisibilityChange()
        // The owner is absent here; diagnostics must still expose epoch 2.
        XCTAssertEqual(
            controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch,
            2
        )

        let stale = ResponsiveRimeSnapshot(
            sessionEpoch: 1,
            revision: 1,
            actionID: "stale-visibility",
            output: RimeOutput(
                rawInput: "stale",
                composition: RimeComposition(
                    preeditText: "stale",
                    cursorPosition: 5
                )
            )
        )
        NotificationCenter.default.post(
            name: .threadAffineRimeSnapshotPublished,
            object: stale
        )

        let settleWhileStopped = expectation(description: "stale stopped-owner delivery settles")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            settleWhileStopped.fulfill()
        }
        await fulfillment(of: [settleWhileStopped], timeout: 1)
        XCTAssertEqual(
            presentationCount,
            0,
            "an epoch-1 snapshot must not paint while the owner is stopped"
        )

        controller.resumeRimeAfterVisibilityChange()
        XCTAssertEqual(
            controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch,
            2,
            "replacement owner must replay the coordinator lifecycle epoch"
        )

        NotificationCenter.default.post(
            name: .threadAffineRimeSnapshotPublished,
            object: stale
        )
        let settleAfterRestart = expectation(description: "stale restarted-owner delivery settles")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            settleAfterRestart.fulfill()
        }
        await fulfillment(of: [settleAfterRestart], timeout: 1)
        XCTAssertEqual(
            presentationCount,
            0,
            "an epoch-1 snapshot must remain stale after owner replacement"
        )

        controller.suspendRimeForVisibilityChange()
    }

    func testThreadAffineBridgePublishesOwnerNativeSessionSnapshot() {
        let expected = RimeSessionDiagnosticSnapshot(identity: 733, isValid: true)
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap(sessionSnapshot: expected)
        )

        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        XCTAssertEqual(controller.rimeEngine?.diagnosticSessionSnapshot, expected)
        XCTAssertEqual(
            controller.threadAffineRimeCoordinator?.diagnostics.diagnosticSessionSnapshot,
            expected
        )

        _ = controller.handle(.insertKey("n"))
        controller.threadAffineRimeCoordinator?.flushPending()
        XCTAssertEqual(controller.rimeEngine?.diagnosticSessionSnapshot, expected)
        controller.suspendRimeForVisibilityChange()
    }

    func testThreadAffineOwnerTimeoutIsNotReportedReady() {
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                FakeBootstrap(startupDelayNanoseconds: 50_000_000)
            ),
            configuration: ThreadAffineRimeOwnerConfiguration(
                ownerReadyTimeoutNanoseconds: 1_000_000
            )
        )
        defer { coordinator.shutdown() }

        XCTAssertFalse(coordinator.isOwnerReady)
        XCTAssertFalse(
            ThreadAffineRimeEngineBridge(coordinator: coordinator).isOwnerReady
        )
    }

    func testActiveKillFenceRejectsNewAcceptanceAndDrainsAcceptedBacklog() {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                FakeBootstrap(processEntered: entered, releaseFirst: release)
            )
        )

        coordinator.scheduleProcessKey("n")
        coordinator.scheduleProcessKey("i")
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)

        guard let fence = coordinator.issueActiveKillFence() else {
            return XCTFail("active kill must create one fence")
        }
        XCTAssertEqual(fence.acceptedThroughRevision, 2)
        XCTAssertNil(
            coordinator.performOrderedNow(.processKey("h")),
            "new work must be refused after the active-kill fence"
        )

        release.signal()
        guard let result = coordinator.drainActiveKillAndShutdown(
            after: fence,
            timeout: .now() + 2
        ) else {
            return XCTFail("fenced owner must return a shutdown result")
        }
        XCTAssertEqual(result.acceptedThrough, fence)
        XCTAssertTrue(result.acceptedBacklogDrained)
        XCTAssertTrue(result.ownerDestroyed)
        XCTAssertTrue(result.mailboxTerminal)
        XCTAssertTrue(result.deliveryDrained)
        XCTAssertTrue(result.isPositive)
        XCTAssertNil(coordinator.drainActiveKillAndShutdown(after: fence))
    }

    func testActiveKillTimeoutRetainsFencedOwnerUntilPositiveShutdown() {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                FakeBootstrap(processEntered: entered, releaseFirst: release)
            )
        )

        coordinator.scheduleProcessKey("n")
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        guard let fence = coordinator.issueActiveKillFence() else {
            return XCTFail("active kill must create one fence")
        }

        let timedOut = coordinator.drainActiveKillAndShutdown(
            after: fence,
            timeout: .now() + .milliseconds(5)
        )
        XCTAssertEqual(timedOut?.acceptedThrough, fence)
        XCTAssertFalse(timedOut?.isPositive ?? true)
        XCTAssertTrue(
            coordinator.isOwnerReady,
            "timeout must retain the owner rather than clearing its reference"
        )
        XCTAssertNil(
            coordinator.performOrderedNow(.processKey("i")),
            "the timeout path stays fenced and refuses new acceptance"
        )

        release.signal()
        let completed = coordinator.drainActiveKillAndShutdown(
            after: fence,
            timeout: .now() + 2
        )
        XCTAssertTrue(completed?.isPositive ?? false)
    }

    func testActiveKillDoesNotReuseSettledWatermarkAcrossEpochs() throws {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                FakeBootstrap(
                    processEntered: entered,
                    releaseFirst: release,
                    blockedProcessCall: 4
                )
            )
        )

        // Establish a high settled watermark in epoch 1.
        for key in ["n", "i", "h"] {
            XCTAssertNotNil(coordinator.performOrderedNow(.processKey(key)))
        }
        coordinator.bumpSessionEpoch(resetEngineSession: true)
        XCTAssertEqual(coordinator.diagnostics.sessionEpoch, 2)

        coordinator.scheduleProcessKey("n")
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        let fence = try XCTUnwrap(coordinator.issueActiveKillFence())
        XCTAssertEqual(fence.sessionEpoch, 2)
        XCTAssertEqual(fence.acceptedThroughRevision, 1)

        let timedOut = try XCTUnwrap(
            coordinator.drainActiveKillAndShutdown(
                after: fence,
                timeout: .now() + .milliseconds(5)
            )
        )
        XCTAssertFalse(
            timedOut.acceptedBacklogDrained,
            "epoch 1's settled watermark must not satisfy epoch 2's fence"
        )
        XCTAssertTrue(coordinator.isOwnerReady)
        XCTAssertNil(coordinator.performOrderedNow(.processKey("i")))

        release.signal()
        let completed = try XCTUnwrap(
            coordinator.drainActiveKillAndShutdown(after: fence, timeout: .now() + 2)
        )
        XCTAssertTrue(completed.isPositive)
        XCTAssertEqual(coordinator.completedPublishCount, 4)
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    func testPresentationAcknowledgementRequiresCompleteCanarySessionIdentity() throws {
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(FakeBootstrap())
        )
        coordinator.setCanarySessionInstance(1)
        let snapshot = try XCTUnwrap(
            coordinator.performOrderedNow(.processKey("n"))
        )

        XCTAssertEqual(coordinator.pendingPresentationIdentities.count, 1)
        coordinator.acknowledgePresentationTerminal(
            canarySessionInstance: 2,
            sessionEpoch: snapshot.sessionEpoch,
            revision: snapshot.revision
        )
        XCTAssertEqual(
            coordinator.pendingPresentationIdentities.count,
            1,
            "a new session must not consume an old session's pending terminal"
        )

        coordinator.acknowledgePresentationTerminal(
            canarySessionInstance: 1,
            sessionEpoch: snapshot.sessionEpoch,
            revision: snapshot.revision
        )
        XCTAssertTrue(coordinator.pendingPresentationIdentities.isEmpty)
        coordinator.suspendForVisibilityChange()
    }

    func testCanaryPaintRequiresPositiveSynchronousUIAcknowledgement() async {
        let terminalReceived = expectation(description: "failed-visible terminal")
        var observedTerminal: ResponsiveRimeCanaryPresentationTerminal?
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap()
        )
        controller.onResponsiveCanaryPresentationNeeded = { _ in false }
        controller.onResponsiveCanaryPresentationTerminal = { terminal in
            observedTerminal = terminal
            terminalReceived.fulfill()
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        controller.markResponsiveCanaryOwnerInstalled(
            runID: "paint-failure",
            modeGeneration: 1,
            sessionInstance: 1
        )

        _ = controller.handle(.insertKey("n"))
        await fulfillment(of: [terminalReceived], timeout: 2)

        guard let paint = observedTerminal?.paint,
              case .failedVisible(let reason) = paint
        else {
            controller.suspendRimeForVisibilityChange()
            return XCTFail("missing UI acknowledgement must not be recorded as PAINT")
        }
        XCTAssertEqual(reason, .uiSynchronizationFailed)
        controller.suspendRimeForVisibilityChange()
    }

    func testVisibilityPreterminationDoesNotConsumeFreshSessionPublish() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let twoTerminals = expectation(description: "old fenced plus fresh painted")
        twoTerminals.expectedFulfillmentCount = 2
        var terminals: [ResponsiveRimeCanaryPresentationTerminal] = []

        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap(processEntered: entered, releaseFirst: release)
        )
        controller.onResponsiveCanaryPresentationNeeded = { _ in true }
        controller.onResponsiveCanaryPresentationTerminal = { terminal in
            terminals.append(terminal)
            twoTerminals.fulfill()
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        controller.markResponsiveCanaryOwnerInstalled(
            runID: "visibility-identity",
            modeGeneration: 1,
            sessionInstance: 1
        )

        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()

        // Preterminate the owner-delivered publication while its MainActor
        // notification is still queued, then complete the visibility teardown.
        controller.beginResponsiveCanaryPresentationFence()
        controller.suspendRimeForVisibilityChange()
        controller.finalizeResponsiveCanaryFencedPresentations()
        _ = controller.abandonCompositionForVisibilityChange()
        XCTAssertTrue(controller.lastResponsiveCanaryVisibilityTeardown?.isPositive == true)

        controller.resumeRimeAfterVisibilityChange()
        controller.activateResponsiveCanarySessionInstance(
            runID: "visibility-identity",
            modeGeneration: 2,
            sessionInstance: 2
        )
        controller.resumeResponsiveCanaryPresentationAfterOwnerReady()
        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        release.signal()

        await fulfillment(of: [twoTerminals], timeout: 3)
        XCTAssertEqual(terminals.map(\.canarySessionInstance), [1, 2])
        XCTAssertEqual(terminals.first?.paint, .failedFencedBeforeVisible)
        XCTAssertEqual(terminals.last?.paint, .painted)
        controller.suspendRimeForVisibilityChange()
    }
    #endif

    func testVisibilityTeardownReceiptsCoverEveryAcceptedUnexecutedRevision() {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                FakeBootstrap(processEntered: entered, releaseFirst: release)
            )
        )
        defer {
            release.signal()
            coordinator.shutdown()
        }

        coordinator.scheduleProcessKey("n")
        coordinator.scheduleProcessKey("i")
        coordinator.scheduleProcessKey("h")
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)

        // This first call enqueues control-lane stop while revision 1 is still
        // executing. Its timeout must retain the owner and not hide receipts.
        let timedOut = coordinator.suspendForVisibilityChange(
            timeout: .now() + .milliseconds(5)
        )
        XCTAssertFalse(timedOut?.isPositive ?? true)
        XCTAssertTrue(coordinator.isOwnerReady)

        release.signal()
        guard let result = coordinator.suspendForVisibilityChange(
            timeout: .now() + 2
        ) else {
            return XCTFail("visibility teardown must expose its terminal result")
        }

        XCTAssertTrue(result.isPositive)
        XCTAssertEqual(result.abandonedReceipts.map(\.revision), [2, 3])
        XCTAssertEqual(
            result.abandonedReceipts.map(\.terminal),
            [.abandonedVisibility, .abandonedVisibility]
        )
        XCTAssertEqual(result.abandonedReceipts.map(\.actionID), ["pk-2", "pk-3"])
        XCTAssertFalse(coordinator.isOwnerReady)
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
        observePresentation(on: controller) { _ in
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
        #if T9_RESPONSIVE_CANARY_INTERNAL
        var presentationTerminals: [ResponsiveRimeCanaryPresentationTerminal] = []
        #endif

        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            FakeBootstrap(processEntered: entered, releaseFirst: release)
        )
        observePresentation(on: controller) { _ in
            paintCount += 1
            painted.fulfill()
        }
        #if T9_RESPONSIVE_CANARY_INTERNAL
        controller.onResponsiveCanaryPresentationTerminal = { terminal in
            presentationTerminals.append(terminal)
        }
        #endif
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
        XCTAssertEqual(controller.threadAffineRimeCoordinator?.completedPublishCount, 5)
        XCTAssertEqual(controller.threadAffineRimeCoordinator?.lastPublished?.revision, 5)
        XCTAssertEqual(controller.state.currentComposition, "nihao")
        #if T9_RESPONSIVE_CANARY_INTERNAL
        XCTAssertEqual(presentationTerminals.count, 5)
        XCTAssertEqual(
            Set(presentationTerminals.map(\.revision)),
            Set([1, 2, 3, 4, 5])
        )
        for terminal in presentationTerminals {
            if terminal.revision == 5 {
                XCTAssertEqual(
                    terminal.visibility,
                    .visible(presentationRevision: 5)
                )
                XCTAssertEqual(terminal.paint, .painted)
            } else {
                guard case .notVisibleCoalesced(
                    let absorbedRevisionRange,
                    let replacementRevision
                ) = terminal.visibility,
                      case .coalesced(
                          let paintedAbsorbedRange,
                          let paintedReplacementRevision
                      ) = terminal.paint
                else {
                    XCTFail("non-latest revision must have one coalesced terminal")
                    continue
                }
                XCTAssertEqual(
                    absorbedRevisionRange,
                    terminal.revision...terminal.revision
                )
                XCTAssertEqual(paintedAbsorbedRange, absorbedRevisionRange)
                XCTAssertEqual(paintedReplacementRevision, replacementRevision)
                XCTAssertGreaterThan(replacementRevision, terminal.revision)
            }
        }
        #endif
        controller.suspendRimeForVisibilityChange()
    }
}
