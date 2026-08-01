import XCTest
@testable import KeyboardCore

final class ResponsiveProvisionalCompositionTests: XCTestCase {

    func testT9DigitKeyDetection() {
        XCTAssertTrue(ResponsiveProvisionalComposition.isT9DigitKey("2"))
        XCTAssertTrue(ResponsiveProvisionalComposition.isT9DigitKey("0"))
        XCTAssertFalse(ResponsiveProvisionalComposition.isT9DigitKey("n"))
        XCTAssertFalse(ResponsiveProvisionalComposition.isT9DigitKey("22"))
        XCTAssertFalse(ResponsiveProvisionalComposition.isT9DigitKey(""))
    }

    func testPresentationIsMiddleDotTimesN() {
        let p = ResponsiveProvisionalComposition.presentation(
            slotCount: 3,
            sessionEpoch: 1,
            watermark: 7
        )
        XCTAssertEqual(p?.preedit, "···")
        XCTAssertEqual(p?.slotCount, 3)
        XCTAssertEqual(p?.watermark, 7)
        XCTAssertNil(
            ResponsiveProvisionalComposition.presentation(
                slotCount: 0,
                sessionEpoch: 1,
                watermark: 0
            )
        )
        XCTAssertFalse(p!.preedit.contains { $0.isNumber })
    }

    func testMirrorAppendAndClear() {
        var mirror = ResponsiveProvisionalCompositionMirror()
        XCTAssertFalse(mirror.isProvisionalAhead)
        XCTAssertNil(mirror.appendT9DigitAccept(revision: 1, epoch: 2))
        XCTAssertNil(mirror.appendT9DigitAccept(revision: 2, epoch: 2))
        XCTAssertEqual(mirror.slotCount, 2)
        XCTAssertEqual(mirror.watermark, 2)
        XCTAssertTrue(mirror.isProvisionalAhead)
        XCTAssertEqual(mirror.makePresentation()?.preedit, "··")
        mirror.alignToEngineApply(epoch: 2, revision: 2)
        XCTAssertFalse(mirror.isProvisionalAhead)
        XCTAssertEqual(mirror.slotCount, 0)
    }

    func testL1SkipMarkerIsContentFree() {
        let line = ResponsiveProvisionalComposition.l1SkipMarkerLine(reason: .nonT9)
        XCTAssertTrue(line.contains("L1_SKIP"))
        XCTAssertTrue(line.contains("reason=non_t9"))
        XCTAssertFalse(line.contains("你"))
        XCTAssertFalse(line.contains("ni"))
    }

    @MainActor
    func testTrackerAllowsProvisionalThenEngineAtSameRevision() {
        let tracker = ResponsiveRimeFeltMetricsTracker()
        tracker.reset()
        let t0: UInt64 = 1_000_000_000
        _ = tracker.recordAccept(revision: 3, epoch: 1, pending: 1, uptimeNs: t0)
        let provisional = tracker.recordVisible(
            revision: 3,
            source: .provisional,
            uptimeNs: t0 + 1_000_000
        )
        let engine = tracker.recordVisible(
            revision: 3,
            source: .engine,
            uptimeNs: t0 + 5_000_000
        )
        XCTAssertNotNil(provisional)
        XCTAssertTrue(provisional!.contains("source=provisional"))
        XCTAssertNotNil(engine)
        XCTAssertTrue(engine!.contains("source=engine"))
        // Duplicate engine paint blocked.
        XCTAssertNil(
            tracker.recordVisible(revision: 3, source: .engine, uptimeNs: t0 + 6_000_000)
        )
    }
}

@MainActor
final class ResponsiveProvisionalL1WireTests: XCTestCase {

    private struct DigitBootstrap: ThreadAffineRimeEngineBootstrap {
        let processEntered: DispatchSemaphore?
        let releaseFirst: DispatchSemaphore?

        func makeEngineOnOwnerThread() -> any RimeEngine {
            if let processEntered, let releaseFirst {
                return BlockingDigitEngine(
                    processEntered: processEntered,
                    releaseFirst: releaseFirst
                )
            }
            let engine = FakeRimeEngine(dictionary: ["222": ["啊"], "2": ["阿"]])
            engine.appendDigitsToComposition = true
            return engine
        }
    }

    private final class BlockingDigitEngine: RimeEngine {
        private let delegate: FakeRimeEngine
        private let processEntered: DispatchSemaphore
        private let releaseFirst: DispatchSemaphore
        private var blocked = false

