import XCTest

@testable import KeyboardCore

@MainActor
final class CommitTraceRecorderTests: XCTestCase {
    func testLifecycleAndContentFreeSamples() throws {
        var now: TimeInterval = 0
        var context: String? = "B34SENTINEL甲乙"
        var reads = 0
        var events: [(UInt64, [DiagnosticEvent.Field])] = []
        let recorder = CommitTraceRecorder(
            clock: { now },
            context: {
                reads += 1; return context
            }, emit: { events.append(($0, $1)) })
        recorder.enabled = true
        let base = FakeTextInputClient()
        let client = TracingTextInputClient(base, recorder: recorder)
        client.setMarkedText("B34SENTINEL甲乙", selectedRange: 0..<0)
        recorder.didChange()
        recorder.begin(entry: .compact, preeditBefore: true)
        client.insertText("B34SENTINEL甲乙")
        recorder.endSyncPhase(preeditAfter: false, partialAfter: true)
        context = "B34SENTINEL甲乙B34SENTINEL甲乙"
        recorder.didChange()
        now = 0.05
        recorder.begin(entry: .expanded, preeditBefore: false)
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events[0].1.contains(.count(.traceSinceMarked, 1)))
        XCTAssertTrue(events[0].1.contains(.count(.traceOccurrenceFirstChange, 2)))
        XCTAssertTrue(events[0].1.contains(.flag(.tracePartialAfter, true)))
        XCTAssertLessThanOrEqual(reads, 3)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.close(.nextInput)
        let traceStorage = Mirror(reflecting: recorder).children.first { $0.label == "trace" }
        XCTAssertEqual(traceStorage.map { Mirror(reflecting: $0.value).children.count }, 0)
        XCTAssertNotEqual(events[0].0, events[1].0)
        XCTAssertTrue(events[1].1.contains(.duration(.traceSincePrevious, 50)))
        let encoded = try JSONEncoder().encode(events[0].1)
        let json = String(decoding: encoded, as: UTF8.self)
        XCTAssertFalse(json.contains("B34SENTINEL"))
        XCTAssertFalse(json.contains("甲乙"))
    }

    func testDisabledAndAllCloseReasons() {
        var now: TimeInterval = 0
        var reads = 0
        var events: [[DiagnosticEvent.Field]] = []
        let recorder = CommitTraceRecorder(
            clock: { now },
            context: {
                reads += 1; return nil
            }, emit: { _, fields in events.append(fields) })
        recorder.begin(entry: .other, preeditBefore: false)
        recorder.willWrite(.insert, text: "x")
        recorder.didChange()
        recorder.close(.nextInput)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(reads, 0)
        recorder.enabled = true
        for reason in [
            CommitTraceRecorder.CloseReason.nextSelection, .nextInput, .documentChanged, .disappear, .windowLimit,
        ] {
            recorder.begin(entry: .legacy, preeditBefore: false)
            recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
            recorder.close(reason)
            XCTAssertTrue(events.last!.contains(.count(.traceCloseReason, reason.rawValue)))
            XCTAssertTrue(events.last!.contains(.count(.traceOccurrenceClose, 8)))
        }
        recorder.begin(entry: .other, preeditBefore: false)
        recorder.willWrite(.insert, text: "x")
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        now += 6
        recorder.didChange()
        XCTAssertTrue(events.last!.contains(.count(.traceCloseReason, 4)))
        XCTAssertTrue(events.last!.contains(.count(.traceOccurrencePre, 9)))
    }

    func testCountsAndTransparentClient() {
        var fields: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(context: { "" }, emit: { _, value in fields = value })
        recorder.enabled = true
        let direct = FakeTextInputClient()
        let wrappedBase = FakeTextInputClient()
        let wrapped = TracingTextInputClient(wrappedBase, recorder: recorder)
        recorder.begin(entry: .other, preeditBefore: false)
        for client in [direct, wrapped as any TextInputClient] {
            client.setMarkedText("ab", selectedRange: 2..<2)
            client.unmarkText()
            client.insertText("c")
            client.deleteBackward()
            client.adjustTextPosition(byCharacterOffset: -1)
            client.setMarkedText("", selectedRange: 0..<0)
        }
        XCTAssertEqual(direct.text, wrappedBase.text)
        XCTAssertEqual(direct.cursorOffset, wrappedBase.cursorOffset)
        XCTAssertEqual(direct.markedText, wrappedBase.markedText)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        for _ in 0..<16 { wrapped.deleteBackward() }
        recorder.close(.nextInput)
        XCTAssertEqual(direct.text, "ab")
        XCTAssertTrue(fields.contains(.count(.traceSyncSetMarked, 1)))
        XCTAssertTrue(fields.contains(.count(.traceSyncClearMarked, 1)))
        XCTAssertTrue(fields.contains(.count(.traceAsyncDelete, 15)))
        XCTAssertTrue(fields.contains(.flag(.traceCounterCapped, true)))
        XCTAssertEqual(direct.markedTextHistory, wrappedBase.markedTextHistory)
    }
    func testOccurrenceValuesAndSamplingLimit() {
        var context: String? = ""
        var reads = 0
        var captured: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(
            context: {
                reads += 1; return context
            }, emit: { _, fields in captured = fields })
        recorder.enabled = true
        for (sample, expected) in [("", 0), ("x", 1), ("xx", 2), ("xxx", 3)] {
            context = sample
            reads = 0
            recorder.begin(entry: .compact, preeditBefore: false)
            recorder.willWrite(.insert, text: "x")
            recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
            recorder.didChange()
            recorder.didChange()
            recorder.close(.nextInput)
            XCTAssertTrue(captured.contains(.count(.traceOccurrencePre, expected)))
            XCTAssertTrue(captured.contains(.count(.traceOccurrenceFirstChange, expected)))
            XCTAssertTrue(captured.contains(.count(.traceOccurrenceClose, expected)))
            XCTAssertEqual(reads, 3)
        }
        context = nil
        recorder.begin(entry: .other, preeditBefore: false)
        recorder.willWrite(.insert, text: "x")
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.close(.disappear)
        XCTAssertTrue(captured.contains(.count(.traceOccurrencePre, 9)))
        XCTAssertTrue(captured.contains(.count(.traceOccurrenceClose, 8)))
    }

    func testActionsAndUnclosedWindow() {
        var events: [[DiagnosticEvent.Field]] = []
        let recorder = CommitTraceRecorder(context: { nil }, emit: { _, fields in events.append(fields) })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.observeAction(.insertKey("a"))
        XCTAssertTrue(events.isEmpty)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.observeAction(.keyboardTypeChanged(.default))
        XCTAssertTrue(events.isEmpty)
        recorder.observeAction(.insertKey("a"))
        XCTAssertEqual(events.count, 1)
        recorder.begin(entry: .compact, preeditBefore: false)
        XCTAssertEqual(events.count, 1)
    }

    func testTypedWireRoundTripAndUnknownFieldRejection() throws {
        CommitTraceRecorder.resetTraceProcessStateForTesting()
        var fields: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(clock: { 1 }, context: { "" }, emit: { _, value in fields = value })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: "B34SENTINEL甲乙")
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.close(.nextInput)
        let event = DiagnosticEvent(
            utcTimestamp: .now, monotonicNanoseconds: 1, origin: .keyboardExtension,
            processInstanceID: UUID(), localSequence: 1, actionSequence: 1, code: .candidateCommitTrace,
            level: .info, category: .display, fields: fields)
        let data = try JSONEncoder().encode(event)
        XCTAssertNil(DiagnosticEventWireValidator.rejectionReason(for: data))
        XCTAssertEqual(try JSONDecoder().decode(DiagnosticEvent.self, from: data), event)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        var encodedFields = try XCTUnwrap(object["fields"] as? [[String: Any]])
        let names = Set(encodedFields.compactMap { $0["name"] as? String })
        XCTAssertEqual(
            names,
            Set([
                "trace_entry", "sync_insert", "sync_set_marked", "sync_clear_marked", "sync_unmark", "sync_delete",
                "async_insert", "async_set_marked", "async_clear_marked", "async_unmark", "async_delete",
                "did_change_since_marked_write", "did_change_in_window", "repeat_suppressed", "guard_rejected",
                "preedit_before", "preedit_after_sync", "partial_after_sync", "document_changed",
                "occurrence_pre_commit", "occurrence_first_did_change", "occurrence_at_close", "close_reason",
                "first_write_ms", "window_ms", "counter_capped",
            ]))
        encodedFields[0]["name"] = "unapproved_name"
        object["fields"] = encodedFields
        let invalid = try JSONSerialization.data(withJSONObject: object)
        XCTAssertNotNil(DiagnosticEventWireValidator.rejectionReason(for: invalid))
    }

    func testSyntheticHostConfirmationAndPartialSelections() {
        var now: TimeInterval = 0
        let host = FakeTextInputClient()
        var events: [(UInt64, [DiagnosticEvent.Field])] = []
        let recorder = CommitTraceRecorder(clock: { now }, context: { host.text }, emit: { events.append(($0, $1)) })
        recorder.enabled = true
        let client = TracingTextInputClient(host, recorder: recorder)
        client.setMarkedText("甲", selectedRange: 1..<1)
        host.unmarkText()  // Simulated host action; this proves field logic only.
        recorder.didChange()
        recorder.begin(entry: .compact, preeditBefore: true)
        client.insertText("甲")
        recorder.endSyncPhase(preeditAfter: true, partialAfter: true)
        recorder.didChange()
        now = 0.05
        recorder.begin(entry: .compact, preeditBefore: true)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.close(.nextInput)
        XCTAssertEqual(events.count, 2)
        XCTAssertNotEqual(events[0].0, events[1].0)
        XCTAssertTrue(events[0].1.contains(.count(.traceSinceMarked, 1)))
        XCTAssertTrue(events[0].1.contains(.count(.traceOccurrenceFirstChange, 2)))
        XCTAssertTrue(events[0].1.contains(.flag(.tracePartialAfter, true)))
        XCTAssertTrue(events[1].1.contains(.duration(.traceSincePrevious, 50)))
    }

    func testRawCallbacksAndGuardCountsAreCapped() {
        var fields: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(context: { nil }, emit: { _, result in fields = result })
        recorder.enabled = true
        recorder.willWrite(.setMarked, text: "x")
        for _ in 0..<16 { recorder.didChange() }
        recorder.begin(entry: .compact, preeditBefore: true)
        for _ in 0..<16 { recorder.didChange(); recorder.reject(suppressed: true); recorder.reject(suppressed: false) }
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.close(.documentChanged)
        XCTAssertTrue(fields.contains(.count(.traceSinceMarked, 15)))
        XCTAssertTrue(fields.contains(.count(.traceChanges, 15)))
        XCTAssertTrue(fields.contains(.count(.traceSuppressed, 15)))
        XCTAssertTrue(fields.contains(.count(.traceRejected, 15)))
        XCTAssertTrue(fields.contains(.flag(.traceCounterCapped, true)))
        XCTAssertTrue(fields.contains(.flag(.traceDocumentChanged, true)))
    }

    func testPrivacySentinelAndChineseSubstrings() throws {
        let sentinel = "B34SENTINEL甲乙丙丁"
        let chinese = Array("甲乙丙丁")
        var captured: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(context: { sentinel + sentinel }, emit: { _, fields in captured = fields })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: sentinel)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.didChange()
        recorder.close(.nextInput)
        let event = DiagnosticEvent(
            utcTimestamp: .now, monotonicNanoseconds: 1, origin: .keyboardExtension,
            processInstanceID: UUID(), localSequence: 1, actionSequence: 1, code: .candidateCommitTrace,
            level: .info, category: .display, fields: captured)
        let json = String(decoding: try JSONEncoder().encode(event), as: UTF8.self)
        XCTAssertFalse(json.contains(sentinel))
        XCTAssertFalse(json.contains("B34SENTINEL"))
        for start in 0..<chinese.count {
            for end in (start + 2)...max(start + 2, chinese.count) where end <= chinese.count {
                XCTAssertFalse(json.contains(String(chinese[start..<end])))
            }
        }
    }

}
