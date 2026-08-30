import CryptoKit
import Foundation

/// Validates and installs the immutable RIME closure bundled by the main App.
public struct RimeBuiltinResourceInstaller {
    static let manifestFileName = "RimeBuiltin.manifest.json"

    public struct InstallationResult: Equatable, Sendable {
        public let generationID: String
        public let fileCount: Int
        public let byteCount: Int64
    }

    public enum InstallationError: Error, Equatable, Sendable {
        case manifestMissing
        case manifestInvalid
        case unsupportedManifestVersion(Int)
        case unsafePath
        case duplicatePath
        case resourceSetMismatch
        case resourceNotRegularFile
        case byteCountMismatch
        case checksumMismatch
        case fileOperationFailed
        case rollbackFailed
    }

    struct Manifest: Codable, Equatable, Sendable {
        let formatVersion: Int
        let generationID: String
        let sourcePins: [String: String]
        let generators: [String: Generator]
        let reproducibility: Reproducibility
        let overlayPolicy: OverlayPolicy
        let entries: [Entry]

        struct Generator: Codable, Equatable, Sendable {
            let version: String
            let sha256: String?
            let sourceRevision: String?
        }

        struct Reproducibility: Codable, Equatable, Sendable {
            let host: String
            let command: String
            let cleanOutputSHA256A: String
            let cleanOutputSHA256B: String
        }

        struct OverlayPolicy: Codable, Equatable, Sendable {
            let identifier: String
            let requiredFiles: [String]
        }

        struct Entry: Codable, Equatable, Sendable {
            let path: String
            let byteCount: Int64
            let sha256: String
            let role: String
        }
    }

    struct ResourceReceipt: Codable, Equatable, Sendable {
        let formatVersion: Int
        let manifestSHA256: String
        let manifest: Manifest
    }

    struct OverlayReceipt: Codable, Equatable, Sendable {
        let formatVersion: Int
        let generationID: String
        let manifestSHA256: String
        let policyIdentifier: String
        let entries: [OverlayEntry]

        struct OverlayEntry: Codable, Equatable, Sendable {
            let path: String
            let byteCount: Int64
            let sha256: String
        }
    }

    /// The allowlist prevents an incomplete manifest from authorizing an
    /// incomplete runtime. Closure changes must therefore be explicit here.
    static let requiredRelativePaths: Set<String> = [
        "build/luna_pinyin.prism.bin",
        "build/luna_pinyin.reverse.bin",
        "build/luna_pinyin.table.bin",
        "build/stroke.prism.bin",
        "build/stroke.reverse.bin",
        "build/stroke.table.bin",
        "default.yaml",
        "essay.txt",
        "key_bindings.yaml",
        "luna_pinyin.dict.yaml",
        "luna_pinyin.schema.yaml",
        "opencc/HKVariants.ocd2",
        "opencc/STCharacters.ocd2",
        "opencc/STPhrases.ocd2",
        "opencc/TSCharacters.ocd2",
        "opencc/TSPhrases.ocd2",
        "opencc/TWVariants.ocd2",
        "opencc/s2t.json",
        "opencc/t2hk.json",
        "opencc/t2s.json",
        "opencc/t2tw.json",
        "pinyin.yaml",
        "punctuation.yaml",
        "stroke.dict.yaml",
        "stroke.schema.yaml",
        "symbols.yaml",
    ]
    static let resourceReceiptFileName = "builtin-resource-receipt.json"
    static let overlayReceiptFileName = "builtin-overlay-receipt.json"
    static let overlayPolicyIdentifier = "universe-luna-overlay-v1"
    static let requiredOverlayPaths: Set<String> = [
        "default.custom.yaml",
        "luna_pinyin.custom.yaml",
    ]
    private static let requiredSourcePinKeys: Set<String> = [
        "essay", "lunaPinyin", "opencc", "prelude", "stroke",
    ]
    private static let requiredGeneratorKeys: Set<String> = ["opencc", "rimeDeployer"]

    private struct Mutation {
        let destination: URL
        let backup: URL?
        let installedNew: Bool
    }

