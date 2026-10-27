import Dispatch
import Foundation
import Synchronization

#if DEBUG
    /// 测试可替换的批写入器。生产 `DiagnosticsJournalWriter` 是默认实现。
    protocol DiagnosticsJournalBatchWriting: Actor {
        func prepareRootIfOwnedByMainApp() async throws
        func append(
            _ events: [DiagnosticEvent],
            isWritePermitted: @escaping @Sendable () -> Bool
        ) async throws
        func rotateIdentityAfterReclaim() async
    }

    extension DiagnosticsJournalWriter: DiagnosticsJournalBatchWriting {}
#endif

/// Typed journal 的有界热路径入口。它不读取 App Group、不编码 JSON，也不等待
/// writer；这些工作只会在 utility executor 的批处理阶段发生。
public final class DiagnosticsJournalIngress: Sendable {
    public static let maximumPendingEventCount = 256

    #if DEBUG
        /// Debug 热路径上的排队单元。ticket 只在 DEBUG 存在，用来界定测试等待，不表示已落盘。
        private struct QueuedDiagnostic: Sendable {
            var ticket: UInt64
            var event: DiagnosticEvent
        }

        private struct WaiterRecord: Sendable {
            var unfinished: Set<UInt64>
        }
    #endif

    private struct PendingState: Sendable {
        #if DEBUG
            var events: [QueuedDiagnostic] = []
            /// 下一次 admission 使用的 ticket。到达 `UInt64.max` 后不再分配，也不回绕。
            var nextTicket: UInt64 = 1
            var openTickets: Set<UInt64> = []
            var inFlightTickets: [UInt64] = []
            var waiters: [UInt64: WaiterRecord] = [:]
            var nextWaiterID: UInt64 = 1
            var resumeBuffers: [UInt64: AsyncStream<Void>.Continuation] = [:]
            var exclusiveResumeCount = 0
            var testingAppended = 0
            var testingFiltered = 0
            var testingDropped = 0
            var testingLifecycleCancelled = 0
        #else
            var events: [DiagnosticEvent] = []
        #endif
        var flushScheduled = false
        var writeInFlight = false
        var inFlightEventCount = 0
        var appendAdmitted = false
        var isSuspended = false
        var lifecycleEpoch: UInt64 = 0
        var droppedWhileSuspended = 0
        var droppedWhileQueueFull = 0
        var deferredFailureReasons: [DiagnosticEvent.Reason: Int] = [:]
        #if DEBUG
            var writer: (any DiagnosticsJournalBatchWriting)?
        #else
            var writer: DiagnosticsJournalWriter?
        #endif

        #if DEBUG
            /// 单一终结转移：ticket 离开 open 集合后不能再被同一个 waiter 观察。
            mutating func terminate(_ tickets: Set<UInt64>, outcome: String = "dropped") -> [AsyncStream<Void>
                .Continuation]
            {
                guard !tickets.isEmpty else { return [] }
                let count = openTickets.intersection(tickets).count
                switch outcome {
                case "appended": testingAppended += count
                case "filtered": testingFiltered += count
                case "lifecycle": testingLifecycleCancelled += count
                default: testingDropped += count
                }
                openTickets.subtract(tickets)
                if !inFlightTickets.isEmpty {
                    inFlightTickets.removeAll { tickets.contains($0) }
                }
                var ready: [AsyncStream<Void>.Continuation] = []
                for id in Array(waiters.keys) {
                    guard var waiter = waiters[id] else { continue }
                    waiter.unfinished.subtract(tickets)
                    if waiter.unfinished.isEmpty {
                        waiters[id] = nil
                        if let continuation = resumeBuffers.removeValue(forKey: id) {
                            // 与取消路径抢同一把锁：只有拿走 continuation 的一方计数。
                            exclusiveResumeCount += 1
                            ready.append(continuation)
                        }
                    } else {
                        waiters[id] = waiter
                    }
                }
                return ready
            }
        #endif
    }

