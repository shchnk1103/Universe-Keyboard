import Foundation
import RimeBridgeObjC

/// RIME 官方同步执行所需的目录与设备标识。
///
/// `syncDirectoryURL` 是用户在文件提供器中明确选定的共享目录；桌面或 Android
/// 客户端应把同一目录配置为各自的 RIME `sync_dir`。
public struct RimeStandardSyncRequest: Sendable {
    public let sharedDataURL: URL
    public let userDataURL: URL
    public let syncDirectoryURL: URL
    public let installationID: String

    public init(
        sharedDataURL: URL,
        userDataURL: URL,
        syncDirectoryURL: URL,
        installationID: String
    ) {
        self.sharedDataURL = sharedDataURL
        self.userDataURL = userDataURL
        self.syncDirectoryURL = syncDirectoryURL
        self.installationID = installationID
    }
}

public enum RimeStandardSyncError: LocalizedError, Equatable, Sendable {
    case invalidInstallationID
    case invalidInstallationConfiguration
    case unavailableUserDirectory
    case unavailableSyncDirectory
    case synchronizationFailed

    public var errorDescription: String? {
        switch self {
        case .invalidInstallationID:
            return "RIME 同步设备标识无效。"
        case .invalidInstallationConfiguration:
            return "无法安全更新 RIME 同步配置，请重新部署后再试。"
        case .unavailableUserDirectory:
            return "RIME 用户目录尚未准备好，请先完成一次部署。"
        case .unavailableSyncDirectory:
            return "无法访问所选同步文件夹，请重新选择。"
        case .synchronizationFailed:
            return "RIME 标准同步失败；本机现有设置和学习记录没有被删除。"
        }
    }
}

public protocol RimeStandardSyncing: Sendable {
    func synchronize(_ request: RimeStandardSyncRequest) async throws
}

/// 串行执行 librime 官方用户资料同步的主 App 服务。
///
/// 这里不提供自动同步：`sync_user_data` 会读取和更新用户资料，必须只在用户从
/// 主 App 明确发起、键盘未被使用的维护窗口调用。
public actor RimeStandardSyncService: RimeStandardSyncing {
    public init() {}

    public func synchronize(_ request: RimeStandardSyncRequest) async throws {
        guard Self.isSafeInstallationID(request.installationID) else {
            throw RimeStandardSyncError.invalidInstallationID
        }
        guard FileManager.default.fileExists(atPath: request.userDataURL.path) else {
            throw RimeStandardSyncError.unavailableUserDirectory
        }

        let didStartAccess = request.syncDirectoryURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                request.syncDirectoryURL.stopAccessingSecurityScopedResource()
            }
        }

        let synchronizer = RimeUserDataSynchronizer()
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var operationError: Error?
        var synchronizationSucceeded = false

        // 文件提供器会在协调访问期间给出可写的 URL。librime 的同步过程会在
        // `sync_dir` 下创建多个文件，因此必须把整个维护操作放在同一次协调中。
        coordinator.coordinate(
            writingItemAt: request.syncDirectoryURL,
            options: .forMerging,
            error: &coordinationError
        ) { coordinatedSyncDirectoryURL in
            do {
                try FileManager.default.createDirectory(
                    at: coordinatedSyncDirectoryURL,
                    withIntermediateDirectories: true
                )
                try RimeStandardSyncInstallation.configure(
                    userDataURL: request.userDataURL,
                    syncDirectoryURL: coordinatedSyncDirectoryURL,
                    installationID: request.installationID
                )
                synchronizationSucceeded = synchronizer.sync(
                    withSharedDataDir: request.sharedDataURL.path,
                    userDataDir: request.userDataURL.path
                )
            } catch {
                operationError = error
            }
        }

        if coordinationError != nil {
            throw RimeStandardSyncError.unavailableSyncDirectory
        }
        if let operationError {
            throw operationError
        }
        guard synchronizationSucceeded else {
            throw RimeStandardSyncError.synchronizationFailed
        }
    }

    private static func isSafeInstallationID(_ value: String) -> Bool {
        guard !value.isEmpty, value.count <= 80 else { return false }
        return value.allSatisfy { character in
            character.isASCII && (character.isLowercase || character.isNumber || character == "-" || character == "_")
        }
    }
}

/// 只管理 `installation.yaml` 的两个官方同步字段，保留其他 RIME 配置。
public enum RimeStandardSyncInstallation {
    private static let fileName = "installation.yaml"
    private static let maximumConfigurationBytes = 64 * 1024

    public static func configure(
        userDataURL: URL,
        syncDirectoryURL: URL,
        installationID: String
    ) throws {
        let fileURL = userDataURL.appendingPathComponent(fileName)
        let existing = try existingConfiguration(at: fileURL)
        let retainedLines = try existing.split(separator: "\n", omittingEmptySubsequences: false).filter { line in
            try shouldRetain(line: String(line))
        }

        var output = retainedLines.joined(separator: "\n")
        if !output.isEmpty, !output.hasSuffix("\n") {
            output += "\n"
        }
        output += "installation_id: '\(yamlQuoted(installationID))'\n"
        output += "sync_dir: '\(yamlQuoted(syncDirectoryURL.path))'\n"

        try output.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private static func existingConfiguration(at url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else { return "" }
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        guard data.count <= maximumConfigurationBytes,
              let text = String(data: data, encoding: .utf8)
        else {
            throw RimeStandardSyncError.invalidInstallationConfiguration
        }
        return text
    }

    private static func shouldRetain(line: String) throws -> Bool {
        for key in ["installation_id", "sync_dir"] {
            let prefix = "\(key):"
            guard line.hasPrefix(prefix) else { continue }

            let value = line.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)
            // 这两个字段必须是根级标量。遇到块、锚点或空值时停止，避免破坏用户 YAML。
            guard !value.isEmpty, value != "|", value != ">", !value.hasPrefix("&") else {
                throw RimeStandardSyncError.invalidInstallationConfiguration
            }
            return false
        }
        return true
    }

    private static func yamlQuoted(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}