    private let fileManager: FileManager
    private let testFailureBeforeInstallingPath: String?

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.testFailureBeforeInstallingPath = nil
    }

    init(
        fileManager: FileManager = .default,
        testFailureBeforeInstallingPath: String?
    ) {
        self.fileManager = fileManager
        self.testFailureBeforeInstallingPath = testFailureBeforeInstallingPath
    }

    /// Source validation completes before any shared-runtime mutation. A
    /// synchronous move failure rolls every installed file back to its prior
    /// value, preserving the last known-good runtime.
    public func install(sourceRoot: URL, rimeRoot: URL) throws -> InstallationResult {
        let manifest = try validateResourceTree(at: sourceRoot)
        let manifestSHA256 = try Self.manifestSHA256(manifest)
        let stagingRoot = rimeRoot.appendingPathComponent(
            ".builtin-staging-\(UUID().uuidString)", isDirectory: true
        )
        let stagedShared = stagingRoot.appendingPathComponent("shared", isDirectory: true)
        let backupRoot = rimeRoot.appendingPathComponent(
            ".builtin-backup-\(UUID().uuidString)", isDirectory: true
        )
        let sharedRoot = rimeRoot.appendingPathComponent("shared", isDirectory: true)
        let receiptURL = rimeRoot.appendingPathComponent(Self.resourceReceiptFileName)
        let priorReceiptData = try? Data(contentsOf: receiptURL)
        // Never trust a stale-path ownership claim from receipt JSON alone.
        // When a receipt exists, its manifest hash and every currently owned
        // byte must validate before it may authorize removals.
        let priorManifest = try priorReceiptData.map { _ in
            try validateInstalledResources(rimeRoot: rimeRoot).manifest
        }
        var mutations: [Mutation] = []

        do {
            try fileManager.createDirectory(at: stagedShared, withIntermediateDirectories: true)
            try copyManifestAndEntries(manifest, from: sourceRoot, to: stagedShared)
            _ = try validateResourceTree(at: stagedShared)
            try fileManager.createDirectory(at: sharedRoot, withIntermediateDirectories: true)

            for entry in manifest.entries.sorted(by: { $0.path < $1.path }) {
                let stagedURL = stagedShared.appendingPathComponent(entry.path)
                let destinationURL = sharedRoot.appendingPathComponent(entry.path)
                try fileManager.createDirectory(
                    at: destinationURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                var backupURL: URL?
                if fileManager.fileExists(atPath: destinationURL.path) {
                    let candidate = backupRoot.appendingPathComponent(entry.path)
                    try fileManager.createDirectory(
                        at: candidate.deletingLastPathComponent(),
                        withIntermediateDirectories: true
                    )
                    try fileManager.moveItem(at: destinationURL, to: candidate)
                    backupURL = candidate
                }
                do {
                    if entry.path == testFailureBeforeInstallingPath {
                        throw InstallationError.fileOperationFailed
                    }
                    try fileManager.moveItem(at: stagedURL, to: destinationURL)
                    mutations.append(Mutation(destination: destinationURL, backup: backupURL, installedNew: true))
                } catch {
                    if let backupURL {
                        try fileManager.moveItem(at: backupURL, to: destinationURL)
                    }
                    throw error
                }
            }

            // A previous generation may own paths that the new manifest no
            // longer contains. Remove only receipt-owned stale files so
            // downloaded schemes and librime output remain untouched.
            let stalePaths = Set(priorManifest?.entries.map(\.path) ?? [])
                .subtracting(manifest.entries.map(\.path))
            for path in stalePaths.sorted() {
                guard Self.isSafeRelativePath(path) else {
                    throw InstallationError.unsafePath
                }
                let destinationURL = sharedRoot.appendingPathComponent(path)
                guard fileManager.fileExists(atPath: destinationURL.path) else { continue }
                let backupURL = backupRoot.appendingPathComponent("stale/\(path)")
                try fileManager.createDirectory(
                    at: backupURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try fileManager.moveItem(at: destinationURL, to: backupURL)
                mutations.append(
                    Mutation(destination: destinationURL, backup: backupURL, installedNew: false)
                )
            }

            try validateDeployedEntries(manifest, under: sharedRoot)
            let receipt = ResourceReceipt(
                formatVersion: 1,
                manifestSHA256: manifestSHA256,
                manifest: manifest
            )
            let receiptData = try Self.sortedJSONEncoder().encode(receipt)
            try receiptData.write(to: receiptURL, options: .atomic)
            _ = try validateInstalledResources(rimeRoot: rimeRoot)
            // A resource-generation change invalidates every previously
            // recorded overlay until the main App writes and hashes it again.
            let overlayReceiptURL = rimeRoot.appendingPathComponent(Self.overlayReceiptFileName)
            if fileManager.fileExists(atPath: overlayReceiptURL.path) {
                try fileManager.removeItem(at: overlayReceiptURL)
            }
            try? fileManager.removeItem(at: backupRoot)
            try? fileManager.removeItem(at: stagingRoot)
            return InstallationResult(
                generationID: manifest.generationID,
                fileCount: manifest.entries.count,
                byteCount: manifest.entries.reduce(0) { $0 + $1.byteCount }
            )
        } catch let error as InstallationError {
            try rollbackOrThrow(mutations.reversed(), receiptURL: receiptURL, priorReceiptData: priorReceiptData)
            try? fileManager.removeItem(at: stagingRoot)
            try? fileManager.removeItem(at: backupRoot)
            throw error
        } catch {
            try rollbackOrThrow(mutations.reversed(), receiptURL: receiptURL, priorReceiptData: priorReceiptData)
            try? fileManager.removeItem(at: stagingRoot)
            try? fileManager.removeItem(at: backupRoot)
            throw InstallationError.fileOperationFailed
        }
    }

    /// Verifies that the receipt describes the exact bytes currently owned by
    /// the built-in generation in `Rime/shared`.
    @discardableResult
    func validateInstalledResources(rimeRoot: URL) throws -> ResourceReceipt {
        let receiptURL = rimeRoot.appendingPathComponent(Self.resourceReceiptFileName)
        let receipt: ResourceReceipt
        do {
            receipt = try JSONDecoder().decode(ResourceReceipt.self, from: Data(contentsOf: receiptURL))
        } catch {
            throw InstallationError.manifestInvalid
        }
        guard receipt.formatVersion == 1 else { throw InstallationError.manifestInvalid }
        try validateManifest(receipt.manifest)
        guard try Self.manifestSHA256(receipt.manifest) == receipt.manifestSHA256 else {
            throw InstallationError.checksumMismatch
        }
        try validateDeployedEntries(
            receipt.manifest,
            under: rimeRoot.appendingPathComponent("shared", isDirectory: true)
        )
        return receipt
    }

    /// Binds the dynamic user overlays to the immutable resource generation.
    /// The receipt is written only after both required overlays are readable
    /// regular files and their hashes have been collected.
    func recordOverlayReceipt(rimeRoot: URL, userDataURL: URL) throws {
        let resourceReceipt = try validateInstalledResources(rimeRoot: rimeRoot)
        let entries = try Self.requiredOverlayPaths.sorted().map { path -> OverlayReceipt.OverlayEntry in
            guard Self.isSafeRelativePath(path) else { throw InstallationError.unsafePath }
            let url = userDataURL.appendingPathComponent(path)
            let values = try url.resourceValues(forKeys: [
                .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey,
            ])
            guard values.isRegularFile == true, values.isSymbolicLink != true else {
                throw InstallationError.resourceNotRegularFile
            }
            return OverlayReceipt.OverlayEntry(
                path: path,
                byteCount: Int64(values.fileSize ?? -1),
                sha256: try Self.sha256(of: url)
            )
        }
        let receipt = OverlayReceipt(
            formatVersion: 1,
            generationID: resourceReceipt.manifest.generationID,
            manifestSHA256: resourceReceipt.manifestSHA256,
            policyIdentifier: resourceReceipt.manifest.overlayPolicy.identifier,
            entries: entries
        )
        try Self.sortedJSONEncoder().encode(receipt).write(
            to: rimeRoot.appendingPathComponent(Self.overlayReceiptFileName),
            options: .atomic
        )
    }

    /// Runtime smoke authorization for built-in Luna. A missing, stale or
    /// corrupt resource/overlay receipt fails closed.
    func validateInstalledRuntime(rimeRoot: URL, userDataURL: URL) throws {
        let resourceReceipt = try validateInstalledResources(rimeRoot: rimeRoot)
        let overlayReceipt: OverlayReceipt
        do {
            overlayReceipt = try JSONDecoder().decode(
                OverlayReceipt.self,
                from: Data(
                    contentsOf: rimeRoot.appendingPathComponent(Self.overlayReceiptFileName)
                )
            )
        } catch {
            throw InstallationError.manifestInvalid
        }
        guard
            overlayReceipt.formatVersion == 1,
            overlayReceipt.generationID == resourceReceipt.manifest.generationID,
            overlayReceipt.manifestSHA256 == resourceReceipt.manifestSHA256,
            overlayReceipt.policyIdentifier == resourceReceipt.manifest.overlayPolicy.identifier,
            Set(overlayReceipt.entries.map(\.path)) == Self.requiredOverlayPaths
        else { throw InstallationError.manifestInvalid }

        for entry in overlayReceipt.entries {
            let url = userDataURL.appendingPathComponent(entry.path)
            let values = try url.resourceValues(forKeys: [
                .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey,
            ])
            guard values.isRegularFile == true, values.isSymbolicLink != true else {
                throw InstallationError.resourceNotRegularFile
            }
            guard Int64(values.fileSize ?? -1) == entry.byteCount else {
                throw InstallationError.byteCountMismatch
            }
            guard try Self.sha256(of: url) == entry.sha256 else {
                throw InstallationError.checksumMismatch
            }
        }
    }

    @discardableResult
    func validateResourceTree(at root: URL) throws -> Manifest {
        let manifestURL = root.appendingPathComponent(Self.manifestFileName)
        guard fileManager.fileExists(atPath: manifestURL.path) else {
            throw InstallationError.manifestMissing
        }
        let manifest: Manifest
        do {
            manifest = try JSONDecoder().decode(Manifest.self, from: Data(contentsOf: manifestURL))
        } catch {
            throw InstallationError.manifestInvalid
        }
        try validateManifest(manifest)
        guard try actualResourcePaths(under: root) == Self.requiredRelativePaths else {
            throw InstallationError.resourceSetMismatch
        }

        for entry in manifest.entries {
            guard Self.isSafeRelativePath(entry.path) else { throw InstallationError.unsafePath }
            let url = root.appendingPathComponent(entry.path)
            let values: URLResourceValues
            do {
                values = try url.resourceValues(forKeys: [
                    .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey,
                ])
            } catch {
                throw InstallationError.resourceNotRegularFile
            }
            guard values.isRegularFile == true, values.isSymbolicLink != true else {
                throw InstallationError.resourceNotRegularFile
            }
            guard Int64(values.fileSize ?? -1) == entry.byteCount else {
                throw InstallationError.byteCountMismatch
            }
            guard try Self.sha256(of: url) == entry.sha256 else {
                throw InstallationError.checksumMismatch
            }
        }
        return manifest
    }

    private func validateManifest(_ manifest: Manifest) throws {
        guard manifest.formatVersion == 2 else {
            throw InstallationError.unsupportedManifestVersion(manifest.formatVersion)
        }
        guard
            !manifest.generationID.isEmpty,
            Self.isSafeIdentifier(manifest.generationID),
            Set(manifest.sourcePins.keys) == Self.requiredSourcePinKeys,
            manifest.sourcePins.values.allSatisfy(Self.isSHA1),
            Set(manifest.generators.keys) == Self.requiredGeneratorKeys,
            let rimeGenerator = manifest.generators["rimeDeployer"],
            !rimeGenerator.version.isEmpty,
            rimeGenerator.sha256.map(Self.isSHA256) == true,
            rimeGenerator.sourceRevision == nil,
            let openCCGenerator = manifest.generators["opencc"],
            !openCCGenerator.version.isEmpty,
            openCCGenerator.sha256 == nil,
            openCCGenerator.sourceRevision.map(Self.isSHA1) == true,
            openCCGenerator.sourceRevision == manifest.sourcePins["opencc"],
            !manifest.reproducibility.host.isEmpty,
            !manifest.reproducibility.command.isEmpty,
            Self.isSHA256(manifest.reproducibility.cleanOutputSHA256A),
            manifest.reproducibility.cleanOutputSHA256A
                == manifest.reproducibility.cleanOutputSHA256B,
            manifest.overlayPolicy.identifier == Self.overlayPolicyIdentifier,
            Set(manifest.overlayPolicy.requiredFiles) == Self.requiredOverlayPaths
        else { throw InstallationError.manifestInvalid }

        let paths = manifest.entries.map(\.path)
        guard Set(paths).count == paths.count else { throw InstallationError.duplicatePath }
        guard Set(paths) == Self.requiredRelativePaths else {
            throw InstallationError.resourceSetMismatch
        }
        for entry in manifest.entries {
            guard
                Self.isSafeRelativePath(entry.path),
                entry.byteCount > 0,
                Self.isSHA256(entry.sha256),
                entry.role == Self.expectedRole(for: entry.path)
            else { throw InstallationError.manifestInvalid }
        }
    }

    private func validateDeployedEntries(_ manifest: Manifest, under root: URL) throws {
        for entry in manifest.entries {
            let url = root.appendingPathComponent(entry.path)
            let values: URLResourceValues
            do {
                values = try url.resourceValues(forKeys: [
                    .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey,
                ])
            } catch {
                throw InstallationError.resourceNotRegularFile
            }
            guard values.isRegularFile == true, values.isSymbolicLink != true else {
                throw InstallationError.resourceNotRegularFile
            }
            guard Int64(values.fileSize ?? -1) == entry.byteCount else {
                throw InstallationError.byteCountMismatch
            }
            guard try Self.sha256(of: url) == entry.sha256 else {
                throw InstallationError.checksumMismatch
            }
        }
    }

    private func copyManifestAndEntries(_ manifest: Manifest, from source: URL, to destination: URL) throws {
        try fileManager.copyItem(
            at: source.appendingPathComponent(Self.manifestFileName),
            to: destination.appendingPathComponent(Self.manifestFileName)
        )
        for entry in manifest.entries {
            let target = destination.appendingPathComponent(entry.path)
            try fileManager.createDirectory(
                at: target.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try fileManager.copyItem(at: source.appendingPathComponent(entry.path), to: target)
        }
    }

    private func actualResourcePaths(under root: URL) throws -> Set<String> {
        guard
            let enumerator = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey],
                options: []
            )
        else { throw InstallationError.resourceSetMismatch }

        var paths = Set<String>()
        for case let url as URL in enumerator {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
            guard values.isRegularFile == true else { continue }
            guard values.isSymbolicLink != true else {
                throw InstallationError.resourceNotRegularFile
            }
            let path = url.path.replacingOccurrences(of: root.path + "/", with: "")
            if path != Self.manifestFileName { paths.insert(path) }
        }
        return paths
    }

    private func rollbackOrThrow<T: Sequence>(
        _ mutations: T,
        receiptURL: URL,
        priorReceiptData: Data?
    ) throws where T.Element == Mutation {
        do {
            for mutation in mutations {
                if mutation.installedNew,
                    fileManager.fileExists(atPath: mutation.destination.path)
                {
                    try fileManager.removeItem(at: mutation.destination)
                }
                if let backup = mutation.backup {
                    try fileManager.createDirectory(
                        at: mutation.destination.deletingLastPathComponent(),
                        withIntermediateDirectories: true
                    )
                    try fileManager.moveItem(at: backup, to: mutation.destination)
                }
            }
            if let priorReceiptData {
                try priorReceiptData.write(to: receiptURL, options: .atomic)
            } else if fileManager.fileExists(atPath: receiptURL.path) {
                try fileManager.removeItem(at: receiptURL)
            }
        } catch {
            throw InstallationError.rollbackFailed
        }
    }

    private static func sortedJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func manifestSHA256(_ manifest: Manifest) throws -> String {
        let data = try sortedJSONEncoder().encode(manifest)
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func isSafeRelativePath(_ path: String) -> Bool {
        guard !path.isEmpty, !path.hasPrefix("/"), !path.hasSuffix("/") else { return false }
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        return components.allSatisfy { !$0.isEmpty && $0 != "." && $0 != ".." }
    }

    private static func isSafeIdentifier(_ value: String) -> Bool {
        !value.isEmpty
            && value.unicodeScalars.allSatisfy {
                CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._")).contains($0)
            }
    }

    private static func isSHA1(_ value: String) -> Bool {
        value.count == 40 && value.allSatisfy { $0.isHexDigit && !$0.isUppercase }
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { $0.isHexDigit && !$0.isUppercase }
    }

    private static func expectedRole(for path: String) -> String {
        if path.hasSuffix(".bin") { return "generated-rime" }
        if path.hasSuffix(".ocd2") { return "generated-opencc" }
        if path.hasSuffix(".json") { return "opencc-config" }
        if path == "essay.txt" { return "preset-vocabulary" }
        return "source"
    }

    private static func sha256(of url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while let data = try handle.read(upToCount: 1_048_576), !data.isEmpty {
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }
}
