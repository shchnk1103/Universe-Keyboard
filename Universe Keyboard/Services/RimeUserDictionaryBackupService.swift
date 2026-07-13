import CryptoKit
import Foundation

enum RimeUserDictionaryBackupReadiness: Equatable {
    case noLearningData
    case needsInitialBackup
    case upToDate
    case hasNewLearningData
    case unknown
}

struct RimeUserDictionaryBackupStatus: Equatable {
    let hasLearningData: Bool
    let latestBackupDate: Date?
    let readiness: RimeUserDictionaryBackupReadiness

    var canBackup: Bool {
        switch readiness {
        case .needsInitialBackup, .hasNewLearningData, .unknown:
            return hasLearningData
        case .noLearningData, .upToDate:
            return false
        }
    }
}

struct RimeUserDictionaryOperationResult: Equatable {
    let succeeded: Bool
    let message: String
}

@MainActor
protocol RimeUserDictionaryBackingUp: AnyObject {
    func status(for schemaID: String) -> RimeUserDictionaryBackupStatus
    func backup(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult
    func restoreLatest(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult
    func resetLearningData(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult
}

@MainActor
final class AppGroupRimeUserDictionaryBackupService: RimeUserDictionaryBackingUp {
    private let appGroupID: String
    private let fileManager: FileManager
    private let containerURLOverride: URL?
    private let maxBackupCount = 5
    private static let manifestFileName = "manifest.json"

    init(
        appGroupID: String = universeAppGroupID,
        fileManager: FileManager = .default,
        containerURL: URL? = nil
    ) {
        self.appGroupID = appGroupID
        self.fileManager = fileManager
        self.containerURLOverride = containerURL
    }

    func status(for schemaID: String) -> RimeUserDictionaryBackupStatus {
        let items = learningItems(for: schemaID)
        let latestBackup = latestBackupDirectory(for: schemaID)
        let readiness = backupReadiness(currentItems: items, latestBackupURL: latestBackup?.url)
        return RimeUserDictionaryBackupStatus(
            hasLearningData: !items.isEmpty,
            latestBackupDate: latestBackup?.date,
            readiness: readiness
        )
    }

    func backup(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        let items = learningItems(for: schemaID)
        guard !items.isEmpty else {
            return .init(succeeded: false, message: "\(displayName) 还没有可备份的学习记录。")
        }
        let status = status(for: schemaID)
        guard status.canBackup else {
            return .init(succeeded: false, message: "\(displayName) 的学习记录已备份，无需重复备份。")
        }

        do {
            _ = try createVerifiedBackup(items: items, schemaID: schemaID)
            return .init(succeeded: true, message: "已备份 \(displayName) 的学习记录。")
        } catch {
            return .init(succeeded: false, message: "备份失败，请稍后再试。")
        }
    }

    func restoreLatest(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        guard let latestBackup = latestBackupDirectory(for: schemaID)?.url else {
            return .init(succeeded: false, message: "\(displayName) 还没有可恢复的备份。")
        }
        guard let userDir = userDirectoryURL() else {
            return .init(succeeded: false, message: "无法访问键盘数据，请确认已允许完全访问。")
        }

        let currentItems = learningItems(for: schemaID)
        var recoveryBackupURL: URL?
        do {
            // 已有的手动备份可能早于最近学习记录，不能替代恢复前的保护副本。
            if !currentItems.isEmpty {
                recoveryBackupURL = try createVerifiedBackup(
                    items: currentItems,
                    schemaID: schemaID,
                    preserving: [latestBackup]
                )
            }
            try replaceLearningData(
                for: schemaID,
                withBackupAt: latestBackup,
                userDirectoryURL: userDir
            )
            let recoverySuffix = recoveryBackupURL == nil ? "" : "，已自动保护当前记录"
            return .init(succeeded: true, message: "已恢复 \(displayName) 最近一次备份\(recoverySuffix)。")
        } catch {
            return rollbackAfterFailedReplacement(
                for: schemaID,
                recoveryBackupURL: recoveryBackupURL,
                userDirectoryURL: userDir,
                failureMessage: "恢复失败"
            )
        }
    }

    func resetLearningData(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        let currentItems = learningItems(for: schemaID)
        guard !currentItems.isEmpty else {
            return .init(succeeded: false, message: "\(displayName) 现在没有可清空的学习记录。")
        }
        guard let userDir = userDirectoryURL() else {
            return .init(succeeded: false, message: "无法访问键盘数据，请确认已允许完全访问。")
        }

        var recoveryBackupURL: URL?
        do {
            // “清空”同样是破坏性操作，必须先留下已经校验过的恢复副本。
            recoveryBackupURL = try createVerifiedBackup(items: currentItems, schemaID: schemaID)
            try removeLearningData(for: schemaID)
            return .init(succeeded: true, message: "已安全备份并清空 \(displayName) 的学习记录。")
        } catch {
            return rollbackAfterFailedReplacement(
                for: schemaID,
                recoveryBackupURL: recoveryBackupURL,
                userDirectoryURL: userDir,
                failureMessage: "清空未完成"
            )
        }
    }

    private func createVerifiedBackup(
        items: [URL],
        schemaID: String,
        preserving backupURLs: [URL] = []
    ) throws -> URL {
        guard let backupRoot = backupRootURL(for: schemaID) else {
            throw RimeUserDictionaryBackupError.unavailableStorage
        }

        let manifest = try Self.makeManifest(for: items)
        let backupURL = uniqueBackupDirectoryURL(in: backupRoot, date: Date())
        do {
            try fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true)
            for item in items {
                try fileManager.copyItem(
                    at: item,
                    to: backupURL.appendingPathComponent(item.lastPathComponent)
                )
            }
            let manifestData = try JSONEncoder().encode(manifest)
            try manifestData.write(to: backupURL.appendingPathComponent(Self.manifestFileName), options: .atomic)

            guard try Self.readManifest(at: backupURL.appendingPathComponent(Self.manifestFileName)) == manifest else {
                throw RimeUserDictionaryBackupError.verificationFailed
            }

            pruneOldBackups(for: schemaID, preserving: backupURLs)
            return backupURL
        } catch {
            try? fileManager.removeItem(at: backupURL)
            throw error
        }
    }

    private func replaceLearningData(
        for schemaID: String,
        withBackupAt backupURL: URL,
        userDirectoryURL: URL
    ) throws {
        try removeLearningData(for: schemaID)
        let backupItems = try fileManager.contentsOfDirectory(
            at: backupURL,
            includingPropertiesForKeys: nil
        )
        for item in backupItems where item.lastPathComponent != Self.manifestFileName {
            try fileManager.copyItem(
                at: item,
                to: userDirectoryURL.appendingPathComponent(item.lastPathComponent)
            )
        }
    }

    private func removeLearningData(for schemaID: String) throws {
        for item in learningItems(for: schemaID) {
            try fileManager.removeItem(at: item)
        }
    }

    private func rollbackAfterFailedReplacement(
        for schemaID: String,
        recoveryBackupURL: URL?,
        userDirectoryURL: URL,
        failureMessage: String
    ) -> RimeUserDictionaryOperationResult {
        guard let recoveryBackupURL else {
            return .init(succeeded: false, message: "\(failureMessage)，当前学习记录未被替换。")
        }

        do {
            try replaceLearningData(
                for: schemaID,
                withBackupAt: recoveryBackupURL,
                userDirectoryURL: userDirectoryURL
            )
            return .init(succeeded: false, message: "\(failureMessage)，当前学习记录已还原。")
        } catch {
            return .init(succeeded: false, message: "\(failureMessage)，已保留自动恢复备份，请稍后重试。")
        }
    }

    private func learningItems(for schemaID: String) -> [URL] {
        guard let userDir = userDirectoryURL() else { return [] }
        guard let items = try? fileManager.contentsOfDirectory(
            at: userDir,
            includingPropertiesForKeys: nil
        ) else { return [] }

        let prefix = "\(schemaID).userdb"
        return items.filter { $0.lastPathComponent.hasPrefix(prefix) }
    }

    private func backupReadiness(
        currentItems: [URL],
        latestBackupURL: URL?
    ) -> RimeUserDictionaryBackupReadiness {
        guard !currentItems.isEmpty else { return .noLearningData }
        guard let latestBackupURL else { return .needsInitialBackup }
        do {
            let currentManifest = try Self.makeManifest(for: currentItems)
            let backupManifest = try Self.readManifest(
                at: latestBackupURL.appendingPathComponent(Self.manifestFileName)
            )
            return currentManifest == backupManifest ? .upToDate : .hasNewLearningData
        } catch {
            return .unknown
        }
    }

    private func latestBackupDirectory(for schemaID: String) -> (url: URL, date: Date)? {
        guard let backupRoot = backupRootURL(for: schemaID) else { return nil }
        guard let backups = try? fileManager.contentsOfDirectory(
            at: backupRoot,
            includingPropertiesForKeys: nil
        ) else { return nil }

        return backups
            .compactMap { url -> (URL, Date)? in
                guard let date = Self.date(fromBackupDirectoryName: url.lastPathComponent) else { return nil }
                return (url, date)
            }
            .max { $0.1 < $1.1 }
    }

    private func pruneOldBackups(for schemaID: String, preserving backupURLs: [URL]) {
        guard let backupRoot = backupRootURL(for: schemaID) else { return }
        guard let backups = try? fileManager.contentsOfDirectory(
            at: backupRoot,
            includingPropertiesForKeys: nil
        ) else { return }

        let sortedBackups = backups
            .compactMap { url -> (URL, Date)? in
                guard let date = Self.date(fromBackupDirectoryName: url.lastPathComponent) else { return nil }
                return (url, date)
            }
            .sorted { $0.1 > $1.1 }

        let preservedPaths = Set(backupURLs.map(\.standardizedFileURL.path))
        let removableBackups = sortedBackups.filter {
            !preservedPaths.contains($0.0.standardizedFileURL.path)
        }
        for backup in removableBackups.dropFirst(maxBackupCount) {
            try? fileManager.removeItem(at: backup.0)
        }
    }

    private func userDirectoryURL() -> URL? {
        containerURL()?.appendingPathComponent("Rime/user")
    }

    private func backupRootURL(for schemaID: String) -> URL? {
        guard let containerURL = containerURL() else { return nil }
        return containerURL
            .appendingPathComponent("Rime/user_dictionary_backups")
            .appendingPathComponent(schemaID)
    }

    private func containerURL() -> URL? {
        if let containerURLOverride { return containerURLOverride }
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    private func uniqueBackupDirectoryURL(in backupRoot: URL, date: Date) -> URL {
        let baseName = Self.backupDirectoryName(for: date)
        let baseURL = backupRoot.appendingPathComponent(baseName, isDirectory: true)
        guard fileManager.fileExists(atPath: baseURL.path) else { return baseURL }
        return backupRoot.appendingPathComponent("\(baseName)-\(UUID().uuidString)", isDirectory: true)
    }

    private static func backupDirectoryName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: date)
    }

    private static func date(fromBackupDirectoryName name: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.date(from: String(name.prefix(15)))
    }

    private static func makeManifest(for items: [URL]) throws -> RimeUserDictionaryBackupManifest {
        var entries: [RimeUserDictionaryBackupManifest.Entry] = []
        for item in items.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            entries.append(contentsOf: try manifestEntries(for: item, baseURL: item.deletingLastPathComponent()))
        }
        return RimeUserDictionaryBackupManifest(entries: entries.sorted { $0.path < $1.path })
    }

