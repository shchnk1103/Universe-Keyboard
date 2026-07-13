import Foundation
import KeyboardCore
import Observation
import SwiftUI

@MainActor
protocol RimeSettingsPersisting {
    func string(forKey key: String) -> String?
    func integer(forKey key: String) -> Int
    func bool(forKey key: String) -> Bool
    func hasValue(forKey key: String) -> Bool
    func set(_ value: Any?, forKey key: String)
    func synchronize()
}

@MainActor
struct SharedDefaultsRimeSettingsPersistence: RimeSettingsPersisting {
    private let defaults =
        UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard") ?? .standard

    func string(forKey key: String) -> String? { defaults.string(forKey: key) }
    func integer(forKey key: String) -> Int { defaults.integer(forKey: key) }
    func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func hasValue(forKey key: String) -> Bool { defaults.object(forKey: key) != nil }
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func synchronize() { defaults.synchronize() }
}

enum RimeDeploymentState {
    case idle, needsDeploy, triggered, deploying, deployed, failed

    var icon: String {
        switch self {
        case .idle: return "circle"
        case .needsDeploy: return "exclamationmark.circle.fill"
        case .triggered: return "hourglass"
        case .deploying: return "arrow.triangle.2.circlepath"
        case .deployed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .idle, .needsDeploy, .triggered: return .orange
        case .deploying: return .primary
        case .deployed: return .green
        case .failed: return .red
        }
    }

    var label: String {
        switch self {
        case .idle: return "未部署"
        case .needsDeploy: return "需重新部署"
        case .triggered: return "准备部署…"
        case .deploying: return "正在部署…"
        case .deployed: return "已部署"
        case .failed: return "部署失败"
        }
    }
}

enum RimeUserDictionaryStatusSymbol: Equatable {
    case unavailable
    case off
    case empty
    case ready
    case upToDate
    case changed
    case warning
}

enum RimeAdvancedInputRecoveryAction: Equatable {
    case setCurrentSchema
    case applySettings
    case redownloadSchema

    var title: String {
        switch self {
        case .setCurrentSchema: return "设为当前方案"
        case .applySettings: return "重新部署"
        case .redownloadSchema: return "重新下载雾凇拼音"
        }
    }

    var systemImage: String {
        switch self {
        case .setCurrentSchema: return "keyboard"
        case .applySettings: return "arrow.triangle.2.circlepath"
        case .redownloadSchema: return "arrow.down.circle"
        }
    }
}

@MainActor
@Observable
final class RimeSettingsStore {
    private enum UserDictionaryAutoBackup {
        static let enabledKey = "rime_user_dict_auto_backup_enabled"
        static let throttleInterval: TimeInterval = 12 * 60 * 60

        static func lastRunKey(for schemaID: String) -> String {
            "rime_user_dict_auto_backup_last_run_\(schemaID)"
        }
    }

    private let schemaManager: SchemaManager
    private let persistence: any RimeSettingsPersisting
    private let userDictionaryBackupService: any RimeUserDictionaryBackingUp
    var pageSize: Double = 9
    var simplified = true
    var fuzzyEnabled = true
    var fuzzyZhZEnabled = true
    var fuzzyChCEnabled = true
    var fuzzyShSEnabled = true
    var fuzzyNLEnabled = true
    var advancedInputMasterEnabled = true
    var advancedInputFeatureEnabled: [RimeAdvancedInputFeature: Bool] = Dictionary(
        uniqueKeysWithValues: RimeAdvancedInputFeature.allCases.map { ($0, true) }
    )
    var lunaPinyinUserDictionaryEnabled = true
    var rimeIceUserDictionaryEnabled = true
    var userDictionaryAutoBackupEnabled = false
    var deploymentState: RimeDeploymentState = .idle
    var deploymentLog: [String] = []
    var updateStatusMessage: String?
    var userDictionaryMessage: String?
    var userDictionaryMessageSucceeded = true
    var userDictionaryMessageVersion = 0

    init(
        schemaManager: SchemaManager = SchemaManager(),
        persistence: any RimeSettingsPersisting = SharedDefaultsRimeSettingsPersistence(),
        userDictionaryBackupService: any RimeUserDictionaryBackingUp = AppGroupRimeUserDictionaryBackupService()
    ) {
        self.schemaManager = schemaManager
        self.persistence = persistence
        self.userDictionaryBackupService = userDictionaryBackupService
    }

