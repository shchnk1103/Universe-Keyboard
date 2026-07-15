import Foundation
import KeyboardCore
import Observation
import RimeBridge

@MainActor
@Observable
final class RimeSyncViewModel {
    private typealias StorageKey = RimeSyncStorageKey

    private enum SecretAccount {
        static let encryptionKey = "encryption-key"
        static let webDAVPassword = "webdav-password"
    }

    private let rimeStore: RimeSettingsStore
    private let defaults: UserDefaults
    private let secretStore: RimeSyncSecretStore
    private let coordinator: RimeSyncCoordinator
    private let standardRimeSyncService: any RimeStandardSyncing

    var provider: RimeSyncProvider = .none
    var status: RimeSyncStatus = .idle
    var webDAVURL = ""
    var webDAVUsername = ""
    var webDAVPassword = ""
    var folderName: String?
    var folderSelectionNeedsRepair = false
    var recoveryCode = ""
    var recoveryCodeInput = ""
    var lastSuccessDate: Date?
    var standardRimeLastSuccessDate: Date?
    var automaticSyncEnabled = false
    var automaticStandardRimeDataEnabled = true
    var automaticPrivateSettingsEnabled = true
    var automaticSyncCadence: RimeAutomaticSyncCadence = .daily
    var automaticSyncNotificationsEnabled = false
    var automaticSyncNotice: String?
    var statusVersion = 0

    init(
        rimeStore: RimeSettingsStore,
        defaults: UserDefaults = .standard,
        secretStore: RimeSyncSecretStore = RimeSyncSecretStore(),
        coordinator: RimeSyncCoordinator = RimeSyncCoordinator(),
        standardRimeSyncService: any RimeStandardSyncing = RimeStandardSyncService()
    ) {
        self.rimeStore = rimeStore
        self.defaults = defaults
        self.secretStore = secretStore
        self.coordinator = coordinator
        self.standardRimeSyncService = standardRimeSyncService
        provider = RimeSyncProvider(rawValue: defaults.string(forKey: StorageKey.provider) ?? "") ?? .none
        webDAVURL = defaults.string(forKey: StorageKey.webDAVURL) ?? ""
        webDAVUsername = defaults.string(forKey: StorageKey.webDAVUsername) ?? ""
        folderName = defaults.string(forKey: StorageKey.folderName)
        folderSelectionNeedsRepair = defaults.bool(forKey: StorageKey.folderSelectionNeedsRepair)
        lastSuccessDate = defaults.object(forKey: StorageKey.lastSuccess) as? Date
        standardRimeLastSuccessDate = defaults.object(forKey: StorageKey.standardRimeLastSuccess) as? Date
        automaticSyncEnabled = defaults.bool(forKey: StorageKey.automaticSyncEnabled)
        // 旧版本只有总开关。缺少子项键时按原有行为迁移为两项都开启。
        automaticStandardRimeDataEnabled =
            (defaults.object(forKey: StorageKey.automaticStandardRimeDataEnabled) as? Bool) ?? true
        automaticPrivateSettingsEnabled =
            (defaults.object(forKey: StorageKey.automaticPrivateSettingsEnabled) as? Bool) ?? true
        if automaticSyncEnabled,
           !automaticStandardRimeDataEnabled,
           !automaticPrivateSettingsEnabled {
            // 修复旧状态中的矛盾组合：没有任何同步内容时，总开关不能保持开启。
            automaticSyncEnabled = false
            defaults.set(false, forKey: StorageKey.automaticSyncEnabled)
        }
        automaticSyncCadence = RimeAutomaticSyncCadence(
            rawValue: defaults.string(forKey: StorageKey.automaticSyncCadence) ?? ""
        ) ?? .daily
        automaticSyncNotificationsEnabled = defaults.bool(
            forKey: StorageKey.automaticSyncNotificationsEnabled
        )
        status = isConfigured ? .idle : .notConfigured
    }

    var isConfigured: Bool {
        switch provider {
        case .none:
            return false
        case .localFolder:
            return defaults.data(forKey: StorageKey.folderBookmark) != nil && !folderSelectionNeedsRepair
        case .webDAV:
            return !webDAVURL.isEmpty && !webDAVUsername.isEmpty && !webDAVPassword.isEmpty
        }
    }