    private struct FlushWork: Sendable {
        let events: [DiagnosticEvent]
        #if DEBUG
            /// 与 `events` 等长。`writerReclaimed` 重排时必须原样带回，不能按完成序号重编号。
            let tickets: [UInt64]
        #endif
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
    private let writerVersion: DiagnosticsJournalWriterVersion
    private let flushDelay: TimeInterval
    private let makeHealthEvent: (@Sendable (DiagnosticEvent.Reason, Int) -> DiagnosticEvent)?
    #if DEBUG
        private let batchWriterFactory = Mutex<(@Sendable (URL) -> any DiagnosticsJournalBatchWriting)?>(nil)
        private let waiterRegisteredProbe = Mutex<(@Sendable (Int) -> Void)?>(nil)
    #endif

    public init(
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID,
        isMainAppWriter: Bool,
        writerVersion: DiagnosticsJournalWriterVersion = .v5,
        rootURL: @escaping @Sendable () -> URL?,
        isCategoryEnabled: @escaping @Sendable (Logger.Category) -> Bool,
        makeHealthEvent: (@Sendable (DiagnosticEvent.Reason, Int) -> DiagnosticEvent)? = nil,
        flushDelay: TimeInterval = 0.25
    ) {
        queue = DispatchQueue(label: "com.universekeyboard.diagnostics-journal", qos: .utility)
        self.origin = origin
        self.processInstanceID = processInstanceID
        self.isMainAppWriter = isMainAppWriter
        self.writerVersion = writerVersion
        self.rootURL = rootURL
        self.isCategoryEnabled = isCategoryEnabled
        self.makeHealthEvent = makeHealthEvent
        self.flushDelay = max(0, flushDelay)
    }

    #if DEBUG
        /// 测试在第一次 flush 前安装可控 writer。生产调用点不会碰这个入口。
        internal func installBatchWriterFactoryForTesting(
            _ factory: @escaping @Sendable (URL) -> any DiagnosticsJournalBatchWriting
        ) {
            batchWriterFactory.withLock { $0 = factory }
        }

        internal struct FlushWaitTestingSnapshot: Sendable, Equatable {
            var waiterCount: Int
            var droppedWhileQueueFull: Int
            var queuedTickets: [UInt64]
            var inFlightTickets: [UInt64]
            var exclusiveResumeCount: Int
            var accepted: UInt64
            var appended: Int
            var filtered: Int
            var dropped: Int
            var lifecycleCancelled: Int
        }

        /// 只读测试快照。不改变 ticket、丢弃或 resume 的生产规则。
        internal func testingSnapshotForTesting() -> FlushWaitTestingSnapshot {
            pending.withLock { state in
                FlushWaitTestingSnapshot(
                    waiterCount: state.waiters.count,
                    droppedWhileQueueFull: state.droppedWhileQueueFull,
                    queuedTickets: state.events.map(\.ticket),
                    inFlightTickets: state.inFlightTickets,
                    exclusiveResumeCount: state.exclusiveResumeCount,
                    accepted: state.nextTicket - 1,
                    appended: state.testingAppended,
                    filtered: state.testingFiltered,
                    dropped: state.testingDropped,
                    lifecycleCancelled: state.testingLifecycleCancelled
                )
            }
        }

        /// waiter 插入锁释放后同步通知当前 waiter 数。探针不得再进入 Ingress 的锁。
        internal func testingObserveWaiterCountForTesting(_ probe: (@Sendable (Int) -> Void)?) {
            waiterRegisteredProbe.withLock { $0 = probe }
        }
    #endif

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
            #if DEBUG
                // ticket 溢出不回绕：热路径拒绝这次 admission，并计入已有的满队列丢弃。
                // Debug 成本是有界的：一次 UInt64 递增、一次 Set 插入，以及队列里的 ticket。
                // 开放 ticket 不超过 pending 上限加在途一批（各 256）。Release 没有这些字段。
                guard state.nextTicket < UInt64.max else {
                    state.droppedWhileQueueFull &+= 1
                    return false
                }
                let ticket = state.nextTicket
                state.nextTicket += 1
                state.openTickets.insert(ticket)
                state.events.append(QueuedDiagnostic(ticket: ticket, event: event))
            #else
                state.events.append(event)
            #endif
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