    var schemas: [SchemaMetadata] { schemaManager.schemas }
    var activeSchemaID: String { schemaManager.activeSchemaID }
    var downloadState: DownloadState { schemaManager.rimeIceDownloadState }
    var licenseAccepted: Bool { schemaManager.rimeIceLicenseAccepted }
    var rimeIceVersion: String? { schemaManager.rimeIceVersion }
    var isRimeIceInstalled: Bool {
        schemas.contains { $0.schemaID == "rime_ice" && $0.installed }
    }

    var deploymentStatusHint: String {
        switch deploymentState {
        case .idle: return "修改设置后需重新部署方可生效"
        case .needsDeploy: return "设置已修改，请点击「应用并重新部署」"
        case .triggered: return "主 App 正在准备配置文件…"
        case .deploying: return "主 App 正在编译配置和词库…"
        case .deployed: return "配置已生效 ✓"
        case .failed: return "部署失败，请留在主 App 中重试"
        }
    }

    func licenseAccepted(for schemaID: String) -> Bool {
        schemaManager.licenseAccepted(for: schemaID)
    }

    func load() {
        let savedPageSize = persistence.integer(forKey: "rime_page_size")
        pageSize = Double(savedPageSize > 0 ? savedPageSize : 9)
        simplified =
            persistence.hasValue(forKey: "rime_simplification")
            ? persistence.bool(forKey: "rime_simplification") : true
        fuzzyEnabled = boolPreference(forKey: RimeFuzzyPinyinSettings.enabledKey, defaultValue: true)
        fuzzyZhZEnabled = boolPreference(forKey: RimeFuzzyPinyinSettings.zhZKey, defaultValue: true)
        fuzzyChCEnabled = boolPreference(forKey: RimeFuzzyPinyinSettings.chCKey, defaultValue: true)
        fuzzyShSEnabled = boolPreference(forKey: RimeFuzzyPinyinSettings.shSKey, defaultValue: true)
        fuzzyNLEnabled = boolPreference(forKey: RimeFuzzyPinyinSettings.nLKey, defaultValue: true)
        advancedInputMasterEnabled = boolPreference(
            forKey: RimeAdvancedInputSettings.masterEnabledKey,
            defaultValue: true
        )
        advancedInputFeatureEnabled = Dictionary(
            uniqueKeysWithValues: RimeAdvancedInputFeature.allCases.map { feature in
                (
                    feature,
                    boolPreference(
                        forKey: RimeAdvancedInputSettings.enabledKey(for: feature),
                        defaultValue: true
                    )
                )
            }
        )
        lunaPinyinUserDictionaryEnabled = boolPreference(
            forKey: RimeUserDictionarySettings.lunaPinyinEnabledKey,
            defaultValue: true
        )
        rimeIceUserDictionaryEnabled = boolPreference(
            forKey: RimeUserDictionarySettings.rimeIceEnabledKey,
            defaultValue: true
        )
        userDictionaryAutoBackupEnabled = boolPreference(
            forKey: UserDictionaryAutoBackup.enabledKey,
            defaultValue: false
        )
        refreshDeploymentState()
    }

    func stop() {}

    func savePreferences() {
        persistence.set(Int(pageSize), forKey: "rime_page_size")
        persistence.set(simplified, forKey: "rime_simplification")
        persistence.synchronize()
    }

    func saveFuzzyPinyinSettings() {
        persistence.set(fuzzyEnabled, forKey: RimeFuzzyPinyinSettings.enabledKey)
        persistence.set(fuzzyZhZEnabled, forKey: RimeFuzzyPinyinSettings.zhZKey)
        persistence.set(fuzzyChCEnabled, forKey: RimeFuzzyPinyinSettings.chCKey)
        persistence.set(fuzzyShSEnabled, forKey: RimeFuzzyPinyinSettings.shSKey)
        persistence.set(fuzzyNLEnabled, forKey: RimeFuzzyPinyinSettings.nLKey)
        updateFuzzyDeploymentIntent()
    }