    var statusText: String {
        switch status {
        case .idle:
            if let lastSuccessDate {
                return "上次同步：\(Self.relativeDateFormatter.localizedString(for: lastSuccessDate, relativeTo: Date()))"
            }
            return isConfigured ? "准备同步" : "尚未配置"
        case .notConfigured:
            return "尚未配置"
        case .syncing(let phase):
            return phase.progressMessage
        case .succeeded(let date, let completion):
            return "\(completion.message) · \(Self.relativeDateFormatter.localizedString(for: date, relativeTo: Date()))"
        case .failed(let message):
            return message
        }
    }

    var statusSystemImage: String {
        switch status {
        case .syncing(_): return "arrow.triangle.2.circlepath"
        case .succeeded(_, _): return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        case .idle, .notConfigured: return isConfigured ? "icloud" : "icloud.slash"
        }
    }

    /// RIME 官方同步只支持用户选定的本地/文件提供器目录。
    /// WebDAV 仍可承载 Universe 私密设置，但不能直接成为其他 RIME 前端的 sync_dir。
    var canSynchronizeStandardRimeData: Bool {
        provider == .localFolder && isConfigured
    }

    var localFolderRecoveryMessage: String? {
        guard provider == .localFolder, folderSelectionNeedsRepair else { return nil }
        if let folderName {
            return "新文件夹未生效；同步已暂停，之前的“\(folderName)”不会被写入。"
        }
        return "新文件夹未生效；同步已暂停，请重新选择一个可写文件夹。"
    }

    /// 只有完成过一次用户明确发起的标准同步后，才允许后台任务接手后续维护。
    var canEnableAutomaticStandardSync: Bool {
        canSynchronizeStandardRimeData && standardRimeLastSuccessDate != nil
    }

    var hasEnabledAutomaticSyncScope: Bool {
        automaticStandardRimeDataEnabled || automaticPrivateSettingsEnabled
    }

    var automaticSyncScheduleText: String {
        guard canEnableAutomaticStandardSync else {
            return "请先完成一次“立即同步”来确认共享文件夹；完成后仍由你决定是否开启自动同步。"
        }
        guard automaticSyncEnabled else {
            return "自动同步尚未开启。手动同步不会替你开启；需要时请主动打开总开关。"
        }
        switch (automaticStandardRimeDataEnabled, automaticPrivateSettingsEnabled) {
        case (true, true):
            return "RIME 标准资料会由系统在后台空闲时更新；Universe App 设置也会在打开 App 时检查更新。两项共用“\(automaticSyncCadence.title)”冷却时间。"
        case (true, false):
            return "只自动同步 RIME 常用词和标准资料；系统会在后台空闲且键盘未使用时，最早按“\(automaticSyncCadence.title)”安排。"
        case (false, true):
            return "只自动同步 Universe App 设置；打开或回到 App 时会按“\(automaticSyncCadence.title)”检查更新。"
        case (false, false):
            return "当前没有选择任何自动同步内容；“立即同步”仍可完整同步两部分。"
        }
    }

    func loadSecrets() async {
        do {
            if let passwordData = try await secretStore.data(for: SecretAccount.webDAVPassword) {
                webDAVPassword = String(decoding: passwordData, as: UTF8.self)
            }
            if let keyData = try await secretStore.data(for: SecretAccount.encryptionKey) {
                recoveryCode = RimeSyncPackageCodec.recoveryCode(for: keyData)
            }
        } catch {
            setStatus(.failed(error.localizedDescription))
        }
    }

    func selectProvider(_ newProvider: RimeSyncProvider) {
        provider = newProvider
        defaults.set(newProvider.rawValue, forKey: StorageKey.provider)
        status = isConfigured ? .idle : .notConfigured
        if newProvider != .localFolder {
            automaticSyncEnabled = false
            defaults.set(false, forKey: StorageKey.automaticSyncEnabled)
            RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
        }
    }

