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

    static let shared = DiagnosticsJournalRetentionScheduler()

    private let policy: Policy
    private let reclaim: @Sendable (URL) async -> Void
    private var lastStartedAt: Date?
    private var isRunning = false

    init(
        policy: Policy = .standard,
        reclaim: @escaping @Sendable (URL) async -> Void = { rootURL in
            let coordinator = DiagnosticsJournalRetentionCoordinator(rootURL: rootURL)
            _ = coordinator.runReclaim()
        }
    ) {
        self.policy = policy
        self.reclaim = reclaim
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
        lastStartedAt = now
        let reclaim = reclaim
        Task.detached(priority: .utility) { [weak self] in
            await reclaim(rootURL)
            await self?.finishRun()
        }
        return true
    }

    private func finishRun() {
        isRunning = false
    }
}
