import CryptoKit
import Foundation
import KeyboardCore

/// PR1 isolation fixture only: no installer callback, scheme registration or readiness publication.
/// Resource rollback models the installer's outer boundary; PR2 must reverify the real wiring.
final class LunaT9DeploymentSupport {
    enum Point: String, CaseIterable, Sendable {
        case backupResources, backupSource, backupOverlays, backupReceipts
        case resourceWrite, resourceReceiptWrite
        case sourceWrite, sourceReplace, overlayWrite, overlayReplace, overlayReceiptWrite
        case cacheDelete, restoreSource, restoreOverlay, restoreResources
    }

    enum TransactionError: Error, Equatable {
        case injected(Point)
        case unsafePath
        case contentMismatch
        case rollbackFailed([Point])
    }

    struct Prepared: Equatable {
        let sourceSHA256: String
        let patchInputSHA256: String
    }

    private struct SavedFile {
        let path: String
        let backup: URL?
    }

    let scenario: URL
    let runtime: URL
    let backupRoot: URL
    private let fileManager = FileManager.default
    private let inject: (Point) throws -> Void
    private var deletionAudit = ""
    private(set) var oldAuthorizationPreserved = false

    init(scenario: URL, inject: @escaping (Point) throws -> Void = { _ in }) throws {
        let root = scenario.standardizedFileURL.resolvingSymlinksInPath()
        // The caller creates a fresh scene. Never accept an alias as a deletion boundary.
        guard root.pathComponents == scenario.standardizedFileURL.pathComponents else {
            throw TransactionError.unsafePath
        }
        self.scenario = root
        self.runtime = root.appendingPathComponent("runtime", isDirectory: true)
        self.backupRoot = root.appendingPathComponent("backup-\(UUID().uuidString)", isDirectory: true)
        self.inject = inject
        try fileManager.createDirectory(at: backupRoot, withIntermediateDirectories: true)
    }

    /// Fixture orchestration boundary: resources -> callback-like prepare -> resource rollback.
    /// A callback rollback error must survive even if resource restoration succeeds.
    func deploy(sourceRoot: URL) throws -> Prepared {
        oldAuthorizationPreserved = false
        let installer = RimeBuiltinResourceInstaller()
        let manifest = try installer.validateResourceTree(at: sourceRoot)
        let resourcePaths =
            manifest.entries.map { "shared/\($0.path)" }
            + [RimeBuiltinResourceInstaller.resourceReceiptFileName]
        try inject(.backupResources)
        let resources = try save(resourcePaths, group: "resources")
        var resourcesMutated = false
        do {
            // Set before the first write: even an I/O error halfway through needs restoration.
            resourcesMutated = true
            for entry in manifest.entries {
                try inject(.resourceWrite)
                try write(Data(contentsOf: sourceRoot.appendingPathComponent(entry.path)), to: "shared/\(entry.path)")
            }
            try inject(.resourceReceiptWrite)
            let receipt = RimeBuiltinResourceInstaller.ResourceReceipt(
                formatVersion: 1, manifestSHA256: Self.digest(try Self.encode(manifest)), manifest: manifest
            )
            try write(try Self.encode(receipt), to: RimeBuiltinResourceInstaller.resourceReceiptFileName)
            _ = try installer.validateInstalledResources(rimeRoot: runtime)
            return try prepare()
        } catch {
            var failed = Self.rollbackFailures(in: error)
            if resourcesMutated {
                do {
                    try inject(.restoreResources)
                    try restore(resources)
                } catch {
                    failed.append(.restoreResources)
                }
            }
            if !failed.isEmpty {
                // No unconditional cleanup: both layers' backups remain usable by the caller.
                throw TransactionError.rollbackFailed(failed)
            }
            oldAuthorizationPreserved =
                (try? installer.validateInstalledRuntime(
                    rimeRoot: runtime, userDataURL: runtime.appendingPathComponent("user")
                )) != nil
            throw error
        }
    }