    /// `hasActivePickerScope` 必须由文件选择回调同步取得，保证进入异步任务前
    /// 已经持有外部目录的安全作用域；否则 iCloud URL 可能在任务执行时失效。
    func configureLocalFolder(_ url: URL, hasActivePickerScope: Bool) async {
        let selectedFolderName = url.lastPathComponent
        Logger.shared.info(
            "rimeSync folder selection started pickerScopeActive=\(hasActivePickerScope)",
            category: .config
        )

        do {
            try RimeSyncFolderAccess.preflight(url)
            Logger.shared.info("rimeSync folder access preflight succeeded", category: .config)

            // Apple 的文件选择器要求在安全作用域仍处于激活状态时持久化 bookmark。
            let bookmark = try RimeSyncFolderAccess.bookmarkData(for: url)
            defaults.set(bookmark, forKey: StorageKey.folderBookmark)
            defaults.set(selectedFolderName, forKey: StorageKey.folderName)
            defaults.set(false, forKey: StorageKey.folderSelectionNeedsRepair)
            folderName = selectedFolderName
            folderSelectionNeedsRepair = false
            selectProvider(.localFolder)
            resetAutomaticStandardSyncEligibility()
            try await ensureEncryptionKey()
            setStatus(.idle)
            Logger.shared.info("rimeSync folder selection committed", category: .config)
        } catch {
            // 新选择未通过读写验证时，绝不悄悄回退到旧目录执行同步。
            // 旧 bookmark 仅作为可恢复信息保留，直到用户重新选择成功的目录。
            defaults.set(true, forKey: StorageKey.folderSelectionNeedsRepair)
            folderSelectionNeedsRepair = true
            setStatus(.failed("未切换同步文件夹：所选文件夹无法完成读写验证。同步已暂停，请重新选择。"))
            Logger.shared.error(
                "rimeSync folder selection failed code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error)) "
                    + "previousSelectionRetained=\(folderName != nil)",
                category: .config
            )
            Logger.shared.requestFlush()
        }
    }

    /// 文件选择器本身失败时，也保留可诊断的错误码，但不把文件提供器的原始文案暴露到界面。
    func reportLocalFolderPickerFailure(_ error: Error) {
        setStatus(.failed("无法打开所选文件夹，请重新选择后再试。"))
        Logger.shared.error(
            "rimeSync folder picker failed code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error))",
            category: .config
        )
        Logger.shared.requestFlush()
    }

    func saveWebDAVConfiguration() async {
        do {
            guard let url = normalizedWebDAVURL() else { throw RimeSyncError.invalidServerURL }
            guard isSecure(url) else { throw RimeSyncError.insecureServerURL }
            guard !webDAVUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !webDAVPassword.isEmpty
            else {
                throw RimeSyncError.missingCredentials
            }

            webDAVURL = url.absoluteString
            webDAVUsername = webDAVUsername.trimmingCharacters(in: .whitespacesAndNewlines)
            defaults.set(webDAVURL, forKey: StorageKey.webDAVURL)
            defaults.set(webDAVUsername, forKey: StorageKey.webDAVUsername)
            try await secretStore.set(Data(webDAVPassword.utf8), for: SecretAccount.webDAVPassword)
            selectProvider(.webDAV)
            try await ensureEncryptionKey()
            setStatus(.idle)
        } catch {
            setStatus(.failed(error.localizedDescription))
        }
    }

    func importRecoveryCode() async {
        do {
            let keyData = try RimeSyncPackageCodec.keyData(fromRecoveryCode: recoveryCodeInput)
            try await secretStore.set(keyData, for: SecretAccount.encryptionKey)
            recoveryCode = RimeSyncPackageCodec.recoveryCode(for: keyData)
            recoveryCodeInput = ""
            setStatus(.idle)
        } catch {
            setStatus(.failed(error.localizedDescription))
        }
    }

