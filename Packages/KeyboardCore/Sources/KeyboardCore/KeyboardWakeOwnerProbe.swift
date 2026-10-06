#if DEBUG
    import Foundation
    import Synchronization

    /// A one-shot, content-free snapshot of observed keyboard-owner boundaries.
    /// This probe is deliberately independent of the diagnostic journal and logger.
    public final class KeyboardWakeOwnerProbe: Sendable {
        public enum Stage: UInt64, Sendable, CaseIterable {
            case appearance = 1
            case armed = 2
            case insertBegin = 3
            case insertEnd = 4
            case suspendBegin = 5
            case suspendEnd = 6
            case resumeBegin = 7
            case resumeEnd = 8
            case schedule = 9
            case teardown = 10
            case replacement = 11
        }

        public enum TeardownResult: UInt64, Sendable {
            case notApplicable = 0
            case completed = 1
            case failed = 2
            case cancelled = 3
        }

        public struct Snapshot: Sendable, Equatable {
            /// Header followed by fixed-width event records. No field contains text.
            public let words: [UInt64]

            public var isIncomplete: Bool {
                words.count > Self.completenessWordIndex
                    && words[Self.completenessWordIndex] == Self.incompleteValue
            }

            /// The raw pointer is valid only for the duration of `body`.
            /// The caller must copy bytes inside the closure if it needs to retain them.
            public func withUnsafeBytes<Result>(
                _ body: (UnsafeRawBufferPointer) throws -> Result
            ) rethrows -> Result {
                try words.withUnsafeBufferPointer { buffer in
                    let bytes = UnsafeRawBufferPointer(
                        start: buffer.baseAddress,
                        count: buffer.count * MemoryLayout<UInt64>.size
                    )
                    return try body(bytes)
                }
            }

            fileprivate static let completenessWordIndex = 2
            fileprivate static let incompleteValue: UInt64 = 1

            fileprivate init(words: [UInt64]) {
                self.words = words
            }
        }

        /// UI policy uses touch idleness, never composition or owner readiness.
        public static func showsControl(
            isObserving: Bool, hasCandidates: Bool, hasActiveTouches: Bool,
            elapsedIdleNanoseconds: UInt64
        ) -> Bool {
            !hasActiveTouches && elapsedIdleNanoseconds >= 2_000_000_000
                && (isObserving || !hasCandidates)
        }

        public static let shared = KeyboardWakeOwnerProbe()
        public static let recordCapacity = 128
        public static let lifetimeNanoseconds: UInt64 = 600_000_000_000

        private static let headerWordCount = 11
        private static let recordWordCount = 11
        private static let magicWord: UInt64 = 0x4B57_4F50_524F_4245  // KWOPROBE
        private static let formatVersion: UInt64 = 1

        private let state: Mutex<State>
        private let processIdentifier: IdentifierWords
        private let clock: @Sendable () -> UInt64

        /// `now` is injectable so TTL behavior can be checked without sleeping.
        public init(
            now: @escaping @Sendable () -> UInt64 = {
                DispatchTime.now().uptimeNanoseconds
            }
        ) {
            self.state = Mutex(State())
            self.processIdentifier = IdentifierWords(uuid: UUID())
            self.clock = now
        }

        public var isArmed: Bool {
            let now = clock()
            return state.withLock { value in
                value.refreshExpiry(now: now)
                return value.lifecycle == .armed
            }
        }

        /// Expiry is terminal too, so the UI can keep the export affordance visible.
        public var isFrozen: Bool {
            let now = clock()
            return state.withLock { value in
                value.refreshExpiry(now: now)
                return value.lifecycle == .expired || value.lifecycle == .frozen
            }
        }

        /// Arms this instance once. An expired or frozen instance cannot be re-armed.
        @discardableResult
        public func arm() -> Bool {
            let now = clock()
            return state.withLock { value in
                guard value.lifecycle == .disarmed else { return false }

                value.lifecycle = .armed
                value.runIdentifier = IdentifierWords(uuid: UUID())
                value.armedAt = now
                value.expiresAt = Self.saturatingAdd(now, Self.lifetimeNanoseconds)
                _ = Self.append(
                    stage: .armed,
                    timestamp: now,
                    coordinatorOrdinal: 0,
                    appearanceOrdinal: 0,
                    attemptOrdinal: 0,
                    ownerPresent: false,
                    receiptPresent: false,
                    teardownResult: .notApplicable,
                    epoch: 0,
                    revision: 0,
                    to: &value
                )
                return true
            }
        }

        /// Allocates a process-local ordinal without retaining the coordinator.
        /// Zero means the UInt64 ordinal space has been exhausted.
        public func nextCoordinatorOrdinal() -> UInt64 {
            state.withLock { value in
                let (next, overflow) = value.lastCoordinatorOrdinal.addingReportingOverflow(1)
                guard !overflow, next != 0 else { return 0 }
                value.lastCoordinatorOrdinal = next
                return next
            }
        }

        /// Begins a synchronous insert-key observation window. Pair with `endAttempt`
        /// using `defer`; never carry its ordinal across an asynchronous boundary.
        public func beginAttempt(appearanceOrdinal: UInt64) -> UInt64? {
            let now = clock()
            return state.withLock { value in
                value.refreshExpiry(now: now)
                guard value.lifecycle == .armed else { return nil }
                guard value.activeAttemptOrdinal == 0 else {
                    // Reentrant input cannot borrow the outer attempt's identity.
                    value.invalidAttemptContext = true
                    value.activeAttemptOrdinal = 0
                    return nil
                }

                let (next, overflow) = value.lastAttemptOrdinal.addingReportingOverflow(1)
                guard !overflow, next != 0 else { return nil }
                value.lastAttemptOrdinal = next
                value.activeAttemptOrdinal = next
                value.appearanceOrdinal = appearanceOrdinal
                return next
            }
        }

        @discardableResult
        public func endAttempt(_ attemptOrdinal: UInt64) -> Bool {
            state.withLock { value in
                guard value.lifecycle == .armed,
                    attemptOrdinal != 0,
                    value.activeAttemptOrdinal == attemptOrdinal
                else {
                    return false
                }
                value.activeAttemptOrdinal = 0
                return true
            }
        }

        /// Appends finite metadata only while the one-shot probe is armed.
        @discardableResult
        public func record(
            stage: Stage,
            coordinatorOrdinal: UInt64,
            appearanceOrdinal: UInt64? = nil,
            ownerPresent: Bool,
            receiptPresent: Bool = false,
            teardownResult: TeardownResult = .notApplicable,
            epoch: UInt64 = 0,
            revision: UInt64 = 0
        ) -> Bool {
            let now = clock()
            return state.withLock { value in
                value.refreshExpiry(now: now)
                guard value.lifecycle == .armed else { return false }

                if let appearanceOrdinal {
                    value.appearanceOrdinal = appearanceOrdinal
                }
                return Self.append(
                    stage: stage,
                    timestamp: now,
                    coordinatorOrdinal: coordinatorOrdinal,
                    appearanceOrdinal: value.appearanceOrdinal,
                    attemptOrdinal: value.activeAttemptOrdinal,
                    ownerPresent: ownerPresent,
                    receiptPresent: receiptPresent,
                    teardownResult: teardownResult,
                    epoch: epoch,
                    revision: revision,
                    to: &value
                )
            }
        }

        /// Copies the bounded values under the mutex, then encodes after unlocking.
        public func freeze() -> Snapshot? {
            let now = clock()
            let frozenValue = state.withLock { value -> FrozenValue? in
                value.refreshExpiry(now: now)
                guard let runIdentifier = value.runIdentifier else { return nil }
                if let existing = value.frozenValue { return existing }

                let incomplete =
                    value.lifecycle == .expired || value.overflowCount != 0
                    || value.invalidAttemptContext || value.activeAttemptOrdinal != 0
                let records = (0..<value.recordCount).compactMap { value.records[$0] }
                let copy = FrozenValue(
                    isIncomplete: incomplete,
                    runIdentifier: runIdentifier,
                    processIdentifier: processIdentifier,
                    armedAt: value.armedAt,
                    expiresAt: value.expiresAt,
                    overflowCount: value.overflowCount,
                    records: records
                )
                value.lifecycle = .frozen
                value.activeAttemptOrdinal = 0
                value.frozenValue = copy
                return copy
            }

            guard let frozenValue else { return nil }
            return Snapshot(words: Self.encode(frozenValue))
        }

        private static func append(
            stage: Stage,
            timestamp: UInt64,
            coordinatorOrdinal: UInt64,
            appearanceOrdinal: UInt64,
            attemptOrdinal: UInt64,
            ownerPresent: Bool,
            receiptPresent: Bool,
            teardownResult: TeardownResult,
            epoch: UInt64,
            revision: UInt64,
            to state: inout State
        ) -> Bool {
            let (incremented, overflow) = state.lastSequence.addingReportingOverflow(1)
            let sequence = overflow ? UInt64.max : incremented
            state.lastSequence = sequence

            guard state.recordCount < recordCapacity else {
                state.overflowCount = saturatingIncrement(state.overflowCount)
                return false
            }

            state.records[state.recordCount] = StoredRecord(
                sequence: sequence,
                timestamp: timestamp,
                stage: stage.rawValue,
                coordinatorOrdinal: coordinatorOrdinal,
                appearanceOrdinal: appearanceOrdinal,
                attemptOrdinal: attemptOrdinal,
                ownerPresent: ownerPresent,
                receiptPresent: receiptPresent,
                teardownResult: teardownResult.rawValue,
                epoch: epoch,
                revision: revision
            )
            state.recordCount += 1
            return true
        }

        private static func encode(_ value: FrozenValue) -> [UInt64] {
            var words: [UInt64] = []
            words.reserveCapacity(headerWordCount + value.records.count * recordWordCount)
            words.append(magicWord)
            words.append(formatVersion)
            words.append(value.isIncomplete ? Snapshot.incompleteValue : 0)
            words.append(value.runIdentifier.high)
            words.append(value.runIdentifier.low)
            words.append(value.processIdentifier.high)
            words.append(value.processIdentifier.low)
            words.append(value.armedAt)
            words.append(value.expiresAt)
            words.append(UInt64(value.records.count))
            words.append(value.overflowCount)

            for record in value.records {
                words.append(record.sequence)
                words.append(record.timestamp)
                words.append(record.stage)
                words.append(record.coordinatorOrdinal)
                words.append(record.appearanceOrdinal)
                words.append(record.attemptOrdinal)
                words.append(record.ownerPresent ? 1 : 0)
                words.append(record.receiptPresent ? 1 : 0)
                words.append(record.teardownResult)
                words.append(record.epoch)
                words.append(record.revision)
            }
            return words
        }

        private static func saturatingIncrement(_ value: UInt64) -> UInt64 {
            value == UInt64.max ? UInt64.max : value + 1
        }

        private static func saturatingAdd(_ lhs: UInt64, _ rhs: UInt64) -> UInt64 {
            let (sum, overflow) = lhs.addingReportingOverflow(rhs)
            return overflow ? UInt64.max : sum
        }

        private enum Lifecycle: Equatable, Sendable {
            case disarmed
            case armed
            case expired
            case frozen
        }

        private struct State: Sendable {
            var lifecycle: Lifecycle = .disarmed
            var records = Array<StoredRecord?>(repeating: nil, count: recordCapacity)
            var recordCount = 0
            var overflowCount: UInt64 = 0
            var lastSequence: UInt64 = 0
            var lastCoordinatorOrdinal: UInt64 = 0
            var lastAttemptOrdinal: UInt64 = 0
            var invalidAttemptContext = false
            var activeAttemptOrdinal: UInt64 = 0
            var appearanceOrdinal: UInt64 = 0
            var armedAt: UInt64 = 0
            var expiresAt: UInt64 = 0
            var runIdentifier: IdentifierWords?
            var frozenValue: FrozenValue?

            mutating func refreshExpiry(now: UInt64) {
                guard lifecycle == .armed, now >= expiresAt else { return }
                lifecycle = .expired
                activeAttemptOrdinal = 0
            }
        }

        private struct StoredRecord: Sendable {
            let sequence: UInt64
            let timestamp: UInt64
            let stage: UInt64
            let coordinatorOrdinal: UInt64
            let appearanceOrdinal: UInt64
            let attemptOrdinal: UInt64
            let ownerPresent: Bool
            let receiptPresent: Bool
            let teardownResult: UInt64
            let epoch: UInt64
            let revision: UInt64
        }

        private struct FrozenValue: Sendable {
            let isIncomplete: Bool
            let runIdentifier: IdentifierWords
            let processIdentifier: IdentifierWords
            let armedAt: UInt64
            let expiresAt: UInt64
            let overflowCount: UInt64
            let records: [StoredRecord]
        }

        private struct IdentifierWords: Sendable {
            let high: UInt64
            let low: UInt64

            init(uuid: UUID) {
                let bytes = withUnsafeBytes(of: uuid.uuid) { Array($0) }
                high = Self.makeWord(bytes, startingAt: 0)
                low = Self.makeWord(bytes, startingAt: 8)
            }

            private static func makeWord(_ bytes: [UInt8], startingAt start: Int) -> UInt64 {
                var word: UInt64 = 0
                for index in start..<(start + 8) {
                    word = (word << 8) | UInt64(bytes[index])
                }
                return word
            }
        }
    }
#endif
