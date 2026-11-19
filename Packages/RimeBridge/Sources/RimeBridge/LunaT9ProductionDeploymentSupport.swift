import CryptoKit
import Foundation
import KeyboardCore

/// Main-App production materialization of `luna_pinyin_t9.schema.yaml`.
/// The keyboard extension must never call this type.
public enum LunaT9ProductionDeploymentSupport {
    public struct Step: Equatable, Sendable {
        public let step: String
        public let reason: String
    }

    public struct CompiledCheck: Equatable, Sendable {
        public let step: Step
        public var failed: Bool { step.reason != "compiledClean" }
    }

    public struct ProductionError: Error, CustomStringConvertible, Equatable {
        public let message: String
        public var description: String { message }
    }

    #if DEBUG
        /// Release builds omit this seam. Tests set it for one `LunaT9DeploymentSupport.Point` at a time.
        nonisolated(unsafe) static var debugInjection: ((LunaT9DeploymentSupport.Point) throws -> Void)?
    #endif

    static func debugHit(_ point: LunaT9DeploymentSupport.Point) throws {
        #if DEBUG
            try debugInjection?(point)
        #endif
    }

    public static func logText(_ step: Step) -> String {
        "schemaID=luna_pinyin_t9 step=\(step.step) reason=\(step.reason)"
    }

