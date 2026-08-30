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
        // Installation metadata is a prerequisite of a usable generation. Write
        // it before replacing the last known-good shared closure so a metadata
        // failure cannot leave a partially authorized new generation behind.
        try RimeConfigTemplates.installationYaml.write(
            to: userDir.appendingPathComponent("installation.yaml"),
            atomically: true,
            encoding: .utf8
        )
        let result = try RimeBuiltinResourceInstaller().install(
            sourceRoot: resourceRoot,
            rimeRoot: rimeRoot
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
        try validateBundledResourceMembership(bundle: bundle, manifest: manifest)
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

    /// Rejects RIME-looking files that are present in the flattened main-App
    /// bundle but absent from the signed closure manifest. Non-RIME resources
    /// such as license text and asset catalogs remain outside this boundary.
    private static func validateBundledResourceMembership(
        bundle: Bundle,
        manifest: RimeBuiltinResourceInstaller.Manifest
    ) throws {
        guard let resourceURL = bundle.resourceURL else {
            throw RimeBuiltinResourceInstaller.InstallationError.resourceSetMismatch
        }
        let expected = Set(
            manifest.entries.compactMap { $0.path.split(separator: "/").last.map(String.init) }
        ).union([RimeBuiltinResourceInstaller.manifestFileName])
        let closureExtensions: Set<String> = ["bin", "json", "ocd2", "yaml"]
        let rootFiles = try FileManager.default.contentsOfDirectory(
            at: resourceURL,
            includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey]
        )
        for url in rootFiles where closureExtensions.contains(url.pathExtension.lowercased()) {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
            guard values.isRegularFile == true, values.isSymbolicLink != true else {
                throw RimeBuiltinResourceInstaller.InstallationError.resourceNotRegularFile
            }
            guard expected.contains(url.lastPathComponent) else {
                throw RimeBuiltinResourceInstaller.InstallationError.resourceSetMismatch
            }
        }
    }
}
