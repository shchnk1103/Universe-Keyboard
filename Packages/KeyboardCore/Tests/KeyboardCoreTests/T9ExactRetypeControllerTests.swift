import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

@MainActor
final class T9ExactRetypeControllerTests: XCTestCase {
    private enum Fault: Sendable {
        case none, rejectRestore, doubleWrong, recoveryFailsOnce, unexpectedCommit, schemaFallback
    }

    private final class Ledger: Sendable {
        struct Facts: Sendable, Equatable {
            var keys = 0
            var replacements: [String] = []
            var recoveries = 0
            var resets = 0
            var deletes = 0
            var windows = 0
        }
        private let state = Mutex(Facts())
        func record(_ action: String, input: String = "") {
            state.withLock {
                switch action {
                case "key": $0.keys += 1
                case "replace": $0.replacements.append(input)
                case "recover": $0.recoveries += 1
                case "reset": $0.resets += 1
                case "delete": $0.deletes += 1
                case "window": $0.windows += 1
                default: break
                }
            }
        }
        var facts: Facts { state.withLock { $0 } }
    }

    private struct Bootstrap: ThreadAffineRimeEngineBootstrap {
        let ledger: Ledger
        let fault: Fault
        func makeEngineOnOwnerThread() -> any RimeEngine { Engine(ledger: ledger, fault: fault) }
    }

