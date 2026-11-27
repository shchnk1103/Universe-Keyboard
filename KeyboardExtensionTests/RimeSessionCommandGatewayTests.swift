import KeyboardCore
import XCTest

/// PB-016 PR-1 §3.2: the six release paths of the quick-menu session
/// transaction. Every path must leave `isRuntimeResselectionInFlight == false`
/// — the gate never sticks — and no release path may rebuild chrome, write
/// back preferences or revive the menu.
///
/// The gateway source is compiled into this target (project exception), so
/// these are real behavior tests, not source-contract strings.
nonisolated final class RimeSessionCommandGatewayTests: XCTestCase {
    // MARK: - Dispatch mode contract (arch r3 Note-2: per-call re-query)

    @MainActor
    func testFailClosedDispatchCallsDirectHeldEngineAndRequeriesGatesEveryCall() {
        let controller = KeyboardController()
        let engine = ProbeEngine()
        controller.rimeEngine = engine
        let gateway = RimeSessionCommandGateway(controller: controller)

        guard case .schema(true) = gateway.reselectSchema(requested: "luna_pinyin") else {
            return XCTFail("fail-closed dispatch must call the direct-held engine")
        }
        XCTAssertEqual(engine.selectedSchemaID, "luna_pinyin")
        guard case .option(.confirmed(true)) = gateway.setOption(name: "traditionalization", value: true)
        else {
            return XCTFail("fail-closed option dispatch must return the engine result")
        }
        XCTAssertEqual(engine.optionWrites, ["traditionalization": true])

        // Readiness mismatch: gates flipped on but no owner was installed —
        // the gateway must refuse, not fall through to a stale mode decision.
        controller.isResponsiveRimePipelineEnabled = true
        guard case .unavailable = gateway.reselectSchema(requested: "luna_pinyin") else {
            return XCTFail("gate-on without owner must be unavailable")
        }
        XCTAssertEqual(engine.selectedSchemaID, "luna_pinyin", "refusal must not touch the engine")

        // Per-call re-query: gates off again → direct dispatch works anew.
        controller.isResponsiveRimePipelineEnabled = false
        guard case .schema(true) = gateway.reselectSchema(requested: "rime_ice") else {
            return XCTFail("re-queried fail-closed dispatch must work again")
        }
        XCTAssertEqual(engine.selectedSchemaID, "rime_ice")
    }

    @MainActor
    func testUnavailableWhenEngineMissingAndFailClosedKeepsNoTrackedSelection() {
        let controller = KeyboardController()
        let gateway = RimeSessionCommandGateway(controller: controller)

        guard case .unavailable = gateway.reselectSchema(requested: "luna_pinyin") else {
            return XCTFail("missing engine must be unavailable")
        }
        // §3.2 #6: fail-closed has no asynchronous owner work to track; the
        // gate stays released and a release call is a safe no-op.
        XCTAssertNil(gateway.beginSelection())
        XCTAssertFalse(gateway.isRuntimeResselectionInFlight)
        gateway.abandonInFlightSelection()
        XCTAssertFalse(gateway.isRuntimeResselectionInFlight)
    }

    @MainActor
    func testSerialQueuedResselectionReleasesThroughControllerConsumer() throws {
        let controller = KeyboardController()
        controller.isResponsiveRimePipelineEnabled = true
        let engine = ProbeEngine()
        controller.rimeEngine = engine
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        let gateway = RimeSessionCommandGateway(controller: controller)
        let spy = GatewayConsumerSpy(gateway: gateway)
        controller.quickMenuSessionCommandConsumer = spy

        let selection = try XCTUnwrap(gateway.beginSelection())
        XCTAssertEqual(
            selection.sessionEpoch,
            controller.responsiveRimeCoordinator?.diagnostics.sessionEpoch
        )
        XCTAssertTrue(gateway.isRuntimeResselectionInFlight)
        XCTAssertNil(gateway.beginSelection(), "single-flight: a second begin must be refused")

        guard case .queued(let receipt) = gateway.reselectSchema(requested: "luna_pinyin") else {
            return XCTFail("gate-on serial dispatch must queue the command")
        }
        XCTAssertEqual(receipt.sessionEpoch, selection.sessionEpoch)
        XCTAssertEqual(engine.selectedSchemaID, nil, "queued work must not run on the caller stack")

        controller.responsiveRimeCoordinator?.flushPending()

        XCTAssertEqual(
            spy.deliveredActionIDs,
            [receipt.actionID],
            "the controller must deliver the command completion to the consumer"
        )
        XCTAssertEqual(engine.selectedSchemaID, "luna_pinyin")
        XCTAssertFalse(
            gateway.isRuntimeResselectionInFlight,
            "the published completion must release the gate through the consumer"
        )
    }

    // MARK: - §3.2 release path table

    /// #1 epoch 校验通过、selection 成功：committed 回调恰好一次，旗标清零。
    @MainActor
    func testReleasePath1MatchingEpochCompletionCommitsAndReleases() {
        let gateway = RimeSessionCommandGateway(controller: KeyboardController())
        let selection = gateway.beginSelection(sessionEpoch: 5)
        var committed: [RimeSessionCommandGateway.Selection] = []
        gateway.onSelectionCommitted = { committed.append($0) }

        gateway.consumeCommandResult(
            ResponsiveRimeSnapshot(
                sessionEpoch: 5, revision: 2, actionID: "command-schema",
                output: RimeOutput(), schemaSelectionSucceeded: true
            ),
            presentationEpoch: 5
        )

        XCTAssertEqual(committed.map(\.id), [selection?.id])
        XCTAssertFalse(gateway.isRuntimeResselectionInFlight)
    }

    /// #2 过期完成（presentation epoch 已前移：期间 reload/可见性清理/组字重置）：
    /// 丢弃引擎结果但必须清旗标；不重建、不写回、不复活。
    @MainActor
    func testReleasePath2ExpiredCompletionReleasesWithoutCommit() {
        let gateway = RimeSessionCommandGateway(controller: KeyboardController())
        gateway.beginSelection(sessionEpoch: 5)
        var committedCount = 0
        gateway.onSelectionCommitted = { _ in committedCount &+= 1 }

        gateway.consumeCommandResult(
            ResponsiveRimeSnapshot(
                sessionEpoch: 5, revision: 2, actionID: "command-schema",
                output: RimeOutput(), schemaSelectionSucceeded: true
            ),
            presentationEpoch: 6
        )

        XCTAssertEqual(committedCount, 0)
        XCTAssertFalse(gateway.isRuntimeResselectionInFlight, "expired completion must still release")
    }

    /// #2 变体：来自更旧、已被释放的选择的迟到完成，不得释放新的在途选择。
    @MainActor
    func testStaleCompletionDoesNotReleaseNewerTrackedSelection() {
        let gateway = RimeSessionCommandGateway(controller: KeyboardController())
        gateway.beginSelection(sessionEpoch: 5)
        gateway.abandonInFlightSelection()
        let newer = gateway.beginSelection(sessionEpoch: 6)
        var committedCount = 0
        gateway.onSelectionCommitted = { _ in committedCount &+= 1 }

        gateway.consumeCommandResult(
            ResponsiveRimeSnapshot(
                sessionEpoch: 5, revision: 2, actionID: "command-schema",
                output: RimeOutput(), schemaSelectionSucceeded: true
            ),
            presentationEpoch: 6
        )

        XCTAssertEqual(committedCount, 0)
        XCTAssertEqual(gateway.inFlightSelectionForTesting, newer, "newer selection must survive")
    }

    /// #3 失败完成：清旗标，不 committed，不写回。
    @MainActor
    func testReleasePath3FailedCompletionReleasesWithoutCommit() {
        let gateway = RimeSessionCommandGateway(controller: KeyboardController())
        gateway.beginSelection(sessionEpoch: 5)
        var committedCount = 0
        gateway.onSelectionCommitted = { _ in committedCount &+= 1 }

        gateway.consumeCommandResult(
            ResponsiveRimeSnapshot(
                sessionEpoch: 5, revision: 2, actionID: "command-schema",
                output: RimeOutput(), schemaSelectionSucceeded: false
            ),
            presentationEpoch: 5
        )

        XCTAssertEqual(committedCount, 0)
        XCTAssertFalse(gateway.isRuntimeResselectionInFlight)
    }

    /// #4/#5 cleanup / 直接 reload（abandon 钩子）：立即释放；迟到完成按
    /// 未跟踪完成处理——不再 committed、不再有第二次释放副作用。
    @MainActor
    func testReleasePaths4And5AbandonReleasesAndLateCompletionIsUntracked() {
        let gateway = RimeSessionCommandGateway(controller: KeyboardController())
        gateway.beginSelection(sessionEpoch: 5)
        var committedCount = 0
        gateway.onSelectionCommitted = { _ in committedCount &+= 1 }

        gateway.abandonInFlightSelection()
        XCTAssertFalse(gateway.isRuntimeResselectionInFlight)

        gateway.consumeCommandResult(
            ResponsiveRimeSnapshot(
                sessionEpoch: 5, revision: 2, actionID: "command-schema",
                output: RimeOutput(), schemaSelectionSucceeded: true
            ),
            presentationEpoch: 5
        )
        XCTAssertEqual(committedCount, 0, "abandoned completion must not rebuild chrome")
    }

    /// option 快照不含选择生命周期：在途选择不受影响（§3.1 非生命周期型）。
    @MainActor
    func testOptionResultSnapshotDoesNotTouchSelectionLifecycle() {
        let gateway = RimeSessionCommandGateway(controller: KeyboardController())
        let selection = gateway.beginSelection(sessionEpoch: 5)
        var committedCount = 0
        gateway.onSelectionCommitted = { _ in committedCount &+= 1 }

        gateway.consumeCommandResult(
            ResponsiveRimeSnapshot(
                sessionEpoch: 5, revision: 3, actionID: "command-option",
                output: RimeOutput(), optionResult: .confirmed(true)
            ),
            presentationEpoch: 5
        )

        XCTAssertEqual(committedCount, 0)
        XCTAssertEqual(gateway.inFlightSelectionForTesting, selection)
    }
}

