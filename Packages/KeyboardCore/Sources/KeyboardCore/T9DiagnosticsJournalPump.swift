import Dispatch
import Foundation

/// 009 S1c: background bridge from `T9DiagnosticAdmission` to the diagnostics journal.
///
/// The key path never touches this type. One process-level pump owns a serial utility queue and
/// (in production) one repeating timer. Each tick takes at most one batch, merges it in admission
/// order and hands events to the runtime. No tick re-enters, nothing busy-waits, and no engine
/// is referenced here.
public final class T9DiagnosticsJournalPump: @unchecked Sendable {
    /// Test seam: tests install a manual scheduler and call `tick()` themselves.
    public enum Scheduler: Sendable {
        case timer(interval: TimeInterval)
        case manual
    }

    private enum LifecycleCommand {
        case enable
        case revoke
    }

    private let admission: T9DiagnosticAdmission
    private let runtime: DiagnosticsJournalRuntime
    private let isSwitchEnabled: @Sendable () -> Bool
    private let closeGeneration: @Sendable () -> UInt64
    private let queue: DispatchQueue
    private var timer: DispatchSourceTimer?

    // All state below is touched only on `queue`.
    private var writableGeneration: UInt64 = 0
    private var isWritable = false
    private var pendingCommands: [LifecycleCommand] = []
    private var closeSeen: UInt64
    private var ticking = false
    private var tickCountForTesting = 0

    public init(
        admission: T9DiagnosticAdmission,
        runtime: DiagnosticsJournalRuntime,
        isSwitchEnabled: @escaping @Sendable () -> Bool,
        closeGeneration: @escaping @Sendable () -> UInt64,
        scheduler: Scheduler = .timer(interval: 0.5)
    ) {
        self.admission = admission
        self.runtime = runtime
        self.isSwitchEnabled = isSwitchEnabled
        self.closeGeneration = closeGeneration
        closeSeen = closeGeneration()
        queue = DispatchQueue(label: "com.universekeyboard.t9-diagnostics-pump", qos: .utility)
        if case .timer(let interval) = scheduler {
            let source = DispatchSource.makeTimerSource(queue: queue)
            source.schedule(deadline: .now() + interval, repeating: interval, leeway: .milliseconds(100))
            source.setEventHandler { [weak self] in self?.tickOnQueue() }
            timer = source
            source.resume()
        }
    }

    deinit { timer?.cancel() }

    /// Keyboard became visible (viewWillAppear / host recovery). Asynchronous, never waits.
    public func enable() {
        queue.async { [self] in
            pendingCommands.append(.enable)
            applyCommands()
        }
    }

    /// Keyboard no longer visible / runtime suspended. Revokes the writable generation and drops
    /// the untaken tail asynchronously; nothing waits for background I/O.
    public func revoke() {
        queue.async { [self] in
            writableGeneration &+= 1
            isWritable = false
            pendingCommands.append(.revoke)
            applyCommands()
        }
    }

    /// One scheduler step. Production timers call it on the pump queue; tests call it manually.
    public func tick() {
        queue.sync { tickOnQueue() }
    }

    #if DEBUG
        /// Test barrier: returns after everything queued before this call ran on the pump queue.
        public func drainForTesting() { queue.sync {} }
        public var tickCount: Int { queue.sync { tickCountForTesting } }
        public var writableForTesting: Bool { queue.sync { isWritable } }
    #endif

    // MARK: - Queue-confined

    private func applyCommands() {
        // Commands are serialized here; a busy admission lock leaves the rest for the next tick.
        while let command = pendingCommands.first {
            switch command {
            case .revoke:
                guard admission.tryDropTail(suspend: true) else { return }
                runtime.suspendForExtensionLifecycle()
            case .enable:
                if !isWritable {
                    guard admission.trySetSuspended(false) else { return }
                    isWritable = true
                    runtime.resumeForExtensionLifecycle()
                }
            }
            pendingCommands.removeFirst()
        }
    }

    private func tickOnQueue() {
        guard !ticking else { return }
        ticking = true
        defer { ticking = false }
        tickCountForTesting &+= 1
        applyCommands()

        // Awareness: read the close generation before taking any batch.
        let live = closeGeneration()
        if live > closeSeen {
            // Drop everything not yet written; trylock failure keeps closeSeen so we retry.
            guard admission.tryDropTail(suspend: nil) else { return }
            closeSeen = live
            runtime.observeCloseGeneration()
            return
        }

        guard isWritable else { return }
        // Background switch read: when diagnostics are off, queued events are discarded unwritten.
        guard isSwitchEnabled() else {
            _ = admission.tryTakeBatch()
            return
        }
        let generation = writableGeneration
        guard case .batch(let batch) = admission.tryTakeBatch() else { return }
        let ordered = batch.mergedInAdmissionOrder()
        // Re-check the invisible generation and the close generation before submitting.
        guard isWritable, generation == writableGeneration else {
            admission.tryAddDrops(ordered.count)
            return
        }
        if closeGeneration() > closeSeen {
            admission.tryAddDrops(ordered.count)
            return
        }
        for envelope in ordered.prefix(256) {
            runtime.recordAdmittedT9(envelope)
        }
    }
}
