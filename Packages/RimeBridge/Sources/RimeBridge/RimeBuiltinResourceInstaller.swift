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
    }

    struct Manifest: Codable, Equatable, Sendable {
        let formatVersion: Int
        let generationID: String
        let sourcePins: [String: String]
        let generators: [String: Generator]
        let entries: [Entry]

        struct Generator: Codable, Equatable, Sendable {
            let version: String
            let sha256: String?
            let sourceRevision: String?
        }

        struct Entry: Codable, Equatable, Sendable {
            let path: String
            let byteCount: Int64
            let sha256: String
            let role: String
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

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /// Source validation completes before any shared-runtime mutation. A
    /// synchronous move failure rolls every installed file back to its prior
    /// value, preserving the last known-good runtime.
    public func install(sourceRoot: URL, rimeRoot: URL) throws -> InstallationResult {
        let manifest = try validateResourceTree(at: sourceRoot)
        let stagingRoot = rimeRoot.appendingPathComponent(
            ".builtin-staging-\(UUID().uuidString)", isDirectory: true
        )
        let stagedShared = stagingRoot.appendingPathComponent("shared", isDirectory: true)
        let backupRoot = rimeRoot.appendingPathComponent(
            ".builtin-backup-\(UUID().uuidString)", isDirectory: true
        )
        let sharedRoot = rimeRoot.appendingPathComponent("shared", isDirectory: true)
        var installed: [(destination: URL, backup: URL?)] = []

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
                    try fileManager.moveItem(at: stagedURL, to: destinationURL)
                    installed.append((destinationURL, backupURL))
                } catch {
                    if let backupURL {
                        try? fileManager.moveItem(at: backupURL, to: destinationURL)
                    }
                    throw error
                }
            }

            let receiptURL = rimeRoot.appendingPathComponent("builtin-resource-receipt.json")
            let receiptData = try JSONEncoder().encode(manifest)
            try receiptData.write(to: receiptURL, options: .atomic)
            try? fileManager.removeItem(at: backupRoot)
            try? fileManager.removeItem(at: stagingRoot)
            return InstallationResult(
                generationID: manifest.generationID,
                fileCount: manifest.entries.count,
                byteCount: manifest.entries.reduce(0) { $0 + $1.byteCount }
            )
        } catch let error as InstallationError {
            rollback(installed.reversed())
            try? fileManager.removeItem(at: stagingRoot)
            try? fileManager.removeItem(at: backupRoot)
            throw error
        } catch {
            rollback(installed.reversed())
            try? fileManager.removeItem(at: stagingRoot)
            try? fileManager.removeItem(at: backupRoot)
            throw InstallationError.fileOperationFailed
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
        guard manifest.formatVersion == 1 else {
            throw InstallationError.unsupportedManifestVersion(manifest.formatVersion)
        }
        guard !manifest.generationID.isEmpty else { throw InstallationError.manifestInvalid }

        let paths = manifest.entries.map(\.path)
        guard Set(paths).count == paths.count else { throw InstallationError.duplicatePath }
        guard Set(paths) == Self.requiredRelativePaths else {
            throw InstallationError.resourceSetMismatch
        }
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
            guard try Self.sha256(of: url) == entry.sha256.lowercased() else {
                throw InstallationError.checksumMismatch
            }
        }
        return manifest
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
                options: [.skipsHiddenFiles]
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

    private func rollback<T: Sequence>(_ installed: T) where T.Element == (destination: URL, backup: URL?) {
        for item in installed {
            try? fileManager.removeItem(at: item.destination)
            if let backup = item.backup {
                try? fileManager.moveItem(at: backup, to: item.destination)
            }
        }
    }

    private static func isSafeRelativePath(_ path: String) -> Bool {
        guard !path.isEmpty, !path.hasPrefix("/"), !path.hasSuffix("/") else { return false }
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        return components.allSatisfy { !$0.isEmpty && $0 != "." && $0 != ".." }
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
