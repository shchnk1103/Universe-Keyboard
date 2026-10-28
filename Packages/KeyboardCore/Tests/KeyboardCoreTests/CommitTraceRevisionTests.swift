import XCTest

@testable import KeyboardCore

@MainActor
private final class RecordingTraceClient: TextInputClient {
    var calls: [String] = []
    var hasTextBeforeInput: Bool {
        calls.append("hasTextBeforeInput")
        return true
    }
    func insertText(_ text: String) { calls.append("insert:\(text)") }
    func deleteBackward() { calls.append("delete") }
    func adjustTextPosition(byCharacterOffset offset: Int) { calls.append("adjust:\(offset)") }
    func setMarkedText(_ text: String, selectedRange: Range<Int>) {
        calls.append("marked:\(text):\(selectedRange.lowerBound):\(selectedRange.upperBound)")
    }
    func unmarkText() { calls.append("unmark") }
}

@MainActor
final class CommitTraceRevisionTests: XCTestCase {
    func testTransparentForwardingOfEveryMember() {
        let recorder = CommitTraceRecorder(context: { nil }, emit: { _, _ in })
        recorder.enabled = true
        let direct = RecordingTraceClient()
        let base = RecordingTraceClient()
        let wrapped = TracingTextInputClient(base, recorder: recorder)
        func script(_ client: any TextInputClient) {
            XCTAssertTrue(client.hasTextBeforeInput)
            client.setMarkedText("abc", selectedRange: 1..<2)
            client.setMarkedText("", selectedRange: 0..<0)
            client.unmarkText()
            client.insertText("xyz")
            client.deleteBackward()
            client.adjustTextPosition(byCharacterOffset: -3)
        }
        script(direct)
        recorder.begin(entry: .compact, preeditBefore: false)
        script(wrapped)
        XCTAssertEqual(direct.calls, base.calls)
    }