    /// Single installer callback body: backup derived schema, materialize, sync overlays.
    /// Any failure restores the previous derived file (or deletes a fresh one) and rethrows.
    public static func commitInInstallerCallback(
        defaults: UserDefaults?,
        rimeRoot: URL,
        pendingSchemaID: String? = nil
    ) throws {
        let fileManager = FileManager.default
        let shared = rimeRoot.appendingPathComponent("shared", isDirectory: true)
        let derived = shared.appendingPathComponent("luna_pinyin_t9.schema.yaml")
        let backupRoot = rimeRoot.appendingPathComponent(
            ".luna-t9-txn-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: backupRoot, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: backupRoot) }
        let backup = backupRoot.appendingPathComponent("luna_pinyin_t9.schema.yaml")
        var hadOld = false
        var materialized = false
        var staged: URL?
        do {
            try debugHit(.backupSource)
            if fileManager.fileExists(atPath: derived.path) {
                hadOld = true
                try fileManager.copyItem(at: derived, to: backup)
            }
            let user = rimeRoot.appendingPathComponent("user", isDirectory: true)
            try clearDerivedBuildCaches(sharedDataURL: shared, userDataURL: user)
            let sourceURL = shared.appendingPathComponent("luna_pinyin.schema.yaml")
            let rewritten = try LunaT9SchemaCompatibility.rewrite(Data(contentsOf: sourceURL))
            guard sha256Hex(rewritten) == LunaT9SchemaCompatibility.outputSHA256 else {
                throw ProductionError(message: "rewrite output hash mismatch")
            }
            try debugHit(.sourceWrite)
            let temporary = shared.appendingPathComponent(".luna-t9-tmp-\(UUID().uuidString)")
            staged = temporary
            try rewritten.write(to: temporary, options: .atomic)
            guard try Data(contentsOf: temporary) == rewritten else {
                throw ProductionError(message: "staged derived bytes mismatch")
            }
            try debugHit(.sourceReplace)
            if fileManager.fileExists(atPath: derived.path) {
                _ = try fileManager.replaceItemAt(derived, withItemAt: temporary)
            } else {
                try fileManager.moveItem(at: temporary, to: derived)
            }
            staged = nil
            materialized = true
            guard
                RimeConfigManager.syncCustomYamlFiles(
                    defaults: defaults,
                    rimeRoot: rimeRoot,
                    pendingSchemaID: pendingSchemaID
                )
            else {
                throw ProductionError(message: "syncCustomYamlFiles failed")
            }
        } catch {
            try debugHit(.restoreSource)
            if materialized {
                if hadOld {
                    if fileManager.fileExists(atPath: derived.path) {
                        try fileManager.removeItem(at: derived)
                    }
                    try fileManager.copyItem(at: backup, to: derived)
                } else if fileManager.fileExists(atPath: derived.path) {
                    try fileManager.removeItem(at: derived)
                }
            }
            if let staged, fileManager.fileExists(atPath: staged.path) {
                try? fileManager.removeItem(at: staged)
            }
            throw error
        }
    }

    /// Enable preflight: never writes. A present derived file with the wrong hash fails closed.
    public static func validateSourceBeforeEnable(sharedDataURL: URL) throws {
        let derived = sharedDataURL.appendingPathComponent("luna_pinyin_t9.schema.yaml")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: derived.path) {
            let actual = sha256Hex(try Data(contentsOf: derived))
            guard actual == LunaT9SchemaCompatibility.outputSHA256 else {
                throw ProductionError(
                    message: "expected \(String(LunaT9SchemaCompatibility.outputSHA256.prefix(8))) "
                        + "actual \(String(actual.prefix(8)))"
                )
            }
            return
        }
        let sourceURL = sharedDataURL.appendingPathComponent("luna_pinyin.schema.yaml")
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw ProductionError(message: "luna_pinyin.schema.yaml missing")
        }
        let rewritten = try LunaT9SchemaCompatibility.rewrite(Data(contentsOf: sourceURL))
        let actual = sha256Hex(rewritten)
        guard actual == LunaT9SchemaCompatibility.outputSHA256 else {
            throw ProductionError(
                message: "expected \(String(LunaT9SchemaCompatibility.outputSHA256.prefix(8))) "
                    + "actual \(String(actual.prefix(8)))"
            )
        }
    }

    public static func clearDerivedBuildCaches(sharedDataURL: URL, userDataURL: URL) throws {
        let fileManager = FileManager.default
        for root in [
            sharedDataURL.appendingPathComponent("build", isDirectory: true),
            userDataURL.appendingPathComponent("build", isDirectory: true),
        ] where fileManager.fileExists(atPath: root.path) {
            let entries = try fileManager.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
            for entry in entries where entry.lastPathComponent.hasPrefix("luna_pinyin_t9.") {
                // luna_pinyin_t9. is not a prefix of luna_pinyin. t9 or wanxiang artifacts.
                try debugHit(.cacheDelete)
                try fileManager.removeItem(at: entry)
            }
        }
    }

    public static func rewriteCheckPassed(sharedDataURL: URL, userDataURL: URL) -> Bool {
        !recheckCompiled(sharedDataURL: sharedDataURL, userDataURL: userDataURL).failed
    }

    public static func recheckCompiled(sharedDataURL: URL, userDataURL: URL) -> CompiledCheck {
        let name = "luna_pinyin_t9.schema.yaml"
        let userBuild = userDataURL.appendingPathComponent("build", isDirectory: true).appendingPathComponent(name)
        let sharedBuild = sharedDataURL.appendingPathComponent("build", isDirectory: true).appendingPathComponent(name)
        let loaded = FileManager.default.fileExists(atPath: userBuild.path) ? userBuild : sharedBuild
        guard FileManager.default.fileExists(atPath: loaded.path) else {
            return CompiledCheck(step: Step(step: "recheckCompiled", reason: "compiledMissing"))
        }
        guard let compiled = try? String(contentsOf: loaded, encoding: .utf8) else {
            return CompiledCheck(step: Step(step: "recheckCompiled", reason: "compiledUnreadable"))
        }
        if compiled.contains("t9_processor") {
            return CompiledCheck(step: Step(step: "recheckCompiled", reason: "t9ProcessorPresent"))
        }
        let derived = sharedDataURL.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: derived.path),
            let bytes = try? Data(contentsOf: derived),
            sha256Hex(bytes) == LunaT9SchemaCompatibility.outputSHA256
        else {
            return CompiledCheck(step: Step(step: "recheckCompiled", reason: "sourceNotCompatible"))
        }
        return CompiledCheck(step: Step(step: "recheckCompiled", reason: "compiledClean"))
    }

    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