    /// 用户点按的唯一同步入口。
    ///
    /// 选择标准文件夹时，先完成 RIME 官方用户资料同步，再更新同一位置中的
    /// Universe 私密设置包；任一步失败都会停止，避免向用户呈现模糊的部分成功。
    /// WebDAV 不可作为其他 RIME 前端的 `sync_dir`，因此只执行私密设置同步。
    func synchronizeAllNow() async {
        guard isConfigured, !isSynchronizing else { return }
        let includesStandardRimeData = canSynchronizeStandardRimeData
        let isFirstStandardSync = includesStandardRimeData && standardRimeLastSuccessDate == nil
        Logger.shared.info(
            "rimeSync manual sync started standardRimeData=\(includesStandardRimeData)",
            category: .config
        )
        if automaticSyncNotificationsEnabled {
            await RimeSyncNotificationService.shared.notify(.manualStarted)
        }

        do {
            if includesStandardRimeData {
                setStatus(.syncing(.standardRimeData))
                try await synchronizeStandardRimeData()
                Logger.shared.info("rimeSync standard user data completed", category: .config)
            }

            setStatus(.syncing(.privateSettings))
            let completedAt = try await synchronizePrivateSettings()
            let completion: RimeSyncCompletion = includesStandardRimeData
                ? .standardRimeAndPrivateSettings
                : .privateSettings
            setStatus(.succeeded(completedAt, completion))
            if includesStandardRimeData {
                handleManualStandardSyncSuccess(isFirstStandardSync: isFirstStandardSync)
            }
            Logger.shared.info("rimeSync manual sync completed", category: .config)
            if automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.manualCompleted)
            }
        } catch is CancellationError {
            setStatus(.idle)
            Logger.shared.warning("rimeSync manual sync cancelled", category: .config)
            if automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.manualFailed)
            }
        } catch {
            let didPauseLocalFolderSync = pauseLocalFolderSyncIfNeeded(after: error)
            setStatus(.failed(
                didPauseLocalFolderSync
                    ? "无法访问或写入同步目录。同步已暂停，请重新选择一个可写文件夹。"
                    : error.localizedDescription
            ))
            Logger.shared.error(
                "rimeSync manual sync failed code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error)) "
                    + "localSyncPaused=\(didPauseLocalFolderSync)",
                category: .config
            )
            Logger.shared.requestFlush()
            if automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.manualFailed)
            }
        }
    }

    /// 前台自动更新只覆盖加密管理型设置；绝不自动触发会读写用户资料的
    /// RIME 标准同步。启用自动同步后，这条前台路径也服从用户选择的冷却时间，
    /// 避免每次打开 App 都重复同步并展示成功 Toast。
    func synchronizeIfNeeded(minimumInterval: TimeInterval? = nil) async {
        guard isConfigured, !isSynchronizing else { return }
        if provider == .localFolder {
            guard automaticSyncEnabled, automaticPrivateSettingsEnabled else { return }
        }
        let effectiveInterval = minimumInterval
            ?? (provider == .localFolder ? automaticSyncCadence.interval : 60)
        let persistedLastSuccess = defaults.object(forKey: StorageKey.lastSuccess) as? Date
        let lastAttempt = automaticSyncEnabled
            ? [
                defaults.object(forKey: StorageKey.lastForegroundPrivateAttempt) as? Date,
                persistedLastSuccess ?? lastSuccessDate,
            ].compactMap { $0 }.max()
            : persistedLastSuccess ?? lastSuccessDate
        if let lastAttempt, Date().timeIntervalSince(lastAttempt) < effectiveInterval { return }

        if provider == .localFolder, automaticSyncEnabled {
            // 失败也算一次自动尝试，防止文件提供器暂时不可用时每次打开 App 都重试。
            defaults.set(Date(), forKey: StorageKey.lastForegroundPrivateAttempt)
        }

        setStatus(.syncing(.privateSettings))
        let notificationScope = RimeAutomaticSyncScope.privateSettings
        if provider == .localFolder, automaticSyncNotificationsEnabled {
            await RimeSyncNotificationService.shared.notify(.automaticStarted(notificationScope))
        }
        do {
            let completedAt = try await synchronizePrivateSettings()
            setStatus(.succeeded(completedAt, .privateSettings))
            if provider == .localFolder, automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.automaticCompleted(notificationScope))
            }
        } catch is CancellationError {
            setStatus(.idle)
            if provider == .localFolder, automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.automaticFailed(notificationScope))
            }
        } catch {
            let didPauseLocalFolderSync = pauseLocalFolderSyncIfNeeded(after: error)
            setStatus(.failed(
                didPauseLocalFolderSync
                    ? "无法访问或写入同步目录。同步已暂停，请重新选择一个可写文件夹。"
                    : error.localizedDescription
            ))
            Logger.shared.error(
                "rimeSync automatic private sync failed code=\(RimeSyncFolderAccess.diagnosticErrorCode(for: error)) "
                    + "localSyncPaused=\(didPauseLocalFolderSync)",
                category: .config
            )
            Logger.shared.requestFlush()
            if provider == .localFolder, automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.automaticFailed(notificationScope))
            }
        }
    }

    /// 后台自动同步只在主 App 获得系统执行时间后运行。
    /// 它延续官方快照合并路径，但会先检查冷却时间和键盘扩展的活动心跳。
    func synchronizeAutomatically() async -> RimeAutomaticSyncResult {
        guard automaticSyncEnabled else { return .skipped(.disabled) }
        guard automaticStandardRimeDataEnabled else {
            return .skipped(.standardRimeDataDisabled)
        }
        guard canSynchronizeStandardRimeData else { return .skipped(.notConfigured) }
        guard standardRimeLastSuccessDate != nil else {
            return .skipped(.waitingForFirstManualSync)
        }
        guard !isSynchronizing else { return .skipped(.alreadyRunning) }
        guard RimeAutomaticSyncPolicy.isDue(
            lastAutomaticAttempt: defaults.object(forKey: StorageKey.lastAutomaticAttempt) as? Date,
            cadence: automaticSyncCadence
        ) else {
            return .skipped(.coolingDown)
        }

        let sharedDefaults = UserDefaults(suiteName: universeAppGroupID) ?? .standard
        guard !RimeSyncKeyboardActivity.isKeyboardActive(in: sharedDefaults) else {
            Logger.shared.info("rimeSync automatic standard sync skipped keyboardActive=true", category: .config)
            return .skipped(.keyboardActive)
        }

        let startedAt = Date()
        defaults.set(startedAt, forKey: StorageKey.lastAutomaticAttempt)
        let notificationScope: RimeAutomaticSyncScope = automaticPrivateSettingsEnabled
            ? .all
            : .standardRimeData
        setStatus(.syncing(.standardRimeData))
        Logger.shared.info("rimeSync automatic standard sync started", category: .config)
        if automaticSyncNotificationsEnabled {
            await RimeSyncNotificationService.shared.notify(.automaticStarted(notificationScope))
        }

        do {
            try Task.checkCancellation()
            try await synchronizeStandardRimeData()
            try Task.checkCancellation()

            let completedAt: Date
            if automaticPrivateSettingsEnabled {
                setStatus(.syncing(.privateSettings))
                completedAt = try await synchronizePrivateSettings()
                setStatus(.succeeded(completedAt, .standardRimeAndPrivateSettings))
            } else {
                completedAt = standardRimeLastSuccessDate ?? Date()
                setStatus(.succeeded(completedAt, .standardRimeData))
            }
            Logger.shared.info("rimeSync automatic standard sync completed", category: .config)
            if automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.automaticCompleted(notificationScope))
            }
            return .completed(completedAt)
        } catch is CancellationError {
            setStatus(.idle)
            Logger.shared.warning("rimeSync automatic standard sync cancelled", category: .config)
            if automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.automaticFailed(notificationScope))
            }
            return .skipped(.cancelled)
        } catch {
            let didPauseLocalFolderSync = pauseLocalFolderSyncIfNeeded(after: error)
            setStatus(.failed(
                didPauseLocalFolderSync
                    ? "无法访问或写入同步目录。自动同步已暂停，请重新选择一个可写文件夹。"
                    : "自动同步未完成，会在下个同步周期再试。"
            ))
            Logger.shared.error(
                "rimeSync automatic standard sync failed code="
                    + "\(RimeSyncFolderAccess.diagnosticErrorCode(for: error)) "
                    + "localSyncPaused=\(didPauseLocalFolderSync)",
                category: .config
            )
            Logger.shared.requestFlush()
            if automaticSyncNotificationsEnabled {
                await RimeSyncNotificationService.shared.notify(.automaticFailed(notificationScope))
            }
            return .failed
        }
    }

    func setAutomaticSyncEnabled(_ enabled: Bool) {
        guard enabled == false || canEnableAutomaticStandardSync else {
            automaticSyncNotice = "请先完成一次“立即同步”，以确认共享文件夹可用。"
            return
        }

        // 用户主动打开总开关、但此前已关闭全部子项时，恢复为最容易理解的默认状态。
        // 若仍有一个子项开启，则保留用户原来的范围选择。
        if enabled, !hasEnabledAutomaticSyncScope {
            automaticStandardRimeDataEnabled = true
            automaticPrivateSettingsEnabled = true
            defaults.set(true, forKey: StorageKey.automaticStandardRimeDataEnabled)
            defaults.set(true, forKey: StorageKey.automaticPrivateSettingsEnabled)
        }
        automaticSyncEnabled = enabled
        defaults.set(enabled, forKey: StorageKey.automaticSyncEnabled)
        automaticSyncNotice = nil
        RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
    }

    func setAutomaticStandardRimeDataEnabled(_ enabled: Bool) {
        automaticStandardRimeDataEnabled = enabled
        defaults.set(enabled, forKey: StorageKey.automaticStandardRimeDataEnabled)
        disableAutomaticSyncWhenNoScopeRemains()
        RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
    }

    func setAutomaticPrivateSettingsEnabled(_ enabled: Bool) {
        automaticPrivateSettingsEnabled = enabled
        defaults.set(enabled, forKey: StorageKey.automaticPrivateSettingsEnabled)
        disableAutomaticSyncWhenNoScopeRemains()
        RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
    }

    func setAutomaticSyncCadence(_ cadence: RimeAutomaticSyncCadence) {
        automaticSyncCadence = cadence
        defaults.set(cadence.rawValue, forKey: StorageKey.automaticSyncCadence)
        RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
    }

    func setAutomaticSyncNotificationsEnabled(_ enabled: Bool) async {
        guard enabled else {
            automaticSyncNotificationsEnabled = false
            defaults.set(false, forKey: StorageKey.automaticSyncNotificationsEnabled)
            automaticSyncNotice = nil
            return
        }

        let granted = await RimeSyncNotificationService.shared.requestPermission()
        automaticSyncNotificationsEnabled = granted
        defaults.set(granted, forKey: StorageKey.automaticSyncNotificationsEnabled)
        automaticSyncNotice = granted ? nil : "没有通知权限；自动同步仍会继续。"
    }

    func disconnect(deleteRemoteData: Bool) async {
        guard !isSynchronizing else { return }
        do {
            if deleteRemoteData, isConfigured {
                let transport = try await makeTransport()
                try await transport.deleteRemoteData()
            }
            try await secretStore.remove(SecretAccount.webDAVPassword)
            if deleteRemoteData {
                try await secretStore.remove(SecretAccount.encryptionKey)
                recoveryCode = ""
            }
            defaults.removeObject(forKey: StorageKey.provider)
            defaults.removeObject(forKey: StorageKey.webDAVURL)
            defaults.removeObject(forKey: StorageKey.webDAVUsername)
            defaults.removeObject(forKey: StorageKey.folderBookmark)
            defaults.removeObject(forKey: StorageKey.folderName)
            defaults.removeObject(forKey: StorageKey.folderSelectionNeedsRepair)
            defaults.removeObject(forKey: StorageKey.lastSuccess)
            defaults.removeObject(forKey: StorageKey.standardRimeLastSuccess)
            defaults.removeObject(forKey: StorageKey.automaticSyncEnabled)
            defaults.removeObject(forKey: StorageKey.automaticStandardRimeDataEnabled)
            defaults.removeObject(forKey: StorageKey.automaticPrivateSettingsEnabled)
            defaults.removeObject(forKey: StorageKey.automaticSyncCadence)
            defaults.removeObject(forKey: StorageKey.automaticSyncNotificationsEnabled)
            defaults.removeObject(forKey: StorageKey.lastAutomaticAttempt)
            defaults.removeObject(forKey: StorageKey.lastForegroundPrivateAttempt)
            provider = .none
            folderName = nil
            folderSelectionNeedsRepair = false
            webDAVPassword = ""
            lastSuccessDate = nil
            standardRimeLastSuccessDate = nil
            automaticSyncEnabled = false
            automaticStandardRimeDataEnabled = true
            automaticPrivateSettingsEnabled = true
            automaticSyncNotificationsEnabled = false
            automaticSyncNotice = nil
            setStatus(.notConfigured)
            RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
        } catch {
            setStatus(.failed(error.localizedDescription))
        }
    }

    private var isSynchronizing: Bool {
        if case .syncing(_) = status { return true }
        return false
    }

    /// 文件访问被撤销或提供器拒绝写入时，不能在下一次前台自动同步里悄悄回退到
    /// 原目录。保留 bookmark 只为在界面上解释状态，不再把它当作可用同步配置。
    private func pauseLocalFolderSyncIfNeeded(after error: Error) -> Bool {
        guard provider == .localFolder else { return false }

        let needsRepair: Bool
        if let syncError = error as? RimeSyncError {
            needsRepair = syncError == .accessDenied
        } else if let standardError = error as? RimeStandardSyncError {
            needsRepair = standardError == .unavailableSyncDirectory
        } else {
            needsRepair = false
        }

        guard needsRepair else { return false }
        folderSelectionNeedsRepair = true
        defaults.set(true, forKey: StorageKey.folderSelectionNeedsRepair)
        return true
    }

    private func synchronizePrivateSettings() async throws -> Date {
        let keyData = try await encryptionKey()
        let transport = try await makeTransport()
        rimeStore.load()

        let baseline = loadProfile()
        let localProfile = baseline.updating(
            values: rimeStore.portableSyncValues(),
            deviceID: deviceID
        )
        let result = try await coordinator.synchronize(
            localProfile: localProfile,
            keyData: keyData,
            transport: transport
        )
        try saveProfile(result.profile)
        await rimeStore.applyPortableSyncValues(result.profile.scalarValues)

        let completedAt = Date()
        lastSuccessDate = completedAt
        defaults.set(completedAt, forKey: StorageKey.lastSuccess)
        return completedAt
    }

    private func handleManualStandardSyncSuccess(isFirstStandardSync: Bool) {
        guard canEnableAutomaticStandardSync else { return }

        if isFirstStandardSync {
            automaticSyncNotice = "共享文件夹已确认。需要自动更新时，请在下方自行开启“自动同步”。"
        }
        // 手动同步是自动模式的安全起点；冷却时间从这次尝试开始，避免刚完成就重复执行。
        defaults.set(Date(), forKey: StorageKey.lastAutomaticAttempt)
        defaults.set(Date(), forKey: StorageKey.lastForegroundPrivateAttempt)
        RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
    }

    private func disableAutomaticSyncWhenNoScopeRemains() {
        guard !hasEnabledAutomaticSyncScope else {
            automaticSyncNotice = nil
            return
        }

        automaticSyncEnabled = false
        defaults.set(false, forKey: StorageKey.automaticSyncEnabled)
        automaticSyncNotice = "两项自动同步内容都已关闭，自动同步也已关闭。"
    }

    /// 新文件夹意味着新的 RIME `sync_dir`；不能把旧目录的一次确认当作新目录的授权。
    private func resetAutomaticStandardSyncEligibility() {
        automaticSyncEnabled = false
        automaticSyncNotificationsEnabled = false
        automaticSyncNotice = nil
        standardRimeLastSuccessDate = nil
        defaults.set(false, forKey: StorageKey.automaticSyncEnabled)
        defaults.set(false, forKey: StorageKey.automaticSyncNotificationsEnabled)
        defaults.removeObject(forKey: StorageKey.automaticStandardRimeDataEnabled)
        defaults.removeObject(forKey: StorageKey.automaticPrivateSettingsEnabled)
        defaults.removeObject(forKey: StorageKey.lastAutomaticAttempt)
        defaults.removeObject(forKey: StorageKey.lastForegroundPrivateAttempt)
        defaults.removeObject(forKey: StorageKey.standardRimeLastSuccess)
        RimeAutomaticSyncScheduler.shared.refreshSchedule(defaults: defaults)
    }

    private func synchronizeStandardRimeData() async throws {
        guard let directories = RimeConfigManager.runtimeDirectories() else {
            throw RimeStandardSyncError.unavailableUserDirectory
        }
        let syncDirectoryURL = try selectedFolderURL()

        // 先把本 App 当前管理的选项刷新成 RIME 标准 .custom.yaml，
        // 再交给 librime 进行快照合并与 YAML/TXT 备份。
        await Task.detached(priority: .userInitiated) {
            RimeConfigManager.syncCustomYamlFiles()
        }.value

        try await standardRimeSyncService.synchronize(
            RimeStandardSyncRequest(
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir, isDirectory: true),
                userDataURL: URL(fileURLWithPath: directories.userDir, isDirectory: true),
                syncDirectoryURL: syncDirectoryURL,
                installationID: standardRimeInstallationID
            )
        )

        let completedAt = Date()
        standardRimeLastSuccessDate = completedAt
        defaults.set(completedAt, forKey: StorageKey.standardRimeLastSuccess)
    }

    private var deviceID: String {
        if let existing = defaults.string(forKey: StorageKey.deviceID) { return existing }
        let generated = UUID().uuidString.lowercased()
        defaults.set(generated, forKey: StorageKey.deviceID)
        return generated
    }

    private var standardRimeInstallationID: String {
        "universe-ios-\(deviceID)"
    }

    private func ensureEncryptionKey() async throws {
        if let existing = try await secretStore.data(for: SecretAccount.encryptionKey) {
            recoveryCode = RimeSyncPackageCodec.recoveryCode(for: existing)
            return
        }
        let generated = RimeSyncPackageCodec.generateKey()
        try await secretStore.set(generated, for: SecretAccount.encryptionKey)
        recoveryCode = RimeSyncPackageCodec.recoveryCode(for: generated)
    }

    private func encryptionKey() async throws -> Data {
        guard let key = try await secretStore.data(for: SecretAccount.encryptionKey) else {
            throw RimeSyncError.missingEncryptionKey
        }
        return key
    }

    private func makeTransport() async throws -> any RimeSyncTransport {
        switch provider {
        case .none:
            throw RimeSyncError.notConfigured
        case .localFolder:
            return LocalFolderRimeSyncTransport(selectedFolderURL: try selectedFolderURL())
        case .webDAV:
            guard let parentURL = normalizedWebDAVURL() else { throw RimeSyncError.invalidServerURL }
            guard let passwordData = try await secretStore.data(for: SecretAccount.webDAVPassword) else {
                throw RimeSyncError.missingCredentials
            }
            let password = String(decoding: passwordData, as: UTF8.self)
            let rootURL = parentURL.appendingPathComponent("universe-rime-sync", isDirectory: true)
            return WebDAVRimeSyncTransport(
                baseURL: rootURL,
                username: webDAVUsername,
                password: password
            )
        }
    }

    private func selectedFolderURL() throws -> URL {
        guard let bookmark = defaults.data(forKey: StorageKey.folderBookmark) else {
            throw RimeSyncError.notConfigured
        }
        var stale = false
        let url = try URL(
            resolvingBookmarkData: bookmark,
            // iOS 的文件选择器 bookmark 带有临时安全作用域。这里禁止解析时
            // 隐式开始访问，确保每次同步都由 transport/service 成对地开始和结束。
            options: [.withoutUI, .withoutImplicitStartAccessing],
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        )
        if stale {
            let renewed = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
            defaults.set(renewed, forKey: StorageKey.folderBookmark)
        }
        return url
    }

    private func loadProfile() -> RimeSyncProfile {
        guard let data = defaults.data(forKey: StorageKey.profile),
              let profile = try? JSONDecoder().decode(RimeSyncProfile.self, from: data)
        else {
            return RimeSyncProfile()
        }
        return profile
    }

    private func saveProfile(_ profile: RimeSyncProfile) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        defaults.set(try encoder.encode(profile), forKey: StorageKey.profile)
    }

    private func normalizedWebDAVURL() -> URL? {
        let trimmed = webDAVURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              components.host != nil,
              components.user == nil,
              components.password == nil
        else {
            return nil
        }
        components.path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .isEmpty ? "" : "/" + components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return components.url
    }

    private func isSecure(_ url: URL) -> Bool {
        if url.scheme?.lowercased() == "https" { return true }
        return ["localhost", "127.0.0.1", "::1"].contains(url.host?.lowercased() ?? "")
    }

    private func setStatus(_ newStatus: RimeSyncStatus) {
        status = newStatus
        statusVersion += 1
    }

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        return formatter
    }()
}