    func saveAdvancedInputSettings() {
        persistence.set(advancedInputMasterEnabled, forKey: RimeAdvancedInputSettings.masterEnabledKey)
        for feature in RimeAdvancedInputFeature.allCases {
            persistence.set(
                isAdvancedInputFeatureEnabled(feature),
                forKey: RimeAdvancedInputSettings.enabledKey(for: feature)
            )
        }
        updateAdvancedInputDeploymentIntent()
    }

    func saveUserDictionarySettings() {
        persistence.set(
            lunaPinyinUserDictionaryEnabled,
            forKey: RimeUserDictionarySettings.lunaPinyinEnabledKey
        )
        persistence.set(
            rimeIceUserDictionaryEnabled,
            forKey: RimeUserDictionarySettings.rimeIceEnabledKey
        )
        updateUserDictionaryDeploymentIntent()
    }

    func saveUserDictionaryAutoBackupSetting() {
        persistence.set(userDictionaryAutoBackupEnabled, forKey: UserDictionaryAutoBackup.enabledKey)
        persistence.synchronize()
    }

    func userDictionaryLearningStatusText(for schemaID: String) -> String {
        if schemaID == "rime_ice" && !isRimeIceInstalled {
            return "安装雾凇拼音后可用。"
        }
        if !isUserDictionaryEnabled(for: schemaID) {
            return "已关闭：键盘不会调整这个方案的候选顺序。"
        }
        switch deploymentState {
        case .needsDeploy:
            return "等待应用：设置会自动生效。"
        case .triggered, .deploying:
            return "正在应用：完成后键盘会按你的选择学习。"
        case .failed:
            return "应用失败：请回到主 App 后重试。"
        case .idle, .deployed:
            return "已开启：键盘会记住你常选的词。"
        }
    }

    func userDictionaryBackupStatusText(for schemaID: String) -> String {
        if schemaID == "rime_ice" && !isRimeIceInstalled {
            return "安装雾凇拼音后可用。"
        }
        let status = userDictionaryBackupService.status(for: schemaID)
        switch status.readiness {
        case .noLearningData:
            return "暂无学习记录，暂时不用备份。"
        case .needsInitialBackup:
            return "已有学习记录，可以先备份一份。"
        case .upToDate:
            return "已备份，暂无新的学习记录。"
        case .hasNewLearningData:
            return "有新的学习记录，可以更新备份。"
        case .unknown:
            if let date = status.latestBackupDate {
                return "无法确认是否有新变化，可以重新备份。最近备份：\(Self.backupDateFormatter.string(from: date))"
            }
            return "无法确认是否有新变化，可以重新备份。"
        }
    }

    func userDictionaryListStatusText(for schemaID: String) -> String {
        if schemaID == "rime_ice" && !isRimeIceInstalled {
            return "安装后可用"
        }
        guard isUserDictionaryEnabled(for: schemaID) else {
            return "已关闭"
        }

        switch userDictionaryBackupService.status(for: schemaID).readiness {
        case .noLearningData:
            return "已开启 · 暂无学习记录"
        case .needsInitialBackup:
            return "已开启 · 可以备份"
        case .upToDate:
            return "已开启 · 已备份"
        case .hasNewLearningData:
            return "已开启 · 有新的学习记录"
        case .unknown:
            return "已开启 · 可重新备份"
        }
    }

    func userDictionaryStatusSymbol(for schemaID: String) -> RimeUserDictionaryStatusSymbol {
        if schemaID == "rime_ice" && !isRimeIceInstalled {
            return .unavailable
        }
        guard isUserDictionaryEnabled(for: schemaID) else {
            return .off
        }

        switch userDictionaryBackupService.status(for: schemaID).readiness {
        case .noLearningData:
            return .empty
        case .needsInitialBackup:
            return .ready
        case .upToDate:
            return .upToDate
        case .hasNewLearningData:
            return .changed
        case .unknown:
            return .warning
        }
    }

    func rimeIceAdvancedInputDiagnostic(logResult: Bool = false) -> RimeLuaCapabilityDiagnostic {
        schemaManager.rimeIceLuaCapabilityDiagnostic(logResult: logResult)
    }

