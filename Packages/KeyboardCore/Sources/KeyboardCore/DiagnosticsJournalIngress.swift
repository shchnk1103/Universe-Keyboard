import Dispatch
import Foundation
import Synchronization

/// Typed journal 的有界热路径入口。它不读取 App Group、不编码 JSON，也不等待
/// writer；这些工作只会在 utility executor 的批处理阶段发生。
public final class DiagnosticsJournalIngress: Sendable {
    public static let maximumPendingEventCount = 256

    private struct PendingState: Sendable {
        var events: [DiagnosticEvent] = []
        var flushScheduled = false
        var writeInFlight = false
        var inFlightEventCount = 0
        var appendAdmitted = false
        var isSuspended = false
        var lifecycleEpoch: UInt64 = 0
        var droppedWhileSuspended = 0
        var droppedWhileQueueFull = 0
        var deferredFailureReasons: [DiagnosticEvent.Reason: Int] = [:]
        var writer: DiagnosticsJournalWriter?
    }

    private struct FlushWork: Sendable {
        let events: [DiagnosticEvent]
        let lifecycleEpoch: UInt64
        let deferredHealth: [(DiagnosticEvent.Reason, Int)]
    }

    private let queue: DispatchQueue
    private let pending = Mutex(PendingState())
    private let rootURL: @Sendable () -> URL?
    private let isCategoryEnabled: @Sendable (Logger.Category) -> Bool
    private let origin: DiagnosticEvent.Origin
    private let processInstanceID: UUID
    private let isMainAppWriter: Bool
    private let flushDelay: TimeInterval
    private let makeHealthEvent: (@Sendable (DiagnosticEvent.Reason, Int) -> DiagnosticEvent)?

    public init(
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID,
        isMainAppWriter: Bool,
        rootURL: @escaping @Sendable () -> URL?,
        isCategoryEnabled: @escaping @Sendable (Logger.Category) -> Bool,
        makeHealthEvent: (@Sendable (DiagnosticEvent.Reason, Int) -> DiagnosticEvent)? = nil,
        flushDelay: TimeInterval = 0.25
    ) {
        queue = DispatchQueue(label: "com.universekeyboard.diagnostics-journal", qos: .utility)
        self.origin = origin
        self.processInstanceID = processInstanceID
        self.isMainAppWriter = isMainAppWriter
        self.rootURL = rootURL
        self.isCategoryEnabled = isCategoryEnabled
        self.makeHealthEvent = makeHealthEvent
        self.flushDelay = max(0, flushDelay)
    }

    /// 非阻塞且有界。满载时新事件被舍弃，绝不把排队或 I/O 传导到按键路径。
    public func record(_ event: DiagnosticEvent) {
        guard event.origin == origin, event.processInstanceID == processInstanceID else { return }
        let shouldSchedule = pending.withLock { state in
            guard !state.isSuspended else {
                state.droppedWhileSuspended += 1
                return false
            }
            guard state.events.count < Self.maximumPendingEventCount else {
                state.droppedWhileQueueFull &+= 1
                return false
            }
            state.events.append(event)
            guard !state.flushScheduled else { return false }
            state.flushScheduled = true
            return true
        }
        guard shouldSchedule else { return }
        queue.asyncAfter(deadline: .now() + flushDelay) {
            self.flushPendingEvents()
        }
    }

    /// 生命周期或测试可请求立即批处理；仍然不会同步等待磁盘写入完成。
    public func requestFlush() {
        queue.async {
            self.flushPendingEvents()
        }
    }

    /// 进入 Extension suspend 边界时，仅在内存中丢弃尚未开始的尾批并使已排队的
    /// delayed flush 失效。这里刻意不等待正在进行的文件写入，以免把 I/O 延迟带回
    /// UIKit 生命周期；已经进入 writer 的有限批仍遵循其 lock 内 generation 校验。
    public func suspendForExtensionLifecycle() {
        pending.withLock { state in
            guard !state.isSuspended else { return }
            state.isSuspended = true
            state.lifecycleEpoch &+= 1
            state.droppedWhileSuspended += state.events.count
            if state.writeInFlight && !state.appendAdmitted {
                // 已取出但尚未获准进入 writer 的批也必须计入 resume health，
                // 不能在 suspend 与 append 之间静默消失。
                state.droppedWhileSuspended += state.inFlightEventCount
            }
            state.events.removeAll(keepingCapacity: true)
            state.flushScheduled = false
        }
    }

    /// 恢复后返回前一可见期因为 suspend 而舍弃的数量。调用者应使用这个数字构造
    /// 已审核的 `.journalResumed` health event，再通过 `record(_:)` 作为新一批写入。
    /// 若进程在恢复前终止，此计数本来就是 best-effort，不会被伪装成已持久化事实。
    @discardableResult
    public func resumeForExtensionLifecycle() -> Int {
        pending.withLock { state in
            state.isSuspended = false
            let dropped = state.droppedWhileSuspended
            state.droppedWhileSuspended = 0
            return dropped
        }
    }

