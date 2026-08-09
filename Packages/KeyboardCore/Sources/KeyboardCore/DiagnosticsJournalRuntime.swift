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
    private let nextSequence: SequenceCounter

    public init(
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID = UUID(),
        isMainAppWriter: Bool,
        rootURL: @escaping @Sendable () -> URL?,
        isCategoryEnabled: @escaping @Sendable (Logger.Category) -> Bool,
        flushDelay: TimeInterval = 0.25
    ) {
        self.origin = origin
        self.processInstanceID = processInstanceID
        let sequenceCounter = SequenceCounter()
        nextSequence = sequenceCounter
        ingress = DiagnosticsJournalIngress(
            origin: origin,
            processInstanceID: processInstanceID,
            isMainAppWriter: isMainAppWriter,
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
