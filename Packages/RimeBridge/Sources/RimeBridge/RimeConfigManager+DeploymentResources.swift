import Foundation
import KeyboardCore

private let deploymentResourcesAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

extension RimeConfigManager {
    /// Validates and installs the main-App-owned built-in runtime closure.
    ///
    /// The keyboard extension must never call this API: hashing and persistent
    /// file writes belong to an explicit main-App deployment transaction.
    public static func prepareDirectories(
        resourceBundle: Bundle = .main
    ) throws -> (sharedDir: String, userDir: String) {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: deploymentResourcesAppGroupID
            )
        else {
            Logger.shared.error("App Group 容器不可用", category: .config)
            throw RimeBuiltinResourceInstaller.InstallationError.fileOperationFailed
        }
        // Reconstruct and verify the complete bundle before creating or changing
        // anything in the shared container. A corrupt App bundle must leave the
        // last known-good runtime byte-for-byte untouched.
        let resourceRoot = try stageBundledResourceClosure(from: resourceBundle)
        defer { try? FileManager.default.removeItem(at: resourceRoot) }

        let rimeRoot = containerURL.appendingPathComponent("Rime", isDirectory: true)
        let userDir = rimeRoot.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)

        let result = try RimeBuiltinResourceInstaller().install(
            sourceRoot: resourceRoot,
            rimeRoot: rimeRoot
        )
        try RimeConfigTemplates.installationYaml.write(
            to: userDir.appendingPathComponent("installation.yaml"),
            atomically: true,
            encoding: .utf8
        )
        Logger.shared.info(
            "Built-in RIME resources installed fileCount=\(result.fileCount) "
                + "byteCount=\(result.byteCount)",
            category: .config
        )

        return (
            rimeRoot.appendingPathComponent("shared", isDirectory: true).path,
            userDir.path
        )
    }

    /// Xcode's synchronized resource group flattens subdirectories in the App
    /// bundle. Reconstruct the manifest's logical paths in a private temporary
    /// tree, then let the installer perform the authoritative hash validation.
    static func stageBundledResourceClosure(from bundle: Bundle) throws -> URL {
        let installer = RimeBuiltinResourceInstaller()
        let manifestName = (RimeBuiltinResourceInstaller.manifestFileName as NSString)
            .deletingPathExtension
        guard
            let manifestURL = bundle.url(
                forResource: manifestName,
                withExtension: "json"
            ),
            let manifest = try? JSONDecoder().decode(
                RimeBuiltinResourceInstaller.Manifest.self,
                from: Data(contentsOf: manifestURL)
            ),
            Set(manifest.entries.map(\.path)) == RimeBuiltinResourceInstaller.requiredRelativePaths
        else {
            throw RimeBuiltinResourceInstaller.InstallationError.manifestMissing
        }
        let filenames = manifest.entries.compactMap { $0.path.split(separator: "/").last.map(String.init) }
        guard Set(filenames).count == manifest.entries.count else {
            // Xcode flattens synchronized resources. Duplicate basenames would
            // make a manifest entry resolve ambiguously at runtime.
            throw RimeBuiltinResourceInstaller.InstallationError.resourceSetMismatch
        }

        let stagedRoot = FileManager.default.temporaryDirectory.appendingPathComponent(
            "rime-builtin-bundle-\(UUID().uuidString)",
            isDirectory: true
        )
        do {
            try FileManager.default.createDirectory(at: stagedRoot, withIntermediateDirectories: true)
            try FileManager.default.copyItem(
                at: manifestURL,
                to: stagedRoot.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName)
            )
            for entry in manifest.entries {
                let filename = entry.path.components(separatedBy: "/").last ?? ""
                let resourceName = (filename as NSString).deletingPathExtension
                let resourceExtension = (filename as NSString).pathExtension
                guard
                    !resourceName.isEmpty,
                    let source = bundle.url(
                        forResource: resourceName,
                        withExtension: resourceExtension
                    )
                else {
                    throw RimeBuiltinResourceInstaller.InstallationError.resourceSetMismatch
                }
                let values = try source.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
                guard values.isRegularFile == true, values.isSymbolicLink != true else {
                    throw RimeBuiltinResourceInstaller.InstallationError.resourceNotRegularFile
                }
                let destination = stagedRoot.appendingPathComponent(entry.path)
                try FileManager.default.createDirectory(
                    at: destination.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try FileManager.default.copyItem(at: source, to: destination)
            }
            _ = try installer.validateResourceTree(at: stagedRoot)
            return stagedRoot
        } catch {
            try? FileManager.default.removeItem(at: stagedRoot)
            throw error
        }
    }
}
