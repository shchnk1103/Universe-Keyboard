import Foundation
import KeyboardCore
import Observation
import UserNotifications

nonisolated private enum AppNotificationMetadataKey {
    static let prefersToastWhenForeground = "prefersToastWhenForeground"
    static let appCategory = "appNotificationCategory"
}

/// App 内可独立管理的本地通知类别。新增类别时必须同时补充产品文案与迁移测试。
nonisolated enum AppNotificationCategory: String, CaseIterable, Sendable {
    case rimeSync
    /// Debug-only UI 仍使用统一模型，避免到期提醒绕过其他通知的授权和取消规则。
    case diagnosticsHighFidelityExpiry

    var title: String {
        switch self {
        case .rimeSync:
            return "RIME 云同步"
        case .diagnosticsHighFidelityExpiry:
            return "首屏高保真诊断"
        }
    }

    var detail: String {
        switch self {
        case .rimeSync:
            return "在手动或自动同步开始、完成和失败时通知你。"
        case .diagnosticsHighFidelityExpiry:
            return "在短时高保真采样自动结束后提醒你。"
        }
    }
}

nonisolated enum AppLocalNotificationDelivery: Equatable, Sendable {
    case immediate
    case after(TimeInterval)
}

nonisolated enum AppNotificationAuthorizationStatus: Equatable, Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    var canDeliver: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}

/// 与 UserNotifications 解耦的请求值，便于单元测试授权和发送边界。
nonisolated struct AppLocalNotificationRequest: Equatable, Sendable {
    let identifier: String
    let title: String
    let body: String
    let category: AppNotificationCategory
    let prefersToastWhenForeground: Bool
    let delivery: AppLocalNotificationDelivery
}

nonisolated enum AppNotificationForegroundPresentationPolicy {
    static func options(
        hasKnownCategory: Bool,
        prefersToast: Bool
    ) -> UNNotificationPresentationOptions {
        if hasKnownCategory, prefersToast {
            return [.list]
        }
        return [.banner, .list, .sound]
    }
}

@MainActor
protocol AppNotificationClient: AnyObject {
    func authorizationStatus() async -> AppNotificationAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func schedule(_ request: AppLocalNotificationRequest) async throws
    func cancelPendingNotification(identifier: String) async
}

/// 持久化键只有这一处定义，避免 RIME 页面和全局设置各自维护一份状态。
@MainActor
final class AppNotificationSettingsStore {
    enum StorageKey {
        static let notificationsEnabled = "app_notifications_enabled"
        static let operationToastsEnabled = "app_operation_toasts_enabled"
        // 保留旧键，使已开启 RIME 同步通知的用户可无损迁移。
        static let rimeSyncEnabled = "rime_standard_sync_notifications_enabled"
        static let rimeStandardSyncEnabled = "rime_standard_data_notifications_enabled"
        static let rimePrivateSettingsEnabled = "rime_private_settings_notifications_enabled"
        static let diagnosticsHighFidelityExpiryEnabled =
            "diagnostics_high_fidelity_expiry_notifications_enabled"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasStoredNotificationsPreference: Bool {
        defaults.object(forKey: StorageKey.notificationsEnabled) != nil
    }

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: StorageKey.notificationsEnabled) }
        set { defaults.set(newValue, forKey: StorageKey.notificationsEnabled) }
    }

    var operationToastsEnabled: Bool {
        get {
            (defaults.object(forKey: StorageKey.operationToastsEnabled) as? Bool) ?? true
        }
        set { defaults.set(newValue, forKey: StorageKey.operationToastsEnabled) }
    }

    func isCategorySelected(_ category: AppNotificationCategory) -> Bool {
        switch category {
        case .rimeSync:
            return defaults.bool(forKey: StorageKey.rimeSyncEnabled)
        case .diagnosticsHighFidelityExpiry:
            return defaults.bool(forKey: StorageKey.diagnosticsHighFidelityExpiryEnabled)
        }
    }

    func setCategorySelected(_ selected: Bool, category: AppNotificationCategory) {
        switch category {
        case .rimeSync:
            defaults.set(selected, forKey: StorageKey.rimeSyncEnabled)
        case .diagnosticsHighFidelityExpiry:
            defaults.set(selected, forKey: StorageKey.diagnosticsHighFidelityExpiryEnabled)
        }
    }

    func isRimeSyncScopeSelected(_ scope: RimeSyncNotificationScope) -> Bool {
        let key = rimeSyncScopeKey(scope)
        // 旧版本只有 RIME 通知总开关；缺少子项时沿用总开关值完成兼容迁移。
        return (defaults.object(forKey: key) as? Bool) ?? isCategorySelected(.rimeSync)
    }

    func setRimeSyncScopeSelected(_ selected: Bool, scope: RimeSyncNotificationScope) {
        defaults.set(selected, forKey: rimeSyncScopeKey(scope))
    }

    var selectedRimeSyncScopes: Set<RimeSyncNotificationScope> {
        Set(RimeSyncNotificationScope.allCases.filter(isRimeSyncScopeSelected))
    }

    func selectDefaultRimeSyncScopesIfNeeded() {
        guard selectedRimeSyncScopes.isEmpty else { return }
        for scope in RimeSyncNotificationScope.allCases {
            setRimeSyncScopeSelected(true, scope: scope)
        }
    }

    var hasSelectedCategory: Bool {
        AppNotificationCategory.allCases.contains(where: isCategorySelected)
    }

    private func rimeSyncScopeKey(_ scope: RimeSyncNotificationScope) -> String {
        switch scope {
        case .standardRimeData: return StorageKey.rimeStandardSyncEnabled
        case .privateSettings: return StorageKey.rimePrivateSettingsEnabled
        }
    }
}

