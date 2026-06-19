import Foundation

public struct RimeAdvancedInputPostProcessor {
    public enum ApplyStatus: Equatable, Sendable {
        case unchanged
        case disabledComponents([String])
        case restoredAllFeatures
        case missingSchema
        case noRestorableSource
    }

    public struct ApplyResult: Equatable, Sendable {
        public let status: ApplyStatus
        public let disabledComponentNames: [String]
    }

    /// Applies advanced-input feature switches to a schema file.
    ///
    /// The source schema is preserved in a sidecar file so turning a feature
    /// back on can restore the upstream component line without redownloading.
    public static func apply(
        settings: RimeAdvancedInputSettings,
        supportedFeatures: Set<RimeAdvancedInputFeature>,
        schemaURL: URL
    ) -> ApplyResult {
        guard FileManager.default.fileExists(atPath: schemaURL.path) else {
            return ApplyResult(status: .missingSchema, disabledComponentNames: [])
        }

        let sourceURL = sourceBackupURL(for: schemaURL)
        guard let currentYaml = try? String(contentsOf: schemaURL, encoding: .utf8) else {
            return ApplyResult(status: .missingSchema, disabledComponentNames: [])
        }

        if !FileManager.default.fileExists(atPath: sourceURL.path), schemaContainsLuaComponents(currentYaml) {
            try? currentYaml.write(to: sourceURL, atomically: true, encoding: .utf8)
        }

        let sourceYaml = (try? String(contentsOf: sourceURL, encoding: .utf8)) ?? currentYaml
        guard schemaContainsLuaComponents(sourceYaml) else {
            return ApplyResult(status: .noRestorableSource, disabledComponentNames: [])
        }

        let disabledComponents = settings.disabledComponentNames(supportedFeatures: supportedFeatures)
        let processedYaml = removeLuaComponents(disabledComponents, from: sourceYaml)

        guard processedYaml != currentYaml else {
            return ApplyResult(
                status: disabledComponents.isEmpty ? .unchanged : .disabledComponents(disabledComponents.sorted()),
                disabledComponentNames: disabledComponents.sorted()
            )
        }

        try? processedYaml.write(to: schemaURL, atomically: true, encoding: .utf8)

        if disabledComponents.isEmpty {
            return ApplyResult(status: .restoredAllFeatures, disabledComponentNames: [])
        }
        return ApplyResult(
            status: .disabledComponents(disabledComponents.sorted()),
            disabledComponentNames: disabledComponents.sorted()
        )
    }

    private static func sourceBackupURL(for schemaURL: URL) -> URL {
        schemaURL.deletingLastPathComponent()
            .appendingPathComponent(".universe-\(schemaURL.lastPathComponent).source")
    }

    private static func schemaContainsLuaComponents(_ yaml: String) -> Bool {
        yaml.contains("lua_processor@")
            || yaml.contains("lua_translator@")
            || yaml.contains("lua_filter@")
            || yaml.contains("lua_segmentor@")
    }

    private static func removeLuaComponents(_ componentNames: Set<String>, from yaml: String) -> String {
        guard !componentNames.isEmpty else { return yaml }

        let lines = yaml.components(separatedBy: "\n")
        var result: [String] = []
        var skipUntilIndentation: Int?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let indentation = line.prefix(while: { $0 == " " || $0 == "\t" }).count

            if let skipIndent = skipUntilIndentation {
                if indentation > skipIndent, !trimmed.isEmpty {
                    continue
                }
                skipUntilIndentation = nil
            }

            if referencesLuaComponent(trimmed, componentNames: componentNames) {
                skipUntilIndentation = indentation
                continue
            }

            result.append(line)
        }

        return result.joined(separator: "\n")
    }

    private static func referencesLuaComponent(
        _ trimmedLine: String,
        componentNames: Set<String>
    ) -> Bool {
        guard trimmedLine.contains("lua_processor@")
            || trimmedLine.contains("lua_translator@")
            || trimmedLine.contains("lua_filter@")
            || trimmedLine.contains("lua_segmentor@")
        else {
            return false
        }

        return componentNames.contains { component in
            trimmedLine.contains("@\(component)") || trimmedLine.contains("@*\(component)")
        }
    }
}
