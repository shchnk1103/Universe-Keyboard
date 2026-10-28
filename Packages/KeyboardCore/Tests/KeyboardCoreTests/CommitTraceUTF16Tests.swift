import XCTest

@testable import KeyboardCore

@MainActor
final class CommitTraceUTF16Tests: XCTestCase {
    func testSamplesUseTextAtEachSamplingPoint() {
        var context: String? = "AA"
        var fields: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(clock: { 0 }, context: { context }, emit: { _, value in fields = value })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: "A")
        recorder.didChange()
        recorder.willWrite(.insert, text: "B")
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        context = "B"
        recorder.observeAction(.insertKey("x"))
        XCTAssertTrue(fields.contains(.count(.traceOccurrencePre, 2)))
        XCTAssertTrue(fields.contains(.count(.traceOccurrenceFirstChange, 2)))
        XCTAssertTrue(fields.contains(.count(.traceOccurrenceClose, 1)))
    }

    func testUnavailableFirstSampleIsNotRetried() {
        var context: String? = "A"
        var reads = 0
        var fields: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(
            clock: { 0 },
            context: {
                reads += 1
                return context
            }, emit: { _, value in fields = value })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: "A")
        context = nil
        recorder.didChange()
        XCTAssertEqual(reads, 2)
        context = "AA"
        recorder.didChange()
        XCTAssertEqual(reads, 2)
        recorder.close(.disappear)
        XCTAssertTrue(fields.contains(.count(.traceOccurrenceFirstChange, 9)))
    }

    func testIneligibleCallbackUsesLatestTextWhenEligible() {
        var context = "A"
        var reads = 0
        var fields: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(
            clock: { 0 },
            context: {
                reads += 1
                return context
            }, emit: { _, value in fields = value })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: "A")
        recorder.didChange(sampling: false)
        XCTAssertEqual(reads, 1)
        recorder.willWrite(.insert, text: "B")
        context = "BB"
        recorder.didChange()
        XCTAssertEqual(reads, 2)
        recorder.close(.disappear)
        XCTAssertTrue(fields.contains(.count(.traceOccurrenceFirstChange, 2)))
    }

    func testNoEligibleCallbackLeavesFirstSampleUnobserved() {
        var fields: [DiagnosticEvent.Field] = []
        let recorder = CommitTraceRecorder(clock: { 0 }, context: { "x" }, emit: { _, value in fields = value })
        recorder.enabled = true
        recorder.begin(entry: .compact, preeditBefore: false)
        recorder.willWrite(.insert, text: "x")
        recorder.didChange(sampling: false)
        recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
        recorder.observeAction(.insertKey("x"))
        XCTAssertTrue(fields.contains(.count(.traceOccurrenceFirstChange, 8)))
    }

    func testExpiredRejectionsCloseWithoutCountingOrOpeningTrace() {
        for suppressed in [true, false] {
            var now: TimeInterval = 0
            var events: [[DiagnosticEvent.Field]] = []
            let recorder = CommitTraceRecorder(
                clock: { now }, context: { nil }, emit: { _, fields in events.append(fields) })
            recorder.enabled = true
            recorder.begin(entry: .compact, preeditBefore: false)
            recorder.endSyncPhase(preeditAfter: false, partialAfter: false)
            now = 5.001
            recorder.reject(suppressed: suppressed)
            XCTAssertEqual(events.count, 1)
            XCTAssertTrue(events[0].contains(.count(.traceCloseReason, 4)))
            XCTAssertTrue(events[0].contains(.count(.traceSuppressed, 0)))
            XCTAssertTrue(events[0].contains(.count(.traceRejected, 0)))
            recorder.close(.nextInput)
            XCTAssertEqual(events.count, 1)
        }
    }

    func testUTF16WindowsAndExactCodeUnitMatching() {
        let longCluster = "e" + String(repeating: "\u{0301}", count: 10000)
        let cases: [(String, String, Int)] = [
            ("x", longCluster + "x", 1),
            ("甲", longCluster + "甲", 1),
            ("ab", "abxxxxxx", 0),
            ("é", "e\u{0301}", 0),
            ("aa", "aaaaaa", 3),
            ("abcdef", "abcdef" + String(repeating: "x", count: 12), 1),
            ("abcdef", "abcdef" + String(repeating: "x", count: 13), 0),
            ("a", "😀aa", 2),
        ]
        for (text, context, expected) in cases {
            var fields: [DiagnosticEvent.Field] = []
            let recorder = CommitTraceRecorder(clock: { 0 }, context: { context }, emit: { _, value in fields = value })
            recorder.enabled = true
            recorder.begin(entry: .compact, preeditBefore: false)
            recorder.willWrite(.insert, text: text)
            recorder.close(.disappear)
            XCTAssertTrue(fields.contains(.count(.traceOccurrencePre, expected)))
        }
    }
}