@MainActor
@Observable
final class AppNotificationSettingsModel {
    private let store: AppNotificationSettingsStore
    private let client: any AppNotificationClient
    private let diagnosticsDefaults: UserDefaults?

    static let diagnosticsHighFidelityExpiryIdentifier =
        "diagnostics-high-fidelity-expiry"

    var notificationsEnabled: Bool
    var operationToastsEnabled: Bool
    var authorizationStatus: AppNotificationAuthorizationStatus = .notDetermined
    var notice: String?

    init(
        defaults: UserDefaults = .standard,
        diagnosticsDefaults: UserDefaults? = UserDefaults(suiteName: universeAppGroupID),
        client: any AppNotificationClient = SystemAppNotificationClient.shared
    ) {
        let store = AppNotificationSettingsStore(defaults: defaults)
        self.store = store
        self.diagnosticsDefaults = diagnosticsDefaults
        self.client = client
        notificationsEnabled = store.notificationsEnabled
        operationToastsEnabled = store.operationToastsEnabled
    }

    var permissionSummary: String {
        switch authorizationStatus {
        case .notDetermined:
            return "尚未请求系统通知权限。开启后，系统会询问是否允许。"
        case .denied:
            return "系统通知权限已关闭。你可以前往系统设置重新允许。"
        case .authorized:
            return notificationsEnabled ? "通知已开启。" : "系统已允许通知，但 App 内总开关处于关闭状态。"
        case .provisional:
            return "通知会先安静地进入通知中心。"
        case .ephemeral:
            return "系统暂时允许通知。"
        }
    }

    func isCategorySelected(_ category: AppNotificationCategory) -> Bool {
        store.isCategorySelected(category)
    }

    func isCategoryEnabled(_ category: AppNotificationCategory) -> Bool {
        notificationsEnabled && authorizationStatus.canDeliver && isCategorySelected(category)
    }

    func isRimeSyncScopeSelected(_ scope: RimeSyncNotificationScope) -> Bool {
        store.isRimeSyncScopeSelected(scope)
    }

    /// 首次刷新完成兼容迁移；以后系统权限被外部关闭时，只关闭总开关并保留类别选择。
    func refreshAuthorizationStatus() async {
        // 正常 UI 会共享根模型；这里仍从持久层刷新，使后台任务或未来新入口的改动可收敛。
        notificationsEnabled = store.notificationsEnabled
        operationToastsEnabled = store.operationToastsEnabled
        let status = await client.authorizationStatus()
        authorizationStatus = status

        if !store.hasStoredNotificationsPreference {
            let shouldMigrateEnabledState = store.isCategorySelected(.rimeSync) && status.canDeliver
            store.notificationsEnabled = shouldMigrateEnabledState
            notificationsEnabled = shouldMigrateEnabledState
            Logger.shared.info(
                "app notification preference migrated master=\(shouldMigrateEnabledState) "
                    + "authorization=\(status)",
                category: .config
            )
        } else if status == .denied, notificationsEnabled {
            setMasterState(false)
            notice = "系统通知权限已关闭，App 内通知也已暂停。"
            Logger.shared.info(
                "app notification master disabled authorization=denied",
                category: .config
            )
        } else if status != .denied {
            notice = nil
        }
        await synchronizeDiagnosticsHighFidelityExpiryNotification()
    }