    #if DEBUG
        /// 只有未取消的正常完成表示调用瞬间已接受的事件均已终结；取消返回不证明终结。
        /// 终结可能是 append 返回、过滤或丢弃，不保证 reader 可见。
        /// 前后快照非原子、非屏障精确上界或逐 ticket 对账；累计结果之和不能推断屏障覆盖。
        /// 计数按首个终结原因归类，不是物理 I/O 审计；dropped 合并多种原因。
        /// 不是 fsync；历史读到零条与合同相容但违反测试数量断言，根因 UNKNOWN。
        ///
        /// 取消会注销 waiter 并恰好 resume 一次；不会持锁等待，也不会被生命周期调用。
        internal func flushAndWaitForTesting() async {
            let registration: WaitRegistration? = pending.withLock { state in
                let limit = state.nextTicket &- 1
                let unfinished = state.openTickets.filter { $0 <= limit }
                guard !unfinished.isEmpty else { return nil }
                // waiter ID 不回绕。耗尽只可能发生在测试进程里，直接停住而不是复用旧 waiter。
                precondition(state.nextWaiterID < UInt64.max, "flush waiter IDs must not wrap")
                let id = state.nextWaiterID
                state.nextWaiterID += 1
                state.waiters[id] = WaiterRecord(unfinished: unfinished)
                let (stream, continuation) = AsyncStream.makeStream(
                    of: Void.self,
                    bufferingPolicy: .bufferingNewest(1)
                )
                state.resumeBuffers[id] = continuation
                let shouldFlush = state.events.contains { $0.ticket <= limit }
                if shouldFlush {
                    state.flushScheduled = true
                }
                return WaitRegistration(id: id, stream: stream, shouldFlush: shouldFlush)
            }
            guard let registration else { return }
            let waiterCount = pending.withLock { $0.waiters.count }
            let probe = waiterRegisteredProbe.withLock { $0 }
            probe?(waiterCount)
            if registration.shouldFlush {
                // 测试等待不等 flushDelay；生产 record 的延迟调度保持原样。
                queue.async {
                    self.flushPendingEvents()
                }
            }
            await withTaskCancellationHandler {
                var iterator = registration.stream.makeAsyncIterator()
                await iterator.next()
            } onCancel: {
                let continuation = self.pending.withLock { state -> AsyncStream<Void>.Continuation? in
                    state.waiters[registration.id] = nil
                    guard let continuation = state.resumeBuffers.removeValue(forKey: registration.id) else {
                        return nil
                    }
                    state.exclusiveResumeCount += 1
                    return continuation
                }
                continuation?.finish()
            }
        }

        /// 测试专用：把下一次 ticket 拨到指定值。用于定义溢出拒绝，不参与生产路径。
        internal func testingSetNextTicketForTesting(_ ticket: UInt64) {
            pending.withLock { state in
                state.nextTicket = ticket
            }
        }

        private struct WaitRegistration: Sendable {
            let id: UInt64
            let stream: AsyncStream<Void>
            let shouldFlush: Bool
        }
    #endif

