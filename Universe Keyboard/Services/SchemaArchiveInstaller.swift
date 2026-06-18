import Foundation
import RimeBridge

struct SchemaDeploymentDirectories: Sendable {
    let sharedDataURL: URL
    let userDataURL: URL
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
    func uninstallSchemaFiles(plan: RimeSchemeInstallationPlan)
    func clearBuildCache(plan: RimeSchemeInstallationPlan)
    func sharedDataDirectoryURL() -> URL?
    func deploymentDirectories() throws -> SchemaDeploymentDirectories
}

@MainActor
final class SharedContainerSchemaArchiveInstaller: SchemaArchiveInstalling {
    private let appGroupID: String
    private let fileManager: FileManager

    init(appGroupID: String, fileManager: FileManager = .default) {
        self.appGroupID = appGroupID
        self.fileManager = fileManager
    }

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        fileManager.temporaryDirectory.appendingPathComponent(distribution.cachedArchiveFileName)
    }

    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        let directory = fileManager.temporaryDirectory.appendingPathComponent(distribution.extractionDirectoryName)
        try? fileManager.removeItem(at: directory)
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

            let relativePath = fileURL.path.replacingOccurrences(of: extractDir.path + "/", with: "")
            let destinationURL = sharedDirectory.appendingPathComponent(relativePath)
            if plan.skippedFiles.contains(fileURL.lastPathComponent)
                || plan.prefixesToSkip(luaAvailable: luaAvailable).contains(where: { relativePath.hasPrefix($0) })
            {
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

    func uninstallSchemaFiles(plan: RimeSchemeInstallationPlan) {
        guard let sharedDirectory = sharedDirectory() else { return }

        for file in plan.removableFiles {
            try? fileManager.removeItem(at: sharedDirectory.appendingPathComponent(file))
        }
        for subdirectory in plan.removableDirectories {
            try? fileManager.removeItem(at: sharedDirectory.appendingPathComponent(subdirectory))
        }

        clearBuildCache(plan: plan)
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

    func deploymentDirectories() throws -> SchemaDeploymentDirectories {
        guard
            let plugInsURL = Bundle.main.builtInPlugInsURL,
            let keyboardBundle = Bundle(url: plugInsURL.appendingPathComponent("Keyboard.appex")),
            let prepared = RimeConfigManager.prepareDirectories(resourceBundle: keyboardBundle)
        else {
            throw DownloadError.networkError("键盘运行时资源不可用")
        }
        return SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: prepared.sharedDir),
            userDataURL: URL(fileURLWithPath: prepared.userDir)
        )
    }

    private func containerURL() -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    private func sharedDirectory() -> URL? {
        containerURL()?.appendingPathComponent("Rime/shared")
    }
}