    func isAdvancedInputFeatureEnabled(_ feature: RimeAdvancedInputFeature) -> Bool {
        advancedInputFeatureEnabled[feature] ?? true
    }

    func setAdvancedInputFeature(_ feature: RimeAdvancedInputFeature, enabled: Bool) {
        advancedInputFeatureEnabled[feature] = enabled
        saveAdvancedInputSettings()
    }

    func supportedAdvancedInputFeatures(for schemaID: String) -> Set<RimeAdvancedInputFeature> {
        schemaID == "rime_ice" ? Set(RimeAdvancedInputFeature.allCases) : []
    }

    func advancedInputFeatureIsSupported(_ feature: RimeAdvancedInputFeature) -> Bool {
        supportedAdvancedInputFeatures(for: activeSchemaID).contains(feature)
    }

    var activeSchemaSupportsAdvancedInput: Bool {
        !supportedAdvancedInputFeatures(for: activeSchemaID).isEmpty
    }

    var activeSchemaAdvancedInputStatusText: String {
        let schemaName = displayName(forSchemaID: activeSchemaID)
        guard activeSchemaSupportsAdvancedInput else {
            return "\(schemaName) 暂不支持这些高级输入功能。你的选择会保留，切换到支持的方案后可用。"
        }

        if !advancedInputMasterEnabled {
            return "高级输入功能已关闭。基础拼音输入不受影响。"
        }

        switch deploymentState {
        case .needsDeploy:
            return "设置已修改，重新部署后在键盘中生效。"
        case .triggered, .deploying:
            return "正在应用设置，完成后回到键盘即可使用。"
        case .failed:
            return "设置应用失败，请重新部署后再试。"
        case .idle, .deployed:
            return "\(schemaName) 支持这些高级输入功能。"
        }
    }

    func advancedInputStatusText(for diagnostic: RimeLuaCapabilityDiagnostic) -> String {
        if diagnostic.status == .available, !advancedInputMasterEnabled {
            return "未开启"
        }

        switch diagnostic.status {
        case .available:
            return "基础检查通过"
        case .notInstalled:
            return "安装后可用"
        case .inactiveSchema:
            return "未使用"
        case .needsDeploy:
            return "需要重新部署"
        case .engineUnavailable, .runtimeModuleMissing, .schemaMissing, .schemaStripped, .luaFilesMissing:
            return "暂不可用"
        }
    }

    func advancedInputStatusDetail(for diagnostic: RimeLuaCapabilityDiagnostic) -> String {
        if diagnostic.status == .available, !advancedInputMasterEnabled {
            return "高级输入功能已关闭。基础拼音输入可以继续使用。"
        }

        switch diagnostic.status {
        case .available:
            return "文件、部署和基础动态候选检查正常；日期、时间等高级输入可以使用。"
        case .notInstalled:
            return "安装雾凇拼音后，可以检查日期、时间、计算器等高级输入功能。"
        case .inactiveSchema:
            return "当前键盘没有使用雾凇拼音。设为当前方案并应用后，再检查高级输入功能。"
        case .needsDeploy:
            return "雾凇拼音文件已准备好，但最新设置还没有应用到 RIME。"
        case .engineUnavailable:
            return "当前键盘引擎未启用高级输入能力，基础输入仍可继续使用。"
        case .runtimeModuleMissing:
            return "当前键盘没有加载高级输入能力，日期、时间等动态候选不会出现。请重新部署后检查诊断日志。"
        case .schemaMissing:
            return "没有找到雾凇拼音配置文件，基础输入可能会回退到其他方案。"
        case .schemaStripped:
            return "当前安装缺少高级输入配置，需要重新下载完整的雾凇拼音文件。"
        case .luaFilesMissing:
            return "当前安装缺少高级输入脚本，需要重新下载完整的雾凇拼音文件。"
        }
    }

    func advancedInputRecoveryAction(for diagnostic: RimeLuaCapabilityDiagnostic) -> RimeAdvancedInputRecoveryAction? {
        switch diagnostic.status {
        case .inactiveSchema:
            return .setCurrentSchema
        case .needsDeploy:
            return .applySettings
        case .schemaMissing, .schemaStripped, .luaFilesMissing:
            return .redownloadSchema
        case .available, .notInstalled, .engineUnavailable, .runtimeModuleMissing:
            return nil
        }
    }

