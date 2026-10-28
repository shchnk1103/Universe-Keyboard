import Foundation

/// A bounded, process-local observation window. Host callbacks are raw signals,
/// not evidence of the host's marked-text state.
@MainActor
public final class CommitTraceRecorder {
    public enum Entry: Int { case compact, expanded, legacy, other }
    public enum CloseReason: Int { case nextSelection, nextInput, documentChanged, disappear, windowLimit }
    public enum Operation: Int { case insert, setMarked, clearMarked, unmark, delete }
    private struct Trace {
        let id: UInt64
        let entry: Entry
        let start: TimeInterval
        let before: Bool
        let sincePrevious: Int?
        let sinceMarked: Int
        var sync = true
        var counts = [Int](repeating: 0, count: 10)
        var changes = 0
        var suppressed = 0
        var rejected = 0
        var capped = false
        var after = false
        var partial = false
        var firstWrite: Int?
        var text: String?
        var markedText: String?
        var pre = 8
        var firstChange = 8
    }
    private let clock: () -> TimeInterval
    private let context: () -> String?
    private let emit: (UInt64, [DiagnosticEvent.Field]) -> Void
    private var trace: Trace?
    private static var sequence: UInt64 = 0
    private static var previous: TimeInterval?
    private var hasMarkedWrite = false
    private var changesSinceMarked = 0
    private var changesSinceMarkedCapped = false
    public var enabled = false {
        didSet {
            if !enabled {
                trace = nil; hasMarkedWrite = false; changesSinceMarked = 0; changesSinceMarkedCapped = false
            }
        }
    }
    public init(
        clock: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime },
        context: @escaping () -> String?, emit: @escaping (UInt64, [DiagnosticEvent.Field]) -> Void
    ) {
        self.clock = clock; self.context = context; self.emit = emit
    }
    private func milliseconds(_ interval: TimeInterval, cap: Int) -> Int {
        Int(min(Double(cap), max(0, interval * 1000)))
    }
    private func expire() {
        guard enabled, let current = trace, clock() - current.start > 5 else { return }
        close(.windowLimit)
    }
    public func begin(entry: Entry, preeditBefore: Bool) {
        guard enabled else { return }
        expire(); if trace != nil { close(.nextSelection) }
        let now = clock(); Self.sequence &+= 1
        trace = Trace(
            id: Self.sequence, entry: entry, start: now, before: preeditBefore,
            sincePrevious: Self.previous.map { milliseconds(now - $0, cap: 10000) }, sinceMarked: changesSinceMarked,
            capped: changesSinceMarkedCapped)
        Self.previous = now
    }
    public func endSyncPhase(preeditAfter: Bool, partialAfter: Bool) {
        guard enabled else { return }; expire()
        trace?.after = preeditAfter; trace?.partial = partialAfter; trace?.sync = false
    }
    public func observeAction(_ action: KeyboardAction) {
        guard enabled else { return }; expire()
        guard let current = trace, !current.sync else { return }
        if case .keyboardTypeChanged = action { return }
        close(.nextInput)
    }
    public func reject(suppressed: Bool) {
        guard enabled else { return }; expire()
        guard trace != nil else { return }
        if suppressed {
            if trace!.suppressed < 15 {
                trace!.suppressed += 1; if trace!.suppressed == 15 { trace!.capped = true }
            } else {
                trace!.capped = true
            }
        } else {
            if trace!.rejected < 15 {
                trace!.rejected += 1; if trace!.rejected == 15 { trace!.capped = true }
            } else {
                trace!.capped = true
            }
        }
    }
    public func didChange() {
        guard enabled else { return }; expire()
        if hasMarkedWrite {
            if changesSinceMarked < 15 {
                changesSinceMarked += 1; if changesSinceMarked == 15 { changesSinceMarkedCapped = true }
            } else {
                changesSinceMarkedCapped = true
            }
        }
        guard trace != nil else { return }
        if trace!.changes < 15 {
            trace!.changes += 1; if trace!.changes == 15 { trace!.capped = true }
        } else {
            trace!.capped = true
        }
        if let text = trace?.text, trace?.firstChange == 8 { trace?.firstChange = occurrence(text) }
    }
    public func willWrite(_ operation: Operation, text: String? = nil) {
        guard enabled else { return }; expire()
        if operation == .setMarked { hasMarkedWrite = true; changesSinceMarked = 0; changesSinceMarkedCapped = false }
        guard trace != nil else { return }
        let index = operation.rawValue + (trace!.sync ? 0 : 5)
        if trace!.counts[index] < 15 {
            trace!.counts[index] += 1; if trace!.counts[index] == 15 { trace!.capped = true }
        } else {
            trace!.capped = true
        }
        if trace!.firstWrite == nil { trace!.firstWrite = milliseconds(clock() - trace!.start, cap: 60000) }
        if operation == .setMarked { trace!.markedText = text }
        if operation == .clearMarked { trace!.markedText = nil }
        let committed = operation == .insert ? text : (operation == .unmark ? trace!.markedText : nil)
        if let committed, !committed.isEmpty {
            if trace!.pre == 8 { trace!.pre = occurrence(committed) }
            trace!.text = committed
        }
    }
    private func occurrence(_ text: String) -> Int {
        guard !text.isEmpty, let value = context() else { return 9 }
        let suffix = String(value.suffix(text.count * 3))
        var rest = suffix[...]; var count = 0
        while count < 3, let range = rest.range(of: text) { count += 1; rest = rest[range.upperBound...] }
        return count
    }
    public func close(_ requestedReason: CloseReason) {
        guard enabled, var current = trace else { return }
        let reason: CloseReason = clock() - current.start > 5 ? .windowLimit : requestedReason
        let final = (reason == .documentChanged || reason == .disappear) ? 8 : current.text.map { occurrence($0) } ?? 8
        trace = nil
        current.text = nil
        current.markedText = nil  // Release content before submitting the content-free event.
        let metrics: [DiagnosticEvent.CountMetric] = [
            .traceSyncInsert, .traceSyncSetMarked, .traceSyncClearMarked, .traceSyncUnmark, .traceSyncDelete,
            .traceAsyncInsert, .traceAsyncSetMarked, .traceAsyncClearMarked, .traceAsyncUnmark, .traceAsyncDelete,
        ]
        var fields: [DiagnosticEvent.Field] = zip(metrics, current.counts).map { .count($0, $1) }
        fields += [
            .count(.traceEntry, current.entry.rawValue), .count(.traceSinceMarked, current.sinceMarked),
            .count(.traceChanges, current.changes), .count(.traceSuppressed, current.suppressed),
            .count(.traceRejected, current.rejected), .count(.traceOccurrencePre, current.pre),
            .count(.traceOccurrenceFirstChange, current.firstChange), .count(.traceOccurrenceClose, final),
            .count(.traceCloseReason, reason.rawValue), .flag(.tracePreeditBefore, current.before),
            .flag(.tracePreeditAfter, current.after), .flag(.tracePartialAfter, current.partial),
            .flag(.traceDocumentChanged, reason == .documentChanged), .flag(.traceCounterCapped, current.capped),
            .duration(.traceWindow, milliseconds(clock() - current.start, cap: 60000)),
        ]
        if let first = current.firstWrite { fields.append(.duration(.traceFirstWrite, first)) }
        if let previous = current.sincePrevious { fields.append(.duration(.traceSincePrevious, previous)) }
        emit(current.id, fields)
    }
}
