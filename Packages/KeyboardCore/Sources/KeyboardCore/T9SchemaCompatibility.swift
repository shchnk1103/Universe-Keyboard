import Foundation

/// Generates Universe Keyboard–compatible T9 schema text for the pinned librime build.
public enum T9SchemaCompatibility {
    public static let requiredDigitAlgebraSnippets = [
        "derive/[abc]/2/",
        "derive/[def]/3/",
        "derive/[hgi]/4/",
        "derive/[jkl]/5/",
        "derive/[omn]/6/",
        "derive/[pqrs]/7/",
        "derive/[tuv]/8/",
        "derive/[wxyz]/9/",
    ]

    /// Upstream fog-ice / Hamster T9 registers a Lua translator that runs
    /// `collectgarbage("step")` on every translation. On long unconfirmed T9 digit
    /// compositions, device logs show multi-hundred-ms main-thread spikes almost
    /// entirely inside librime `process_key` (`api`), with the next key fast again —
    /// the signature of intermittent GC work on the input hot path.
    ///
    /// Stripped **only from `t9.schema.yaml`**. Shared `lua/force_gc.lua` and 26-key
    /// schemas (`rime_ice`, double_pinyin, …) are left unchanged so full-pinyin memory
    /// behavior stays upstream-compatible.
    public static let forceGCTranslatorMarker = "force_gc"

    /// Removes unsupported processors and T9-only hot-path GC translator list entries
    /// while preserving digit algebra.
    public static func makeCompatibleSchema(fromUpstreamYAML yaml: String) throws -> String {
        guard yaml.contains("schema_id: t9") || yaml.contains("schema_id:t9") else {
            throw T9SchemaCompatibilityError.missingSchemaID
        }
        for snippet in requiredDigitAlgebraSnippets {
            guard yaml.contains(snippet) else {
                throw T9SchemaCompatibilityError.missingDigitAlgebra(snippet)
            }
        }

        let lines = yaml.split(separator: "\n", omittingEmptySubsequences: false)
        var output: [String] = []
        var removedProcessorLines = 0
        var removedForceGCLines = 0
        for line in lines {
            if line.contains("t9_processor") {
                removedProcessorLines += 1
                continue
            }
            // Strip translator list entries only (e.g. `- lua_translator@*force_gc`).
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("-"), trimmed.contains(forceGCTranslatorMarker) {
                removedForceGCLines += 1
                continue
            }
            output.append(String(line))
        }
        guard removedProcessorLines > 0 || !yaml.contains("t9_processor") else {
            throw T9SchemaCompatibilityError.failedToStripProcessor
        }
        var result = output.joined(separator: "\n")
        if !result.hasSuffix("\n") {
            result.append("\n")
        }
        // Ensure the unsupported processor is gone after rewrite.
        if result.contains("t9_processor") {
            throw T9SchemaCompatibilityError.failedToStripProcessor
        }
        // Force-GC list entries must be gone; comments without `-` are left alone.
        let stillHasForceGCTranslator = result
            .split(separator: "\n", omittingEmptySubsequences: false)
            .contains { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return trimmed.hasPrefix("-") && trimmed.contains(forceGCTranslatorMarker)
            }
        if stillHasForceGCTranslator {
            throw T9SchemaCompatibilityError.failedToStripForceGC
        }
        _ = removedForceGCLines
        return result
    }
}

public enum T9SchemaCompatibilityError: Error, Equatable {
    case missingSchemaID
    case missingDigitAlgebra(String)
    case failedToStripProcessor
    case failedToStripForceGC
}