    func setNotificationsEnabled(_ enabled: Bool) async {
        guard enabled else {
            setMasterState(false)
            notice = nil
            await synchronizeDiagnosticsHighFidelityExpiryNotification()
            Logger.shared.info("app notification master changed enabled=false", category: .config)
            return
        }

        if !store.hasSelectedCategory {
            store.setCategorySelected(true, category: .rimeSync)
            store.selectDefaultRimeSyncScopesIfNeeded()
        }

        let status = await resolvedAuthorizationStatusForEnabling()
        authorizationStatus = status
        guard status.canDeliver else {
            setMasterState(false)
            await synchronizeDiagnosticsHighFidelityExpiryNotification()
            notice =
                status == .denied
                ? "系统没有允许通知。你可以前往系统设置重新开启。"
                : "暂时无法开启通知，请稍后再试。"
            return
        }

        setMasterState(true)
        notice = nil
        await synchronizeDiagnosticsHighFidelityExpiryNotification()
        Logger.shared.info(
            "app notification master changed enabled=true authorization=\(status)",
            category: .config
        )
    }

    /// 从任意入口开启类别时会同步开启总开关；关闭最后一个类别时总开关自动关闭。
    func setCategorySelected(_ selected: Bool, category: AppNotificationCategory) async {
        if selected, category == .rimeSync {
            store.selectDefaultRimeSyncScopesIfNeeded()
        }
        store.setCategorySelected(selected, category: category)
        Logger.shared.info(
            "app notification category changed category=\(category.rawValue) selected=\(selected)",
            category: .config
        )

        if selected {
            await setNotificationsEnabled(true)
        } else if !store.hasSelectedCategory {
            setMasterState(false)
            await synchronizeDiagnosticsHighFidelityExpiryNotification()
        } else {
            await synchronizeDiagnosticsHighFidelityExpiryNotification()
        }
    }

    /// 通知子项只决定提醒范围，不会改动实际的自动同步总开关或同步内容开关。
    func setRimeSyncScopeSelected(_ selected: Bool, scope: RimeSyncNotificationScope) async {
        store.setRimeSyncScopeSelected(selected, scope: scope)
        Logger.shared.info(
            "app notification RIME scope changed scope=\(scope.rawValue) selected=\(selected)",
            category: .config
        )

        if selected {
            store.setCategorySelected(true, category: .rimeSync)
            await setNotificationsEnabled(true)
        } else if store.selectedRimeSyncScopes.isEmpty {
            store.setCategorySelected(false, category: .rimeSync)
            if !store.hasSelectedCategory {
                setMasterState(false)
            }
        }
    }

    func setOperationToastsEnabled(_ enabled: Bool) {
        operationToastsEnabled = enabled
        store.operationToastsEnabled = enabled
        Logger.shared.info("app operation toast changed enabled=\(enabled)", category: .config)
    }

    /// 让唯一的待发送到期提醒与 App Group 的绝对过期时间保持一致。
    /// 仅 Main App 可调用；Keyboard Extension 永不请求或安排通知。窗口缺失或过期时
    /// 主动取消旧请求，避免下一次测试收到过时提醒。
    func synchronizeDiagnosticsHighFidelityExpiryNotification() async {
        guard
            notificationsEnabled,
            store.isCategorySelected(.diagnosticsHighFidelityExpiry),
            let expiration = DiagnosticsHighFidelityConfiguration.expiration(in: diagnosticsDefaults)
        else {
            await client.cancelPendingNotification(
                identifier: Self.diagnosticsHighFidelityExpiryIdentifier
            )
            return
        }

        let remaining = expiration.timeIntervalSinceNow
        guard remaining > 0 else {
            await client.cancelPendingNotification(
                identifier: Self.diagnosticsHighFidelityExpiryIdentifier
            )
            return
        }

        let status = await client.authorizationStatus()
        authorizationStatus = status
        guard status.canDeliver else {
            await client.cancelPendingNotification(
                identifier: Self.diagnosticsHighFidelityExpiryIdentifier
            )
            return
        }

        let request = AppLocalNotificationRequest(
            identifier: Self.diagnosticsHighFidelityExpiryIdentifier,
            title: "首屏高保真诊断已结束",
            body: "30 分钟的短时采样已自动关闭。",
            category: .diagnosticsHighFidelityExpiry,
            // 它没有对应的 App 内 Toast，前台也应保留横幅和声音提示。
            prefersToastWhenForeground: false,
            delivery: .after(remaining)
        )

        do {
            try await client.schedule(request)
        } catch {
            Logger.shared.warning(
                "diagnostics expiry notification scheduling failed "
                    + "code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error))",
                category: .config
            )
        }
    }

