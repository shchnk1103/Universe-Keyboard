#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import Synchronization

    /// One production arm attempt and a fixed, content-free buffer.
    /// Recoverable invalidity never controls the query. Swift/OS allocation failure
    /// may terminate the process; a missing snapshot is unavailable evidence, never zero cost.
    public final class QueryCostMemoryProbe: Sendable {
        public static let shared = QueryCostMemoryProbe(now: { DispatchTime.now().uptimeNanoseconds }, synthetic: false)
        public static let capacity = 4096
        public static let lifetimeNanoseconds: UInt64 = 1_800_000_000_000
        public static let magic: UInt64 = 0x5143_5052_4F42_4531
        public static let headerWords = 32
        public static let recordWords = 20
        public static let maximumBytes = 655_616

        /// These identities describe different query facades; an owner epoch is never a native session ID.
        public enum ScopeKind: UInt64, Sendable {
            case unavailable = 0, nativeCorrectionSession = 1, threadAffineProvider = 2, unsupportedResponsive = 3
        }
        public struct FacadeScope: Equatable, Sendable {
            public let kind: ScopeKind
            public let facadeOrdinal: UInt64
            public let lifetimeOrdinal: UInt64
            public let schema: TypoCorrectionQueryDebugScope.Schema

            public init(
                kind: ScopeKind, facadeOrdinal: UInt64, lifetimeOrdinal: UInt64,
                schema: TypoCorrectionQueryDebugScope.Schema
            ) {
                self.kind = kind
                self.facadeOrdinal = facadeOrdinal
                self.lifetimeOrdinal = lifetimeOrdinal
                self.schema = schema
            }
            public static func unavailable(kind: ScopeKind = .unavailable, facadeOrdinal: UInt64 = 0) -> Self {
                Self(kind: kind, facadeOrdinal: facadeOrdinal, lifetimeOrdinal: 0, schema: .unknown)
            }
            public var isAdmissible: Bool {
                (kind == .nativeCorrectionSession || kind == .threadAffineProvider)
                    && facadeOrdinal != 0 && lifetimeOrdinal != 0 && schema == .lunaPinyin
            }
            /// Only immutable, already-published owner observations. No session creation or waiting.
            public static func threadAffineProvider(
                facadeOrdinal: UInt64, epochBefore: UInt64, epochAfter: UInt64,
                ownerReady: Bool, nativeSessionValid: Bool, schema: TypoCorrectionQueryDebugScope.Schema
            ) -> Self? {
                guard facadeOrdinal != 0, epochBefore != 0, epochBefore == epochAfter,
                    ownerReady, nativeSessionValid, schema == .lunaPinyin
                else { return nil }
                return Self(
                    kind: .threadAffineProvider, facadeOrdinal: facadeOrdinal,
                    lifetimeOrdinal: epochBefore, schema: schema)
            }
        }
        public struct Scope: Equatable, Sendable {
            public let runID: UUID
            public let coordinatorOrdinal: UInt64
            public let facade: FacadeScope
            public let fullAccess: Bool
            public init(
                runID: UUID = UUID(), coordinatorOrdinal: UInt64,
                facade: FacadeScope, fullAccess: Bool
            ) {
                self.runID = runID
                self.coordinatorOrdinal = coordinatorOrdinal
                self.facade = facade
                self.fullAccess = fullAccess
            }
        }
        public enum Status: Equatable, Sendable { case disabled, rejected, armed, frozen }
        public enum ArmResult: Equatable, Sendable { case armed, rejected, alreadyAttempted }
        public enum Terminal: UInt64, Sendable {
            case completed = 1, cancelled = 2, fenced = 3, lifecycle = 4, invalid = 5
        }
        public struct Reason: OptionSet, Sendable {
            public let rawValue: UInt64
            public init(rawValue: UInt64) { self.rawValue = rawValue }
            public static let capacity = Self(rawValue: 1)
            public static let expiry = Self(rawValue: 2)
            public static let scopeChange = Self(rawValue: 4)
            public static let lifecycle = Self(rawValue: 8)
            public static let queryActive = Self(rawValue: 16)
            public static let operationActive = Self(rawValue: 32)
            public static let unmatched = Self(rawValue: 64)
            public static let counterOverflow = Self(rawValue: 128)
            public static let clockInvalid = Self(rawValue: 256)
            public static let schemaOrAccessUnknown = Self(rawValue: 512)
            public static let observerPause = Self(rawValue: 1024)
            public static let sequenceInvalid = Self(rawValue: 2048)
        }
        public struct Reservation: Sendable {
            fileprivate let slot: Int
            fileprivate let ordinal: UInt64
            fileprivate let probeID: UUID
        }
        private struct Record: Sendable {
            var kind: UInt64 = 0, ordinal: UInt64 = 0, tick: UInt64 = 0
            var sequence: UInt64 = 0, fixture: UInt64 = 0, arm: UInt64 = 0
            var operation: UInt64 = 0, query: UInt64 = 0, stage: UInt64 = 0
            var readiness: UInt64 = 0, result: UInt64 = 0, bucket: UInt64 = 0
            var disposition: UInt64 = 0, elapsed: UInt64 = 0, duration: UInt64 = 0
            var terminal: UInt64 = 0, validity: UInt64 = 0, epoch: UInt64 = 0, revision: UInt64 = 0
            var words: [UInt64] {
                [
                    kind, ordinal, tick, sequence, fixture, arm, operation, query, stage,
                    readiness, result, bucket, disposition, elapsed, duration, terminal,
                    validity, epoch, revision, 0,
                ]
            }
        }
        private struct Operation: Sendable {
            var ordinal: UInt64 = 0, sequence: UInt64 = 0, fixture: UInt64 = 0, arm: UInt64 = 0
        }
        private struct Frozen: Sendable {
            let header: [UInt64]
            let records: [Record]
        }
        private struct State: Sendable {
            var status: Status = .disabled
            var scope: Scope?
            var records: [Record] = []
            var operations: [Operation] = []
            var count = 0
            var reasons: Reason = []
            var start: UInt64 = 0, lastTick: UInt64 = 0
            var queryStarted: UInt64 = 0, queryCompleted: UInt64 = 0, queryActive: UInt64 = 0
            var operationStarted: UInt64 = 0, operationTerminal: UInt64 = 0, operationActive: UInt64 = 0
            var rejected: UInt64 = 0, sequenceBegins: UInt64 = 0, sequenceEnds: UInt64 = 0
            var sequence: UInt64 = 0, fixture: UInt64 = 0, arm: UInt64 = 0
            var frozen: Frozen?

            mutating func increment(_ key: WritableKeyPath<State, UInt64>) -> Bool {
                let (value, overflow) = self[keyPath: key].addingReportingOverflow(1)
                guard !overflow else {
                    reasons.insert(.counterOverflow)
                    return false
                }
                self[keyPath: key] = value
                return true
            }
            mutating func append(_ record: Record) -> Int? {
                guard count < QueryCostMemoryProbe.capacity else {
                    reasons.insert(.capacity)
                    _ = increment(\.rejected)
                    return nil
                }
                var value = record
                value.ordinal = UInt64(count + 1)
                records[count] = value
                count += 1
                return count - 1
            }
            mutating func observe(_ now: UInt64) {
                if now < lastTick { reasons.insert(.clockInvalid) }
                lastTick = max(lastTick, now)
                if now < start || now - start >= QueryCostMemoryProbe.lifetimeNanoseconds {
                    reasons.insert(.expiry)
                }
            }
        }
        private let state = Mutex(State())
        private static let processID = UUID()
        private let probeID = UUID()
        private let clock: @Sendable () -> UInt64
        // Internal ownership is visible only to testable clients; ordinary clients
        // cannot construct or replace the production singleton, including after rejection.
        let isSyntheticForTesting: Bool
        private init(now: @escaping @Sendable () -> UInt64, synthetic: Bool) {
            clock = now
            isSyntheticForTesting = synthetic
        }
        static func makeSyntheticForTesting(
            now: @escaping @Sendable () -> UInt64 = { DispatchTime.now().uptimeNanoseconds }
        ) -> QueryCostMemoryProbe {
            QueryCostMemoryProbe(now: now, synthetic: true)
        }
        public var status: Status { state.withLock { $0.status } }
        public var scope: Scope? { state.withLock { $0.scope } }
        public func arm(_ scope: Scope, eligible: Bool) -> ArmResult {
            // Allocation is confined to the first arm, never a query hook.
            // This is a capacity bound, not a recoverable-OOM guarantee. A process
            // exit or lost snapshot must be admitted as unavailable outside this process.
            state.withLock { state in
                guard state.status == .disabled else { return .alreadyAttempted }
                guard eligible, scope.fullAccess, scope.coordinatorOrdinal != 0,
                    scope.facade.isAdmissible
                else {
                    state.status = .rejected
                    state.reasons.insert(.schemaOrAccessUnknown)
                    return .rejected
                }
                state.records = Array(repeating: Record(), count: Self.capacity)
                state.operations = Array(repeating: Operation(), count: 64)
                state.scope = scope
                state.status = .armed
                state.start = clock()
                state.lastTick = state.start
                return .armed
            }
        }
        public func invalidate(_ reason: Reason) {
            state.withLock { state in
                guard state.status == .armed else { return }
                let newlyInvalid = !state.reasons.isSuperset(of: reason)
                state.reasons.formUnion(reason)
                if newlyInvalid && !reason.intersection([.scopeChange, .lifecycle, .schemaOrAccessUnknown]).isEmpty {
                    let now = clock()
                    state.observe(now)
                    _ = state.append(
                        Record(
                            kind: 6, tick: now, sequence: state.sequence,
                            fixture: state.fixture, arm: state.arm,
                            terminal: reason.contains(.lifecycle)
                                ? Terminal.lifecycle.rawValue : Terminal.invalid.rawValue))
                }
            }
        }
        public func verifyScope(
            facade: FacadeScope?, fullAccess: Bool, coordinatorOrdinal: UInt64? = nil
        ) {
            let changed = state.withLock { state in
                state.status == .armed
                    && (facade != state.scope?.facade || !fullAccess
                        || (coordinatorOrdinal != nil && coordinatorOrdinal != state.scope?.coordinatorOrdinal))
            }
            if changed { invalidate(.scopeChange) }
        }
        @discardableResult
        public func beginSequence(ordinal: UInt64, fixture: UInt64, arm: UInt64, eligible: Bool) -> Bool {
            state.withLock { state in
                guard state.status == .armed else { return false }
                guard eligible, state.operationActive == 0, state.queryActive == 0,
                    state.sequence == 0, ordinal == state.sequenceBegins + 1,
                    ordinal <= 12, (1...6).contains(fixture), (1...2).contains(arm)
                else {
                    state.reasons.insert(.sequenceInvalid)
                    return false
                }
                let now = clock()
                state.observe(now)
                guard state.increment(\.sequenceBegins) else { return false }
                state.sequence = ordinal
                state.fixture = fixture
                state.arm = arm
                return state.append(Record(kind: 1, tick: now, sequence: ordinal, fixture: fixture, arm: arm)) != nil
            }
        }
        @discardableResult
        public func endSequence(eligible: Bool) -> Bool {
            state.withLock { state in
                guard state.status == .armed else { return false }
                guard eligible, state.sequence != 0, state.operationActive == 0, state.queryActive == 0 else {
                    state.reasons.insert(.sequenceInvalid)
                    return false
                }
                let now = clock()
                state.observe(now)
                guard state.increment(\.sequenceEnds) else { return false }
                let appended =
                    state.append(
                        Record(
                            kind: 2, tick: now, sequence: state.sequence,
                            fixture: state.fixture, arm: state.arm)) != nil
                state.sequence = 0
                state.fixture = 0
                state.arm = 0
                return appended
            }
        }
        public func beginOperation(_ ordinal: UInt64) {
            state.withLock { state in
                guard state.status == .armed else { return }
                guard ordinal != 0, state.sequence != 0,
                    !state.records.prefix(state.count).contains(where: { $0.kind == 3 && $0.operation == ordinal }),
                    let index = state.operations.firstIndex(where: { $0.ordinal == 0 })
                else {
                    state.reasons.insert(.unmatched)
                    return
                }
                let now = clock()
                state.observe(now)
                guard state.increment(\.operationStarted), state.increment(\.operationActive) else { return }
                state.operations[index] = Operation(
                    ordinal: ordinal, sequence: state.sequence,
                    fixture: state.fixture, arm: state.arm)
                _ = state.append(
                    Record(
                        kind: 3, tick: now, sequence: state.sequence,
                        fixture: state.fixture, arm: state.arm, operation: ordinal))
            }
        }
        public func endOperation(_ ordinal: UInt64, terminal: Terminal) {
            state.withLock { state in
                guard state.status == .armed else { return }
                // The bounded wire buffer is also the terminal memo. A/B/A cleanup
                // can revisit any earlier operation, not merely the last one. Only a
                // recorded terminal is deduplicated; unknown IDs and capacity loss
                // remain incomplete, without changing production driver cleanup.
                if ordinal != 0
                    && state.records.prefix(state.count).contains(where: {
                        $0.kind == 4 && $0.operation == ordinal
                    })
                {
                    return
                }
                guard let index = state.operations.firstIndex(where: { $0.ordinal == ordinal && ordinal != 0 }) else {
                    state.reasons.insert(.unmatched)
                    return
                }
                let binding = state.operations[index]
                let now = clock()
                state.observe(now)
                _ = state.increment(\.operationTerminal)
                state.operationActive -= 1
                _ = state.append(
                    Record(
                        kind: 4, tick: now, sequence: binding.sequence,
                        fixture: binding.fixture, arm: binding.arm, operation: ordinal, terminal: terminal.rawValue))
                state.operations[index] = Operation()
            }
        }
        public func beginInvocation(
            operation: UInt64, stage: TypoCorrectionRecallStage,
            epoch: UInt64 = 0, revision: UInt64 = 0
        ) -> Reservation? {
            state.withLock { state in
                guard state.status == .armed else { return nil }
                guard let binding = state.operations.first(where: { $0.ordinal == operation && operation != 0 }) else {
                    state.reasons.insert(.unmatched)
                    return nil
                }
                let now = clock()
                state.observe(now)
                guard state.increment(\.queryStarted), state.increment(\.queryActive) else { return nil }
                guard
                    let slot = state.append(
                        Record(
                            kind: 5, tick: now, sequence: binding.sequence,
                            fixture: binding.fixture, arm: binding.arm, operation: operation,
                            query: state.queryStarted, stage: stage == .stageOne ? 1 : 2,
                            validity: 1, epoch: epoch, revision: revision))
                else { return nil }
                return Reservation(slot: slot, ordinal: state.queryStarted, probeID: probeID)
            }
        }
        public func finishInvocation(_ reservation: Reservation?, payload: DiagnosticEvent.TypoRecallQueryPayload) {
            state.withLock { state in
                guard state.status == .armed else { return }
                guard let reservation, reservation.probeID == probeID, (0..<state.count).contains(reservation.slot),
                    state.records[reservation.slot].query == reservation.ordinal,
                    state.records[reservation.slot].validity == 1,
                    state.records[reservation.slot].operation == payload.operationOrdinal,
                    state.records[reservation.slot].stage == (payload.stage == .stageOne ? 1 : 2)
                else {
                    state.reasons.insert(.unmatched)
                    return
                }
                state.observe(clock())
                var record = state.records[reservation.slot]
                record.readiness = Self.code(payload.readiness)
                record.result = Self.code(payload.resultState)
                record.bucket = Self.code(payload.returnedCandidateBucket)
                record.disposition = payload.disposition == .applied ? 1 : 2
                record.elapsed = UInt64(payload.facadeElapsedMicroseconds)
                record.duration = Self.code(payload.durationState)
                record.validity = 2
                state.records[reservation.slot] = record
                _ = state.increment(\.queryCompleted)
                state.queryActive -= 1
            }
        }
        public struct Snapshot: Equatable, Sendable {
            public let words: [UInt64]
            public var isIncomplete: Bool { words[6] != 0 }
            public var queryCount: UInt64 { words[21] }
            public func withUnsafeBytes<T>(_ body: (UnsafeRawBufferPointer) throws -> T) rethrows -> T {
                // Explicit endian encoding is outside all probe locks and query timing.
                let encoded = words.map { $0.littleEndian }
                return try encoded.withUnsafeBufferPointer {
                    try body(UnsafeRawBufferPointer($0))
                }
            }
        }
        /// Freezing/exporting allocates outside query hooks. Allocation failure may
        /// lose the process/snapshot; the external evidence admission must report unavailable.
        public func freeze(callbacksQuiescent: Bool = true) -> Snapshot? {
            let raw: Frozen? = state.withLock { state in
                if let frozen = state.frozen { return frozen }
                guard state.status == .armed, let scope = state.scope else { return nil }
                let now = clock()
                state.observe(now)
                if state.queryActive != 0 { state.reasons.insert(.queryActive) }
                if state.operationActive != 0 { state.reasons.insert(.operationActive) }
                if !callbacksQuiescent || state.sequence != 0 || state.sequenceBegins != state.sequenceEnds {
                    state.reasons.insert(.sequenceInvalid)
                }
                let run = Self.identifier(scope.runID)
                let process = Self.identifier(Self.processID)
                let header: [UInt64] = [
                    Self.magic, 2, 32, 20, UInt64(state.count), UInt64(Self.capacity),
                    state.reasons.isEmpty ? 0 : 1, state.reasons.rawValue, run.0, run.1, process.0, process.1,
                    scope.coordinatorOrdinal, scope.facade.lifetimeOrdinal, scope.facade.schema.rawValue,
                    scope.fullAccess ? 2 : 1, scope.facade.kind.rawValue, state.start, now, Self.lifetimeNanoseconds,
                    state.queryStarted, state.queryCompleted, state.queryActive, state.operationStarted,
                    state.operationTerminal, state.operationActive, state.rejected, state.sequenceBegins,
                    state.sequenceEnds, UInt64(state.count), state.reasons.contains(.clockInvalid) ? 1 : 0,
                    scope.facade.facadeOrdinal,
                ]
                let frozen = Frozen(header: header, records: Array(state.records.prefix(state.count)))
                state.frozen = frozen
                state.status = .frozen
                return frozen
            }
            guard let raw else { return nil }
            return Snapshot(words: raw.header + raw.records.flatMap(\.words))
        }
        /// Strict finite wire admission, outside the keyboard hot path.
        /// Incomplete snapshots retain lower-bound records, never invented missing totals.
        /// Parsing is not guaranteed to survive OOM; only an actually decoded snapshot
        /// can be admitted, and a missing result is never reconstructed.
        public static func decode(_ bytes: [UInt8]) -> Snapshot? {
            guard bytes.count >= headerWords * 8, bytes.count <= maximumBytes,
                bytes.count.isMultiple(of: 8)
            else { return nil }
            var words: [UInt64] = []
            words.reserveCapacity(bytes.count / 8)
            for offset in stride(from: 0, to: bytes.count, by: 8) {
                let value = (0..<8).reduce(UInt64(0)) { $0 | UInt64(bytes[offset + $1]) << (8 * $1) }
                words.append(value)
            }
            guard words[0] == magic, words[1] == 2, words[2] == 32, words[3] == 20,
                words[4] <= UInt64(capacity), words[5] == UInt64(capacity),
                words.count == headerWords + Int(words[4]) * recordWords,
                words[6] <= 1, words[7] & ~UInt64(4095) == 0,
                (words[6] == 0) == (words[7] == 0), words[12] != 0, words[13] != 0,
                words[14] == 1, words[15] == 2, (words[16] == 1 || words[16] == 2),
                words[19] == lifetimeNanoseconds, words[29] == words[4], words[30] <= 1,
                words[31] != 0, words[21] <= words[20], words[24] <= words[23],
                (words[30] == 1) == (words[7] & Reason.clockInvalid.rawValue != 0),
                words[27] >= words[28], words[27] <= 12
            else { return nil }
            if words[30] == 0 && words[18] < words[17] { return nil }
            var queryIDs = Set<UInt64>()
            var operationIDs = Set<UInt64>()
            var activeOperations: [UInt64: (UInt64, UInt64, UInt64)] = [:]
            var activeSequence: (UInt64, UInt64, UInt64)?
            var begins: UInt64 = 0, ends: UInt64 = 0, completeQueries: UInt64 = 0, terminals: UInt64 = 0
            var previousTick = words[17]
            var lastQueryOrdinal: UInt64 = 0
            let lossy = words[7] & (Reason.capacity.rawValue | Reason.counterOverflow.rawValue) != 0
            for index in 0..<Int(words[4]) {
                let start = headerWords + index * recordWords
                let record = Array(words[start..<(start + recordWords)])
                guard (1...6).contains(record[0]), record[1] == UInt64(index + 1), record[19] == 0,
                    record[3] <= 12, record[4] <= 6, record[5] <= 2
                else { return nil }
                if words[30] == 0 && (record[2] < previousTick || record[2] > words[18]) { return nil }
                previousTick = record[2]
                if record[0] != 6 {
                    guard record[3] != 0, record[4] != 0, record[5] != 0 else { return nil }
                }
                switch record[0] {
                case 1:
                    guard activeSequence == nil, record[3] == begins + 1,
                        record[6...18].allSatisfy({ $0 == 0 })
                    else { return nil }
                    activeSequence = (record[3], record[4], record[5])
                    begins += 1
                case 2:
                    guard let sequence = activeSequence,
                        sequence.0 == record[3], sequence.1 == record[4], sequence.2 == record[5],
                        activeOperations.isEmpty, record[6...18].allSatisfy({ $0 == 0 })
                    else { return nil }
                    activeSequence = nil
                    ends += 1
                case 3:
                    guard record[6] != 0, operationIDs.insert(record[6]).inserted,
                        let sequence = activeSequence,
                        sequence.0 == record[3], sequence.1 == record[4], sequence.2 == record[5],
                        record[7...18].allSatisfy({ $0 == 0 })
                    else { return nil }
                    activeOperations[record[6]] = sequence
                case 4:
                    guard let binding = activeOperations.removeValue(forKey: record[6]),
                        binding.0 == record[3], binding.1 == record[4], binding.2 == record[5],
                        (1...5).contains(record[15]), record[7...14].allSatisfy({ $0 == 0 }),
                        record[16...18].allSatisfy({ $0 == 0 })
                    else { return nil }
                    terminals += 1
                case 5:
                    guard let binding = activeOperations[record[6]], binding.0 == record[3],
                        binding.1 == record[4], binding.2 == record[5], record[7] > lastQueryOrdinal,
                        queryIDs.insert(record[7]).inserted, (1...2).contains(record[8]),
                        record[15] == 0, (1...2).contains(record[16])
                    else { return nil }
                    lastQueryOrdinal = record[7]
                    if record[16] == 1 {
                        guard record[9...14].allSatisfy({ $0 == 0 }), words[6] == 1 else { return nil }
                    } else {
                        guard (1...3).contains(record[9]), (1...5).contains(record[10]), record[11] <= 2,
                            (1...2).contains(record[12]), record[13] <= UInt64(UInt32.max),
                            (1...3).contains(record[14])
                        else { return nil }
                        switch record[10] {
                        case 1: guard record[9] != 2 && (1...2).contains(record[11]) else { return nil }
                        case 2: guard record[9] == 2 && record[11] == 0 else { return nil }
                        case 3: guard record[9] == 1 && record[11] == 0 else { return nil }
                        default: guard record[9] == 3 && record[11] == 0 else { return nil }
                        }
                        if record[14] == 2 && record[13] != UInt64(UInt32.max) { return nil }
                        if record[14] == 3 && record[13] != 0 { return nil }
                        completeQueries += 1
                    }
                case 6:
                    guard words[6] == 1,
                        words[7]
                            & (Reason.scopeChange.rawValue | Reason.lifecycle.rawValue
                                | Reason.schemaOrAccessUnknown.rawValue) != 0,
                        record[6...14].allSatisfy({ $0 == 0 }),
                        (4...5).contains(record[15]), record[16...18].allSatisfy({ $0 == 0 })
                    else { return nil }
                    if let sequence = activeSequence {
                        guard sequence.0 == record[3], sequence.1 == record[4], sequence.2 == record[5] else {
                            return nil
                        }
                    } else if record[3...5].contains(where: { $0 != 0 }) {
                        return nil
                    }
                default: return nil
                }
            }
            guard completeQueries <= words[21], UInt64(queryIDs.count) <= words[20],
                UInt64(operationIDs.count) <= words[23], terminals <= words[24],
                begins <= words[27], ends <= words[28]
            else { return nil }
            if !lossy {
                guard begins == words[27], ends == words[28], completeQueries == words[21],
                    UInt64(queryIDs.count) == words[20],
                    UInt64(operationIDs.count) == words[23], terminals == words[24],
                    words[22] == words[20] - words[21], words[25] == words[23] - words[24],
                    queryIDs.allSatisfy({ $0 <= words[20] })
                else { return nil }
            }
            if words[6] == 0 {
                guard words[22] == 0, words[25] == 0, words[26] == 0, activeSequence == nil,
                    activeOperations.isEmpty, words[30] == 0
                else { return nil }
            }
            return Snapshot(words: words)
        }

        private static func identifier(_ id: UUID) -> (UInt64, UInt64) {
            var bytes = id.uuid
            return withUnsafeBytes(of: &bytes) { bytes in
                func word(_ offset: Int) -> UInt64 {
                    (0..<8).reduce(0) { $0 | UInt64(bytes[offset + $1]) << (8 * $1) }
                }
                return (word(0), word(8))
            }
        }
        private static func code(_ value: TypoCorrectionQueryReadiness) -> UInt64 {
            switch value {
            case .ready: 1;
            case .unavailable: 2;
            case .unknown: 3
            }
        }
        private static func code(_ value: TypoCorrectionQueryResultState) -> UInt64 {
            switch value {
            case .candidatesReturned: 1;
            case .sidecarUnavailable: 2;
            case .contextUnavailable: 3;
            case .emptyInput: 4;
            case .zeroLimit: 5
            }
        }
        private static func code(_ value: DiagnosticEvent.TypoRecallCandidateBucket) -> UInt64 {
            switch value {
            case .notApplicable: 0;
            case .zero: 1;
            case .oneToThree: 2
            }
        }
        private static func code(_ value: DiagnosticEvent.TypoRecallQueryDurationState) -> UInt64 {
            switch value {
            case .measured: 1;
            case .saturated: 2;
            case .clockRegression: 3
            }
        }
    }
#endif
