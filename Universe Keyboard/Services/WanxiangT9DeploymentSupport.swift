import Foundation
import KeyboardCore

/// App-side file wrapper for the Wanxiang nine-key compatibility rewrite.
///
/// Rewrites the shared source, deletes stale shared/user build products before
/// compile, and re-reads the compiled schema that librime will load. Does not
/// write a readiness marker.
enum WanxiangT9DeploymentSupport {
    static let schemaID = WanxiangT9SchemaCompatibility.schemaID
    static let sourceFileName = "\(schemaID).schema.yaml"

    struct Step: Equatable {
        let step: String
        let reason: String
    }

    struct PrepareResult: Equatable {
        let steps: [Step]
        var failed: Bool {
            steps.contains { step in
                step.reason != "rewritten" && step.reason != "alreadyCompatible" && step.reason != "removed"
            }
        }
    }

    struct CompiledCheck: Equatable {
        let step: Step
        var failed: Bool { step.reason != "compiledClean" }
    }

    static func logText(_ step: Step) -> String {
        "schemaID=\(schemaID) step=\(step.step) reason=\(step.reason)"
    }

    static func prepare(sharedDataURL: URL, userDataURL: URL? = nil, files: WanxiangT9Files = .live) -> PrepareResult {
        let sourceURL = sharedDataURL.appendingPathComponent(sourceFileName)
        guard files.exists(sourceURL) else {
            return PrepareResult(steps: [Step(step: "rewrite", reason: "sourceMissing")])
        }
        let yaml: String
        do {
            yaml = try files.read(sourceURL)
        } catch {
            return PrepareResult(steps: [Step(step: "rewrite", reason: "sourceUnreadable")])
        }
        switch WanxiangT9SchemaCompatibility.rewrite(yaml) {
        case .failed(let reason):
            return PrepareResult(steps: [Step(step: "rewrite", reason: reason.rawValue)])
        case .alreadyCompatible:
            let deletion = deleteBuildProducts(sharedDataURL: sharedDataURL, userDataURL: userDataURL, files: files)
            return PrepareResult(steps: [Step(step: "rewrite", reason: "alreadyCompatible"), deletion])
        case .rewritten(let text):
            do {
                try files.writeAtomic(text, sourceURL)
            } catch {
                return PrepareResult(steps: [Step(step: "rewrite", reason: "writeFailed")])
            }
            let deletion = deleteBuildProducts(sharedDataURL: sharedDataURL, userDataURL: userDataURL, files: files)
            return PrepareResult(steps: [Step(step: "rewrite", reason: "rewritten"), deletion])
        }
    }

    static func recheckCompiled(
        sharedDataURL: URL,
        userDataURL: URL? = nil,
        files: WanxiangT9Files = .live
    ) -> CompiledCheck {
        let userURL = resolvedUserDataURL(sharedDataURL: sharedDataURL, userDataURL: userDataURL)
            .appendingPathComponent("build", isDirectory: true)
            .appendingPathComponent(sourceFileName)
        let sharedURL =
            sharedDataURL
            .appendingPathComponent("build", isDirectory: true)
            .appendingPathComponent(sourceFileName)
        let loaded = files.exists(userURL) ? userURL : sharedURL
        guard files.exists(loaded) else {
            return CompiledCheck(step: Step(step: "recheckCompiled", reason: "compiledMissing"))
        }
        let compiled: String
        do {
            compiled = try files.read(loaded)
        } catch {
            return CompiledCheck(step: Step(step: "recheckCompiled", reason: "compiledUnreadable"))
        }
        if compiled.contains("t9_processor") {
            return CompiledCheck(step: Step(step: "recheckCompiled", reason: "t9ProcessorPresent"))
        }
        return CompiledCheck(step: Step(step: "recheckCompiled", reason: "compiledClean"))
    }

    private static func deleteBuildProducts(
        sharedDataURL: URL,
        userDataURL: URL?,
        files: WanxiangT9Files
    ) -> Step {
        let roots = [
            sharedDataURL.appendingPathComponent("build", isDirectory: true),
            resolvedUserDataURL(sharedDataURL: sharedDataURL, userDataURL: userDataURL)
                .appendingPathComponent("build", isDirectory: true),
        ]
        let prefix = "\(schemaID)."
        for root in roots where files.exists(root) {
            let entries: [URL]
            do {
                entries = try files.contents(root)
            } catch {
                return Step(step: "deleteBuild", reason: "deleteFailed")
            }
            for item in entries where item.lastPathComponent.hasPrefix(prefix) {
                do {
                    try files.remove(item)
                } catch {
                    return Step(step: "deleteBuild", reason: "deleteFailed")
                }
                if files.exists(item) {
                    return Step(step: "deleteBuild", reason: "deleteIncomplete")
                }
            }
        }
        return Step(step: "deleteBuild", reason: "removed")
    }

    private static func resolvedUserDataURL(sharedDataURL: URL, userDataURL: URL?) -> URL {
        if let userDataURL { return userDataURL }
        return sharedDataURL.deletingLastPathComponent().appendingPathComponent("user", isDirectory: true)
    }
}

struct WanxiangT9Files {
    var exists: (URL) -> Bool
    var read: (URL) throws -> String
    var writeAtomic: (String, URL) throws -> Void
    var contents: (URL) throws -> [URL]
    var remove: (URL) throws -> Void

    static let live = WanxiangT9Files(
        exists: { FileManager.default.fileExists(atPath: $0.path) },
        read: { try String(contentsOf: $0, encoding: .utf8) },
        writeAtomic: { try $0.write(to: $1, atomically: true, encoding: .utf8) },
        contents: {
            try FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil)
        },
        remove: { try FileManager.default.removeItem(at: $0) }
    )
}
