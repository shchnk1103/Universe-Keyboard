import Dispatch
import Foundation
import Synchronization

/// 一个 target 内的 typed journal 运行时。
///
/// 它负责 process identity、单调序列和 suspend health 的组装；调用方仍必须只
/// 提供经过审查的 event code/字段。它刻意不接收 `String`，也不桥接 legacy Logger。
public final class DiagnosticsJournalRuntime: Sendable {
    private final class SequenceCounter: Sendable {
        private let value = Mutex<UInt64>(0)

        func next() -> UInt64 {
            value.withLock { sequence in
                sequence &+= 1
                return sequence
            }
        }
    }

    private let ingress: DiagnosticsJournalIngress
    private let origin: DiagnosticEvent.Origin
    private let processInstanceID: UUID
    private let writerVersion: DiagnosticsJournalWriterVersion
    private let nextSequence: SequenceCounter

    public init(
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID = UUID(),
        isMainAppWriter: Bool,
        rootURL: @escaping @Sendable () -> URL?,
        isCategoryEnabled: @escaping @Sendable (Logger.Category) -> Bool,
        writerVersion: DiagnosticsJournalWriterVersion = .v5,
        flushDelay: TimeInterval = 0.25
    ) {
        self.origin = origin
        self.processInstanceID = processInstanceID
        self.writerVersion = writerVersion
        let sequenceCounter = SequenceCounter()
        nextSequence = sequenceCounter
        ingress = DiagnosticsJournalIngress(
            origin: origin,
            processInstanceID: processInstanceID,
            isMainAppWriter: isMainAppWriter,
            writerVersion: writerVersion,
            rootURL: rootURL,
            isCategoryEnabled: isCategoryEnabled,
            makeHealthEvent: { reason, droppedCount in
                let sequence = sequenceCounter.next()
                return DiagnosticEvent(
                    utcTimestamp: Date(),
                    monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                    origin: origin,
                    processInstanceID: processInstanceID,
                    localSequence: sequence,
                    code: reason == .queueFull ? .journalDropped : .journalUnavailable,
                    level: .warning,
                    category: .general,
                    fields: [
                        .count(.droppedEventCount, droppedCount),
                        .reason(reason),
                    ]
                )
            },
            flushDelay: flushDelay
        )
    }

    /// 热路径只构造一个有限的 value-type event 并投入 ingress；不触及开关、
    /// App Group、JSON 或文件系统。
    public func record(
        code: DiagnosticEvent.Code,
        level: Logger.Level = .info,
        category: Logger.Category,
        appearanceID: UUID? = nil,
        actionSequence: UInt64? = nil,
        fields: [DiagnosticEvent.Field] = []
    ) {
        guard !DiagnosticEvent.isWakeMarkerCode(code) else { return }
        let sequence = nextSequence.next()
        ingress.record(
            DiagnosticEvent(
                utcTimestamp: Date(),
                monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: sequence,
                appearanceID: appearanceID,
                actionSequence: actionSequence,
                code: code,
                level: level,
                category: category,
                fields: fields
            )
        )
    }

    /// Returns whether a marker submission was attempted. The bounded ingress may still drop it.
    @discardableResult
    public func recordKeyboardLifecycle(
        _ phase: DiagnosticEvent.KeyboardLifecyclePhase,
        appearanceID: UUID? = nil
    ) -> Bool {
        guard writerVersion == .v6, origin == .keyboardExtension else { return false }
        let sequence = nextSequence.next()
        guard
            let event = DiagnosticEvent.makeV6KeyboardLifecycleEvent(
                phase: phase,
                utcTimestamp: Date(),
                monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: sequence,
                appearanceID: appearanceID
            )
        else { return false }
        ingress.record(event)
        return true
    }

