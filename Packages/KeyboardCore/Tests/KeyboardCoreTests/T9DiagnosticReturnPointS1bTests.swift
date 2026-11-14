import XCTest

@testable import KeyboardCore

@MainActor
final class T9DiagnosticReturnPointS1bTests: XCTestCase {
    override func tearDown() {
        T9DiagnosticAdmission.shared.resetForTesting()
        super.tearDown()
    }

    func testCycleRecoveryPendingIsNotStarted() {
        let controller = armed()
        controller.t9ExactRetypeRecovery.freeze(
            verifiedDigits: "64",
            namespace: T9ExactRetypeRecovery.Namespace(
                ownerID: UUID(), sessionEpoch: 1, editingGeneration: 1),
            terminal: true)
        _ = controller.handleCycleT9PinyinPath()
        expectCycle(.notStarted)
    }

    func testCycleEmptyPathsIsNotStarted() {
        let controller = armed()
        _ = controller.handleCycleT9PinyinPath()
        expectCycle(.notStarted)
    }

    func testCycleMissingEngineIsNotStarted() {
        let controller = armed()
        let path = path("ni", raw: "ni")
        controller.state.t9PinyinPathState.compactPaths = [path]
        controller.rimeEngine = nil
        _ = controller.handleCycleT9PinyinPath()
        expectCycle(.notStarted)
    }

    func testCycleZeroGenerationIsNotStarted() {
        let fixture = staged(generation: 0, provenance: 0)
        _ = fixture.controller.handleCycleT9PinyinPath()
        expectCycle(.notStarted)
        XCTAssertEqual(fixture.engine.replaceInputCallCount, 0)
    }

    func testCycleUnauthorizedPathIsNotStarted() {
        let fixture = staged(authorized: false)
        _ = fixture.controller.handleCycleT9PinyinPath()
        expectCycle(.notStarted)
        XCTAssertEqual(fixture.engine.replaceInputCallCount, 0)
    }

    func testCycleStaleRevisionIsNotStarted() {
        let fixture = staged(pathRevision: 9, stateRevision: 1)
        _ = fixture.controller.handleCycleT9PinyinPath()
        expectCycle(.notStarted)
        XCTAssertEqual(fixture.engine.replaceInputCallCount, 0)
    }

    func testCycleIncompatibleRawIsNotStarted() {
        let fixture = staged(display: "a", replacement: "a")
        _ = fixture.controller.handleCycleT9PinyinPath()
        expectCycle(.notStarted)
        XCTAssertEqual(fixture.engine.replaceInputCallCount, 0)
    }

    func testCycleSucceededUsesRequestResultNotRestored() {
        let canary = "CANARY'ninh"
        let fixture = staged(display: "ni", replacement: "ni")
        fixture.engine.replaceInputScript = [output("ni", preedit: canary, candidates: ["你"])]
        let off = KeyboardController()
        off.rimeEngine = fixture.engine
        off.usesT9InputSemantics = true
        off.state = fixture.controller.state
        off.t9DiagnosticCaptureEnabled = false
        fixture.engine.resetCallCounts()
        _ = off.handleCycleT9PinyinPath()
        let offCount = fixture.engine.replaceInputCallCount
        fixture.engine.replaceInputScript = [output("ni", preedit: canary, candidates: ["你"])]
        fixture.engine.resetCallCounts()
        _ = fixture.controller.handleCycleT9PinyinPath()
        let event = onlyCycle()
        XCTAssertEqual(event.terminal, .succeeded)
        XCTAssertEqual(event.candidateBand, .nonzero)
        XCTAssertEqual(event.preeditShape, .segmented)
        XCTAssertEqual(event.usable, .yes)
        XCTAssertEqual(event.exact, .yes)
        XCTAssertFalse(T9DiagnosticAdmission.shared.exportedText().contains(canary))
        XCTAssertEqual(fixture.engine.replaceInputCallCount, offCount)
    }