/// Forwards controller deliveries into the gateway while recording what
/// reached the consumer, so delivery failures are distinguishable from
/// release failures.
@MainActor
private final class GatewayConsumerSpy: RimeSessionCommandConsuming {
    let gateway: RimeSessionCommandGateway
    private(set) var deliveredActionIDs: [String] = []

    init(gateway: RimeSessionCommandGateway) {
        self.gateway = gateway
    }

    func consumeCommandResult(_ snapshot: ResponsiveRimeSnapshot, presentationEpoch: UInt64) {
        deliveredActionIDs.append(snapshot.actionID)
        gateway.consumeCommandResult(snapshot, presentationEpoch: presentationEpoch)
    }

    func abandonInFlightSelection() {
        gateway.abandonInFlightSelection()
    }
}

/// Minimal scripted engine for gateway dispatch probes. Option/schema results
/// are recorded so tests can assert fail-closed MainActor direct calls.
@MainActor
private final class ProbeEngine: RimeEngine {
    var schemaSelectionSucceeds = true
    private(set) var selectedSchemaID: String?
    private(set) var optionWrites: [String: Bool] = [:]
    var optionOutcome: RimeOptionResult = .confirmed(true)
    var runtimeSelection: RimeRuntimeSelection?
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)?
    private var rawInput = ""

    func selectSchema(_ schemaID: String) -> Bool {
        guard schemaSelectionSucceeds else { return false }
        selectedSchemaID = schemaID
        rawInput = ""
        return true
    }

    func setOption(_ name: String, value: Bool) -> RimeOptionResult {
        guard case .confirmed = optionOutcome else { return optionOutcome }
        optionWrites[name] = value
        return .confirmed(value)
    }

    func getOption(_ name: String) -> RimeOptionResult {
        guard case .confirmed = optionOutcome else { return optionOutcome }
        return .confirmed(optionWrites[name] ?? false)
    }

    func replaceInput(_ input: String) -> RimeOutput {
        rawInput = input
        return RimeOutput()
    }

    func processKey(_ key: String) -> RimeOutput { RimeOutput() }
    func selectCandidate(at index: Int) -> RimeOutput { RimeOutput() }
    func selectCandidate(globalIndex index: Int) -> RimeOutput { RimeOutput() }
    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        RimeCandidateWindow(candidates: [], startIndex: 0, nextIndex: 0, hasMoreCandidates: false)
    }

    func deleteBackward() -> RimeOutput { RimeOutput() }
    func resetSession() { rawInput = "" }
    func recoverSession() {}
    func suspendForVisibilityChange() {}
    func resumeAfterVisibilityChange() {}
    func isComposing() -> Bool { !rawInput.isEmpty }
    func pageUp() -> RimeOutput { RimeOutput() }
    func pageDown() -> RimeOutput { RimeOutput() }
}