    /// No markers are written, including on success. Compilation/smoke are outside this fixture.
    func prepare() throws -> Prepared {
        _ = try RimeBuiltinResourceInstaller().validateInstalledResources(rimeRoot: runtime)
        let source = try LunaT9SchemaCompatibility.rewrite(
            Data(contentsOf: checked(runtime.appendingPathComponent("shared/luna_pinyin.schema.yaml")))
        )
        try inject(.backupSource)
        let savedSource = try save([Self.derivedPath], group: "derived")
        try inject(.backupOverlays)
        let savedOverlays = try save(Self.overlayPaths, group: "overlays")
        try inject(.backupReceipts)
        let savedReceipt = try save([RimeBuiltinResourceInstaller.overlayReceiptFileName], group: "overlay-receipt")
        var mutated = false
        do {
            try inject(.sourceWrite)
            let stagedSource = backupRoot.appendingPathComponent("staged-source")
            try source.write(to: checked(stagedSource))
            guard try Data(contentsOf: stagedSource) == source else { throw TransactionError.contentMismatch }
            try inject(.sourceReplace)
            mutated = true
            try write(source, to: Self.derivedPath)
            // Read the replaced file, not a stale caller string, to bind the patch's input proof.
            let compileInput = try Data(contentsOf: checked(runtime.appendingPathComponent(Self.derivedPath)))
            guard compileInput == source else { throw TransactionError.contentMismatch }
            let patch = try Self.overlay(for: compileInput)
            let overlays = [
                "user/default.custom.yaml": Data("patch:\n  schema_list:\n    - schema: luna_pinyin\n".utf8),
                "user/luna_pinyin.custom.yaml": Data("patch:\n  translator/enable_user_dict: true\n".utf8),
                Self.derivedOverlayPath: patch,
            ]
            for path in overlays.keys.sorted() {
                guard let content = overlays[path] else { throw TransactionError.contentMismatch }
                try inject(.overlayWrite)
                let staged = backupRoot.appendingPathComponent("staged-\(URL(fileURLWithPath: path).lastPathComponent)")
                try content.write(to: checked(staged))
                guard try Data(contentsOf: staged) == content else { throw TransactionError.contentMismatch }
                try inject(.overlayReplace)
                try write(content, to: path)
            }
            try inject(.overlayReceiptWrite)
            try RimeBuiltinResourceInstaller().recordOverlayReceipt(
                rimeRoot: runtime, userDataURL: runtime.appendingPathComponent("user")
            )
            try clearCaches()
            return Prepared(sourceSHA256: Self.digest(source), patchInputSHA256: Self.digest(compileInput))
        } catch {
            guard mutated else { throw error }
            var failed: [Point] = []
            // Attempt all independent restorations, even after one fails.
            do {
                try inject(.restoreOverlay)
                try restore(savedOverlays + savedReceipt)
            } catch { failed.append(.restoreOverlay) }
            do {
                try inject(.restoreSource)
                try restore(savedSource)
            } catch { failed.append(.restoreSource) }
            if !failed.isEmpty { throw TransactionError.rollbackFailed(failed) }
            throw error
        }
    }