    func testCycleRolledBackKeepsZeroBandFromFailedResult() {
        let fixture = staged(display: "ni", replacement: "ni")
        fixture.engine.replaceInputScript = [
            output("zz", preedit: "zz", candidates: []),
            output("64", preedit: "64", candidates: ["你"]),
        ]
        _ = fixture.controller.handleCycleT9PinyinPath()
        let event = onlyCycle()
        XCTAssertEqual(event.terminal, .rolledBack)
        XCTAssertEqual(event.candidateBand, .zero)
        XCTAssertEqual(event.exact, .no)
    }

    func testCycleRollbackFailedWhenRestoredUnusable() {
        let fixture = staged(display: "ni", replacement: "ni")
        fixture.engine.replaceInputScript = [
            output("zz", preedit: "zz", candidates: []),
            output("64", preedit: "64", candidates: []),
        ]
        _ = fixture.controller.handleCycleT9PinyinPath()
        XCTAssertEqual(onlyCycle().terminal, .rollbackFailed)
        XCTAssertEqual(onlyCycle().candidateBand, .zero)
    }

    func testCycleRollbackFailedWhenRestoredRawMismatches() {
        let fixture = staged(display: "ni", replacement: "ni")
        fixture.engine.replaceInputScript = [
            output("zz", preedit: "zz", candidates: []),
            output("99", preedit: "99", candidates: ["你"]),
        ]
        _ = fixture.controller.handleCycleT9PinyinPath()
        XCTAssertEqual(onlyCycle().terminal, .rollbackFailed)
    }

    func testDirectTapEmitsZeroCycleEvents() {
        let controller = armed()
        _ = controller.handleSelectT9PinyinPath(path("ming", raw: "ming"))
        XCTAssertTrue(T9DiagnosticAdmission.shared.cycles().isEmpty)
        XCTAssertTrue(T9DiagnosticAdmission.shared.deletes().isEmpty)
    }

    func testSelectedDigitUndoRestoredYes() {
        let fixture = deleteBase()
        let selected = path("ni", raw: "ni")
        fixture.controller.state.t9PinyinPathState.selectedDigitUndo = T9SelectedDigitUndo(
            raw: "6", source: "6", selected: selected, paths: [selected], order: ["ni"])
        fixture.controller.state.t9PinyinPathState.selectedPath = selected
        fixture.controller.state.lastRimeOutput = output("64", preedit: "64", candidates: ["你"])
        fixture.engine.seedSessionComposition("64")
        fixture.engine.deleteBackwardScript = [output("6", preedit: "6", candidates: ["吗"])]
        _ = fixture.controller.handle(.deleteBackward)
        let event = onlyDelete()
        XCTAssertEqual(event.branch, .selectedDigitUndo)
        XCTAssertEqual(event.restored, .yes)
    }