    func userDictionaryHasBackup(for schemaID: String) -> Bool {
        userDictionaryBackupService.status(for: schemaID).latestBackupDate != nil
    }

    func userDictionaryCanBackup(for schemaID: String) -> Bool {
        userDictionaryBackupService.status(for: schemaID).canBackup
    }

    func backupUserDictionary(for schemaID: String) {
        let name = displayName(forSchemaID: schemaID)
        let result = userDictionaryBackupService.backup(schemaID: schemaID, displayName: name)
        presentUserDictionaryMessage(result.message, succeeded: result.succeeded)
    }

    func runAutomaticUserDictionaryBackupIfNeeded() {
        guard userDictionaryAutoBackupEnabled else { return }
        let backedUpNames = ["luna_pinyin", "rime_ice"].compactMap { schemaID -> String? in
            guard schemaID != "rime_ice" || isRimeIceInstalled else { return nil }
            guard shouldRunAutomaticBackup(for: schemaID) else { return nil }
            let status = userDictionaryBackupService.status(for: schemaID)
            guard status.canBackup else { return nil }

            let name = displayName(forSchemaID: schemaID)
            let result = userDictionaryBackupService.backup(schemaID: schemaID, displayName: name)
            guard result.succeeded else { return nil }
            persistence.set(Int(Date().timeIntervalSince1970), forKey: UserDictionaryAutoBackup.lastRunKey(for: schemaID))
            return name
        }

        guard !backedUpNames.isEmpty else { return }
        persistence.synchronize()
        presentUserDictionaryMessage(
            "已自动备份 \(backedUpNames.joined(separator: "、")) 的学习记录。",
            succeeded: true
        )
    }

    func restoreLatestUserDictionaryBackup(for schemaID: String) {
        let name = displayName(forSchemaID: schemaID)
        let result = userDictionaryBackupService.restoreLatest(schemaID: schemaID, displayName: name)
        presentUserDictionaryMessage(result.message, succeeded: result.succeeded)
        guard result.succeeded else { return }
        persistence.set(true, forKey: RimeUserDictionarySettings.pendingDeployKey)
        markDeploymentNeeded(reason: "\(name) 的学习记录已恢复")
    }

    func switchToSchema(_ schemaID: String) async {
        schemaManager.switchToSchema(schemaID)
        await triggerDeployment()
    }
    func acceptLicense() { acceptLicense(for: "rime_ice") }
    func acceptLicense(for schemaID: String) { schemaManager.acceptLicense(for: schemaID) }
    func startDownload() { startDownload(schemaID: "rime_ice") }
    func startDownload(schemaID: String) { schemaManager.startDownload(schemaID: schemaID) }
    func cancelDownload() { schemaManager.cancelDownload() }
    func forceRedownload() { forceRedownload(schemaID: "rime_ice") }
    func forceRedownload(schemaID: String) {
        updateStatusMessage = nil
        schemaManager.forceRedownload(schemaID: schemaID)
    }
    func uninstallRimeIce() { uninstallSchema("rime_ice") }
    func uninstallSchema(_ schemaID: String) { schemaManager.uninstallSchema(schemaID) }

    func checkForUpdateAndDownload() async {
        await checkForUpdateAndDownload(schemaID: "rime_ice")
    }

    func checkForUpdateAndDownload(schemaID: String) async {
        updateStatusMessage = nil
        guard await schemaManager.checkForUpdate(schemaID: schemaID) else {
            updateStatusMessage = "已是最新版本"
            return
        }
        schemaManager.startDownload(schemaID: schemaID)
    }

    func handleDownloadStateChange() {
        switch downloadState {
        case .deploying:
            guard deploymentState != .deploying else { return }
            deploymentState = .deploying
            deploymentLog = ["→ 正在部署下载后的 RIME 方案"]
        case .completed:
            deploymentState = .deployed
            deploymentLog = ["✓ RIME 方案已下载并部署"]
        case .failed where deploymentState == .deploying:
            deploymentState = .failed
            deploymentLog = ["✗ RIME 方案部署失败"]
        case .failed:
            refreshDeploymentState()
        case .idle, .fetchingReleaseInfo, .downloading, .extracting, .postProcessing:
            refreshDeploymentState()
        }
    }

