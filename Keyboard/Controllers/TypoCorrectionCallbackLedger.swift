#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import Synchronization

    /// Observes callback bodies; references are aliases, not pending-work evidence.
    @MainActor
    final class TypoCorrectionCallbackLedger {
        enum Phase { case scheduled, runLoopPending, taskPending, running, completed, cancelledBeforeEntry }
        nonisolated final class HandoffReceipt: Sendable {
            private struct Value: Sendable {
                var ordinal: UInt64 = 0
                var observed = false
            }
            private let value = Mutex(Value())
            func prepare(_ ordinal: UInt64) { value.withLock { $0 = Value(ordinal: ordinal) } }
            func note(_ ordinal: UInt64) {
                value.withLock { if $0.ordinal == ordinal { $0.observed = true } }
            }
            func observed(_ ordinal: UInt64) -> Bool {
                value.withLock { $0.ordinal == ordinal && $0.observed }
            }
        }
        struct Token: Equatable, Sendable {
            let ordinal: UInt64
            fileprivate let receipt: HandoffReceipt
            nonisolated func observeRunLoopHandoff() { receipt.note(ordinal) }
            nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.ordinal == rhs.ordinal && lhs.receipt === rhs.receipt
            }
        }
        private struct Entry {
            let token: Token
            var phase: Phase
        }
        private var entries: [Entry?] = Array(repeating: nil, count: 64)
        private let receipts = (0..<64).map { _ in HandoffReceipt() }
        private var next: UInt64 = 0
        private var aliases: (identity: ObjectIdentifier, token: Token)?
        private var invalid = false

        var hasPotentialWork: Bool {
            invalid
                || entries.contains { entry in
                    guard let entry else { return false }
                    return entry.phase != .completed && entry.phase != .cancelledBeforeEntry
                }
        }
        func schedule(_ phase: Phase = .scheduled) -> Token? {
            guard !invalid, next != .max, let slot = entries.firstIndex(where: { $0 == nil }) else {
                invalid = true
                return nil
            }
            next += 1
            receipts[slot].prepare(next)
            let token = Token(ordinal: next, receipt: receipts[slot])
            entries[slot] = Entry(token: token, phase: phase)
            return token
        }
        func bind(_ item: DispatchWorkItem, to token: Token?) {
            guard let token, index(token) != nil else {
                invalid = true
                return
            }
            // Old terminal alias can now be retired without retaining its WorkItem.
            if let old = aliases?.token { retireIfTerminal(old) }
            aliases = (ObjectIdentifier(item), token)
        }
        func cancelObserved(_ item: DispatchWorkItem?) {
            guard let item else { return }
            guard let alias = aliases, alias.identity == ObjectIdentifier(item),
                let index = index(alias.token), var entry = entries[index]
            else {
                invalid = true
                return
            }
            if entry.phase == .scheduled {
                entry.phase = .cancelledBeforeEntry
                entries[index] = entry
            }
            // Running stays running; completed stays completed. Shared aliases are idempotent.
        }
        func enter(_ token: Token?) {
            guard let token, let index = index(token), var entry = entries[index],
                entry.phase == .scheduled || entry.phase == .taskPending
            else {
                invalid = true
                return
            }
            entry.phase = .running
            entries[index] = entry
        }
        func handoff(_ token: Token?) {
            guard let token, let index = index(token), var entry = entries[index],
                entry.phase == .runLoopPending, token.receipt.observed(token.ordinal)
            else {
                invalid = true
                return
            }
            entry.phase = .taskPending
            entries[index] = entry
        }
        func complete(_ token: Token?) {
            guard let token, let index = index(token), var entry = entries[index],
                entry.phase == .running
            else {
                invalid = true
                return
            }
            entry.phase = .completed
            entries[index] = entry
            if aliases?.token != token { entries[index] = nil }
        }
        func quiescent(aliases items: [DispatchWorkItem?]) -> Bool {
            for item in items.compactMap({ $0 }) {
                guard let alias = aliases, alias.identity == ObjectIdentifier(item), index(alias.token) != nil else {
                    invalid = true
                    return false
                }
            }
            return !hasPotentialWork
        }
        func invalidate() { invalid = true }
        private func index(_ token: Token) -> Int? { entries.firstIndex { $0?.token == token } }
        private func retireIfTerminal(_ token: Token) {
            guard let index = index(token), let entry = entries[index],
                entry.phase == .completed || entry.phase == .cancelledBeforeEntry
            else { return }
            entries[index] = nil
        }
    }
#endif
