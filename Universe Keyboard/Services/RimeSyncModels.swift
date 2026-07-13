import Foundation

/// 同步配置在主 App 沙盒中的稳定键名。
///
/// 自动任务会在没有 SwiftUI 视图的后台启动，因此不能依赖界面 model 持有这些状态。
/// 键名集中在这里，避免前台设置与后台调度器读取不同配置。
enum RimeSyncStorageKey {
    static let provider = "rime_sync_provider"
    static let webDAVURL = "rime_sync_webdav_url"
    static let webDAVUsername = "rime_sync_webdav_username"
    static let folderBookmark = "rime_sync_folder_bookmark"
    static let folderName = "rime_sync_folder_name"
    static let folderSelectionNeedsRepair = "rime_sync_folder_selection_needs_repair"
    static let deviceID = "rime_sync_device_id"
    static let profile = "rime_sync_last_profile"
    static let lastSuccess = "rime_sync_last_success"
    static let standardRimeLastSuccess = "rime_standard_sync_last_success"
    static let automaticSyncEnabled = "rime_standard_sync_automatic_enabled"
    static let automaticSyncCadence = "rime_standard_sync_automatic_cadence"
    static let automaticSyncNotificationsEnabled = "rime_standard_sync_notifications_enabled"
    static let lastAutomaticAttempt = "rime_standard_sync_last_automatic_attempt"
}

nonisolated enum RimeAutomaticSyncCadence: String, CaseIterable, Identifiable, Sendable {
    case daily
    case weekly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "每天"
        case .weekly: return "每 7 天"
        }
    }

    var interval: TimeInterval {
        switch self {
        case .daily: return 24 * 60 * 60
        case .weekly: return 7 * 24 * 60 * 60
        }
    }
}

nonisolated enum RimeAutomaticSyncSkipReason: Equatable, Sendable {
    case disabled
    case notConfigured
    case waitingForFirstManualSync
    case coolingDown
    case keyboardActive
    case alreadyRunning
    case cancelled
}

nonisolated enum RimeAutomaticSyncResult: Equatable, Sendable {
    case completed(Date)
    case skipped(RimeAutomaticSyncSkipReason)
    case failed

    var completedSuccessfully: Bool {
        switch self {
        case .completed, .skipped(.disabled), .skipped(.notConfigured),
             .skipped(.waitingForFirstManualSync), .skipped(.coolingDown),
             .skipped(.keyboardActive), .skipped(.alreadyRunning):
            return true
        case .skipped(.cancelled), .failed:
            return false
        }
    }
}

nonisolated enum RimeAutomaticSyncPolicy {
    static func isDue(
        lastAutomaticAttempt: Date?,
        cadence: RimeAutomaticSyncCadence,
        now: Date = Date()
    ) -> Bool {
        guard let lastAutomaticAttempt else { return true }
        return now.timeIntervalSince(lastAutomaticAttempt) >= cadence.interval
    }

    static func nextEligibleDate(
        lastAutomaticAttempt: Date,
        cadence: RimeAutomaticSyncCadence
    ) -> Date {
        lastAutomaticAttempt.addingTimeInterval(cadence.interval)
    }
}

/// 跨平台同步包允许的标量类型。
///
/// 使用 JSON 原生标量而不是 Swift 枚举的自动 Codable 表达，保证其他平台
/// 不需要理解 Swift 特有的关联值编码格式。
nonisolated enum RimeSyncScalar: Codable, Equatable, Sendable {
    case bool(Bool)
    case int(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(
                RimeSyncScalar.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported sync scalar")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }

    var boolValue: Bool? {
        guard case .bool(let value) = self else { return nil }
        return value
    }

    var intValue: Int? {
        guard case .int(let value) = self else { return nil }
        return value
    }

    var stringValue: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }
}

nonisolated struct RimeSyncVersion: Codable, Equatable, Comparable, Sendable {
    let counter: UInt64
    let deviceID: String

    static func < (lhs: RimeSyncVersion, rhs: RimeSyncVersion) -> Bool {
        if lhs.counter != rhs.counter {
            return lhs.counter < rhs.counter
        }
        return lhs.deviceID < rhs.deviceID
    }
}

nonisolated struct RimeSyncField: Codable, Equatable, Sendable {
    let value: RimeSyncScalar
    let version: RimeSyncVersion
}

nonisolated struct RimeSyncProfile: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var fields: [String: RimeSyncField]

    init(schemaVersion: Int = currentSchemaVersion, fields: [String: RimeSyncField] = [:]) {
        self.schemaVersion = schemaVersion
        self.fields = fields
    }

    /// 将当前设备的设置提升为新逻辑版本，同时保留未知字段。
    func updating(values: [String: RimeSyncScalar], deviceID: String) -> RimeSyncProfile {
        var updated = self
        let nextCounter = (fields.values.map(\.version.counter).max() ?? 0) + 1

        for (key, value) in values {
            guard fields[key]?.value != value else { continue }
            updated.fields[key] = RimeSyncField(
                value: value,
                version: RimeSyncVersion(counter: nextCounter, deviceID: deviceID)
            )
        }
        return updated
    }

    /// 字段级确定性合并。不同字段可同时保留；同字段冲突按逻辑版本和设备 ID 决定。
    func merging(_ other: RimeSyncProfile) throws -> RimeSyncProfile {
        guard schemaVersion == Self.currentSchemaVersion,
              other.schemaVersion == Self.currentSchemaVersion
        else {
            throw RimeSyncError.unsupportedFormat
        }

        var merged = self
        for (key, remoteField) in other.fields {
            guard let localField = merged.fields[key] else {
                merged.fields[key] = remoteField
                continue
            }
            if localField.version < remoteField.version {
                merged.fields[key] = remoteField
            } else if localField.version == remoteField.version,
                      localField.value != remoteField.value,
                      Self.stableScalar(remoteField.value) > Self.stableScalar(localField.value)
            {
                // 相同来源版本出现不同内容代表损坏或错误客户端；仍以稳定顺序收敛，
                // 避免设备之间来回覆盖。
                merged.fields[key] = remoteField
            }
        }
        return merged
    }

    var scalarValues: [String: RimeSyncScalar] {
        fields.mapValues(\.value)
    }

    private static func stableScalar(_ scalar: RimeSyncScalar) -> String {
        switch scalar {
        case .bool(let value): return "b:\(value ? 1 : 0)"
        case .int(let value): return "i:\(value)"
        case .string(let value): return "s:\(value)"
        }
    }
}