    /// Failure presence must match `.failed`; the return value only reports an ingress attempt.
    @discardableResult
    public func recordRimeResume(
        _ phase: DiagnosticEvent.RimeResumePhase,
        failure: DiagnosticEvent.RimeResumeFailure? = nil,
        sessionEpoch: UInt64? = nil,
        revision: UInt64? = nil,
        appearanceID: UUID? = nil
    ) -> Bool {
        guard
            writerVersion == .v6,
            origin == .keyboardExtension,
            (phase == .failed) == (failure != nil)
        else { return false }

        let sequence = nextSequence.next()
        guard
            let event = DiagnosticEvent.makeV6RimeResumeEvent(
                phase: phase,
                failure: failure,
                sessionEpoch: sessionEpoch,
                revision: revision,
                utcTimestamp: Date(),
                monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: sequence,
                appearanceID: appearanceID
            )
        else { return false }
        ingress.record(event)
        return true
    }

    /// Returns whether a marker submission was attempted. The bounded ingress may still drop it.
    @discardableResult
    public func recordTextProxyOperation(
        operation: DiagnosticEvent.TextProxyOperation,
        phase: DiagnosticEvent.TextProxyPhase,
        appearanceID: UUID? = nil,
        actionSequence: UInt64? = nil
    ) -> Bool {
        guard writerVersion == .v6, origin == .keyboardExtension else { return false }
        let sequence = nextSequence.next()
        guard
            let event = DiagnosticEvent.makeV6TextProxyEvent(
                operation: operation,
                phase: phase,
                actionSequence: actionSequence,
                utcTimestamp: Date(),
                monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: sequence,
                appearanceID: appearanceID
            )
        else { return false }
        ingress.record(event)
        return true
    }

    /// Records one reviewed composite delivery payload. Journal availability,
    /// filtering and backpressure remain completely outside business control.
    public func recordSchemeDelivery(
        _ payload: DiagnosticEvent.SchemeDeliveryPayload,
        level: Logger.Level = .info
    ) {
        let sequence = nextSequence.next()
        ingress.record(
            DiagnosticEvent(
                utcTimestamp: Date(),
                monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: sequence,
                code: payload.code,
                level: level,
                category: .deployment,
                schemeDeliveryPayload: payload
            )
        )
    }

    /// Records a finite Main-App runtime-route transition without coupling its
    /// journal availability to uninstall or rollback behavior.
    public func recordRuntimeRoute(
        _ payload: DiagnosticEvent.RuntimeRoutePhaseEvent,
        level: Logger.Level = .info
    ) {
        let sequence = nextSequence.next()
        ingress.record(
            DiagnosticEvent(
                utcTimestamp: Date(),
                monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: sequence,
                code: .runtimeRoutePhaseChanged,
                level: level,
                category: .deployment,
                runtimeRoutePayload: payload
            )
        )
    }

    /// Records one reviewed automatic-sync payload. The payload contains only
    /// finite enums and an opaque operation UUID; business execution never
    /// waits for journal persistence.
    public func recordRimeSync(
        _ payload: DiagnosticEvent.RimeSyncPayload,
        level: Logger.Level = .info
    ) {
        let sequence = nextSequence.next()
        ingress.record(
            DiagnosticEvent(
                utcTimestamp: Date(),
                monotonicNanoseconds: DispatchTime.now().uptimeNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: sequence,
                code: payload.code,
                level: level,
                category: .config,
                rimeSyncPayload: payload
            )
        )
    }

    public func requestFlush() {
        ingress.requestFlush()
    }

    /// 在 Extension 可见性结束时立即丢弃未开始的尾批，不等待后台 I/O。
    public func suspendForExtensionLifecycle() {
        ingress.suspendForExtensionLifecycle()
    }

    /// 在同一 process 再次可见时，首先尽力补报此前 suspend 丢弃数量。若诊断
    /// 开关关闭，此 event 和其它普通 event 一样会在后台过滤，绝不影响输入。
    public func resumeForExtensionLifecycle() {
        let droppedEventCount = ingress.resumeForExtensionLifecycle()
        guard droppedEventCount > 0 else { return }
        record(
            code: .journalResumed,
            category: .general,
            fields: [
                .count(.droppedEventCount, droppedEventCount),
                .reason(.suspended),
            ]
        )
    }
}
