import Foundation
import KeyboardCore
import RimeBridge

enum SchemaUninstallRecoveryError: Error {
    case rollbackIncomplete
}

struct SchemaDeploymentDirectories: Sendable {
    let sharedDataURL: URL
    let userDataURL: URL
}

/// Files moved out of the live shared tree while an uninstall is still
/// reversible. The manager commits this only after the active-scheme fallback
/// has completed successfully.
struct SchemaUninstallStaging: Sendable {
    let rootURL: URL
    let movedRelativePaths: [String]
}

enum SchemaUpgradeRecoveryError: Error {
    case upgradeRollbackIncomplete
}

/// Prior-generation files copied aside before a Wanxiang live replace.
/// Distinct from uninstall staging (copy, not move); retained on restore failure.
struct SchemaUpgradeCheckpoint: Sendable {
    let rootURL: URL
    let copiedRelativePaths: [String]
}

/// Owns schema file placement in the shared container. Its synchronous API
/// preserves the existing installation sequence while making it replaceable
/// in tests; installation can be moved off-main without changing the store API.
@MainActor
protocol SchemaArchiveInstalling: AnyObject {
    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL
    func removeTemporaryItem(at url: URL)
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool
    func checkDiskSpace(needed: Int64) throws
    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws
    func createUpgradeCheckpoint(plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws
        -> SchemaUpgradeCheckpoint?
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws
    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint)
    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging
    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan)
    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) throws
    func clearBuildCache(plan: RimeSchemeInstallationPlan)
    func sharedDataDirectoryURL() -> URL?
    /// Resolves an already-deployed runtime tree without preparing resources.
    /// Safe for settings/readiness queries.
    func runtimeDirectories() throws -> SchemaDeploymentDirectories
    /// Prepares writable deployment resources. Only explicit main-App deploy
    /// transactions may call this method.
    func deploymentDirectories() throws -> SchemaDeploymentDirectories
}

@MainActor
final class SharedContainerSchemaArchiveInstaller: SchemaArchiveInstalling {
    private let appGroupID: String
    private let fileManager: FileManager
    /// Tests inject a container root so production copy/uninstall can run
    /// without the App Group. The production initializer leaves this nil.
    private let containerURLOverride: URL?
    // In-process retry evidence: destination existence alone cannot prove that
    // a missing staged file was restored by this transaction.
    private var restoredUninstallPaths: Set<URL> = []

    init(appGroupID: String, fileManager: FileManager = .default, containerURL: URL? = nil) {
        self.appGroupID = appGroupID
        self.fileManager = fileManager
        self.containerURLOverride = containerURL
    }

