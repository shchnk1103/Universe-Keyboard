import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

@MainActor
final class PartialCommitFailureProtectionTests: XCTestCase {
    private enum Fault: Sendable { case none, recoverInvalid, wrongRaw, unexpectedCommit, changedSchema }

    private final class Recorder: Sendable {
        struct Facts: Sendable {
            var calls: [String] = []
            var fault: Fault = .none
            var dropNext = false
            var created = 0
            var destroyed = 0
            var onOwner = true
        }
        private let state = Mutex(Facts())
        let destroyed = DispatchSemaphore(value: 0)
        func snapshot() -> Facts { state.withLock { $0 } }
        func armDrop() { state.withLock { $0.dropNext = true } }
        func setFault(_ fault: Fault) { state.withLock { $0.fault = fault } }
        func consumeDrop() -> Bool {
            state.withLock {
                let drop = $0.dropNext; $0.dropNext = false; return drop
            }
        }
        func born() { state.withLock { $0.created += 1 } }
        func died() { state.withLock { $0.destroyed += 1 }; destroyed.signal() }
        func record(_ call: String, owner: ObjectIdentifier) {
            state.withLock {
                $0.calls.append(call)
                $0.onOwner = $0.onOwner && !Thread.isMainThread && owner == ObjectIdentifier(Thread.current)
            }
        }
    }

    private struct Bootstrap: ThreadAffineRimeEngineBootstrap {
        let recorder: Recorder
        func makeEngineOnOwnerThread() -> any RimeEngine { Engine(recorder: recorder) }
    }