    private final class Engine: RimeEngine {
        private let delegate: FakeRimeEngine
        private let ledger: Ledger
        private let fault: Fault
        private var softAttempted = false
        private var recoveryCount = 0
        init(ledger: Ledger, fault: Fault) {
            self.ledger = ledger
            self.fault = fault
            let comments = [
                "9": ["y"], "94": ["yi"], "946": ["yin"], "9462": ["yin c"],
                "94624": ["yin ci"], "yin": ["yin"], "yin2": ["yin c"],
                "yinci": ["yin ci"], "yinci9": ["yin ci z"], "946249": ["yin ci z"],
            ]
            delegate = FakeRimeEngine(dictionary: comments.mapValues { _ in ["word"] }, comments: comments)
            delegate.appendDigitsToComposition = true
            delegate.seedRuntimeSelection(
                .init(baseSchemaID: "rime_ice", layoutStyle: .nineKey, t9ReadinessMatched: true))
            delegate.diagnosticSessionSnapshot = .init(identity: 1, isValid: true)
        }
        var runtimeSelection: RimeRuntimeSelection? { delegate.runtimeSelection }
        var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? { delegate.diagnosticSessionSnapshot }
        var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
            get { delegate.onRuntimeSelectionChanged }
            set { delegate.onRuntimeSelectionChanged = newValue }
        }
        func processKey(_ key: String) -> RimeOutput {
            ledger.record("key")
            if ledger.facts.keys > 5 { delegate.comments["94624"] = ["xin ai"] }
            return delegate.processKey(key)
        }
        func replaceInput(_ input: String) -> RimeOutput {
            ledger.record("replace", input: input)
            if input == "yinci", !softAttempted {
                softAttempted = true
                switch fault {
                case .none: break
                case .rejectRestore: return RimeOutput()
                case .doubleWrong, .recoveryFailsOnce, .schemaFallback: return delegate.replaceInput("foo")
                case .unexpectedCommit:
                    return RimeOutput(rawInput: "yinci", candidates: [], committedText: "unexpected")
                }
            }
            if softAttempted, input == "94624",
                fault == .doubleWrong || fault == .recoveryFailsOnce || fault == .schemaFallback
            {
                return delegate.replaceInput("bar")
            }
            if fault == .recoveryFailsOnce, recoveryCount == 1, input == "946249" {
                return delegate.replaceInput("bar")
            }
            return delegate.replaceInput(input)
        }
        func recoverSession() {
            ledger.record("recover")
            recoveryCount += 1
            if fault == .schemaFallback { delegate.recoverActualSchemaID = "luna_pinyin" }
            delegate.recoverSession()
            delegate.diagnosticSessionSnapshot = .init(identity: UInt64(recoveryCount + 1), isValid: true)
        }
        func resetSession() { ledger.record("reset"); delegate.resetSession() }
        func deleteBackward() -> RimeOutput { ledger.record("delete"); return delegate.deleteBackward() }
        func candidateWindow(from index: Int, limit: Int) -> RimeCandidateWindow {
            ledger.record("window"); return delegate.candidateWindow(from: index, limit: limit)
        }
        func selectCandidate(at index: Int) -> RimeOutput { delegate.selectCandidate(at: index) }
        func selectCandidate(globalIndex index: Int) -> RimeOutput { delegate.selectCandidate(globalIndex: index) }
        func isComposing() -> Bool { delegate.isComposing() }
        func pageUp() -> RimeOutput { delegate.pageUp() }
        func pageDown() -> RimeOutput { delegate.pageDown() }
        func suspendForVisibilityChange() { delegate.suspendForVisibilityChange() }
        func resumeAfterVisibilityChange() { delegate.resumeAfterVisibilityChange() }
    }

    @MainActor
    private final class Fixture {
        let controller = KeyboardController()
        let host = FakeTextInputClient()
        let ledger = Ledger()
        let coordinator: ThreadAffineRimeSessionCoordinator
        var presentations = 0
        init(fault: Fault, enabled: Bool, prefix: String) throws {
            host.text = prefix
            controller.textClient = host
            controller.state.inputMode = .chinese
            controller.usesT9InputSemantics = true
            controller.isResponsiveRimePipelineEnabled = true
            controller.isThreadAffineRimeOwnerEnabled = true
            controller.isT9ExactRetypeRecoveryEnabled = enabled
            controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
                Bootstrap(ledger: ledger, fault: fault))
            controller.rebuildResponsiveRimeCoordinatorIfNeeded()
            coordinator = try XCTUnwrap(controller.threadAffineRimeCoordinator)
            controller.onResponsivePresentationNeeded = { [weak self] _ in self?.presentations += 1 }
        }
        func stop() {
            controller.onResponsivePresentationNeeded = nil
            coordinator.shutdown()
        }
        func waitReady() async throws {
            let deadline = Date().addingTimeInterval(2)
            while !coordinator.isOwnerReady, Date() < deadline { try await Task.sleep(nanoseconds: 1_000_000) }
            XCTAssertTrue(coordinator.isOwnerReady)
        }
        func key(_ key: String, source: String) async throws {
            let previous = presentations
            _ = controller.handle(.insertKey(key))
            let deadline = Date().addingTimeInterval(2)
            while Date() < deadline {
                if presentations > previous, controller.state.t9PinyinPathState.segmentSourceDigits == source { break }
                try await Task.sleep(nanoseconds: 1_000_000)
            }
            XCTAssertGreaterThan(presentations, previous)
            XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, source)
        }
    }

    private func makeFixture(fault: Fault = .none, enabled: Bool = true, prefix: String = "") async throws -> Fixture {
        let fixture = try Fixture(fault: fault, enabled: enabled, prefix: prefix)
        do {
            try await fixture.waitReady()
            var source = ""
            for key in "94624" {
                source.append(key)
                try await fixture.key(String(key), source: source)
            }
            XCTAssertEqual(fixture.host.markedText.replacingOccurrences(of: " ", with: ""), "yinci")
            return fixture
        } catch { fixture.stop(); throw error }
    }

    private func deleteAndRetypeFirstTail(_ fixture: Fixture) async throws {
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(fixture.controller.state.t9PinyinPathState.segmentSourceDigits, "9462")
        _ = fixture.controller.handle(.deleteBackward)
        XCTAssertEqual(fixture.controller.state.t9PinyinPathState.segmentSourceDigits, "946")
        try await fixture.key("2", source: "9462")
    }

    func testExactReplayRestoresYinciWithOnePaintAndOneReplacement() async throws {
        let f = try await makeFixture()
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        let before = f.ledger.facts
        let paints = f.presentations
        let historyStart = f.host.markedTextHistory.count
        try await f.key("4", source: "94624")
        XCTAssertEqual(f.controller.state.lastRimeOutput?.rawInput, "yinci")
        XCTAssertEqual(f.host.markedText.replacingOccurrences(of: " ", with: ""), "yinci")
        XCTAssertEqual(f.presentations - paints, 1)
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(before.replacements.count)), ["yinci"])
        XCTAssertEqual(f.ledger.facts.keys - before.keys, 1)
        XCTAssertFalse(
            f.host.markedTextHistory.dropFirst(historyStart).contains {
                $0.replacingOccurrences(of: " ", with: "") == "xinai"
            })
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
        XCTAssertTrue(f.controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        XCTAssertNil(f.controller.state.t9PinyinPathState.selectedPath)
        XCTAssertEqual(f.controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        let restored = f.ledger.facts
        try await f.key("9", source: "946249")
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(restored.replacements.count)), ["946249"])
    }

    func testDisabledStagingKeepsExistingReinterpretationWithoutSoftCall() async throws {
        let f = try await makeFixture(enabled: false)
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        let before = f.ledger.facts
        try await f.key("4", source: "94624")
        XCTAssertEqual(f.controller.state.lastRimeOutput?.rawInput, "94624")
        XCTAssertEqual(f.host.markedText.replacingOccurrences(of: " ", with: ""), "xinai")
        XCTAssertEqual(f.ledger.facts.replacements.count, before.replacements.count)
    }

    func testDifferentTailDoesNotRequestOriginalInterpretation() async throws {
        let f = try await makeFixture()
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        let before = f.ledger.facts
        try await f.key("3", source: "94623")
        XCTAssertEqual(f.ledger.facts.replacements.count, before.replacements.count)
        XCTAssertFalse(f.controller.t9ExactRetypeRecovery.hasHistory)
    }

    func testRejectedSoftAttemptRollsBackOnceWithoutFreezeOrCommit() async throws {
        let f = try await makeFixture(fault: .rejectRestore)
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        let before = f.ledger.facts
        try await f.key("4", source: "94624")
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(before.replacements.count)), ["yinci", "94624"])
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
        XCTAssertNil(f.controller.state.lastRimeOutput?.committedText)
    }

    func testDoubleWrongReplyPreservesLastDigitAndNextKeyRecoversExactlyOnce() async throws {
        let f = try await makeFixture(fault: .doubleWrong)
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        let before = f.ledger.facts
        try await f.key("4", source: "94624")
        XCTAssertTrue(f.controller.isT9InputRecoveryPending)
        XCTAssertEqual(f.controller.state.lastRimeOutput?.rawInput, "94624")
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(before.replacements.count)), ["yinci", "94624"])
        let failed = f.ledger.facts
        let history = f.host.markedTextHistory.count
        try await f.key("9", source: "946249")
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
        XCTAssertEqual(f.ledger.facts.recoveries - failed.recoveries, 1)
        XCTAssertEqual(f.ledger.facts.keys, failed.keys)
        XCTAssertEqual(f.ledger.facts.resets, failed.resets)
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(failed.replacements.count)), ["946249"])
        XCTAssertTrue(f.host.markedTextHistory.dropFirst(history).allSatisfy { !$0.isEmpty })
    }

    func testFrozenSelectionCommitPagingAndDirectEntriesHaveNoSideEffects() async throws {
        let f = try await makeFixture(fault: .doubleWrong)
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        try await f.key("4", source: "94624")
        XCTAssertTrue(f.controller.isT9InputRecoveryPending)
        let before = f.ledger.facts
        let state = f.controller.state
        let marked = f.host.markedText
        let text = f.host.text
        let path = T9PinyinPath(displayText: "yin", replacementRawInput: "yin24")
        let correction = TypoCorrectionCommit(committedText: "word", originalInput: "x", correctedInput: "y", edits: [])
        let actions: [KeyboardAction] = [
            .insertSpace, .insertReturn, .insertCandidate("word", kind: .candidate),
            .insertCorrectionCandidate(correction), .insertDirectText("text"), .insertEmoji("emoji"),
            .selectT9PinyinPath(path), .cycleT9PinyinPath, .candidatePageUp, .candidatePageDown,
            .pressT9CommonPunctuation, .pressKaomoji, .insertKey("a"),
        ]
        for action in actions { _ = f.controller.handle(action) }
        _ = f.controller.handleInsertCandidate("word", kind: .candidate)
        _ = f.controller.handleSelectT9PinyinPath(path)
        _ = f.controller.handleCandidatePageDown()
        XCTAssertEqual(f.controller.state, state)
        XCTAssertEqual(f.host.markedText, marked)
        XCTAssertEqual(f.host.text, text)
        XCTAssertEqual(f.ledger.facts, before)
        XCTAssertTrue(f.controller.t9PinyinPathWindow().paths.isEmpty)
        XCTAssertFalse(f.controller.hasSelectableT9PinyinPaths())
    }

    func testDeleteFromFrozenSessionRecoversShortenedFullSourceWithoutNativeDelete() async throws {
        let f = try await makeFixture(fault: .doubleWrong)
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        try await f.key("4", source: "94624")
        let before = f.ledger.facts
        _ = f.controller.handle(.deleteBackward)
        XCTAssertEqual(f.controller.state.t9PinyinPathState.segmentSourceDigits, "9462")
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(before.replacements.count)), ["9462"])
        XCTAssertEqual(f.ledger.facts.deletes, before.deletes)
        XCTAssertEqual(f.ledger.facts.recoveries - before.recoveries, 1)
    }

    func testRepeatedFailureRejectsNextKeyThenDeleteCancelsOnlyUncommittedSegment() async throws {
        let f = try await makeFixture(fault: .recoveryFailsOnce, prefix: "prefix")
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        try await f.key("4", source: "94624")
        let text = f.host.text
        _ = f.controller.handle(.insertKey("9"))
        XCTAssertEqual(f.controller.t9ExactRetypeRecovery.notice, .failed)
        XCTAssertEqual(f.controller.state.t9PinyinPathState.segmentSourceDigits, "94624")
        XCTAssertEqual(f.host.text, text)
        let failed = f.ledger.facts
        _ = f.controller.handle(.insertKey("9"))
        XCTAssertEqual(f.ledger.facts, failed)
        _ = f.controller.handle(.deleteBackward)
        XCTAssertEqual(f.host.text, "prefix")
        XCTAssertTrue(f.host.markedText.isEmpty)
        XCTAssertTrue(f.controller.isT9InputRecoveryPending)
        try await f.key("9", source: "9")
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
        XCTAssertTrue(f.host.text.hasPrefix("prefix"))
    }

    func testUnexpectedCommitDoesNotCommitOrTryRollback() async throws {
        let f = try await makeFixture(fault: .unexpectedCommit, prefix: "prefix")
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        let before = f.ledger.facts
        try await f.key("4", source: "94624")
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(before.replacements.count)), ["yinci"])
        XCTAssertEqual(f.controller.t9ExactRetypeRecovery.notice, .failed)
        XCTAssertFalse(f.host.text.contains("unexpected"))
        _ = f.controller.handle(.deleteBackward)
        XCTAssertEqual(f.host.text, "prefix")
    }

    func testUnbindRetainsFreshFenceWithoutWritingOldMarkedTextToNewHost() async throws {
        let f = try await makeFixture(fault: .doubleWrong)
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        try await f.key("4", source: "94624")
        let oldHistory = f.host.markedTextHistory
        f.controller.textClient = nil
        XCTAssertEqual(f.host.markedTextHistory, oldHistory)
        let newHost = FakeTextInputClient()
        newHost.text = "new-host"
        f.controller.textClient = newHost
        try await f.key("9", source: "9")
        XCTAssertTrue(newHost.text.hasPrefix("new-host"))
        XCTAssertFalse(newHost.markedText.contains("yin"))
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
    }

    func testControlledOneSlotFreezeDeleteValidatesEmptyTargetAndKeepsCommittedPrefix() async throws {
        let f = try Fixture(fault: .none, enabled: true, prefix: "prefix")
        defer { f.stop() }
        try await f.waitReady()
        try await f.key("9", source: "9")
        let bridge = try XCTUnwrap(f.controller.rimeEngine)
        _ = f.coordinator.withPublishHandlerSuppressed { bridge.replaceInput("foo") }
        // Defensive empty-target branch. The R174 two-syllable trigger itself
        // does not naturally start a one-slot freeze; do not claim that repro.
        f.controller.t9ExactRetypeRecovery.freeze(
            verifiedDigits: "9", namespace: try XCTUnwrap(f.controller.t9RetypeNamespace), terminal: false)
        let before = f.ledger.facts
        _ = f.controller.handle(.deleteBackward)
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
        XCTAssertTrue(f.controller.state.currentComposition.isEmpty)
        XCTAssertEqual(f.host.text, "prefix")
        XCTAssertTrue(f.host.markedText.isEmpty)
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(before.replacements.count)), [""])
        XCTAssertEqual(f.ledger.facts.recoveries - before.recoveries, 1)
        XCTAssertEqual(f.ledger.facts.deletes, before.deletes)
    }

    func testSchemaFallbackNeverReplaysOldDigitsAndFresh26KeyStartIsVerified() async throws {
        let f = try await makeFixture(fault: .schemaFallback, prefix: "prefix")
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        try await f.key("4", source: "94624")
        let before = f.ledger.facts
        _ = f.controller.handle(.insertKey("9"))
        XCTAssertEqual(f.controller.t9ExactRetypeRecovery.notice, .failed)
        XCTAssertFalse(f.controller.usesT9InputSemantics)
        XCTAssertEqual(
            f.ledger.facts.replacements, before.replacements,
            "Recovery selecting 26-key must not receive the old T9 source.")
        XCTAssertEqual(f.controller.state.t9PinyinPathState.segmentSourceDigits, "94624")
        _ = f.controller.handle(.deleteBackward)
        XCTAssertEqual(f.host.text, "prefix")
        let cancelled = f.ledger.facts
        _ = f.controller.handle(.insertKey("a"))
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
        XCTAssertEqual(f.controller.state.lastRimeOutput?.rawInput, "a")
        XCTAssertEqual(f.host.text, "prefixa")
        XCTAssertEqual(Array(f.ledger.facts.replacements.dropFirst(cancelled.replacements.count)), ["a"])
        XCTAssertEqual(f.ledger.facts.recoveries - cancelled.recoveries, 1)
        XCTAssertEqual(f.ledger.facts.keys, cancelled.keys)
    }

    func testModeSwitchCancelsUnknownCompositionAndAllowsEnglishText() async throws {
        let f = try await makeFixture(fault: .doubleWrong, prefix: "prefix")
        defer { f.stop() }
        try await deleteAndRetypeFirstTail(f)
        try await f.key("4", source: "94624")
        _ = f.controller.handle(.toggleInputMode)
        XCTAssertEqual(f.controller.state.inputMode, .english)
        XCTAssertEqual(f.host.text, "prefix")
        _ = f.controller.handle(.insertKey("a"))
        XCTAssertEqual(f.host.text, "prefixa")
        _ = f.controller.handle(.toggleInputMode)
        try await f.key("9", source: "9")
        XCTAssertFalse(f.controller.isT9InputRecoveryPending)
    }
}