    private func save(_ paths: [String], group: String) throws -> [SavedFile] {
        try paths.map { path in
            let current = try checked(runtime.appendingPathComponent(path))
            guard fileManager.fileExists(atPath: current.path) else {
                return SavedFile(path: path, backup: nil)
            }
            let backup = try checked(backupRoot.appendingPathComponent("\(group)/\(path)"))
            try fileManager.createDirectory(at: backup.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fileManager.copyItem(at: current, to: backup)
            return SavedFile(path: path, backup: backup)
        }
    }

    private func restore(_ files: [SavedFile]) throws {
        for saved in files {
            if let backup = saved.backup {
                try write(Data(contentsOf: checked(backup)), to: saved.path)
            } else {
                let target = try checked(runtime.appendingPathComponent(saved.path))
                if fileManager.fileExists(atPath: target.path) {
                    try removeManagedItem(target, category: "fresh-rollback")
                }
            }
        }
    }

    private func write(_ bytes: Data, to path: String) throws {
        let url = try checked(runtime.appendingPathComponent(path))
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        // Foundation stages alongside the target and replaces atomically; no remove-then-write gap.
        try bytes.write(to: url, options: .atomic)
        guard try Data(contentsOf: url) == bytes else { throw TransactionError.contentMismatch }
    }

    private func clearCaches() throws {
        for directory in ["shared/build", "user/build"] {
            let build = try checked(runtime.appendingPathComponent(directory))
            guard fileManager.fileExists(atPath: build.path) else { continue }
            for entry in try fileManager.contentsOfDirectory(at: build, includingPropertiesForKeys: nil)
                .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            where entry.lastPathComponent.hasPrefix("luna_pinyin_t9.") {
                try inject(.cacheDelete)
                try removeManagedItem(entry, category: "cache")
                guard !fileManager.fileExists(atPath: entry.path) else { throw TransactionError.contentMismatch }
            }
        }
    }

    /// Resolve symlinks, compare path components, reject the boundary itself and all escapes.
    /// This is a synchronous isolation guard, not a claim of cross-process TOCTOU safety.
    func checked(_ url: URL) throws -> URL {
        let resolved = url.standardizedFileURL.resolvingSymlinksInPath()
        let base = scenario.pathComponents
        let components = resolved.pathComponents
        guard components.count > base.count, Array(components.prefix(base.count)) == base else {
            throw TransactionError.unsafePath
        }
        return resolved
    }

    func removeManagedItem(_ url: URL, category: String) throws {
        let safe = try checked(url)
        let relative = Array(safe.pathComponents.dropFirst(scenario.pathComponents.count)).joined(separator: "/")
        // The private backup tree and arbitrary scene files are never deletion candidates.
        let freshTargets = Set(
            RimeBuiltinResourceInstaller.requiredRelativePaths.map { "runtime/shared/\($0)" }
                + ([Self.derivedPath] + Self.overlayPaths + [
                    RimeBuiltinResourceInstaller.resourceReceiptFileName,
                    RimeBuiltinResourceInstaller.overlayReceiptFileName,
                ]).map { "runtime/\($0)" }
        )
        let isCache =
            ["runtime/shared/build", "runtime/user/build"].contains(
                safe.deletingLastPathComponent().pathComponents.dropFirst(scenario.pathComponents.count).joined(
                    separator: "/")
            ) && safe.lastPathComponent.hasPrefix("luna_pinyin_t9.")
        guard (category == "cache" && isCache) || (category == "fresh-rollback" && freshTargets.contains(relative))
        else { throw TransactionError.unsafePath }
        let values = try safe.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true else { throw TransactionError.unsafePath }
        try fileManager.removeItem(at: safe)
        // Keep a durable audit per scene; backups and audit files are intentionally retained.
        deletionAudit += "\(category)\t\(relative)\n"
        try deletionAudit.write(
            to: checked(scenario.appendingPathComponent("deletions.tsv")), atomically: true, encoding: .utf8)
        print("CONTROLLED_DELETE \(scenario.lastPathComponent) \(category) \(relative)")
    }

    private static func rollbackFailures(in error: Error) -> [Point] {
        if let transactionError = error as? TransactionError,
            case .rollbackFailed(let points) = transactionError
        {
            return points
        }
        return []
    }

    static let derivedPath = "shared/luna_pinyin_t9.schema.yaml"
    static let derivedOverlayPath = "user/luna_pinyin_t9.custom.yaml"
    static let overlayPaths = ["user/default.custom.yaml", "user/luna_pinyin.custom.yaml", derivedOverlayPath]

    static func digest(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    private static func overlay(for source: Data) throws -> Data {
        guard digest(source) == LunaT9SchemaCompatibility.outputSHA256,
            let text = String(data: source, encoding: .utf8),
            let start = text.range(of: "  algebra:\n"),
            let end = text.range(of: "\ntranslator:", range: start.upperBound..<text.endIndex)
        else { throw TransactionError.contentMismatch }
        // Fixture-only compile patch: reviewed algebra copied as a whole, including the final xlit.
        let algebra = String(text[start.upperBound..<end.lowerBound])
        return Data(("# compile-input-sha256: \(digest(source))\npatch:\n  speller/algebra:\n" + algebra + "\n").utf8)
    }
}