    /// 进入 Extension suspend 边界时，仅在内存中丢弃尚未开始的尾批并使已排队的
    /// delayed flush 失效。这里刻意不等待正在进行的文件写入，以免把 I/O 延迟带回
    /// UIKit 生命周期；已经进入 writer 的有限批仍遵循其 lock 内 generation 校验。
    public func suspendForExtensionLifecycle() {
        #if DEBUG
            let ready =
                pending.withLock { state -> [AsyncStream<Void>.Continuation] in
                    guard !state.isSuspended else { return [] }
                    state.isSuspended = true
                    state.lifecycleEpoch &+= 1
                    state.droppedWhileSuspended += state.events.count
                    var ended = Set(state.events.map(\.ticket))
                    if state.writeInFlight && !state.appendAdmitted {
                        // 已取出但尚未获准进入 writer 的批也必须计入 resume health，
                        // 不能在 suspend 与 append 之间静默消失。
                        state.droppedWhileSuspended += state.inFlightEventCount
                        ended.formUnion(state.inFlightTickets)
                    }
                    state.events.removeAll(keepingCapacity: true)
                    state.flushScheduled = false
                    return state.terminate(ended, outcome: "lifecycle")
                }
            resumeWaiters(ready)
        #else
            pending.withLock { state in
                guard !state.isSuspended else { return }
                state.isSuspended = true
                state.lifecycleEpoch &+= 1
                state.droppedWhileSuspended += state.events.count
                if state.writeInFlight && !state.appendAdmitted {
                    state.droppedWhileSuspended += state.inFlightEventCount
                }
                state.events.removeAll(keepingCapacity: true)
                state.flushScheduled = false
            }
        #endif
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
            #if DEBUG
                let selected: [QueuedDiagnostic]
                if state.waiters.isEmpty {
                    // 没有 waiter 时整批取走，和原来的生产批处理相同。
                    // 已注册的 waiter 不可能被这一批里的更新事件拖住：它还不存在。
                    selected = state.events
                    state.events.removeAll(keepingCapacity: true)
                } else {
                    // 有 waiter 时按最小上界截批，避免同一 append 把更新的 ticket 算进旧等待。
                    let limit =
                        state.waiters.keys.compactMap { id in
                            state.waiters[id]?.unfinished.max()
                        }.min() ?? UInt64.max
                    selected = state.events.filter { $0.ticket <= limit }
                    guard !selected.isEmpty else { return nil }
                    let selectedIDs = Set(selected.map(\.ticket))
                    state.events.removeAll { selectedIDs.contains($0.ticket) }
                }
                state.writeInFlight = true
                state.inFlightEventCount = selected.count
                state.appendAdmitted = false
                state.inFlightTickets = selected.map(\.ticket)
                let deferredHealth = state.deferredFailureReasons.map { ($0.key, $0.value) }
                state.deferredFailureReasons.removeAll(keepingCapacity: true)
                let events = selected.map(\.event)
                let tickets = selected.map(\.ticket)
                if state.droppedWhileQueueFull > 0 {
                    return FlushWork(
                        events: events,
                        tickets: tickets,
                        lifecycleEpoch: state.lifecycleEpoch,
                        deferredHealth: deferredHealth + [(.queueFull, state.droppedWhileQueueFull)]
                    )
                }
                return FlushWork(
                    events: events,
                    tickets: tickets,
                    lifecycleEpoch: state.lifecycleEpoch,
                    deferredHealth: deferredHealth
                )
            #else
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
            #endif
        }
        guard let work else { return }

        #if DEBUG
            let decisions = work.events.map { isCategoryEnabled($0.category) }
            let enabledEvents = zip(work.events, decisions).compactMap { $0.1 ? $0.0 : nil }
            let enabledTickets = Set(zip(work.tickets, decisions).compactMap { $0.1 ? $0.0 : nil })
            let filteredTickets = Set(work.tickets).subtracting(enabledTickets)
        #else
            let enabledEvents = work.events.filter { isCategoryEnabled($0.category) }
        #endif
        let resolvedRootURL = rootURL()
        guard !enabledEvents.isEmpty, let rootURL = resolvedRootURL else {
            if resolvedRootURL == nil {
                restoreDeferredHealth([(.appGroupUnavailable, work.events.count)])
            }
            #if DEBUG
                // 全被过滤，或根目录不可用：本批不会进入 writer，也不会重排，因此在此终结。
                resumeWaiters(
                    pending.withLock { state in
                        state.terminate(filteredTickets, outcome: "filtered") + state.terminate(enabledTickets)
                    })
            #endif
            finishWriteAndSchedulePendingEventsIfNeeded()
            return
        }
        #if DEBUG
            let writer = pending.withLock { state -> any DiagnosticsJournalBatchWriting in
                if let writer = state.writer {
                    return writer
                }
                let writer: any DiagnosticsJournalBatchWriting
                if let factory = batchWriterFactory.withLock({ $0 }) {
                    writer = factory(rootURL)
                } else {
                    writer = DiagnosticsJournalWriter(
                        rootURL: rootURL,
                        origin: origin,
                        processInstanceID: processInstanceID,
                        isMainAppWriter: isMainAppWriter,
                        writerVersion: writerVersion
                    )
                }
                state.writer = writer
                return writer
            }
        #else
            let writer = pending.withLock { state -> DiagnosticsJournalWriter in
                if let writer = state.writer {
                    return writer
                }
                let writer = DiagnosticsJournalWriter(
                    rootURL: rootURL,
                    origin: origin,
                    processInstanceID: processInstanceID,
                    isMainAppWriter: isMainAppWriter,
                    writerVersion: writerVersion
                )
                state.writer = writer
                return writer
            }
        #endif

