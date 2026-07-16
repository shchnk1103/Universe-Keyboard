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

    /// Removes unsupported processors (currently `t9_processor`) while preserving digit algebra.
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
        for line in lines {
            if line.contains("t9_processor") {
                removedProcessorLines += 1
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
        return result
    }
}

public enum T9SchemaCompatibilityError: Error, Equatable {
    case missingSchemaID
    case missingDigitAlgebra(String)
    case failedToStripProcessor
}