nonisolated struct RimeSyncFormatManifest: Codable, Equatable, Sendable {
    let format: String
    let version: Int
    let encryption: String
    let settingsPath: String

    static let current = RimeSyncFormatManifest(
        format: "universe-rime-sync",
        version: 1,
        encryption: "chacha20-poly1305",
        settingsPath: "profiles/default/settings.json"
    )
}

nonisolated struct RimeSyncEncryptedSettings: Codable, Equatable, Sendable {
    let version: Int
    let algorithm: String
    let combined: String
}

nonisolated enum RimeSyncProvider: String, CaseIterable, Identifiable, Codable, Sendable {
    case none
    case localFolder
    case webDAV

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: return "未设置"
        case .localFolder: return "RIME 标准文件夹"
        case .webDAV: return "私密 WebDAV"
        }
    }
}

nonisolated enum RimeSyncPhase: Equatable, Sendable {
    /// 写入 `sync_dir` 并调用 librime 官方 `sync_user_data`。
    case standardRimeData
    /// 同步 Universe 自己的端到端加密管理型设置包。
    case privateSettings

    var progressMessage: String {
        switch self {
        case .standardRimeData:
            return "正在同步 RIME 用户资料…"
        case .privateSettings:
            return "正在同步 Universe 私密设置…"
        }
    }
}

nonisolated enum RimeSyncCompletion: Equatable, Sendable {
    case privateSettings
    case standardRimeAndPrivateSettings

    var message: String {
        switch self {
        case .privateSettings:
            return "Universe 私密设置已同步"
        case .standardRimeAndPrivateSettings:
            return "RIME 用户资料与私密设置已同步"
        }
    }
}

nonisolated enum RimeSyncStatus: Equatable, Sendable {
    case idle
    case notConfigured
    case syncing(RimeSyncPhase)
    case succeeded(Date, RimeSyncCompletion)
    case failed(String)
}

nonisolated enum RimeSyncError: LocalizedError, Equatable, Sendable {
    case notConfigured
    case invalidServerURL
    case insecureServerURL
    case missingCredentials
    case missingEncryptionKey
    case invalidRecoveryCode
    case unsupportedFormat
    case packageTooLarge
    case corruptedPackage
    case remoteConflict
    case accessDenied
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "请先选择同步方式。"
        case .invalidServerURL: return "请输入有效的 WebDAV 地址。"
        case .insecureServerURL: return "WebDAV 必须使用 HTTPS；本机测试地址除外。"
        case .missingCredentials: return "请填写 WebDAV 用户名和密码。"
        case .missingEncryptionKey: return "找不到同步密钥，请输入恢复码。"
        case .invalidRecoveryCode: return "恢复码无效，请检查后重试。"
        case .unsupportedFormat: return "云端同步包版本暂不兼容。"
        case .packageTooLarge: return "云端同步包超过安全大小限制。"
        case .corruptedPackage: return "云端数据损坏或密钥不匹配。"
        case .remoteConflict: return "其他设备正在更新，请稍后重试。"
        case .accessDenied: return "无法访问或写入同步目录，请重新选择一个可写文件夹。"
        case .transport(let message): return message
        }
    }
}