    func triggerDeployment() async {
        guard deploymentState != .triggered, deploymentState != .deploying else { return }
        deploymentState = .triggered
        deploymentLog = []
        appendDeploymentLog("→ 主 App 正在准备部署")
        deploymentState = .deploying
        appendDeploymentLog("→ 主 App 正在编译配置和词库…")

        if await schemaManager.deployRimeConfig() {
            deploymentState = .deployed
            appendDeploymentLog("✓ 部署成功，键盘可直接使用")
        } else {
            deploymentState = .failed
            appendDeploymentLog("✗ 部署失败，请在主 App 中重试")
        }
    }

    func triggerPendingDeploymentIfNeeded() async {
        guard hasPendingDeploymentIntent else { return }
        guard deploymentState != .triggered, deploymentState != .deploying else { return }
        await triggerDeployment()
    }

    func triggerFuzzyDeploymentIfNeeded() async {
        await triggerPendingDeploymentIfNeeded()
    }

    func resetUserDictionary(for schemaID: String) {
        let name = displayName(forSchemaID: schemaID)
        let result = userDictionaryBackupService.resetLearningData(schemaID: schemaID, displayName: name)
        presentUserDictionaryMessage(result.message, succeeded: result.succeeded)
        guard result.succeeded else { return }

        persistence.set(true, forKey: RimeUserDictionarySettings.pendingDeployKey)
        markDeploymentNeeded(reason: "\(name) 的学习记录已清空")
    }

    func cancelDeployment() {
        guard deploymentState == .failed else { return }
        resetDeploymentStatus()
    }

    func resetDeploymentStatus() {
        deploymentLog = []
        deploymentState = .idle
    }

    func refreshDeploymentState() {
        if persistence.bool(forKey: "rime_deployed") {
            deploymentState = .deployed
            deploymentLog = ["✓ RIME 已部署"]
        } else if persistence.bool(forKey: "rime_deploying") {
            deploymentState = .deploying
        } else if persistence.bool(forKey: "rime_needs_deploy") {
            deploymentState = .needsDeploy
        }
    }

    private func boolPreference(forKey key: String, defaultValue: Bool) -> Bool {
        persistence.hasValue(forKey: key) ? persistence.bool(forKey: key) : defaultValue
    }

    private var currentFuzzySettings: RimeFuzzyPinyinSettings {
        RimeFuzzyPinyinSettings(
            enabled: fuzzyEnabled,
            zhZEnabled: fuzzyZhZEnabled,
            chCEnabled: fuzzyChCEnabled,
            shSEnabled: fuzzyShSEnabled,
            nLEnabled: fuzzyNLEnabled
        )
    }

    private var currentUserDictionarySettings: RimeUserDictionarySettings {
        RimeUserDictionarySettings(
            lunaPinyinEnabled: lunaPinyinUserDictionaryEnabled,
            rimeIceEnabled: rimeIceUserDictionaryEnabled
        )
    }

    private var currentAdvancedInputSettings: RimeAdvancedInputSettings {
        RimeAdvancedInputSettings(
            masterEnabled: advancedInputMasterEnabled,
            featureEnabled: advancedInputFeatureEnabled
        )
    }

    private var hasPendingDeploymentIntent: Bool {
        persistence.bool(forKey: RimeFuzzyPinyinSettings.pendingDeployKey)
            || persistence.bool(forKey: RimeUserDictionarySettings.pendingDeployKey)
            || persistence.bool(forKey: RimeAdvancedInputSettings.pendingDeployKey)
    }