        Task.detached(priority: .utility) {
            guard self.isWriteStillPermitted(for: work.lifecycleEpoch) else {
                #if DEBUG
                    self.resumeWaiters(
                        self.pending.withLock { state in
                            state.terminate(filteredTickets, outcome: "filtered")
                                + state.terminate(enabledTickets, outcome: "lifecycle")
                        })
                #endif
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
                    #if DEBUG
                        self.resumeWaiters(
                            self.pending.withLock { state in
                                state.terminate(filteredTickets, outcome: "filtered") + state.terminate(enabledTickets)
                            })
                    #endif
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
                #if DEBUG
                    // append 已返回。被过滤的事件没有进入这次 I/O，但也到此终结。
                    self.resumeWaiters(
                        self.pending.withLock { state in
                            state.terminate(filteredTickets, outcome: "filtered")
                                + state.terminate(enabledTickets, outcome: "appended")
                        })
                #endif
            } catch {
                if (error as? DiagnosticsJournalError) == .lifecycleCancelled {
                    #if DEBUG
                        // 未 admission 的票可能已在 suspend 里终结；这里只补仍开着的票。
                        self.resumeWaiters(
                            self.pending.withLock { state in
                                state.terminate(filteredTickets, outcome: "filtered")
                                    + state.terminate(enabledTickets, outcome: "lifecycle")
                            })
                    #endif
                } else if (error as? DiagnosticsJournalError) == .writerReclaimed {
                    await writer.rotateIdentityAfterReclaim()
                    #if DEBUG
                        self.requeueAfterIdentityRotation(work.events, tickets: work.tickets)
                    #else
                        self.requeueAfterIdentityRotation(work.events)
                    #endif
                } else {
                    self.restoreDeferredHealth(
                        work.deferredHealth + [(Self.diagnosticReason(for: error), enabledEvents.count)]
                    )
                    #if DEBUG
                        self.resumeWaiters(
                            self.pending.withLock { state in
                                state.terminate(filteredTickets, outcome: "filtered") + state.terminate(enabledTickets)
                            })
                    #endif
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
            #if DEBUG
                state.inFlightTickets.removeAll(keepingCapacity: true)
            #endif
            guard !state.isSuspended, !state.events.isEmpty, !state.flushScheduled else { return false }
            state.flushScheduled = true
            return true
        }
        guard shouldSchedule else { return }
        #if DEBUG
            let hurry = pending.withLock { !$0.waiters.isEmpty }
            if hurry {
                queue.async { self.flushPendingEvents() }
                return
            }
        #endif
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

    #if DEBUG
        private func requeueAfterIdentityRotation(_ events: [DiagnosticEvent], tickets: [UInt64]) {
            let ready = pending.withLock { state -> [AsyncStream<Void>.Continuation] in
                let queued = zip(tickets, events).map { QueuedDiagnostic(ticket: $0.0, event: $0.1) }
                guard !state.isSuspended else {
                    state.droppedWhileSuspended += queued.count
                    return state.terminate(Set(tickets), outcome: "lifecycle")
                }
                let availableCapacity = max(0, Self.maximumPendingEventCount - state.events.count)
                let retryEvents = Array(queued.prefix(availableCapacity))
                let overflow = Array(queued.dropFirst(availableCapacity))
                state.events.insert(contentsOf: retryEvents, at: 0)
                state.droppedWhileQueueFull &+= overflow.count
                // 装回队列的票保持原编号，仍算未终结。装不下的尾部在计数后终结。
                return state.terminate(Set(overflow.map(\.ticket)))
            }
            resumeWaiters(ready)
        }

        private func resumeWaiters(_ continuations: [AsyncStream<Void>.Continuation]) {
            for continuation in continuations {
                continuation.yield(())
                continuation.finish()
            }
        }
    #else
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
    #endif

    private func consumeQueueFullDropsReported(in entries: [(DiagnosticEvent.Reason, Int)]) {
        let reportedCount = entries.first(where: { $0.0 == .queueFull })?.1 ?? 0
        guard reportedCount > 0 else { return }
        pending.withLock { state in
            state.droppedWhileQueueFull = max(0, state.droppedWhileQueueFull - reportedCount)
        }
    }

    static func diagnosticReason(for error: Error) -> DiagnosticEvent.Reason {
        switch error as? DiagnosticsJournalError {
        case .lockBusy:
            .lockBusy
        case .writerReclaimed:
            .writerReclaimed
        case .rootUnavailable:
            .appGroupUnavailable
        case .diskFull:
            .diskFull
        case .ioFailure, .writeFailed:
            .ioFailure
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