    /// XCTest host teardown must not route this MainActor-owned installer
    /// through the isolated-deinit task-local path.
    nonisolated deinit {}

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        fileManager.temporaryDirectory.appendingPathComponent(distribution.cachedArchiveFileName)
    }

    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        let directory = fileManager.temporaryDirectory.appendingPathComponent(
            "\(distribution.extractionDirectoryName)-\(UUID().uuidString)",
            isDirectory: true
        )
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    func removeTemporaryItem(at url: URL) {
        try? fileManager.removeItem(at: url)
    }

    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool {
        guard let sharedDirectory = sharedDirectory() else { return false }
        return fileManager.fileExists(
            atPath: sharedDirectory.appendingPathComponent(plan.schemaFileName).path
        )
    }

    func checkDiskSpace(needed: Int64) throws {
        guard let containerURL = containerURL() else { return }
        let values = try containerURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        let available = Int64(values.volumeAvailableCapacity ?? 0)
        guard available >= needed else {
            throw DownloadError.diskSpaceInsufficient(needed: needed, available: available)
        }
    }

    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws {
        guard let sharedDirectory = sharedDirectory() else {
            throw DownloadError.networkError("App Group 不可用")
        }
        try fileManager.createDirectory(at: sharedDirectory, withIntermediateDirectories: true)

        guard let enumerator = fileManager.enumerator(at: extractDir, includingPropertiesForKeys: nil) else {
            throw DownloadError.extractionFailed("无法遍历解压目录")
        }

        for case let fileURL as URL in enumerator {
            guard !fileURL.hasDirectoryPath else { continue }

            let relativePath = try plan.normalizedRelativePath(for: fileURL, under: extractDir)
            let destinationURL = sharedDirectory.appendingPathComponent(relativePath)
            guard plan.shouldInstall(relativePath: relativePath, luaAvailable: luaAvailable) else {
                continue
            }

            try fileManager.createDirectory(
                at: destinationURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: fileURL, to: destinationURL)
        }
    }

    /// Copies the prior plan-owned generation aside before live replace.
    /// Returns nil when no prior owned paths exist (first install).
    func createUpgradeCheckpoint(
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws -> SchemaUpgradeCheckpoint? {
        // luaAvailable is part of the install seam; ownership paths today do not
        // gate checkpoint membership on Lua availability.
        _ = luaAvailable
        guard let sharedDirectory = sharedDirectory() else {
            throw DownloadError.networkError("App Group 不可用")
        }

        let checkpointRoot = sharedDirectory.appendingPathComponent(
            ".schema-upgrade-\(UUID().uuidString)",
            isDirectory: true
        )
        var copiedRelativePaths: [String] = []

        do {
            try fileManager.createDirectory(at: checkpointRoot, withIntermediateDirectories: true)
            let paths = try ownedRelativePaths(for: plan, sharedDirectory: sharedDirectory)
            for relativePath in paths {
                let sourceURL = sharedDirectory.appendingPathComponent(relativePath)
                guard fileManager.fileExists(atPath: sourceURL.path) else { continue }

                let checkpointURL = checkpointRoot.appendingPathComponent(relativePath)
                try fileManager.createDirectory(
                    at: checkpointURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try fileManager.copyItem(at: sourceURL, to: checkpointURL)
                copiedRelativePaths.append(relativePath)
            }

            guard !copiedRelativePaths.isEmpty else {
                try? fileManager.removeItem(at: checkpointRoot)
                return nil
            }
            return SchemaUpgradeCheckpoint(
                rootURL: checkpointRoot,
                copiedRelativePaths: copiedRelativePaths
            )
        } catch {
            try? fileManager.removeItem(at: checkpointRoot)
            throw DownloadError.postProcessingFailed("无法创建方案升级检查点")
        }
    }

    /// Restores prior-generation bytes from the upgrade checkpoint.
    /// On any restore failure the checkpoint is retained and
    /// `SchemaUpgradeRecoveryError.upgradeRollbackIncomplete` is thrown.
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {
        guard let sharedDirectory = sharedDirectory() else {
            throw SchemaUpgradeRecoveryError.upgradeRollbackIncomplete
        }
        var restorationFailed = false

        for relativePath in checkpoint.copiedRelativePaths {
            let checkpointURL = checkpoint.rootURL.appendingPathComponent(relativePath)
            let destinationURL = sharedDirectory.appendingPathComponent(relativePath)
            guard fileManager.fileExists(atPath: checkpointURL.path) else {
                restorationFailed = true
                continue
            }
            do {
                try fileManager.createDirectory(
                    at: destinationURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: checkpointURL, to: destinationURL)
            } catch {
                restorationFailed = true
            }
        }

        guard !restorationFailed else {
            throw SchemaUpgradeRecoveryError.upgradeRollbackIncomplete
        }
        try? fileManager.removeItem(at: checkpoint.rootURL)
    }

    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {
        try? fileManager.removeItem(at: checkpoint.rootURL)
    }

    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        guard let sharedDirectory = sharedDirectory() else {
            throw DownloadError.networkError("App Group 不可用")
        }

        let stagingRoot = sharedDirectory.appendingPathComponent(
            ".schema-uninstall-\(UUID().uuidString)",
            isDirectory: true
        )
        var movedRelativePaths: [String] = []

        do {
            try fileManager.createDirectory(at: stagingRoot, withIntermediateDirectories: true)
            let paths = try ownedRelativePaths(for: plan, sharedDirectory: sharedDirectory)
            for relativePath in paths {
                let sourceURL = sharedDirectory.appendingPathComponent(relativePath)
                guard fileManager.fileExists(atPath: sourceURL.path) else { continue }

                let stagedURL = stagingRoot.appendingPathComponent(relativePath)
                try fileManager.createDirectory(
                    at: stagedURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try fileManager.moveItem(at: sourceURL, to: stagedURL)
                movedRelativePaths.append(relativePath)
            }
            return SchemaUninstallStaging(rootURL: stagingRoot, movedRelativePaths: movedRelativePaths)
        } catch {
            try rollbackSchemaUninstall(
                SchemaUninstallStaging(rootURL: stagingRoot, movedRelativePaths: movedRelativePaths)
            )
            throw DownloadError.postProcessingFailed("无法安全暂存待卸载方案文件")
        }
    }

    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {
        // Build output is derived data. It is cleared only after all owned
        // resources have moved out of the live tree.
        clearBuildCache(plan: plan)
        try? fileManager.removeItem(at: staging.rootURL)
    }

    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) throws {
        guard let sharedDirectory = sharedDirectory() else {
            throw SchemaUninstallRecoveryError.rollbackIncomplete
        }
        var restorationFailed = false

        for relativePath in staging.movedRelativePaths.reversed() {
            let stagedURL = staging.rootURL.appendingPathComponent(relativePath)
            let destinationURL = sharedDirectory.appendingPathComponent(relativePath)
            guard fileManager.fileExists(atPath: stagedURL.path) else {
                if !restoredUninstallPaths.contains(stagedURL)
                    || !fileManager.fileExists(atPath: destinationURL.path)
                {
                    restorationFailed = true
                }
                continue
            }
            do {
                try fileManager.createDirectory(
                    at: destinationURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try fileManager.moveItem(at: stagedURL, to: destinationURL)
                restoredUninstallPaths.insert(stagedURL)
            } catch {
                restorationFailed = true
            }
        }
        // A failed restore leaves the only surviving copy in staging. Keep the
        // entire checkpoint and report failure rather than deleting that copy.
        guard !restorationFailed else {
            throw SchemaUninstallRecoveryError.rollbackIncomplete
        }
        try? fileManager.removeItem(at: staging.rootURL)
        for path in staging.movedRelativePaths {
            restoredUninstallPaths.remove(staging.rootURL.appendingPathComponent(path))
        }
    }

    func clearBuildCache(plan: RimeSchemeInstallationPlan) {
        guard let sharedDirectory = sharedDirectory() else { return }
        let buildDirectory = sharedDirectory.appendingPathComponent("build")
        guard let buildFiles = try? fileManager.contentsOfDirectory(atPath: buildDirectory.path) else { return }

        for file in buildFiles where plan.removableBuildFileSubstrings.contains(where: file.contains) {
            try? fileManager.removeItem(at: buildDirectory.appendingPathComponent(file))
        }
    }

    func sharedDataDirectoryURL() -> URL? {
        sharedDirectory()
    }

    func runtimeDirectories() throws -> SchemaDeploymentDirectories {
        guard let containerURL = containerURL() else {
            throw DownloadError.networkError("App Group 不可用")
        }

        let sharedDataURL = containerURL.appendingPathComponent("Rime/shared")
        let userDataURL = containerURL.appendingPathComponent("Rime/user")
        guard
            fileManager.fileExists(atPath: sharedDataURL.path),
            fileManager.fileExists(atPath: userDataURL.path)
        else {
            throw DownloadError.networkError("键盘运行时资源不可用")
        }

        return SchemaDeploymentDirectories(sharedDataURL: sharedDataURL, userDataURL: userDataURL)
    }

    func deploymentDirectories() throws -> SchemaDeploymentDirectories {
        let prepared = try RimeConfigManager.prepareDirectories(resourceBundle: .main)
        return SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: prepared.sharedDir),
            userDataURL: URL(fileURLWithPath: prepared.userDir)
        )
    }

    private func containerURL() -> URL? {
        if let containerURLOverride {
            return containerURLOverride
        }
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    private func sharedDirectory() -> URL? {
        containerURL()?.appendingPathComponent("Rime/shared")
    }

    private func ownedRelativePaths(
        for plan: RimeSchemeInstallationPlan,
        sharedDirectory: URL
    ) throws -> [String] {
        let schemaID = SchemeAdapterRegistry.schemaID(forOwnershipPlanFileName: plan.schemaFileName)
        let view = SchemeOwnershipPlanView(
            schemaFileName: plan.schemaFileName,
            revision: plan.revision,
            removableFiles: plan.removableFiles,
            removableDirectories: plan.removableDirectories
        )
        return try SchemeAdapterRegistry.ownedRelativePaths(
            for: schemaID,
            plan: view,
            sharedRoot: sharedDirectory,
            fileManager: fileManager
        )
    }
}
