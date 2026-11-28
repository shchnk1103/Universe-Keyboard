import Foundation
import Synchronization

#if DEBUG

    // MARK: - 共享有界确定性屏障重试（测试专用，TD-020）

    // 供宿主测试目标（KeyboardTests / KeyboardExtensionTests 等）共用同一份重试循环：
    // 不在每个测试 target 里各写一份。语义与各 target 既有的 flushBarrierValue 一致：
    // - 每次屏障尝试保持调用方传入的墙钟预算（1000ms / 2000ms 不变，逐次重置）；
    // - 只有未取消的正常完成（.completed）才允许进入读盘；取消不证明终结；
    // - 仅当 appended < expectedAppendedCount 且仍有 queued/inFlight 票时才有界重试（≤ maxAttempts）；
    // - 耗尽或取消时分阶段抛错，不使用裸 CancellationError；
    // - 数量断言全部留在调用方闭包中，helper 不读 journal、不削弱任何断言。

    /// 共享屏障尝试的阶段标记（budget-exceeded 分类用）。
    private struct JournalFlushRetryStageState: Sendable {
        var barrierReturned = false
        var readStarted = false
    }

    private final class JournalFlushRetryStageBox: Sendable {
        private let state = Mutex(JournalFlushRetryStageState())

        func markBarrierReturned() {
            state.withLock { $0.barrierReturned = true }
        }

        func markReadStarted() {
            state.withLock { $0.readStarted = true }
        }

        func snapshot() -> (barrierReturned: Bool, readStarted: Bool) {
            state.withLock { ($0.barrierReturned, $0.readStarted) }
        }
    }

    /// 结果槽先到先得。超时一方胜出后立即抛错返回，并取消 body，但不等待它结束。
    private actor JournalFlushRetryOneShot<T: Sendable> {
        private var continuation: CheckedContinuation<Result<T, Error>, Never>?
        private var value: Result<T, Error>?

        func store(_ continuation: CheckedContinuation<Result<T, Error>, Never>) {
            if let value {
                continuation.resume(returning: value)
            } else {
                self.continuation = continuation
            }
        }

        func finish(_ value: Result<T, Error>) {
            guard self.value == nil else { return }
            self.value = value
            continuation?.resume(returning: value)
            continuation = nil
        }
    }

    /// 单次尝试的墙钟预算超限（helper 内部使用；重试裁决后对外转为分阶段错误）。
    private struct JournalFlushRetryBudgetExceeded: Error {
        let stage: String
        let barrierReturned: Bool
        let readStarted: Bool
        let elapsedMilliseconds: Int
    }

    /// 重试裁决所需的内部信号；不逃出 helper。
    private enum JournalFlushRetryAttemptSignal: Error {
        /// flushAndWaitForTesting 返回 .cancelled：不证明任何票终结。
        case barrierCancelled
        /// 屏障正常完成但 testing appended 未达预期数量。
        case appendedShort
        /// 单次尝试的墙钟预算耗尽。
        case budgetExceeded(JournalFlushRetryBudgetExceeded)

        var stageName: String {
            switch self {
            case .barrierCancelled: return "barrier-cancelled"
            case .appendedShort: return "appended-short"
            case .budgetExceeded(let exceeded): return exceeded.stage
            }
        }

        var detail: String {
            switch self {
            case .barrierCancelled:
                return "flushAndWaitForTesting returned .cancelled; cancellation proves no termination"
            case .appendedShort:
                return "barrier completed but testing appended count stayed below the expected count"
            case .budgetExceeded(let exceeded):
                return
                    "barrier budget exceeded: stage=\(exceeded.stage) barrierReturned=\(exceeded.barrierReturned) readStarted=\(exceeded.readStarted) elapsedMilliseconds=\(exceeded.elapsedMilliseconds)"
            }
        }
    }

    /// 共享有界重试耗尽后的分阶段错误：失败可归因，不使用裸 CancellationError。
    struct JournalFlushBarrierRetryExhaustedForTesting: Error, CustomStringConvertible {
        let stage: String
        let attempts: Int
        let maxAttempts: Int
        let expectedAppendedCount: Int
        let appended: Int
        let queuedTickets: Int
        let inFlightTickets: Int
        let detail: String

        var description: String {
            "stage=\(stage) attempts=\(attempts)/\(maxAttempts) expectedAppended=\(expectedAppendedCount) appended=\(appended) queuedTickets=\(queuedTickets) inFlightTickets=\(inFlightTickets) detail=\(detail)"
        }
    }

    /// 有界确定性屏障重试（共享单实现）。
    ///
    /// - 每次尝试 = 一次 `flushAndWaitForTesting()` + `.completed`/appended 门 + 调用方 read 闭包，
    ///   外面包一层墙钟预算（`barrierMilliseconds`，预算时长逐次重置、本身不变）。
    /// - 仅当 appended < expectedAppendedCount 且仍有 queued/inFlight 票时重试（≤ maxAttempts 次）；
    ///   无待终结票时不重试，真死锁仍然有界失败。
    /// - 耗尽或取消抛 `JournalFlushBarrierRetryExhaustedForTesting`（分阶段），不抛裸 CancellationError。
    /// - 数量断言留在调用方 read 闭包中；helper 不读 journal。
    /// - 失败路径上被放弃的 body 可能仍访问目录：每次失败都通知 `onRootAbandoned`，
    ///   调用方用它接回各自 target 的 retained-root 记账。
    func journalFlushBarrierWithBoundedRetryForTesting<T: Sendable>(
        runtime: DiagnosticsJournalRuntime,
        expectedAppendedCount: Int,
        barrierMilliseconds: Int,
        maxAttempts: Int = 3,
        rootURL: URL?,
        onRootAbandoned: (@Sendable (URL) -> Void)? = nil,
        _ read:
            @escaping @Sendable (
                _ before: DiagnosticsJournalIngress.FlushWaitTestingSnapshot,
                _ after: DiagnosticsJournalIngress.FlushWaitTestingSnapshot
            ) async throws -> T
    ) async throws -> T {
        func abandonRoot() {
            guard let rootURL else { return }
            onRootAbandoned?(rootURL)
        }

        func runSingleAttempt() async throws -> T {
            let started = DispatchTime.now()
            let stage = JournalFlushRetryStageBox()
            let shot = JournalFlushRetryOneShot<T>()
            let bodyTask = Task {
                do {
                    let before = runtime.testingFlushSnapshotForTesting()
                    let outcome = await runtime.flushAndWaitForTesting()
                    let after = runtime.testingFlushSnapshotForTesting()
                    guard case .completed = outcome else {
                        // 取消返回不证明任何票终结：不标屏障、不读盘，交外层按重试裁决。
                        throw JournalFlushRetryAttemptSignal.barrierCancelled
                    }
                    guard after.appended >= expectedAppendedCount else {
                        // 完成但数量未达：确定性信号未满足，交外层有界重试。
                        throw JournalFlushRetryAttemptSignal.appendedShort
                    }
                    stage.markBarrierReturned()
                    stage.markReadStarted()
                    let value = try await read(before, after)
                    await shot.finish(.success(value))
                } catch {
                    await shot.finish(.failure(error))
                }
            }
            let sleepTask = Task {
                do {
                    try await Task.sleep(for: .milliseconds(barrierMilliseconds))
                } catch {
                    // 调用方已经拿到结果后会取消睡眠。被取消时不能再写一个超时。
                    return
                }
                let snapshot = stage.snapshot()
                let failureStage: String
                if snapshot.readStarted {
                    failureStage = "read-timeout"
                } else if snapshot.barrierReturned {
                    failureStage = "post-barrier-timeout"
                } else {
                    failureStage = "barrier-timeout"
                }
                await shot.finish(
                    .failure(
                        JournalFlushRetryBudgetExceeded(
                            stage: failureStage,
                            barrierReturned: snapshot.barrierReturned,
                            readStarted: snapshot.readStarted,
                            elapsedMilliseconds: Int(
                                (DispatchTime.now().uptimeNanoseconds - started.uptimeNanoseconds) / 1_000_000
                            )
                        )
                    )
                )
            }
            let outcome: Result<T, Error> = await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    Task { await shot.store(continuation) }
                }
            } onCancel: {
                abandonRoot()
                bodyTask.cancel()
            }
            if case .failure = outcome {
                abandonRoot()
            }
            bodyTask.cancel()
            sleepTask.cancel()
            do {
                return try outcome.get()
            } catch let exceeded as JournalFlushRetryBudgetExceeded {
                throw JournalFlushRetryAttemptSignal.budgetExceeded(exceeded)
            }
        }

        var attemptIndex = 0
        while true {
            attemptIndex += 1
            do {
                return try await runSingleAttempt()
            } catch let signal as JournalFlushRetryAttemptSignal {
                let snapshot = runtime.testingFlushSnapshotForTesting()
                let pendingTickets = snapshot.queuedTickets.count + snapshot.inFlightTickets.count
                let stillShort = snapshot.appended < expectedAppendedCount
                // 任务本身已被取消时不重试：直接分阶段抛出，避免吞掉真实取消。
                if Task.isCancelled {
                    throw JournalFlushBarrierRetryExhaustedForTesting(
                        stage: "cancelled", attempts: attemptIndex, maxAttempts: maxAttempts,
                        expectedAppendedCount: expectedAppendedCount, appended: snapshot.appended,
                        queuedTickets: snapshot.queuedTickets.count,
                        inFlightTickets: snapshot.inFlightTickets.count,
                        detail: "test task cancelled while waiting for the flush barrier")
                }
                if stillShort && pendingTickets > 0 && attemptIndex < maxAttempts {
                    print(
                        "PF024_R journal flush retry scheduled attempt=\(attemptIndex)/\(maxAttempts) reason=\(signal.stageName) appended=\(snapshot.appended) expected=\(expectedAppendedCount) queuedTickets=\(snapshot.queuedTickets.count) inFlightTickets=\(snapshot.inFlightTickets.count)"
                    )
                    continue
                }
                throw JournalFlushBarrierRetryExhaustedForTesting(
                    stage: signal.stageName, attempts: attemptIndex, maxAttempts: maxAttempts,
                    expectedAppendedCount: expectedAppendedCount, appended: snapshot.appended,
                    queuedTickets: snapshot.queuedTickets.count,
                    inFlightTickets: snapshot.inFlightTickets.count,
                    detail: signal.detail)
            }
        }
    }

#endif