    private func setMasterState(_ enabled: Bool) {
        notificationsEnabled = enabled
        store.notificationsEnabled = enabled
    }

    private func resolvedAuthorizationStatusForEnabling() async -> AppNotificationAuthorizationStatus {
        let currentStatus = await client.authorizationStatus()
        guard currentStatus == .notDetermined else { return currentStatus }

        do {
            let granted = try await client.requestAuthorization()
            let refreshedStatus = await client.authorizationStatus()
            if refreshedStatus != .notDetermined {
                return refreshedStatus
            }
            // 测试替身或系统极短延迟下仍以授权返回值安全收敛。
            return granted ? .authorized : .denied
        } catch {
            Logger.shared.warning(
                "app notification authorization failed "
                    + "code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error))",
                category: .config
            )
            return .denied
        }
    }
}

@MainActor
final class SystemAppNotificationClient: NSObject, AppNotificationClient, UNUserNotificationCenterDelegate {
    static let shared = SystemAppNotificationClient()

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    func configure() {
        center.delegate = self
    }

    func authorizationStatus() async -> AppNotificationAuthorizationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .ephemeral
        @unknown default: return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func schedule(_ request: AppLocalNotificationRequest) async throws {
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.categoryIdentifier = request.category.rawValue
        content.userInfo = [
            AppNotificationMetadataKey.prefersToastWhenForeground: request.prefersToastWhenForeground,
            AppNotificationMetadataKey.appCategory: request.category.rawValue,
        ]

        let trigger: UNNotificationTrigger?
        switch request.delivery {
        case .immediate:
            trigger = nil
        case let .after(interval):
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(interval, 1),
                repeats: false
            )
        }

        try await center.add(
            UNNotificationRequest(
                identifier: request.identifier,
                content: content,
                trigger: trigger
            )
        )
    }

    func cancelPendingNotification(identifier: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        let hasKnownCategory = userInfo[AppNotificationMetadataKey.appCategory] as? String != nil
        let prefersToast = userInfo[AppNotificationMetadataKey.prefersToastWhenForeground] as? Bool == true

        // 前台已有操作 Toast 时只写入通知中心，避免同一事件出现两份提示和声音。
        completionHandler(
            AppNotificationForegroundPresentationPolicy.options(
                hasKnownCategory: hasKnownCategory,
                prefersToast: prefersToast
            )
        )
    }
}

@MainActor
protocol AppNotificationNotifying: AnyObject {
    func notify(_ event: RimeSyncNotificationEvent) async
}

/// 所有 RIME 同步路径都把事件交给这里；是否真正发送只由全局设置和系统权限决定。
@MainActor
final class AppNotificationService: AppNotificationNotifying {
    static let shared = AppNotificationService()

    private let store: AppNotificationSettingsStore
    private let client: any AppNotificationClient

    init(
        defaults: UserDefaults = .standard,
        client: any AppNotificationClient = SystemAppNotificationClient.shared
    ) {
        store = AppNotificationSettingsStore(defaults: defaults)
        self.client = client
    }

    func notify(_ event: RimeSyncNotificationEvent) async {
        let status = await client.authorizationStatus()
        guard store.notificationsEnabled,
            store.isCategorySelected(.rimeSync),
            status.canDeliver
        else {
            Logger.shared.info(
                "rimeSync notification skipped master=\(store.notificationsEnabled) "
                    + "category=\(store.isCategorySelected(.rimeSync)) authorization=\(status)",
                category: .config
            )
            return
        }

        guard let payload = event.payload(enabledScopes: store.selectedRimeSyncScopes) else {
            Logger.shared.info(
                "rimeSync notification skipped event outside selected scopes",
                category: .config
            )
            return
        }

        let request = AppLocalNotificationRequest(
            identifier: "rime-standard-sync-\(UUID().uuidString)",
            title: payload.title,
            body: payload.body,
            category: .rimeSync,
            prefersToastWhenForeground: store.operationToastsEnabled,
            delivery: .immediate
        )

        do {
            try await client.schedule(request)
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