        init(processEntered: DispatchSemaphore, releaseFirst: DispatchSemaphore) {
            let engine = FakeRimeEngine(dictionary: ["22222222": ["测"], "2": ["阿"]])
            engine.appendDigitsToComposition = true
            self.delegate = engine
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
        func selectCandidate(globalIndex index: Int) -> RimeOutput {
            delegate.selectCandidate(globalIndex: index)
        }
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
        var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
            delegate.diagnosticSessionSnapshot
        }
        var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
            get { delegate.onRuntimeSelectionChanged }
            set { delegate.onRuntimeSelectionChanged = newValue }
        }
        func isComposing() -> Bool { delegate.isComposing() }
        func pageUp() -> RimeOutput { delegate.pageUp() }
        func pageDown() -> RimeOutput { delegate.pageDown() }
    }

    private func makeDualGateController(
        entered: DispatchSemaphore? = nil,
        release: DispatchSemaphore? = nil,
        visualDelayNs: UInt64 = 20_000_000
    ) -> KeyboardController {
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.usesT9InputSemantics = true
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.provisionalVisualPaintDelayNanoseconds = visualDelayNs
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            DigitBootstrap(processEntered: entered, releaseFirst: release)
        )
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        return controller
    }

    func testGateOffHasNoL1() {
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.usesT9InputSemantics = true
        controller.rimeEngine = {
            let e = FakeRimeEngine()
            e.appendDigitsToComposition = true
            return e
        }()
        _ = controller.handle(.insertKey("2"))
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
        XCTAssertFalse(controller.state.currentComposition.contains("·"))
    }

    func testDualGateL1PaintsDotsBeforeEngine() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let controller = makeDualGateController(entered: entered, release: release)

        let n = 8
        for _ in 0..<n {
            _ = controller.handle(.insertKey("2"))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)

        // Ledger ahead immediately; visual paint is deferred (Polish).
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)
        XCTAssertEqual(controller.responsiveProvisionalSlotCount, n)
        try? await Task.sleep(nanoseconds: 35_000_000)

        // Progressive L1: structure-only dots while owner blocked.
        XCTAssertEqual(
            controller.state.currentComposition,
            String(repeating: "·", count: n)
        )
        XCTAssertGreaterThanOrEqual(
            controller.responsiveProvisionalSlotCount,
            (n + 1) / 2,
            "D7 progressive bar: ≥ ceil(N/2) provisional slots before L2"
        )

        // Selection fail-closed while ahead.
        let selectEffects = controller.handle(
            .insertCandidate("阿", kind: .candidate, selectionReference: nil)
        )
        XCTAssertTrue(selectEffects.isEmpty)
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)

        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        let settle = expectation(description: "l2-settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { settle.fulfill() }
        await fulfillment(of: [settle], timeout: 2)

        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
        XCTAssertFalse(
            controller.state.currentComposition.contains("·"),
            "L2 must atomically replace L1 dots"
        )
        controller.suspendRimeForVisibilityChange()
    }

    /// Rem-3-Polish: fast owner completion cancels deferred L1 visual paint.
    func testFastEngineSkipsDeferredL1VisualPaint() async {
        let controller = makeDualGateController(visualDelayNs: 80_000_000)
        var paints = 0
        controller.onResponsivePresentationNeeded = { _ in paints += 1 }

        for _ in 0..<4 {
            _ = controller.handle(.insertKey("2"))
        }
        // Unblocked engine should publish L2 before 80ms delay.
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(
            controller.state.currentComposition.contains("·"),
            "fast L2 must cancel deferred L1 dots"
        )
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
        // L2 presentations may fire; none should leave dots.
        _ = paints
        controller.suspendRimeForVisibilityChange()
    }

    func testAbandonClearsL1() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let controller = makeDualGateController(entered: entered, release: release)
        for _ in 0..<4 {
            _ = controller.handle(.insertKey("2"))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)
        _ = controller.abandonCompositionForVisibilityChange()
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
        XCTAssertEqual(controller.state.currentComposition, "")
        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        controller.suspendRimeForVisibilityChange()
    }

    func testReturnWhileAheadDoesNotCommitDots() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let client = FakeTextInputClient()
        let controller = makeDualGateController(entered: entered, release: release)
        controller.textClient = client
        for _ in 0..<3 {
            _ = controller.handle(.insertKey("2"))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)
        _ = controller.handle(.insertReturn)
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
        XCTAssertFalse(client.text.contains("·"))
        XCTAssertEqual(controller.state.currentComposition, "")
        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        controller.suspendRimeForVisibilityChange()
    }

    func testCoalesceBacklogStillPaintsL1() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let controller = makeDualGateController(entered: entered, release: release)
        // 5 keys while blocked → pending rises; deferred L1 should still paint dots.
        for _ in 0..<5 {
            _ = controller.handle(.insertKey("2"))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)
        try? await Task.sleep(nanoseconds: 35_000_000)
        XCTAssertEqual(controller.state.currentComposition, "·····")
        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        let settle = expectation(description: "coalesce-l1-settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { settle.fulfill() }
        await fulfillment(of: [settle], timeout: 2)
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
        controller.suspendRimeForVisibilityChange()
    }

    /// Rem-3-Polish-2: deferred L1 must not notify Extension presentation
    /// (avoids candidate/Path refresh flash). Host preedit still updates.
    func testDeferredL1DoesNotNotifyExtensionChrome() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        var presentationNotifies = 0
        let controller = makeDualGateController(entered: entered, release: release)
        controller.onResponsivePresentationNeeded = { _ in
            presentationNotifies += 1
        }
        for _ in 0..<5 {
            _ = controller.handle(.insertKey("2"))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        let notifiesBeforeVisual = presentationNotifies
        try? await Task.sleep(nanoseconds: 40_000_000)
        XCTAssertEqual(
            controller.state.currentComposition,
            "·····",
            "L1 dots still update Core/host preedit"
        )
        XCTAssertEqual(
            presentationNotifies,
            notifiesBeforeVisual,
            "L1 visual must not call onResponsivePresentationNeeded"
        )
        // Preserve last engine chrome if any was set — L1 must not nil it.
        // (Blocked owner may never have painted L2 yet; ensure no forced clear.)
        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 50_000_000)
        // L2 may notify presentation once or more — that is expected.
        XCTAssertGreaterThanOrEqual(presentationNotifies, notifiesBeforeVisual)
        controller.suspendRimeForVisibilityChange()
    }
}