    private final class Engine: RimeEngine {
        let recorder: Recorder
        let owner = ObjectIdentifier(Thread.current)
        let delegate = FakeRimeEngine(
            dictionary: [
                "nihaoanpai": ["你好安排", "你好", "拟好安排"],
                "anpai": ["安排", "按排", "安派"], "x": ["新", "心", "欣"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]])
        var valid = true
        var selection = RimeRuntimeSelection(
            baseSchemaID: "rime_ice", layoutStyle: .twentySixKey, t9ReadinessMatched: false)
        init(recorder: Recorder) { self.recorder = recorder; recorder.born() }
        deinit { recorder.died() }
        func record(_ call: String) { recorder.record(call, owner: owner) }
        func paged(_ output: RimeOutput) -> RimeOutput {
            guard output.composition != nil else { return output }
            return RimeOutput(
                rawInput: output.rawInput, composition: output.composition,
                candidates: Array(output.candidates.prefix(2)), committedText: output.committedText,
                hasMorePages: output.candidates.count > 2, highlightedIndex: output.highlightedIndex)
        }
        func processKey(_ key: String) -> RimeOutput {
            record("process:\(key)")
            return recorder.consumeDrop() ? RimeOutput() : paged(delegate.processKey(key))
        }
        func selectCandidate(at index: Int) -> RimeOutput {
            record("select"); return paged(delegate.selectCandidate(at: index))
        }
        func selectCandidate(globalIndex index: Int) -> RimeOutput {
            record("selectGlobal"); return paged(delegate.selectCandidate(globalIndex: index))
        }
        func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
            record("window"); return delegate.candidateWindow(from: globalIndex, limit: limit)
        }
        func resetSession() { record("reset"); delegate.resetSession() }
        func recoverSession() {
            record("recover"); delegate.resetSession()
            valid = recorder.snapshot().fault != .recoverInvalid
            if recorder.snapshot().fault == .changedSchema {
                selection = RimeRuntimeSelection(
                    baseSchemaID: "rime_ice", layoutStyle: .nineKey, t9ReadinessMatched: true)
            }
        }
        func replaceInput(_ input: String) -> RimeOutput {
            record("replace:\(input)")
            switch recorder.snapshot().fault {
            case .wrongRaw:
                return RimeOutput(
                    rawInput: "wrong", composition: RimeComposition(preeditText: "wrong", cursorPosition: 5))
            case .unexpectedCommit: return RimeOutput(committedText: "不应提交")
            default: return paged(delegate.replaceInput(input))
            }
        }
        func deleteBackward() -> RimeOutput { record("delete"); return paged(delegate.deleteBackward()) }
        func isComposing() -> Bool { record("isComposing"); return delegate.isComposing() }
        func pageUp() -> RimeOutput { record("pageUp"); return paged(delegate.pageUp()) }
        func pageDown() -> RimeOutput { record("pageDown"); return paged(delegate.pageDown()) }
        func suspendForVisibilityChange() { record("suspend"); delegate.suspendForVisibilityChange() }
        func resumeAfterVisibilityChange() { record("resume"); delegate.resumeAfterVisibilityChange() }
        var runtimeSelection: RimeRuntimeSelection? { selection }
        var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? { .init(identity: 1, isValid: valid) }
        var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)?
    }

    private struct Fixture {
        let controller: KeyboardController
        let host: FakeTextInputClient
        let recorder: Recorder
        let coordinator: ThreadAffineRimeSessionCoordinator
        let stale: ResponsiveRimeSnapshot
        func close() {
            coordinator.shutdown()
            let deadline = DispatchTime.now() + 2
            while recorder.snapshot().destroyed < recorder.snapshot().created {
                guard recorder.destroyed.wait(timeout: deadline) == .success else {
                    XCTFail("Every fixture engine must be destroyed."); return
                }
            }
            XCTAssertTrue(recorder.snapshot().onOwner)
        }
    }

    private func failedFixture() async throws -> Fixture {
        let recorder = Recorder()
        let controller = KeyboardController()
        let host = FakeTextInputClient()
        controller.textClient = host
        controller.state.inputMode = .chinese
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(Bootstrap(recorder: recorder))
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        let coordinator = try XCTUnwrap(controller.threadAffineRimeCoordinator)
        let seeded = expectation(description: "actual Core seed publication")
        controller.onResponsivePresentationNeeded = { _ in
            if controller.state.lastRimeOutput?.rawInput == "nihaoanpai" { seeded.fulfill() }
        }
        for key in "nihaoanpai" { _ = controller.handle(.insertKey(String(key))) }
        await fulfillment(of: [seeded], timeout: 2)
        controller.onResponsivePresentationNeeded = nil
        // Batch 2 requires the exact published native origin; an unbound item
        // is local-only and cannot exercise a native Partial Commit checkpoint.
        let origin = try XCTUnwrap(controller.state.lastRimeOutput?.candidateOrigin)
        _ = controller.handle(
            .insertCandidate(
                "你好", kind: .candidate,
                selectionReference: .init(page: 0, indexOnPage: 1, globalIndex: 1, candidateOrigin: origin)))
        guard host.markedText == "你好anpai", controller.state.partialCommit?.checkpoint != nil,
            controller.state.lastRimeOutput?.hasMorePages == true
        else {
            coordinator.shutdown()
            throw NSError(
                domain: "R252", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Real partial selection precondition failed"])
        }
        let stale = try XCTUnwrap(coordinator.lastPublished)
        recorder.armDrop()
        _ = controller.handle(.deleteBackward)
        return Fixture(controller: controller, host: host, recorder: recorder, coordinator: coordinator, stale: stale)
    }

    func testFailurePreservesMarkedPrefixAndRevokesCandidateAuthority() async throws {
        let f = try await failedFixture(); defer { f.close() }
        XCTAssertEqual(f.host.text, "你好anpai")
        XCTAssertEqual(f.host.markedText, "你好anpai")
        XCTAssertNil(f.controller.state.partialCommit?.checkpoint)
        XCTAssertTrue(f.controller.isPartialCommitFailureRecoveryPending)
        XCTAssertTrue(f.controller.isCompositionInputRecoveryPending)
        XCTAssertFalse(f.controller.isT9InputRecoveryPending, "R174 state must remain independent.")
        XCTAssertNil(f.controller.state.lastRimeOutput)
        XCTAssertTrue(f.controller.t9CompositionPresentationSnapshot().candidates.isEmpty)
        XCTAssertFalse(f.controller.t9CompositionPresentationSnapshot().hasMorePages)
        XCTAssertEqual(f.controller.compositionInputRecoveryMessage, "输入恢复失败，按删除取消未确认拼音后重新输入")
        let writes = f.host.markedTextHistory
        f.controller.applyResponsivePublishedSnapshot(f.stale)
        await Task.yield()
        XCTAssertEqual(f.host.markedTextHistory, writes)
        XCTAssertNil(f.controller.state.lastRimeOutput)
    }

    func testOldActionsAndDirectCandidateEndpointsHaveNoSideEffects() async throws {
        let f = try await failedFixture(); defer { f.close() }
        let calls = f.recorder.snapshot().calls
        let writes = f.host.markedTextHistory
        let path = T9PinyinPath(displayText: "an", replacementRawInput: "an")
        let correction = TypoCorrectionCommit(committedText: "旧", originalInput: "a", correctedInput: "b", edits: [])
        var actions: [KeyboardAction] = [
            .insertKey("x"), .insertSpace, .insertReturn, .insertDirectText("!"),
            .insertEmoji("🙂"), .insertCorrectionCandidate(correction), .candidatePageUp, .candidatePageDown,
            .selectT9PinyinPath(path), .cycleT9PinyinPath, .pressT9CommonPunctuation, .pressKaomoji,
        ]
        for kind in [
            CandidateKind.candidate, .composition, .continuationCandidate, .punctuationCandidate, .kaomojiCandidate,
            .correctionCandidate, .placeholder,
        ] {
            actions.append(
                .insertCandidate("旧", kind: kind, selectionReference: .init(page: 1, indexOnPage: 0, globalIndex: 2)))
        }
        for action in actions { _ = f.controller.handle(action) }
        _ = f.controller.handleInsertCandidate("旧", kind: .candidate)
        _ = f.controller.handleInsertCorrectionCandidate(correction)
        _ = f.controller.handleCandidatePageDown()
        _ = f.controller.handleSelectT9PinyinPath(path)
        XCTAssertEqual(f.recorder.snapshot().calls, calls)
        XCTAssertEqual(f.host.markedTextHistory, writes)
        XCTAssertEqual(f.host.text, "你好anpai")
        XCTAssertEqual(f.host.deletedCount, 0)
    }

    func testDeleteCancelsOnlyRemainderAndModeSwitchDoesNotRetryEngine() async throws {
        let f = try await failedFixture(); defer { f.close() }
        let calls = f.recorder.snapshot().calls
        let writes = f.host.markedTextHistory.count
        _ = f.controller.handle(.deleteBackward)
        XCTAssertEqual(f.host.text, "你好")
        XCTAssertEqual(f.host.markedText, "你好")
        XCTAssertEqual(f.controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(f.controller.state.currentComposition, "")
        XCTAssertEqual(f.host.markedTextHistory.count, writes + 1)
        _ = f.controller.handle(.deleteBackward)
        _ = f.controller.handle(.toggleShift)
        _ = f.controller.handle(.togglePage)
        _ = f.controller.handle(.togglePage)
        _ = f.controller.handle(.toggleInputMode)
        _ = f.controller.handle(.insertKey("A"))
        XCTAssertEqual(f.host.text, "你好A")
        XCTAssertEqual(f.host.markedText, "")
        XCTAssertTrue(f.controller.isPartialCommitFailureRecoveryPending)
        XCTAssertEqual(f.recorder.snapshot().calls, calls)
        XCTAssertEqual(f.host.deletedCount, 0)
    }

    func testFreshKeyUsesOneRecoveryAndOneReplacementWithoutReplayingOldTail() async throws {
        let f = try await failedFixture(); defer { f.close() }
        _ = f.controller.handle(.deleteBackward)
        let start = f.recorder.snapshot().calls.count
        let writes = f.host.markedTextHistory.count
        _ = f.controller.handle(.insertKey("x"))
        XCTAssertEqual(Array(f.recorder.snapshot().calls.dropFirst(start)), ["recover", "replace:x"])
        XCTAssertFalse(f.controller.isCompositionInputRecoveryPending)
        XCTAssertEqual(f.controller.state.lastRimeOutput?.rawInput, "x")
        XCTAssertEqual(f.host.markedText, "你好x")
        XCTAssertEqual(f.host.text, "你好x")
        XCTAssertEqual(f.host.markedTextHistory.count, writes + 1)
        await Task.yield()
        XCTAssertEqual(f.host.markedText, "你好x", "Late lifecycle publication must not replace the verified result.")
    }

    func testFreshFailureOrChangedSchemaNeverRetriesOrWritesTheNewKey() async throws {
        for fault in [Fault.recoverInvalid, .wrongRaw, .unexpectedCommit, .changedSchema] {
            let f = try await failedFixture(); defer { f.close() }
            _ = f.controller.handle(.deleteBackward)
            f.recorder.setFault(fault)
            let start = f.recorder.snapshot().calls.count
            let writes = f.host.markedTextHistory
            _ = f.controller.handle(.insertKey("x"))
            let attempted = Array(f.recorder.snapshot().calls.dropFirst(start))
            XCTAssertEqual(
                attempted, fault == .recoverInvalid || fault == .changedSchema ? ["recover"] : ["recover", "replace:x"])
            for action in [KeyboardAction.insertKey("x"), .deleteBackward, .insertSpace, .insertReturn] {
                _ = f.controller.handle(action)
            }
            XCTAssertEqual(Array(f.recorder.snapshot().calls.dropFirst(start)), attempted)
            XCTAssertEqual(f.host.markedTextHistory, writes)
            XCTAssertEqual(f.host.text, "你好")
            XCTAssertTrue(f.controller.isCompositionInputRecoveryPending)
            XCTAssertEqual(f.controller.compositionInputRecoveryMessage, "输入暂不可用，请切换键盘后重试")
        }
    }

    func testUnbindAndExternalEditCannotWriteThroughForeignHostAndReadyResumeClearsFence() async throws {
        let f = try await failedFixture(); defer { f.close() }
        let originalWrites = f.host.markedTextHistory
        f.controller.textClient = nil
        let foreign = FakeTextInputClient()
        foreign.insertText("foreign")
        f.controller.textClient = foreign
        _ = f.controller.handle(.deleteBackward)
        _ = f.controller.handle(.insertKey("x"))
        _ = f.controller.noteExternalDocumentChange()
        XCTAssertEqual(f.host.markedTextHistory, originalWrites)
        XCTAssertEqual(foreign.text, "foreign")
        XCTAssertTrue(foreign.markedTextHistory.isEmpty)
        XCTAssertTrue(f.controller.isCompositionInputRecoveryPending)
        _ = f.controller.abandonCompositionForVisibilityChange()
        f.controller.suspendRimeForVisibilityChange()
        f.controller.resumeRimeAfterVisibilityChange()
        let deadline = ContinuousClock.now + .seconds(2)
        while !f.coordinator.isOwnerReady && ContinuousClock.now < deadline { await Task.yield() }
        XCTAssertTrue(f.coordinator.isOwnerReady)
        _ = f.controller.handle(.insertKey("x"))
        XCTAssertFalse(f.controller.isCompositionInputRecoveryPending)
        XCTAssertTrue(f.host.markedTextHistory == originalWrites)
        XCTAssertFalse(foreign.text.contains("你好"))
    }
}