    func testSelectedDigitUndoRestoredNo() {
        let fixture = deleteBase()
        let selected = path("ni", raw: "ni")
        fixture.controller.state.t9PinyinPathState.selectedDigitUndo = T9SelectedDigitUndo(
            raw: "6", source: "6", selected: selected, paths: [selected], order: ["ni"])
        fixture.controller.state.t9PinyinPathState.selectedPath = selected
        fixture.controller.state.lastRimeOutput = output("64", preedit: "64", candidates: ["你"])
        fixture.engine.seedSessionComposition("64")
        fixture.engine.deleteBackwardScript = [output("99", preedit: "99", candidates: ["你"])]
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .selectedDigitUndo)
        XCTAssertEqual(onlyDelete().restored, .no)
    }

    func testIdentityDeleteReturnsNilWithoutEvent() {
        let fixture = deleteBase()
        fixture.controller.state.lastRimeOutput = output("6", preedit: "6", candidates: ["吗"])
        let effect = fixture.controller.handleT9CompositionIdentityDeleteIfNeeded(using: fixture.engine)
        XCTAssertNil(effect)
        XCTAssertTrue(T9DiagnosticAdmission.shared.deletes().isEmpty)
    }

    func testIdentityDeleteEmptiedIsNotApplicable() {
        let fixture = deleteBase()
        fixture.controller.state.t9PinyinPathState.segmentSourceDigits = "6"
        fixture.controller.state.t9PinyinPathState.confirmedSegmentValues = ["ni"]
        fixture.controller.state.lastRimeOutput = output("6", preedit: "ni", candidates: ["你"])
        fixture.engine.seedSessionComposition("6")
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .identityDelete)
        XCTAssertEqual(onlyDelete().restored, .notApplicable)
    }

    func testIdentityDeleteFinalRestoredYesWhenRefineSucceeds() {
        let fixture = deleteBase()
        let selected = path("n", raw: "n")
        fixture.controller.state.t9PinyinPathState.segmentSourceDigits = "64"
        fixture.controller.state.t9PinyinPathState.selectedPath = selected
        fixture.controller.state.lastRimeOutput = output("64", preedit: "64", candidates: ["你"])
        fixture.engine.seedSessionComposition("64")
        fixture.engine.dictionary["6"] = ["你"]
        fixture.engine.dictionary["n"] = ["你"]
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .identityDelete)
        XCTAssertEqual(onlyDelete().restored, .yes)
    }

    func testIdentityDeleteFinalRestoredNoWhenRefineMisses() {
        let fixture = deleteBase()
        let selected = path("n", raw: "n")
        fixture.controller.state.t9PinyinPathState.segmentSourceDigits = "64"
        fixture.controller.state.t9PinyinPathState.selectedPath = selected
        fixture.controller.state.lastRimeOutput = output("64", preedit: "64", candidates: ["你"])
        fixture.engine.seedSessionComposition("64")
        fixture.engine.replaceInputShouldFail = true
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .identityDelete)
        XCTAssertEqual(onlyDelete().restored, .no)
    }

    func testPartialCommitRestoreEmitsZero() {
        let fixture = deleteBase()
        fixture.controller.state.partialCommit = PartialCommitState(
            confirmedText: "你", remainingRawInput: "4", remainingPreeditText: "4",
            displayText: "你4",
            checkpoint: PartialCommitCheckpoint(
                previousRawInput: "64", previousPreeditText: "64", previousDisplayText: "64"))
        fixture.engine.seedSessionComposition("4")
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertTrue(T9DiagnosticAdmission.shared.deletes().isEmpty)
    }

    func testNumberSuffixDeleteEmitsZero() {
        let fixture = deleteBase()
        fixture.controller.state.partialCommit = PartialCommitState(
            confirmedText: "你", remainingRawInput: "64", remainingPreeditText: "64",
            displayText: "你64", source: .numberSuffix)
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertTrue(T9DiagnosticAdmission.shared.deletes().isEmpty)
    }

    func testAutoAnchorRestoredIsOther() {
        let fixture = deleteBase()
        fixture.controller.state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
            phase: .accepted, sourceDigits: "64")
        fixture.engine.replaceInputScript = [output("64", preedit: "64", candidates: ["你"])]
        fixture.engine.seedSessionComposition("ni")
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .other)
        XCTAssertEqual(onlyDelete().restored, .notApplicable)
    }

    func testAutoAnchorFailedIsOther() {
        let fixture = deleteBase()
        fixture.controller.state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
            phase: .accepted, sourceDigits: "")
        fixture.engine.seedSessionComposition("64")
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .other)
        XCTAssertEqual(onlyDelete().restored, .notApplicable)
    }

    func testVisibleDeleteIsOther() {
        let fixture = deleteBase()
        fixture.controller.state.insertedPreeditText = "ni"
        fixture.controller.state.lastRimeOutput = output("64", preedit: "ni", candidates: ["你"])
        fixture.engine.seedSessionComposition("64")
        fixture.engine.replaceInputScript = [output("n", preedit: "n", candidates: ["你"])]
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .other)
        XCTAssertEqual(onlyDelete().restored, .notApplicable)
    }

    func testEngineDeleteRestoredNo() {
        let fixture = deleteBase()
        fixture.controller.state.insertedPreeditText = "你"
        fixture.controller.state.lastRimeOutput = output("64", preedit: "64", candidates: ["你"])
        fixture.engine.seedSessionComposition("64")
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .engineDelete)
        XCTAssertEqual(onlyDelete().restored, .no)
    }

    func testEngineDeleteRestoredYesWhenFocusActuallyRestores() {
        let fixture = deleteBase()
        fixture.controller.usesT9InputSemantics = false
        fixture.controller.state.insertedPreeditText = "你"
        fixture.controller.state.t9PinyinPathState.segmentSourceDigits = "64"
        fixture.controller.state.lastRimeOutput = output("64", preedit: "64", candidates: ["你"])
        fixture.engine.seedSessionComposition("64")
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(onlyDelete().branch, .engineDelete)
        XCTAssertEqual(onlyDelete().restored, .yes)
    }

    private func armed() -> KeyboardController {
        let controller = KeyboardController()
        controller.usesT9InputSemantics = true
        controller.t9DiagnosticCaptureEnabled = true
        return controller
    }

    private func path(_ display: String, raw: String, revision: UInt64 = 0) -> T9PinyinPath {
        T9PinyinPath(displayText: display, replacementRawInput: raw, compositionRevision: revision)
    }

    private func output(_ raw: String, preedit: String, candidates: [String]) -> RimeOutput {
        RimeOutput(
            rawInput: raw,
            composition: RimeComposition(preeditText: preedit, cursorPosition: preedit.utf8.count),
            candidates: candidates.map { RimeCandidate(text: $0) })
    }

    private func staged(
        display: String = "ni", replacement: String = "ni", generation: UInt64 = 1,
        provenance: UInt64 = 1, authorized: Bool = true, pathRevision: UInt64 = 0,
        stateRevision: UInt64 = 0
    ) -> (controller: KeyboardController, engine: FakeRimeEngine) {
        let engine = FakeRimeEngine()
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice", layoutStyle: .nineKey, t9ReadinessMatched: true))
        let controller = armed()
        controller.rimeEngine = engine
        let choice = path(display, raw: replacement, revision: pathRevision)
        controller.state.compositionRevision = stateRevision
        controller.state.lastRimeOutput = output("64", preedit: "64", candidates: ["你"])
        controller.state.t9PinyinPathState = T9PinyinPathState(
            compactPaths: [choice],
            rawInputGeneration: generation,
            provenanceRevision: provenance,
            issuedReplacementKeys: authorized ? [choice.replacementRawInput] : [],
            issuedPathIDs: authorized ? [choice.id] : [])
        return (controller, engine)
    }

    private func deleteBase() -> (controller: KeyboardController, engine: FakeRimeEngine) {
        let engine = FakeRimeEngine()
        let controller = armed()
        controller.rimeEngine = engine
        return (controller, engine)
    }

    private func expectCycle(_ terminal: T9CycleDiagnostic.Terminal) {
        let event = onlyCycle()
        XCTAssertEqual(event.terminal, terminal)
        XCTAssertEqual(event.candidateBand, .notApplicable)
        XCTAssertEqual(event.preeditShape, .notApplicable)
        XCTAssertEqual(event.usable, .notApplicable)
        XCTAssertEqual(event.exact, .notApplicable)
    }

    private func onlyCycle() -> T9CycleDiagnostic {
        let events = T9DiagnosticAdmission.shared.cycles()
        XCTAssertEqual(events.count, 1)
        return events[0]
    }

    private func onlyDelete() -> T9DeleteDiagnostic {
        let events = T9DiagnosticAdmission.shared.deletes()
        XCTAssertEqual(events.count, 1)
        return events[0]
    }
}