    private static var backupDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    private func updateFuzzyDeploymentIntent() {
        let signature = currentFuzzySettings.deploymentSignature(activeSchemaID: activeSchemaID)
        let deployedSignature = persistence.string(forKey: RimeFuzzyPinyinSettings.deployedSignatureKey)
        if signature == deployedSignature {
            let wasFuzzyPending = persistence.bool(forKey: RimeFuzzyPinyinSettings.pendingDeployKey)
            persistence.set(false, forKey: RimeFuzzyPinyinSettings.pendingDeployKey)
            if wasFuzzyPending {
                persistence.set(true, forKey: "rime_deployed")
                persistence.set(false, forKey: "rime_needs_deploy")
                deploymentState = .deployed
                deploymentLog = ["✓ 模糊音设置与当前部署一致"]
            }
            persistence.synchronize()
            return
        }

        persistence.set(true, forKey: RimeFuzzyPinyinSettings.pendingDeployKey)
        markDeploymentNeeded(reason: "模糊音设置已修改")
    }

    private func updateUserDictionaryDeploymentIntent() {
        let signature = currentUserDictionarySettings.deploymentSignature()
        let deployedSignature = persistence.string(forKey: RimeUserDictionarySettings.deployedSignatureKey)
        if signature == deployedSignature {
            let wasPending = persistence.bool(forKey: RimeUserDictionarySettings.pendingDeployKey)
            persistence.set(false, forKey: RimeUserDictionarySettings.pendingDeployKey)
            if wasPending && !hasPendingDeploymentIntent {
                persistence.set(true, forKey: "rime_deployed")
                persistence.set(false, forKey: "rime_needs_deploy")
                deploymentState = .deployed
                deploymentLog = ["✓ 候选学习设置与当前部署一致"]
            }
            persistence.synchronize()
            return
        }

        persistence.set(true, forKey: RimeUserDictionarySettings.pendingDeployKey)
        markDeploymentNeeded(reason: "候选学习设置已修改")
    }

    private func updateAdvancedInputDeploymentIntent() {
        let signature = currentAdvancedInputSettings.deploymentSignature(
            activeSchemaID: activeSchemaID,
            supportedFeatures: supportedAdvancedInputFeatures(for: activeSchemaID)
        )
        let deployedSignature = persistence.string(forKey: RimeAdvancedInputSettings.deployedSignatureKey)
        if signature == deployedSignature {
            let wasPending = persistence.bool(forKey: RimeAdvancedInputSettings.pendingDeployKey)
            persistence.set(false, forKey: RimeAdvancedInputSettings.pendingDeployKey)
            if wasPending && !hasPendingDeploymentIntent {
                persistence.set(true, forKey: "rime_deployed")
                persistence.set(false, forKey: "rime_needs_deploy")
                deploymentState = .deployed
                deploymentLog = ["✓ 高级输入功能设置与当前部署一致"]
            }
            persistence.synchronize()
            return
        }

        persistence.set(true, forKey: RimeAdvancedInputSettings.pendingDeployKey)
        markDeploymentNeeded(reason: "高级输入功能设置已修改")
    }

    private func isUserDictionaryEnabled(for schemaID: String) -> Bool {
        switch schemaID {
        case "rime_ice":
            return rimeIceUserDictionaryEnabled
        default:
            return lunaPinyinUserDictionaryEnabled
        }
    }

    private func shouldRunAutomaticBackup(for schemaID: String) -> Bool {
        let lastRun = persistence.integer(forKey: UserDictionaryAutoBackup.lastRunKey(for: schemaID))
        guard lastRun > 0 else { return true }
        return Date().timeIntervalSince1970 - TimeInterval(lastRun) >= UserDictionaryAutoBackup.throttleInterval
    }

    private func presentUserDictionaryMessage(_ message: String, succeeded: Bool) {
        userDictionaryMessage = message
        userDictionaryMessageSucceeded = succeeded
        userDictionaryMessageVersion += 1
    }

    private func displayName(forSchemaID schemaID: String) -> String {
        schemas.first(where: { $0.schemaID == schemaID })?.name
            ?? (schemaID == "rime_ice" ? "雾凇拼音" : "朙月拼音")
    }

    private func markDeploymentNeeded(reason: String) {
        persistence.set(false, forKey: "rime_deployed")
        persistence.set(true, forKey: "rime_needs_deploy")
        persistence.synchronize()
        deploymentState = .needsDeploy
        deploymentLog = ["→ \(reason)，应用完成后生效"]
    }

    private func appendDeploymentLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        deploymentLog.append("[\(formatter.string(from: Date()))] \(message)")
    }
}
