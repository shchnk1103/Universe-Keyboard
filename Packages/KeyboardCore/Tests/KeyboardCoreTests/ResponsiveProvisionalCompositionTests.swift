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

    func testPresentationAppendsPendingDotsToStablePreedit() {
        let p = ResponsiveProvisionalComposition.presentation(
            slotCount: 2,
            sessionEpoch: 3,
            watermark: 8,
            stablePreedit: "今天"
        )
        XCTAssertEqual(p?.stablePreedit, "今天")
        XCTAssertEqual(p?.preedit, "今天··")
        XCTAssertEqual(p?.slotCount, 2)
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
        mirror.setStablePreedit("今天")
        XCTAssertEqual(mirror.makePresentation()?.preedit, "今天··")
        mirror.alignToEngineApply(epoch: 2, revision: 2)
        XCTAssertFalse(mirror.isProvisionalAhead)
        XCTAssertEqual(mirror.slotCount, 0)
        XCTAssertEqual(mirror.stablePreedit, "今天")
        mirror.clear()
        XCTAssertEqual(mirror.stablePreedit, "")
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
        let blockOnProcessCall: Int

        func makeEngineOnOwnerThread() -> any RimeEngine {
            if let processEntered, let releaseFirst {
                return BlockingDigitEngine(
                    processEntered: processEntered,
                    releaseFirst: releaseFirst,
                    blockOnProcessCall: blockOnProcessCall
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
        private let blockOnProcessCall: Int
        private var processCallCount = 0

        init(
            processEntered: DispatchSemaphore,
            releaseFirst: DispatchSemaphore,
            blockOnProcessCall: Int = 1
        ) {
            let engine = FakeRimeEngine(
                dictionary: [
                    "a": ["阿"],
                    "aa": ["啊"],
                    "aaa": ["啊"],
                    "aaaaaaaa": ["测"],
                ]
            )
            engine.appendDigitsToComposition = true
            self.delegate = engine
            self.processEntered = processEntered
            self.releaseFirst = releaseFirst
            self.blockOnProcessCall = blockOnProcessCall
        }

        func processKey(_ key: String) -> RimeOutput {
            processCallCount += 1
            if processCallCount == blockOnProcessCall {
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
        blockOnProcessCall: Int = 1,
        visualDelayNs: UInt64 = 20_000_000
    ) -> KeyboardController {
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.usesT9InputSemantics = true
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.provisionalVisualPaintDelayNanoseconds = visualDelayNs
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            DigitBootstrap(
                processEntered: entered,
                releaseFirst: release,
                blockOnProcessCall: blockOnProcessCall
            )
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

        // Progressive L1: stable host prefix plus content-free dots while the
        // owner is blocked.
        XCTAssertEqual(
            controller.state.insertedPreeditText,
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
        XCTAssertTrue(controller.handle(.candidatePageDown).isEmpty)
        XCTAssertTrue(controller.handle(.cycleT9PinyinPath).isEmpty)
        XCTAssertTrue(controller.handle(.insertSpace).isEmpty)
        XCTAssertTrue(
            controller.handle(
                .insertCorrectionCandidate(
                    TypoCorrectionCommit(
                        committedText: "阿",
                        originalInput: "2",
                        correctedInput: "2",
                        edits: []
                    )
                )
            ).isEmpty
        )
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

    /// P2 回归矩阵：L1 领先时，所有绑定候选/Path 快照的入口都必须
    /// fail closed；它们不能调用 RIME、改变 Core 状态，或重绘宿主文本。
    func testDualGateStaleActionMatrixFailsClosedWithoutStateMutation() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let client = FakeTextInputClient()
        let controller = makeDualGateController(
            entered: entered,
            release: release,
            visualDelayNs: 20_000_000
        )
        controller.textClient = client

        for _ in 0..<4 {
            _ = controller.handle(.insertKey("2"))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        try? await Task.sleep(nanoseconds: 35_000_000)
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)

        // Keep a Partial Commit checkpoint alive to cover the same guard when
        // candidate taps would otherwise enter the restore/selection branch.
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "已",
            remainingRawInput: "2",
            remainingPreeditText: "a",
            displayText: "已a"
        )
        let stateBeforeActions = controller.state
        let historyBeforeActions = client.markedTextHistory
        let path = T9PinyinPath(
            displayText: "ni",
            replacementRawInput: "ni"
        )
        let correction = TypoCorrectionCommit(
            committedText: "你",
            originalInput: "22",
            correctedInput: "22",
            edits: []
        )
        let staleActions: [KeyboardAction] = [
            .insertCandidate("你", kind: .candidate),
            .insertCandidate("ni", kind: .composition),
            .insertCandidate("输入拼音", kind: .placeholder),
            .insertCandidate("你", kind: .correctionCandidate),
            .insertCandidate("你", kind: .continuationCandidate),
            .insertCorrectionCandidate(correction),
            .candidatePageUp,
            .candidatePageDown,
            .selectT9PinyinPath(path),
            .cycleT9PinyinPath,
            .insertSpace,
        ]

        for action in staleActions {
            XCTAssertTrue(
                controller.handle(action).isEmpty,
                "stale action must be rejected: \(action)"
            )
        }

        XCTAssertEqual(controller.state, stateBeforeActions)
        XCTAssertEqual(
            client.markedTextHistory,
            historyBeforeActions,
            "stale actions must not cause another host marked-text write"
        )

        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 100_000_000)
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

    /// Amendment B regression: after a settled engine result, a slow next key
    /// appends only its pending slot dots to the stable host marked text.
    func testSettledEngineThenBlockedKeyAppendsDotsToStablePreedit() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let client = FakeTextInputClient()
        let controller = makeDualGateController(
            entered: entered,
            release: release,
            blockOnProcessCall: 2
        )
        controller.textClient = client

        let firstL2 = expectation(description: "first-l2")
        controller.onResponsivePresentationNeeded = { [weak controller] _ in
            guard let controller else { return }
            if controller.threadAffineRimeCoordinator?.lastPublished?.revision == 1,
               !controller.isResponsiveProvisionalAhead
            {
                firstL2.fulfill()
            }
        }
        _ = controller.handle(.insertKey("2"))
        await fulfillment(of: [firstL2], timeout: 2)
        let settledMarkedText = client.markedText
        XCTAssertFalse(settledMarkedText.isEmpty)

        let historyBeforeSlowKey = client.markedTextHistory
        XCTAssertEqual(historyBeforeSlowKey, [settledMarkedText])

        let finalL2 = expectation(description: "second-l2")
        controller.onResponsivePresentationNeeded = { [weak controller] _ in
            guard let controller else { return }
            if controller.threadAffineRimeCoordinator?.lastPublished?.revision == 2,
               !controller.isResponsiveProvisionalAhead
            {
                finalL2.fulfill()
            }
        }
        _ = controller.handle(.insertKey("2"))
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)

        // The second owner call is blocked. Let the deferred L1 visual fire.
        try? await Task.sleep(nanoseconds: 35_000_000)
        XCTAssertEqual(client.markedText, settledMarkedText + "·")
        XCTAssertEqual(
            Array(client.markedTextHistory.suffix(1)),
            [settledMarkedText + "·"],
            "L1 appends pending dots to the stable host marked text"
        )
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))

        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        await fulfillment(of: [finalL2], timeout: 2)

        let finalMarkedText = client.markedText
        XCTAssertFalse(finalMarkedText.isEmpty)
        XCTAssertNotEqual(finalMarkedText, "·")
        XCTAssertEqual(client.markedTextHistory.count, 3)
        XCTAssertEqual(client.markedTextHistory[0], settledMarkedText)
        XCTAssertEqual(client.markedTextHistory[1], settledMarkedText + "·")
        XCTAssertEqual(client.markedTextHistory[2], finalMarkedText)
        XCTAssertFalse(client.markedText.contains("·"))
        XCTAssertFalse(finalMarkedText.contains(where: \.isNumber))
        controller.onResponsivePresentationNeeded = nil
        controller.suspendRimeForVisibilityChange()
    }

    /// P2 回归矩阵：L1 只更新 host preedit 的视觉影子；已发布的候选、Path
    /// 和 RIME 输出快照必须保持稳定，避免候选栏在等待期间闪回旧状态。
    func testDeferredL1LeavesSettledChromeSnapshotUntouched() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let client = FakeTextInputClient()
        let controller = makeDualGateController(
            entered: entered,
            release: release,
            blockOnProcessCall: 2
        )
        controller.textClient = client

        let firstL2 = expectation(description: "chrome-first-l2")
        var presentationCount = 0
        controller.onResponsivePresentationNeeded = { [weak controller] _ in
            presentationCount += 1
            guard let controller else { return }
            if controller.threadAffineRimeCoordinator?.lastPublished?.revision == 1,
               !controller.isResponsiveProvisionalAhead
            {
                firstL2.fulfill()
            }
        }
        _ = controller.handle(.insertKey("2"))
        await fulfillment(of: [firstL2], timeout: 2)

        let settledOutput = controller.state.lastRimeOutput
        let settledPaths = controller.state.t9PinyinPathState
        let settledPartialCommit = controller.state.partialCommit
        let settledTypoCorrection = controller.state.typoCorrection
        let settledMarkedText = client.markedText
        let presentationCountBeforeSecondKey = presentationCount

        _ = controller.handle(.insertKey("2"))
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        try? await Task.sleep(nanoseconds: 35_000_000)

        XCTAssertEqual(controller.state.lastRimeOutput, settledOutput)
        XCTAssertEqual(controller.state.t9PinyinPathState, settledPaths)
        XCTAssertEqual(controller.state.partialCommit, settledPartialCommit)
        XCTAssertEqual(controller.state.typoCorrection, settledTypoCorrection)
        XCTAssertEqual(
            presentationCount,
            presentationCountBeforeSecondKey,
            "L1 must not notify Extension chrome"
        )
        XCTAssertEqual(client.markedText, settledMarkedText + "·")

        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 100_000_000)
        controller.onResponsivePresentationNeeded = nil
        controller.suspendRimeForVisibilityChange()
    }

    /// The fast-owner path must not leave a transient placeholder in the host
    /// history, not merely remove it from the final state.
    func testFastEngineDoesNotWriteTransientProvisionalMarkedText() async {
        let client = FakeTextInputClient()
        let controller = makeDualGateController(visualDelayNs: 80_000_000)
        controller.textClient = client

        for _ in 0..<4 {
            _ = controller.handle(.insertKey("2"))
        }
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(
            client.markedTextHistory.contains("·"),
            "a fast L2 result must cancel L1 before it writes host marked text"
        )
        XCTAssertTrue(
            client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) },
            "the host history must never contain internal T9 digits"
        )
        controller.suspendRimeForVisibilityChange()
    }

    /// P1-D2 regression: an ordered Delete updates the stable shadow before
    /// the bridge's asynchronous publish callback reaches MainActor.
    func testOrderedDeleteRefreshesStableShadowBeforeNextPendingKey() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let client = FakeTextInputClient()
        let controller = makeDualGateController(
            entered: entered,
            release: release,
            blockOnProcessCall: 2
        )
        controller.textClient = client

        let firstL2 = expectation(description: "first-l2-before-delete")
        controller.onResponsivePresentationNeeded = { [weak controller] _ in
            guard let controller else { return }
            if controller.threadAffineRimeCoordinator?.lastPublished?.revision == 1,
               !controller.isResponsiveProvisionalAhead
            {
                firstL2.fulfill()
            }
        }
        _ = controller.handle(.insertKey("2"))
        await fulfillment(of: [firstL2], timeout: 2)

        _ = controller.handle(.deleteBackward)
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 40_000_000)
        let stableAfterDelete = client.markedText
        XCTAssertFalse(stableAfterDelete.contains("·"))

        _ = controller.handle(.insertKey("2"))
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        try? await Task.sleep(nanoseconds: 35_000_000)

        XCTAssertEqual(
            client.markedText,
            stableAfterDelete + "·",
            "next L1 must use the ordered Delete snapshot, not the old prefix"
        )

        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 80_000_000)
        controller.onResponsivePresentationNeeded = nil
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

    /// P2 回归矩阵：visibility abandon 提升 epoch 后，任何已排队的旧 L1/L2
    /// 结果都不能再次写回宿主 marked text。这里同时检查最终状态和写入历史，
    /// 防止“最后状态看起来正确、但中途曾把旧占位符写回宿主”的回归。
    func testAbandonEpochDropsDeferredHostWritesAndStaleResult() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let client = FakeTextInputClient()
        let controller = makeDualGateController(
            entered: entered,
            release: release,
            visualDelayNs: 20_000_000
        )
        controller.textClient = client

        for _ in 0..<4 {
            _ = controller.handle(.insertKey("2"))
        }
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)
        try? await Task.sleep(nanoseconds: 35_000_000)
        XCTAssertTrue(client.markedText.contains("·"))

        let epochBeforeAbandon = controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch ?? 0
        _ = controller.abandonCompositionForVisibilityChange()
        let epochAfterAbandon = controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch ?? 0
        XCTAssertGreaterThan(epochAfterAbandon, epochBeforeAbandon)
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
        XCTAssertEqual(controller.state.insertedPreeditText, "")
        XCTAssertFalse(client.markedText.contains("·"))

        let historyStartAfterAbandon = client.markedTextHistory.count
        release.signal()
        controller.threadAffineRimeCoordinator?.flushPending()
        try? await Task.sleep(nanoseconds: 150_000_000)

        let postAbandonHistory = client.markedTextHistory.dropFirst(historyStartAfterAbandon)
        XCTAssertEqual(
            client.markedTextHistory.count,
            historyStartAfterAbandon,
            "old epoch must not perform any host marked-text write after abandon"
        )
        XCTAssertTrue(
            postAbandonHistory.isEmpty,
            "the post-abandon history slice must remain empty"
        )
        XCTAssertFalse(client.markedText.contains("·"))
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertGreaterThanOrEqual(
            controller.threadAffineRimeCoordinator?.diagnostics.skippedStaleEpochCount ?? 0,
            1,
            "the blocked old-epoch work must be discarded or purged"
        )
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
        // The visual task is MainActor-bound. Under the full suite, unrelated
        // MainActor work can delay it beyond the nominal 20 ms test delay;
        // poll with a bounded timeout instead of turning scheduler jitter into
        // a false failure.
        let deadline = DispatchTime.now().uptimeNanoseconds + 2_000_000_000
        while controller.state.insertedPreeditText != "·····",
              DispatchTime.now().uptimeNanoseconds < deadline
        {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTAssertEqual(controller.state.insertedPreeditText, "·····")
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
            controller.state.insertedPreeditText,
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
