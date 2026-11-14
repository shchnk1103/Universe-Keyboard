import Foundation
import os.lock

public struct T9CycleDiagnostic: Equatable, Sendable {
    public enum Terminal: String, Sendable {
        case notStarted = "not_started"
        case succeeded
        case rolledBack = "rolled_back"
        case rollbackFailed = "rollback_failed"
        case criteriaRejected = "criteria_rejected"
    }
    public enum Band: String, Sendable { case zero, nonzero, notApplicable = "not_applicable" }
    public enum Shape: String, Sendable {
        case empty, segmented, unsegmented, notApplicable = "not_applicable"
        public static func shape(of preedit: String?) -> Shape {
            guard let preedit else { return .notApplicable }
            if preedit.isEmpty { return .empty }
            let separators: Set<Unicode.Scalar> = ["'", "\u{2019}", " ", "\u{00B7}"]
            let segmented = preedit.unicodeScalars.contains { separators.contains($0) }
            return segmented ? .segmented : .unsegmented
        }
    }
    public enum Flag: String, Sendable { case yes, no, notApplicable = "not_applicable" }
    public var sequence: UInt64
    public var terminal: Terminal
    public var candidateBand: Band
    public var preeditShape: Shape
    public var usable: Flag
    public var exact: Flag
    public var priorDrops: Int
    public init(
        sequence: UInt64 = 0, terminal: Terminal, candidateBand: Band = .notApplicable,
        preeditShape: Shape = .notApplicable, usable: Flag = .notApplicable,
        exact: Flag = .notApplicable, priorDrops: Int = 0
    ) {
        self.sequence = sequence
        self.terminal = terminal
        self.candidateBand = candidateBand
        self.preeditShape = preeditShape
        self.usable = usable
        self.exact = exact
        self.priorDrops = priorDrops
    }
}

public struct T9DeleteDiagnostic: Equatable, Sendable {
    public enum Branch: String, Sendable {
        case selectedDigitUndo = "selected_digit_undo"
        case identityDelete = "identity_delete"
        case engineDelete = "engine_delete"
        case other
    }
    public enum Restored: String, Sendable { case yes, no, notApplicable = "not_applicable" }
    public var sequence: UInt64
    public var branch: Branch
    public var restored: Restored
    public var priorDrops: Int
    public init(sequence: UInt64 = 0, branch: Branch, restored: Restored, priorDrops: Int = 0) {
        self.sequence = sequence
        self.branch = branch
        self.restored = restored
        self.priorDrops = priorDrops
    }
}

/// Non-waiting T9 admission. Sequence, time and enqueue share one trylock.
/// This type never calls DiagnosticsJournalRuntime.record, Ingress.record,
/// Mutex.withLock, or the Debug ticket set.
public final class T9DiagnosticAdmission: @unchecked Sendable {
    public static let shared = T9DiagnosticAdmission()
    public static let capacity = 256
    public static let windowLimit = 20
    public static let windowNanoseconds: UInt64 = 10_000_000_000
    public private(set) var recordTouchCount = 0

    private var lock = os_unfair_lock()
    private var cyclesQueue: [T9CycleDiagnostic] = []
    private var deletesQueue: [T9DeleteDiagnostic] = []
    private var admittedTimes: [UInt64] = []
    private var drops = 0
    private var nextSequence: UInt64 = 0
    private var suspended = false
    private let holdRelease = DispatchSemaphore(value: 0)
    private let holdEntered = DispatchSemaphore(value: 0)
    private let holdExited = DispatchSemaphore(value: 0)
    private var holdThreadRunning = false

    public func resetForTesting() {
        if holdThreadRunning {
            releaseLockForTesting()
        }
        _ = os_unfair_lock_trylock(&lock)
        cyclesQueue.removeAll()
        deletesQueue.removeAll()
        admittedTimes.removeAll()
        drops = 0
        nextSequence = 0
        suspended = false
        recordTouchCount = 0
        os_unfair_lock_unlock(&lock)
    }

    public func holdLockForTesting() {
        holdThreadRunning = true
        Thread.detachNewThread { [self] in
            os_unfair_lock_lock(&self.lock)
            holdEntered.signal()
            holdRelease.wait()
            os_unfair_lock_unlock(&self.lock)
            holdExited.signal()
        }
        holdEntered.wait()
    }

    public func releaseLockForTesting() {
        guard holdThreadRunning else { return }
        holdThreadRunning = false
        holdRelease.signal()
        holdExited.wait()
    }

    public func setSuspendedForTesting(_ value: Bool) {
        guard os_unfair_lock_trylock(&lock) else { return }
        suspended = value
        os_unfair_lock_unlock(&lock)
    }

    @discardableResult
    public func tryEnqueue(_ event: T9CycleDiagnostic, now: UInt64 = DispatchTime.now().uptimeNanoseconds) -> Bool {
        guard os_unfair_lock_trylock(&lock) else { return false }
        defer { os_unfair_lock_unlock(&lock) }
        guard admit(now: now) else { return false }
        var stored = event
        stored.sequence = nextSequence
        nextSequence &+= 1
        stored.priorDrops = drops
        drops = 0
        cyclesQueue.append(stored)
        return true
    }

    @discardableResult
    public func tryEnqueue(_ event: T9DeleteDiagnostic, now: UInt64 = DispatchTime.now().uptimeNanoseconds) -> Bool {
        guard os_unfair_lock_trylock(&lock) else { return false }
        defer { os_unfair_lock_unlock(&lock) }
        guard admit(now: now) else { return false }
        var stored = event
        stored.sequence = nextSequence
        nextSequence &+= 1
        stored.priorDrops = drops
        drops = 0
        deletesQueue.append(stored)
        return true
    }

    public func cycles() -> [T9CycleDiagnostic] {
        guard os_unfair_lock_trylock(&lock) else { return [] }
        defer { os_unfair_lock_unlock(&lock) }
        return cyclesQueue
    }

    public func deletes() -> [T9DeleteDiagnostic] {
        guard os_unfair_lock_trylock(&lock) else { return [] }
        defer { os_unfair_lock_unlock(&lock) }
        return deletesQueue
    }

    public func exportedText() -> String {
        guard os_unfair_lock_trylock(&lock) else { return "" }
        defer { os_unfair_lock_unlock(&lock) }
        let cycleLines = cyclesQueue.map {
            "cycle terminal=\($0.terminal.rawValue) band=\($0.candidateBand.rawValue) shape=\($0.preeditShape.rawValue) usable=\($0.usable.rawValue) exact=\($0.exact.rawValue) drops=\($0.priorDrops)"
        }
        let deleteLines = deletesQueue.map {
            "delete branch=\($0.branch.rawValue) restored=\($0.restored.rawValue) drops=\($0.priorDrops)"
        }
        return (cycleLines + deleteLines).joined(separator: "\n")
    }

    private func admit(now: UInt64) -> Bool {
        if suspended || cyclesQueue.count + deletesQueue.count >= Self.capacity {
            noteDrop()
            return false
        }
        admittedTimes.removeAll { now &- $0 > Self.windowNanoseconds && now >= $0 }
        if admittedTimes.count >= Self.windowLimit {
            noteDrop()
            return false
        }
        admittedTimes.append(now)
        return true
    }

    private func noteDrop() {
        if drops < 255 { drops += 1 }
    }
}
