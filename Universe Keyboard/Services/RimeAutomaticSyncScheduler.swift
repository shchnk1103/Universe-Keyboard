import BackgroundTasks
import Foundation
import KeyboardCore

/// 用户可以分别订阅 RIME 标准资料和 Universe 设置的同步通知。
nonisolated enum RimeSyncNotificationScope: String, CaseIterable, Hashable, Sendable {
    case standardRimeData
    case privateSettings

    var title: String {
        switch self {
        case .standardRimeData: return "RIME 标准同步"
        case .privateSettings: return "Universe 设置同步"
        }
    }

    var notificationSubject: String {
        switch self {
        case .standardRimeData: return "RIME 常用词和标准资料"
        case .privateSettings: return "Universe App 设置"
        }
    }

    var notificationDetail: String {
        switch self {
        case .standardRimeData:
            return "常用词、候选学习和 RIME 标准资料的同步状态。"
        case .privateSettings:
            return "方案、候选数量等 Universe App 设置的同步状态。"
        }
    }
}

nonisolated enum RimeSyncNotificationMode: Equatable, Sendable {
    case manual
    case automatic

    var startedTitle: String { self == .manual ? "开始同步" : "开始自动同步" }
    var completedTitle: String { self == .manual ? "同步完成" : "自动同步完成" }
    var failedTitle: String { self == .manual ? "同步失败" : "自动同步失败" }
}

nonisolated struct RimeSyncNotificationPayload: Equatable, Sendable {
    let title: String
    let body: String
}

/// 同步通知只表达阶段状态，不携带目录、词典、恢复码或输入内容。
nonisolated enum RimeSyncNotificationEvent: Equatable, Sendable {
    case phaseStarted(
        mode: RimeSyncNotificationMode,
        scope: RimeSyncNotificationScope,
        completedScopes: Set<RimeSyncNotificationScope>,
        pendingScopes: Set<RimeSyncNotificationScope>
    )
    case completed(
        mode: RimeSyncNotificationMode,
        scopes: Set<RimeSyncNotificationScope>
    )
    case failed(
        mode: RimeSyncNotificationMode,
        failedScope: RimeSyncNotificationScope,
        completedScopes: Set<RimeSyncNotificationScope>,
        pendingScopes: Set<RimeSyncNotificationScope>
    )

    /// 根据用户订阅的子项生成最终文案。返回 nil 表示本事件与订阅范围无关。
    func payload(enabledScopes: Set<RimeSyncNotificationScope>) -> RimeSyncNotificationPayload? {
        switch self {
        case .phaseStarted(let mode, let scope, let completedScopes, let pendingScopes):
            guard enabledScopes.contains(scope) else { return nil }
            // 前一阶段已被订阅时，开始通知已把后续订阅阶段合并进去，避免重复提醒。
            guard completedScopes.isDisjoint(with: enabledScopes) else { return nil }
            let announcedScopes = enabledScopes.intersection(pendingScopes.union([scope]))
            return RimeSyncNotificationPayload(
                title: mode.startedTitle,
                body: "正在同步\(Self.subject(for: announcedScopes))。"
            )

        case .completed(let mode, let scopes):
            let completedScopes = enabledScopes.intersection(scopes)
            guard !completedScopes.isEmpty else { return nil }
            return RimeSyncNotificationPayload(
                title: mode.completedTitle,
                body: "\(Self.subject(for: completedScopes))已更新。"
            )

        case .failed(let mode, let failedScope, let completedScopes, let pendingScopes):
            let selectedCompleted = enabledScopes.intersection(completedScopes)
            let selectedPending = enabledScopes.intersection(pendingScopes)

            if enabledScopes.contains(failedScope) {
                var messages: [String] = []
                if !selectedCompleted.isEmpty {
                    messages.append("\(Self.subject(for: selectedCompleted))已更新")
                }
                messages.append("\(failedScope.notificationSubject)未完成")
                if !selectedPending.isEmpty {
                    messages.append("\(Self.subject(for: selectedPending))尚未开始")
                }
                return RimeSyncNotificationPayload(
                    title: mode.failedTitle,
                    body: messages.joined(separator: "；") + "。请打开 App 查看原因。"
                )
            }

            // 用户没有订阅失败阶段，但其订阅的前置阶段已经成功，仍应给出准确完成反馈。
            guard !selectedCompleted.isEmpty else { return nil }
            return RimeSyncNotificationPayload(
                title: mode.completedTitle,
                body: "\(Self.subject(for: selectedCompleted))已更新。"
            )
        }
    }

    private static func subject(for scopes: Set<RimeSyncNotificationScope>) -> String {
        let hasStandard = scopes.contains(.standardRimeData)
        let hasPrivate = scopes.contains(.privateSettings)
        switch (hasStandard, hasPrivate) {
        case (true, true): return "RIME 常用词、标准资料和 Universe App 设置"
        case (true, false): return RimeSyncNotificationScope.standardRimeData.notificationSubject
        case (false, true): return RimeSyncNotificationScope.privateSettings.notificationSubject
        case (false, false): return "同步资料"
        }
    }
}