    func testSamplingBoundariesAndCrossDocumentExpiry() {
        var now: TimeInterval = 0
        var reads = 0
        var events: [[DiagnosticEvent.Field]] = []
        let recorder = CommitTraceRecorder(
            clock: { now },
            context: {
                reads += 1
                return "x"
            }, emit: { _, fields in events.append(fields) })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: String(repeating: "x", count: 65))
        XCTAssertEqual(reads, 0)
        recorder.didChange(sampling: false)
        XCTAssertEqual(reads, 0)
        recorder.didChange()
        XCTAssertEqual(reads, 0)
        now = 5.001
        recorder.close(.documentChanged)
        XCTAssertEqual(reads, 0)
        XCTAssertTrue(events[0].contains(.count(.traceOccurrencePre, 9)))
        XCTAssertTrue(events[0].contains(.count(.traceOccurrenceFirstChange, 9)))
        XCTAssertTrue(events[0].contains(.count(.traceOccurrenceClose, 8)))
        XCTAssertTrue(events[0].contains(.flag(.traceDocumentChanged, true)))
        XCTAssertTrue(events[0].contains(.count(.traceCloseReason, 4)))
        now = 10
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: String(repeating: "x", count: 64))
        XCTAssertEqual(reads, 1)
        recorder.didChange(sampling: false)
        XCTAssertEqual(reads, 1)
        recorder.didChange()
        XCTAssertEqual(reads, 2)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        now += 5
        recorder.observeAction(.insertKey("a"))
        XCTAssertTrue(events[1].contains(.count(.traceCloseReason, 1)))
        XCTAssertEqual(reads, 3)
    }

    func testDisabledOperationsLeaveNoCountsAndClosedEventsDoNotChange() {
        var events: [[DiagnosticEvent.Field]] = []
        let recorder = CommitTraceRecorder(context: { nil }, emit: { _, fields in events.append(fields) })
        recorder.enabled = true
        recorder.enabled = false
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.setMarked, text: "x")
        recorder.didChange()
        recorder.reject(suppressed: true)
        recorder.reject(suppressed: false)
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.observeAction(.insertKey("a"))
        let fields = events[0]
        for metric: DiagnosticEvent.CountMetric in [
            .traceSyncInsert, .traceSyncSetMarked, .traceSyncClearMarked, .traceSyncUnmark, .traceSyncDelete,
            .traceAsyncInsert, .traceAsyncSetMarked, .traceAsyncClearMarked, .traceAsyncUnmark, .traceAsyncDelete,
            .traceSinceMarked, .traceChanges, .traceSuppressed, .traceRejected,
        ] {
            XCTAssertTrue(fields.contains(.count(metric, 0)))
        }
        XCTAssertTrue(fields.contains(.flag(.traceCounterCapped, false)))
        for metric: DiagnosticEvent.CountMetric in [
            .traceOccurrencePre, .traceOccurrenceFirstChange, .traceOccurrenceClose,
        ] {
            XCTAssertTrue(fields.contains(.count(metric, 8)))
        }
        recorder.willWrite(.insert, text: "x")
        recorder.didChange()
        recorder.reject(suppressed: true)
        XCTAssertEqual(events, [fields])
    }

    func testIndividualOperationCounters() {
        let metrics: [DiagnosticEvent.CountMetric] = [
            .traceSyncInsert, .traceSyncSetMarked, .traceSyncClearMarked, .traceSyncUnmark, .traceSyncDelete,
            .traceAsyncInsert, .traceAsyncSetMarked, .traceAsyncClearMarked, .traceAsyncUnmark, .traceAsyncDelete,
        ]
        let operations: [CommitTraceRecorder.Operation] = [.insert, .setMarked, .clearMarked, .unmark, .delete]
        for index in metrics.indices {
            var fields: [DiagnosticEvent.Field] = []
            let recorder = CommitTraceRecorder(context: { nil }, emit: { _, result in fields = result })
            recorder.enabled = true
            recorder.begin(entry: .compact, preeditBefore: false)
            if index >= 5 { recorder.endSyncPhase(preeditAfter: false, partialAfter: false) }
            recorder.willWrite(operations[index % 5], text: "x")
            recorder.close(.nextInput)
            for (position, metric) in metrics.enumerated() {
                XCTAssertTrue(fields.contains(.count(metric, position == index ? 1 : 0)))
            }
        }
    }
    func testPartialSelectionUsesControllerState() {
        let engine = FakeRimeEngine(
            dictionary: ["nihaoanpai": ["你好安排", "你好"], "anpai": ["安排"]],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]])
        let host = FakeTextInputClient()
        var events: [(UInt64, [DiagnosticEvent.Field])] = []
        let recorder = CommitTraceRecorder(context: { host.text }, emit: { events.append(($0, $1)) })
        recorder.enabled = true
        let controller = KeyboardController()
        controller.textClient = TracingTextInputClient(host, recorder: recorder)
        controller.rimeEngine = engine
        controller.onActionObserved = { recorder.observeAction($0) }
        for character in "nihaoanpai" { _ = controller.handle(.insertKey(String(character))) }
        func select(_ text: String, index: Int) {
            recorder.begin(entry: .compact, preeditBefore: controller.state.insertedPreeditCount > 0)
            _ = controller.handle(
                .insertCandidate(text, kind: .candidate, selectionReference: .init(page: 0, indexOnPage: index)))
            recorder.endSyncPhase(
                preeditAfter: controller.state.insertedPreeditCount > 0,
                partialAfter: controller.state.partialCommit != nil)
        }
        select("你好", index: 1)
        select("安排", index: 0)
        recorder.close(.nextInput)
        // This proves field logic through Core's selection path, not real host behavior.
        XCTAssertEqual(events.count, 2)
        XCTAssertNotEqual(events[0].0, events[1].0)
        XCTAssertTrue(events[0].1.contains(.flag(.tracePartialAfter, true)))
        XCTAssertTrue(events[0].1.contains(.count(.traceCloseReason, 0)))
    }

    func testFixedFieldSetsForFirstAndSecondSelection() throws {
        CommitTraceRecorder.resetTraceProcessStateForTesting()
        var events: [[DiagnosticEvent.Field]] = []
        let recorder = CommitTraceRecorder(clock: { 1 }, context: { "" }, emit: { _, fields in events.append(fields) })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: "x")
        recorder.close(.nextInput)
        func names(_ fields: [DiagnosticEvent.Field]) throws -> Set<String> {
            let encoded = try JSONEncoder().encode(fields)
            let objects = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [[String: Any]])
            return Set(objects.compactMap { $0["name"] as? String })
        }
        let base: Set<String> = [
            "trace_entry", "sync_insert", "sync_set_marked", "sync_clear_marked", "sync_unmark", "sync_delete",
            "async_insert", "async_set_marked", "async_clear_marked", "async_unmark", "async_delete",
            "did_change_since_marked_write", "did_change_in_window", "repeat_suppressed", "guard_rejected",
            "preedit_before", "preedit_after_sync", "partial_after_sync", "document_changed",
            "occurrence_pre_commit", "occurrence_first_did_change", "occurrence_at_close", "close_reason",
            "window_ms", "counter_capped",
        ]
        XCTAssertEqual(try names(events[0]), base)
        XCTAssertEqual(try names(events[1]), base.union(["first_write_ms", "since_previous_selection_ms"]))
    }

    func testHostConfirmationThenRealControllerSelection() {
        let host = FakeTextInputClient()
        var events: [[DiagnosticEvent.Field]] = []
        let recorder = CommitTraceRecorder(context: { host.text }, emit: { _, fields in events.append(fields) })
        recorder.enabled = true
        let wrapped = TracingTextInputClient(host, recorder: recorder)
        let controller = KeyboardController()
        controller.textClient = wrapped
        controller.onActionObserved = { recorder.observeAction($0) }
        wrapped.setMarkedText("x", selectedRange: 1..<1)
        host.unmarkText()
        recorder.didChange()
        recorder.begin(entry: .compact, preeditBefore: controller.state.insertedPreeditCount > 0)
        _ = controller.handle(.insertCandidate("x", kind: .candidate, selectionReference: nil))
        recorder.endSyncPhase(
            preeditAfter: controller.state.insertedPreeditCount > 0, partialAfter: controller.state.partialCommit != nil
        )
        recorder.didChange()
        recorder.close(.nextInput)
        // This fake host demonstrates field logic, not actual host behavior.
        XCTAssertEqual(host.text, "xx")
        XCTAssertTrue(events[0].contains(.count(.traceSinceMarked, 1)))
        XCTAssertTrue(events[0].contains(.count(.traceOccurrenceFirstChange, 2)))
    }

    func testCloseBoundariesDoNotReadOrCountExpiredCall() {
        var now: TimeInterval = 0
        var reads = 0
        var events: [[DiagnosticEvent.Field]] = []
        let recorder = CommitTraceRecorder(
            clock: { now },
            context: {
                reads += 1
                return "x"
            }, emit: { _, fields in events.append(fields) })
        recorder.enabled = true
        for reason: CommitTraceRecorder.CloseReason in [.documentChanged, .disappear] {
            recorder.begin(entry: .compact, preeditBefore: false)
            recorder.willWrite(.insert, text: "x")
            recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
            reads = 0
            recorder.close(reason)
            XCTAssertEqual(reads, 0)
            XCTAssertTrue(events.last!.contains(.count(.traceOccurrenceClose, 8)))
        }
        now = 10
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: "x")
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        reads = 0
        now = 15.001
        recorder.didChange()
        XCTAssertEqual(reads, 0)
        XCTAssertTrue(events.last!.contains(.count(.traceCloseReason, 4)))
        XCTAssertTrue(events.last!.contains(.count(.traceChanges, 0)))
        XCTAssertTrue(events.last!.contains(.count(.traceOccurrenceClose, 8)))
    }

}
