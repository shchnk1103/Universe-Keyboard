import Foundation
import KeyboardCore

/// Main App 专属的 journal 目录维护调度器。
///
/// 它把启动、前台恢复和诊断页刷新合并为有限频率的 utility 工作；Keyboard
/// Extension 不引用该类型，因此不会把目录枚举或 reclaim 带入输入路径。
actor DiagnosticsJournalRetentionScheduler {
    struct Policy: Sendable {
        static let standard = Policy(minimumInterval: 15 * 60)

        let minimumInterval: TimeInterval
    }

    static let shared = DiagnosticsJournalRetentionScheduler(
        isForegroundActive: { DiagnosticsAppLifecycle.shared.isProcessActive }
    )

    private let policy: Policy
    private let reclaim: @Sendable (URL) async -> Void
    private let isForegroundActive: @Sendable () -> Bool
    private var lastStartedAt: Date?
    private var isRunning = false

    init(
        policy: Policy = .standard,
        reclaim: @escaping @Sendable (URL) async -> Void = { rootURL in
            let coordinator = DiagnosticsJournalRetentionCoordinator(rootURL: rootURL)
            _ = coordinator.runReclaim()
        },
        isForegroundActive: @escaping @Sendable () -> Bool = { true }
    ) {
        self.policy = policy
        self.reclaim = reclaim
        self.isForegroundActive = isForegroundActive
    }

    /// 返回 `true` 代表本次已投递 reclaim。相邻请求只会被合并；调用方不等待
    /// 目录扫描或删除完成，因此诊断页查询和 UI 刷新不会被 retention 串行化。
    @discardableResult
    func requestReclaim(rootURL: URL, now: Date = Date()) async -> Bool {
        guard !isRunning else { return false }
        if let lastStartedAt, now.timeIntervalSince(lastStartedAt) < policy.minimumInterval {
            return false
        }

        isRunning = true
        let previousStartedAt = lastStartedAt
        lastStartedAt = now
        let reclaim = reclaim
        let isForegroundActive = isForegroundActive
        Task.detached(priority: .utility) { [weak self] in
            // 门闩放在真正执行前。排队之后转入后台则跳过本次，并恢复间隔起点，等下次 active。
            guard isForegroundActive() else {
                await self?.finishRun(.restore(previousStartedAt))
                return
            }
            await reclaim(rootURL)
            await self?.finishRun(.keep)
        }
        return true
    }

    private enum FinishStamp {
        /// 正常跑完：保留 request 时写入的时间，15 分钟间隔继续有效。
        case keep
        /// 执行前发现不在前台：恢复排队前的起点（首次为 nil），避免这次跳过占住间隔。
        case restore(Date?)
    }

    private func finishRun(_ stamp: FinishStamp) {
        if case .restore(let previous) = stamp {
            lastStartedAt = previous
        }
        isRunning = false
    }
}
