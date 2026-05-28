import Foundation
import Observation
import SwiftUI

@MainActor
protocol RimeSettingsPersisting {
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

    func integer(forKey key: String) -> Int { defaults.integer(forKey: key) }
    func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func hasValue(forKey key: String) -> Bool { defaults.object(forKey: key) != nil }
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func synchronize() { defaults.synchronize() }
}

enum RimeDeploymentState {
    case idle, triggered, deploying, deployed, failed

    var icon: String {
        switch self {
        case .idle: return "circle"
        case .triggered: return "hourglass"
        case .deploying: return "arrow.triangle.2.circlepath"
        case .deployed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .idle, .triggered: return .orange
        case .deploying: return .primary
        case .deployed: return .green
        case .failed: return .red
        }
    }

    var label: String {
        switch self {
        case .idle: return "未部署"
        case .triggered: return "准备部署…"
        case .deploying: return "正在部署…"
        case .deployed: return "已部署"
        case .failed: return "部署失败"
        }
    }
}

@MainActor
@Observable
final class RimeSettingsStore {
    private let schemaManager: SchemaManager
    private let persistence: any RimeSettingsPersisting
    var pageSize: Double = 9
    var simplified = true
    var deploymentState: RimeDeploymentState = .idle
    var deploymentLog: [String] = []

    init(
        schemaManager: SchemaManager = SchemaManager(),
        persistence: any RimeSettingsPersisting = SharedDefaultsRimeSettingsPersistence()
    ) {
        self.schemaManager = schemaManager
        self.persistence = persistence
    }

    var schemas: [SchemaMetadata] { schemaManager.schemas }
    var activeSchemaID: String { schemaManager.activeSchemaID }
    var downloadState: DownloadState { schemaManager.rimeIceDownloadState }
    var licenseAccepted: Bool { schemaManager.rimeIceLicenseAccepted }
    var rimeIceVersion: String? { schemaManager.rimeIceVersion }
    var isRimeIceInstalled: Bool {
        schemas.contains { $0.schemaID == "rime_ice" && $0.installed }
    }

    var isShowingDownloadProgress: Bool {
        switch downloadState {
        case .fetchingReleaseInfo, .downloading, .extracting, .postProcessing, .deploying:
            return true
        default:
            return false
        }
    }

    var downloadStatusLabel: String {
        switch downloadState {
        case .fetchingReleaseInfo: return "正在获取最新版本信息…"
        case .downloading(let progress): return "正在下载… \(Int(progress * 100))%"
        case .extracting: return "正在解压配置文件…"
        case .postProcessing: return "正在处理配置…"
        case .deploying: return "正在编译词库…"
        default: return "准备中…"
        }
    }

    var deploymentStatusHint: String {
        switch deploymentState {
        case .idle: return "修改设置后需重新部署方可生效"
        case .triggered: return "主 App 正在准备配置文件…"
        case .deploying: return "主 App 正在编译配置和词库…"
        case .deployed: return "配置已生效 ✓"
        case .failed: return "部署失败，请留在主 App 中重试"
        }
    }

    func load() {
        let savedPageSize = persistence.integer(forKey: "rime_page_size")
        pageSize = Double(savedPageSize > 0 ? savedPageSize : 9)
        simplified =
            persistence.hasValue(forKey: "rime_simplification")
            ? persistence.bool(forKey: "rime_simplification") : true
        refreshDeploymentState()
    }

    func stop() {}

    func savePreferences() {
        persistence.set(Int(pageSize), forKey: "rime_page_size")
        persistence.set(simplified, forKey: "rime_simplification")
        persistence.synchronize()
    }

    func switchToSchema(_ schemaID: String) async {
        schemaManager.switchToSchema(schemaID)
        await triggerDeployment()
    }
    func acceptLicense() { schemaManager.acceptLicense() }
    func startDownload() { schemaManager.startDownload() }
    func cancelDownload() { schemaManager.cancelDownload() }
    func forceRedownload() { schemaManager.forceRedownload() }
    func uninstallRimeIce() { schemaManager.uninstallRimeIce() }

    func checkForUpdateAndDownload() {
        Task {
            guard await schemaManager.checkForUpdate() else { return }
            schemaManager.startDownload()
        }
    }

    func triggerDeployment() async {
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
            deploymentState = .failed
        }
    }

    private func appendDeploymentLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        deploymentLog.append("[\(formatter.string(from: Date()))] \(message)")
    }
}
