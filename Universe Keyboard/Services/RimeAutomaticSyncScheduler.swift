import BackgroundTasks
import Foundation
import KeyboardCore
import UserNotifications

/// 同步通知只表达操作状态，不携带目录、词典、恢复码或输入内容。
nonisolated enum RimeSyncNotificationEvent: Equatable, Sendable {
    case manualStarted
    case manualCompleted
    case manualFailed
    case automaticStarted(RimeAutomaticSyncScope)
    case automaticCompleted(RimeAutomaticSyncScope)
    case automaticFailed(RimeAutomaticSyncScope)

    var title: String {
        switch self {
        case .manualStarted: return "开始同步"
        case .manualCompleted: return "同步完成"
        case .manualFailed: return "同步失败"
        case .automaticStarted: return "开始自动同步"
        case .automaticCompleted: return "自动同步完成"
        case .automaticFailed: return "自动同步失败"
        }
    }

    var body: String {
        switch self {
        case .manualStarted:
            return "正在同步 RIME 常用词、标准资料和 Universe App 设置。"
        case .manualCompleted:
            return "RIME 常用词、标准资料和 Universe App 设置已更新。"
        case .manualFailed:
            return "本次同步未完成，请打开 App 查看原因。"
        case .automaticStarted(let scope):
            return "正在同步\(scope.notificationSubject)。"
        case .automaticCompleted(let scope):
            return "\(scope.notificationSubject)已更新。"
        case .automaticFailed(let scope):
            return "\(scope.notificationSubject)未完成同步，请打开 App 查看原因。"
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

/// 本地通知只描述同步状态，不包含目录、词典、恢复码或任何输入内容。
@MainActor
final class RimeSyncNotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = RimeSyncNotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    func configure() {
        notificationCenter.delegate = self
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            Logger.shared.info(
                "rimeSync notification authorization completed granted=\(granted)",
                category: .config
            )
            return granted
        } catch {
            Logger.shared.warning(
                "rimeSync notification authorization failed "
                    + "code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error))",
                category: .config
            )
            return false
        }
    }

    func notify(_ event: RimeSyncNotificationEvent) async {
        await schedule(event)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    private func schedule(_ event: RimeSyncNotificationEvent) async {
        let settings = await notificationCenter.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        case .denied, .notDetermined:
            Logger.shared.info(
                "rimeSync notification skipped authorizationStatus="
                    + "\(settings.authorizationStatus.rawValue)",
                category: .config
            )
            return
        @unknown default:
            Logger.shared.warning(
                "rimeSync notification skipped authorizationStatus=unknown",
                category: .config
            )
            return
        }

        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = event.body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "rime-standard-sync-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await notificationCenter.add(request)
            Logger.shared.info(
                "rimeSync notification scheduled event=\(String(describing: event))",
                category: .config
            )
        } catch {
            Logger.shared.warning(
                "rimeSync notification scheduling failed "
                    + "code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error))",
                category: .config
            )
        }
    }
}