    private func flushPendingEvents() {
        let work = pending.withLock { state -> FlushWork? in
            state.flushScheduled = false
            guard !state.isSuspended, !state.writeInFlight, !state.events.isEmpty else { return nil }
            state.writeInFlight = true
            state.inFlightEventCount = state.events.count
            state.appendAdmitted = false
            let deferredHealth = state.deferredFailureReasons.map { ($0.key, $0.value) }
            state.deferredFailureReasons.removeAll(keepingCapacity: true)
            let events = state.events
            state.events.removeAll(keepingCapacity: true)
            if state.droppedWhileQueueFull > 0 {
                return FlushWork(
                    events: events,
                    lifecycleEpoch: state.lifecycleEpoch,
                    deferredHealth: deferredHealth + [(.queueFull, state.droppedWhileQueueFull)]
                )
            }
            return FlushWork(
                events: events,
                lifecycleEpoch: state.lifecycleEpoch,
                deferredHealth: deferredHealth
            )
        }
        guard let work else { return }

        let enabledEvents = work.events.filter { isCategoryEnabled($0.category) }
        let resolvedRootURL = rootURL()
        guard !enabledEvents.isEmpty, let rootURL = resolvedRootURL else {
            if resolvedRootURL == nil {
                restoreDeferredHealth([(.appGroupUnavailable, work.events.count)])
            }
            finishWriteAndSchedulePendingEventsIfNeeded()
            return
        }
        let writer = pending.withLock { state -> DiagnosticsJournalWriter in
            if let writer = state.writer {
                return writer
            }
            let writer = DiagnosticsJournalWriter(
                rootURL: rootURL,
                origin: origin,
                processInstanceID: processInstanceID,
                isMainAppWriter: isMainAppWriter
            )
            state.writer = writer
            return writer
        }

        Task.detached(priority: .utility) {
            guard self.isWriteStillPermitted(for: work.lifecycleEpoch) else {
                self.queue.async {
                    self.finishWriteAndSchedulePendingEventsIfNeeded()
                }
                return
            }
            if self.isMainAppWriter {
                do {
                    try await writer.prepareRootIfOwnedByMainApp()
                } catch {
                    self.restoreDeferredHealth([(.directoryUnavailable, enabledEvents.count)])
                    self.queue.async {
                        self.finishWriteAndSchedulePendingEventsIfNeeded()
                    }
                    return
                }
            }
            let healthEvents = work.deferredHealth.compactMap { reason, count in
                self.makeHealthEvent?(reason, count)
            }
            do {
                try await writer.append(healthEvents + enabledEvents) {
                    self.admitAppendIfStillVisible(for: work.lifecycleEpoch)
                }
                self.consumeQueueFullDropsReported(in: work.deferredHealth)
            } catch {
                if (error as? DiagnosticsJournalError) == .lifecycleCancelled {
                    // suspend 已在 state lock 内把尚未 admission 的 in-flight 批计数。
                } else if (error as? DiagnosticsJournalError) == .writerReclaimed {
                    await writer.rotateIdentityAfterReclaim()
                    self.requeueAfterIdentityRotation(work.events)
                } else {
                    self.restoreDeferredHealth(
                        work.deferredHealth + [(self.reason(for: error), enabledEvents.count)]
                    )
                }
            }
            self.queue.async {
                self.finishWriteAndSchedulePendingEventsIfNeeded()
            }
        }
    }

    private func finishWriteAndSchedulePendingEventsIfNeeded() {
        let shouldSchedule = pending.withLock { state in
            state.writeInFlight = false
            state.inFlightEventCount = 0
            state.appendAdmitted = false
            guard !state.isSuspended, !state.events.isEmpty, !state.flushScheduled else { return false }
            state.flushScheduled = true
            return true
        }
        guard shouldSchedule else { return }
        queue.asyncAfter(deadline: .now() + flushDelay) {
            self.flushPendingEvents()
        }
    }

    private func restoreDeferredHealth(_ entries: [(DiagnosticEvent.Reason, Int)]) {
        pending.withLock { state in
            for (reason, count) in entries where count > 0 {
                if reason == .queueFull {
                    state.droppedWhileQueueFull &+= count
                } else {
                    state.deferredFailureReasons[reason, default: 0] &+= count
                }
            }
        }
    }

    private func requeueAfterIdentityRotation(_ events: [DiagnosticEvent]) {
        pending.withLock { state in
            guard !state.isSuspended else {
                state.droppedWhileSuspended += events.count
                return
            }
            let availableCapacity = max(0, Self.maximumPendingEventCount - state.events.count)
            let retryEvents = events.prefix(availableCapacity)
            state.events.insert(contentsOf: retryEvents, at: 0)
            state.droppedWhileQueueFull &+= events.count - retryEvents.count
        }
    }

    private func consumeQueueFullDropsReported(in entries: [(DiagnosticEvent.Reason, Int)]) {
        let reportedCount = entries.first(where: { $0.0 == .queueFull })?.1 ?? 0
        guard reportedCount > 0 else { return }
        pending.withLock { state in
            state.droppedWhileQueueFull = max(0, state.droppedWhileQueueFull - reportedCount)
        }
    }

    private func reason(for error: Error) -> DiagnosticEvent.Reason {
        switch error as? DiagnosticsJournalError {
        case .lockBusy:
            .lockBusy
        case .writerReclaimed:
            .writerReclaimed
        case .rootUnavailable:
            .appGroupUnavailable
        case .writeFailed:
            .diskFull
        default:
            .directoryUnavailable
        }
    }

    private func isWriteStillPermitted(for lifecycleEpoch: UInt64) -> Bool {
        pending.withLock { state in
            !state.isSuspended && state.lifecycleEpoch == lifecycleEpoch
        }
    }

    /// 这是 suspend 与实际 writer 调用之间的最后一道原子门。若 suspend 先
    /// 到达，批次已被计入 dropped；若此处先获准，则按“已开始写入”的
    /// best-effort 语义允许它完成，suspend 不会同步等待磁盘。
    private func admitAppendIfStillVisible(for lifecycleEpoch: UInt64) -> Bool {
        pending.withLock { state in
            guard !state.isSuspended, state.lifecycleEpoch == lifecycleEpoch else { return false }
            state.appendAdmitted = true
            return true
        }
    }
}