/// 后台自动同步的系统接入点。
///
/// `BGProcessingTask` 的执行时刻由 iOS 决定；这里仅提交最早可执行时间，并在每次
/// 已验证的同步或跳过后安排下一次机会，绝不把它描述为定时器或实时服务。
@MainActor
final class RimeAutomaticSyncScheduler {
    static let shared = RimeAutomaticSyncScheduler()
    static let taskIdentifier = "com.DoubleShy0N.Universe-Keyboard.rime-standard-sync"

    private var hasRegisteredTask = false

    private init() {}

    func registerBackgroundTask() {
        guard !hasRegisteredTask else { return }
        hasRegisteredTask = true

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            guard let processingTask = task as? BGProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            Task { @MainActor in
                Self.shared.handle(processingTask)
            }
        }
    }

    /// 在设置变更、手动同步完成和主 App 进入后台时调用。
    func refreshSchedule(defaults: UserDefaults = .standard) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.taskIdentifier)

        guard let earliestBeginDate = nextEligibleDate(defaults: defaults) else {
            return
        }

        let request = BGProcessingTaskRequest(identifier: Self.taskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = earliestBeginDate

        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.shared.info(
                "rimeSync automatic background task scheduled cadence="
                    + "\(automaticCadence(defaults: defaults).rawValue)",
                category: .config
            )
        } catch {
            // 提交被系统拒绝时不改变用户的同步开关；下次前台或进入后台会重新尝试。
            Logger.shared.warning(
                "rimeSync automatic background task scheduling failed "
                    + "code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error))",
                category: .config
            )
            Logger.shared.requestFlush()
        }
    }

    private func handle(_ task: BGProcessingTask) {
        Logger.shared.info("rimeSync automatic background task started", category: .config)

        let operation = Task { @MainActor in
            let model = RimeSyncViewModel(rimeStore: RimeSettingsStore())
            let result = await model.synchronizeAutomatically()
            task.setTaskCompleted(success: result.completedSuccessfully)
            refreshSchedule()
        }
        task.expirationHandler = {
            operation.cancel()
            Logger.shared.warning("rimeSync automatic background task expired", category: .config)
            Logger.shared.requestFlush()
        }
    }

    private func nextEligibleDate(defaults: UserDefaults) -> Date? {
        guard defaults.bool(forKey: RimeSyncStorageKey.automaticSyncEnabled),
              (defaults.object(forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled) as? Bool)
                ?? true,
              defaults.string(forKey: RimeSyncStorageKey.provider) == RimeSyncProvider.localFolder.rawValue,
              defaults.data(forKey: RimeSyncStorageKey.folderBookmark) != nil,
              !defaults.bool(forKey: RimeSyncStorageKey.folderSelectionNeedsRepair),
              let lastAutomaticAttempt = defaults.object(
                  forKey: RimeSyncStorageKey.lastAutomaticAttempt
              ) as? Date
        else {
            return nil
        }

        return RimeAutomaticSyncPolicy.nextEligibleDate(
            lastAutomaticAttempt: lastAutomaticAttempt,
            cadence: automaticCadence(defaults: defaults)
        )
    }

    private func automaticCadence(defaults: UserDefaults) -> RimeAutomaticSyncCadence {
        RimeAutomaticSyncCadence(
            rawValue: defaults.string(forKey: RimeSyncStorageKey.automaticSyncCadence) ?? ""
        ) ?? .daily
    }
}