    private static func manifestEntries(
        for url: URL,
        baseURL: URL
    ) throws -> [RimeUserDictionaryBackupManifest.Entry] {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
        let values = try url.resourceValues(forKeys: keys)
        let relativePath = relativePath(for: url, baseURL: baseURL)

        if values.isDirectory == true {
            let children = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: Array(keys),
                options: []
            )
            return try children.flatMap { try manifestEntries(for: $0, baseURL: baseURL) }
        }

        let data = try Data(contentsOf: url)
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        return [
            .init(
                path: relativePath,
                byteCount: values.fileSize ?? data.count,
                modificationTime: values.contentModificationDate?.timeIntervalSince1970 ?? 0,
                sha256: digest
            )
        ]
    }

    private static func relativePath(for url: URL, baseURL: URL) -> String {
        let basePath = baseURL.standardizedFileURL.path
        let fullPath = url.standardizedFileURL.path
        guard fullPath.hasPrefix(basePath) else { return url.lastPathComponent }
        let start = fullPath.index(fullPath.startIndex, offsetBy: basePath.count)
        return String(fullPath[start...]).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private static func readManifest(at url: URL) throws -> RimeUserDictionaryBackupManifest {
        try JSONDecoder().decode(RimeUserDictionaryBackupManifest.self, from: Data(contentsOf: url))
    }
}

private enum RimeUserDictionaryBackupError: Error {
    case unavailableStorage
    case verificationFailed
}

private struct RimeUserDictionaryBackupManifest: Codable, Equatable {
    struct Entry: Codable, Equatable {
        let path: String
        let byteCount: Int
        let modificationTime: TimeInterval
        let sha256: String

        static func == (lhs: Entry, rhs: Entry) -> Bool {
            lhs.path == rhs.path
                && lhs.byteCount == rhs.byteCount
                && lhs.sha256 == rhs.sha256
        }
    }

    let entries: [Entry]
}
