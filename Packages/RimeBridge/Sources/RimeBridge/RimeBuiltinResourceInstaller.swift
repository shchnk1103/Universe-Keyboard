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
        let sourceInputs: [String: SourceInput]
        let generators: [String: Generator]
        let toolchain: [String: Tool]
        let reproducibility: Reproducibility
        let overlayPolicy: OverlayPolicy
        let entries: [Entry]

        struct SourceInput: Codable, Equatable, Sendable {
            let repository: String
            let revision: String
            let files: [InputFile]
        }

        struct InputFile: Codable, Equatable, Sendable {
            let path: String
            let sha256: String
        }

        struct Generator: Codable, Equatable, Sendable {
            let version: String
            let sha256: String?
            let sourceRepository: String
            let sourceRevision: String?
            let commandArguments: [[String]]
        }

        struct Tool: Codable, Equatable, Sendable {
            let path: String
            let version: String
            let sha256: String
        }

        struct Reproducibility: Codable, Equatable, Sendable {
            let hostOSVersion: String
            let hostOSBuild: String
            let hostArchitecture: String
            let command: String
            let digestScope: String
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
    private static let requiredToolchainKeys: Set<String> = [
        "bash", "cmake", "cxxCompiler", "generationScript", "openccPython", "python3",
    ]
    private static let requiredSourceRepositories: [String: String] = [
        "essay": "https://github.com/rime/rime-essay.git",
        "lunaPinyin": "https://github.com/rime/rime-luna-pinyin.git",
        "opencc": "https://github.com/BYVoid/OpenCC.git",
        "prelude": "https://github.com/rime/rime-prelude.git",
        "stroke": "https://github.com/rime/rime-stroke.git",
    ]
    private static let requiredSourceInputPaths: [String: Set<String>] = [
        "essay": ["essay.txt"],
        "lunaPinyin": [
            "luna_pinyin.dict.yaml", "luna_pinyin.schema.yaml", "pinyin.yaml",
        ],
        "opencc": [
            "data/config/s2t.json", "data/config/t2hk.json", "data/config/t2s.json",
            "data/config/t2tw.json", "data/dictionary/HKVariants.txt",
            "data/dictionary/STCharacters.txt", "data/dictionary/STPhrases.txt",
            "data/dictionary/TSCharacters.txt", "data/dictionary/TSPhrases.txt",
            "data/dictionary/TWVariants.txt",
        ],
        "prelude": ["default.yaml", "key_bindings.yaml", "punctuation.yaml", "symbols.yaml"],
        "stroke": ["stroke.dict.yaml", "stroke.schema.yaml"],
    ]

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
    /// value, preserving the last known-good runtime. The optional completion
    /// runs before installer backups are discarded so the main App can commit
    /// generation-bound overlays inside the same recoverable boundary.
    public func install(
        sourceRoot: URL,
        rimeRoot: URL,
        afterInstallingResources: (() throws -> Void)? = nil
    ) throws -> InstallationResult {
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
            if let afterInstallingResources {
                // The callback owns overlay replacement and receipt creation.
                // If it fails, its local rollback runs first, then this
                // installer's catch restores the prior immutable generation.
                try afterInstallingResources()
            } else {
                // Direct installer callers do not provide replacement
                // overlays, so a prior authorization must not survive.
                let overlayReceiptURL = rimeRoot.appendingPathComponent(Self.overlayReceiptFileName)
                if fileManager.fileExists(atPath: overlayReceiptURL.path) {
                    try fileManager.removeItem(at: overlayReceiptURL)
                }
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
        let receipt = try validatedResourceReceipt(rimeRoot: rimeRoot)
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
        try validateOverlayAuthorization(
            resourceReceipt: resourceReceipt,
            rimeRoot: rimeRoot,
            userDataURL: userDataURL
        )
    }

    /// Lightweight Extension-side authorization. The main App already hashes
    /// the full immutable closure before publishing receipts; startup only
    /// verifies that the resource and overlay receipts still form one identity
    /// and that the small dynamic overlays retain their recorded hashes.
    func validateInstalledRuntimeAuthorization(rimeRoot: URL, userDataURL: URL) throws {
        let resourceReceipt = try validatedResourceReceipt(rimeRoot: rimeRoot)
        try validateOverlayAuthorization(
            resourceReceipt: resourceReceipt,
            rimeRoot: rimeRoot,
            userDataURL: userDataURL
        )
    }

    private func validatedResourceReceipt(rimeRoot: URL) throws -> ResourceReceipt {
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
        return receipt
    }

    private func validateOverlayAuthorization(
        resourceReceipt: ResourceReceipt,
        rimeRoot: URL,
        userDataURL: URL
    ) throws {
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
        guard manifest.formatVersion == 3 else {
            throw InstallationError.unsupportedManifestVersion(manifest.formatVersion)
        }
        guard
            !manifest.generationID.isEmpty,
            Self.isSafeIdentifier(manifest.generationID),
            Set(manifest.sourcePins.keys) == Self.requiredSourcePinKeys,
            manifest.sourcePins.values.allSatisfy(Self.isSHA1),
            Set(manifest.sourceInputs.keys) == Self.requiredSourcePinKeys,
            Set(manifest.generators.keys) == Self.requiredGeneratorKeys,
            let rimeGenerator = manifest.generators["rimeDeployer"],
            !rimeGenerator.version.isEmpty,
            rimeGenerator.sha256.map(Self.isSHA256) == true,
            rimeGenerator.sourceRepository == "https://github.com/rime/librime.git",
            rimeGenerator.sourceRevision == nil,
            let openCCGenerator = manifest.generators["opencc"],
            !openCCGenerator.version.isEmpty,
            openCCGenerator.sha256 == nil,
            openCCGenerator.sourceRepository == Self.requiredSourceRepositories["opencc"],
            openCCGenerator.sourceRevision.map(Self.isSHA1) == true,
            openCCGenerator.sourceRevision == manifest.sourcePins["opencc"],
            Set(manifest.toolchain.keys) == Self.requiredToolchainKeys,
            !manifest.reproducibility.hostOSVersion.isEmpty,
            !manifest.reproducibility.hostOSBuild.isEmpty,
            !manifest.reproducibility.hostArchitecture.isEmpty,
            manifest.reproducibility.command
                == "scripts/generate_builtin_rime_resources.sh <pinned-source-root> <output-root>",
            manifest.reproducibility.digestScope == "payload-tree-excluding-manifest",
            Self.isSHA256(manifest.reproducibility.cleanOutputSHA256A),
            manifest.reproducibility.cleanOutputSHA256A
                == manifest.reproducibility.cleanOutputSHA256B,
            manifest.overlayPolicy.identifier == Self.overlayPolicyIdentifier,
            Set(manifest.overlayPolicy.requiredFiles) == Self.requiredOverlayPaths
        else { throw InstallationError.manifestInvalid }

        try Self.validateProvenance(manifest)

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

    private static func validateProvenance(_ manifest: Manifest) throws {
        for key in requiredSourcePinKeys {
            guard
                let source = manifest.sourceInputs[key],
                source.repository == requiredSourceRepositories[key],
                source.revision == manifest.sourcePins[key],
                source.files.isEmpty == false,
                Set(source.files.map(\.path)).count == source.files.count,
                Set(source.files.map(\.path)) == requiredSourceInputPaths[key],
                source.files.allSatisfy({
                    isSafeRelativePath($0.path) && isSHA256($0.sha256)
                })
            else { throw InstallationError.manifestInvalid }
        }

        for generator in manifest.generators.values {
            guard
                generator.commandArguments.isEmpty == false,
                generator.commandArguments.allSatisfy({ command in
                    command.isEmpty == false && command.allSatisfy { $0.isEmpty == false }
                })
            else { throw InstallationError.manifestInvalid }
        }

        guard
            let rimeDeployer = manifest.generators["rimeDeployer"],
            let rimeDeployerPath = rimeDeployer.commandArguments.first?.first,
            let cmakePath = manifest.toolchain["cmake"]?.path,
            rimeDeployer.commandArguments
                == expectedRimeCommands(executable: rimeDeployerPath),
            manifest.generators["opencc"]?.commandArguments
                == expectedOpenCCCommands(executable: cmakePath)
        else { throw InstallationError.manifestInvalid }

        for tool in manifest.toolchain.values {
            guard
                tool.path.isEmpty == false,
                tool.version.isEmpty == false,
                isSHA256(tool.sha256)
            else { throw InstallationError.manifestInvalid }
        }

        // Directly packaged source/config bytes must be the same bytes named by
        // the upstream input receipt. Generated outputs remain bound by their
        // own manifest entry hashes and the generator command/toolchain receipt.
        let packagedMappings: [(source: String, input: String, entry: String)] = [
            ("essay", "essay.txt", "essay.txt"),
            ("lunaPinyin", "luna_pinyin.dict.yaml", "luna_pinyin.dict.yaml"),
            ("lunaPinyin", "luna_pinyin.schema.yaml", "luna_pinyin.schema.yaml"),
            ("lunaPinyin", "pinyin.yaml", "pinyin.yaml"),
            ("prelude", "default.yaml", "default.yaml"),
            ("prelude", "key_bindings.yaml", "key_bindings.yaml"),
            ("prelude", "punctuation.yaml", "punctuation.yaml"),
            ("prelude", "symbols.yaml", "symbols.yaml"),
            ("stroke", "stroke.dict.yaml", "stroke.dict.yaml"),
            ("stroke", "stroke.schema.yaml", "stroke.schema.yaml"),
            ("opencc", "data/config/s2t.json", "opencc/s2t.json"),
            ("opencc", "data/config/t2hk.json", "opencc/t2hk.json"),
            ("opencc", "data/config/t2s.json", "opencc/t2s.json"),
            ("opencc", "data/config/t2tw.json", "opencc/t2tw.json"),
        ]
        let entriesByPath = Dictionary(
            uniqueKeysWithValues: manifest.entries.map {
                ($0.path, $0.sha256)
            }
        )
        for mapping in packagedMappings {
            let inputHash = manifest.sourceInputs[mapping.source]?.files.first {
                $0.path == mapping.input
            }?.sha256
            guard inputHash == entriesByPath[mapping.entry] else {
                throw InstallationError.manifestInvalid
            }
        }
    }

    private static func expectedRimeCommands(executable: String) -> [[String]] {
        ["rime-a", "rime-b"].flatMap { run in
            ["luna_pinyin.schema.yaml", "stroke.schema.yaml"].map { schema in
                let root = "<work-root>/\(run)"
                return [
                    executable, "--compile", "\(root)/shared/\(schema)",
                    "\(root)/user", "\(root)/shared", "\(root)/staging",
                ]
            }
        }
    }

    private static func expectedOpenCCCommands(executable: String) -> [[String]] {
        ["opencc-a", "opencc-b"].flatMap { run in
            let buildRoot = "<work-root>/\(run)"
            return [
                [
                    executable, "-S", "<pinned-source-root>/OpenCC", "-B", buildRoot,
                    "-DCMAKE_BUILD_TYPE=Release", "-DBUILD_DOCUMENTATION=OFF",
                    "-DENABLE_GTEST=OFF",
                ],
                [
                    executable, "--build", buildRoot, "--target", "Dictionaries", "-j", "8",
                ],
            ]
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
