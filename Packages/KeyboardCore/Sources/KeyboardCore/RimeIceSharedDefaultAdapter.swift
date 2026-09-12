import Foundation

/// Keeps official Prelude `default.yaml` as the only shared config named
/// `default`. Ice's bundled default is copied to a private preset and schema
/// references are rewritten to that name.
public struct RimeIceSharedDefaultAdapter: Sendable {
    public static let presetConfigName = "rime_ice_preset"
    public static let presetFileName = "rime_ice_preset.yaml"
    public static let upstreamDefaultFileName = "default.yaml"

    public enum AdapterError: Error, Equatable, Sendable {
        case missingUpstreamDefault
    }

    private static let schemaFilesToRewrite = [
        "rime_ice.schema.yaml",
        "t9.schema.yaml",
        "melt_eng.schema.yaml",
        "radical_pinyin.schema.yaml",
    ]

    /// Deterministic string rewrite used by extraction post-processing and tests.
    public static func rewritePresetReferences(_ yaml: String) -> String {
        let includeRewritten = yaml.replacingOccurrences(
            of: "__include: default:/",
            with: "__include: \(presetConfigName):/"
        )
        return includeRewritten.replacingOccurrences(
            of: #"import_preset:\s*default\b"#,
            with: "import_preset: \(presetConfigName)",
            options: .regularExpression
        )
    }

    /// Copies Ice `default.yaml` to `rime_ice_preset.yaml` and rewrites admitted
    /// schema files. The upstream `default.yaml` stays in the tree so skip-lists
    /// can keep it out of the staged identity.
    public static func apply(in extractionDirectory: URL) throws {
        let fileManager = FileManager.default
        let source = extractionDirectory.appendingPathComponent(upstreamDefaultFileName)
        guard fileManager.fileExists(atPath: source.path) else {
            throw AdapterError.missingUpstreamDefault
        }
        let destination = extractionDirectory.appendingPathComponent(presetFileName)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: source, to: destination)
        for name in schemaFilesToRewrite {
            let url = extractionDirectory.appendingPathComponent(name)
            guard fileManager.fileExists(atPath: url.path) else { continue }
            let original = try String(contentsOf: url, encoding: .utf8)
            let rewritten = rewritePresetReferences(original)
            if rewritten != original {
                try rewritten.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}

extension RimeIceSharedDefaultAdapter: SchemeSharedDefaultApplying {
    /// Shared Default seam entry for Ice `privatePreset` (P1-3).
    public static let shared = RimeIceSharedDefaultAdapter()

    public var mode: SchemeSharedDefaultMode { .privatePreset }

    public func applyPostExtract(in extractionDirectory: URL) throws {
        try Self.apply(in: extractionDirectory)
    }
}
