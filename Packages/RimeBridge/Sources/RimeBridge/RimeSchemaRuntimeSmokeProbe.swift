import Foundation
import KeyboardCore
import RimeBridgeObjC

/// Content-free post-deployment proof that the requested schema can actually type.
public enum RimeSchemaRuntimeSmokeProbe {
    public struct Result: Equatable, Sendable {
        public let selectedRequestedSchema: Bool
        public let compositionPresent: Bool
        public let rawInputMatched: Bool
        public let candidateCount: Int
        public let hasHanCandidate: Bool
        public let unexpectedCommit: Bool

        public var passed: Bool {
            selectedRequestedSchema && compositionPresent && rawInputMatched && candidateCount > 0
                && hasHanCandidate && !unexpectedCommit
        }
    }

    public static func run(
        sharedDataDir: String,
        userDataDir: String,
        schemaID: String
    ) -> Result {
        let bridge = RimeSessionManager()
        guard bridge.setup(withSharedDataDir: sharedDataDir, userDataDir: userDataDir) else {
            return failedResult
        }
        guard bridge.initializeEngine() else {
            bridge.finalize()
            return failedResult
        }
        defer { bridge.finalize() }
        guard bridge.createSession() else { return failedResult }

        let selected = bridge.selectSchema(schemaID) && bridge.currentSchemaID() == schemaID
        guard selected else { return failedResult }

        bridge.clearComposition()
        var outputs: [RimeOutput] = []
        for character in "ni" {
            outputs.append(
                RimeEngineImpl.parseOutputDictionary(
                    bridge.processKey(RimeEngineImpl.keycode(for: String(character)), modifiers: 0)
                )
            )
        }
        let window = RimeEngineImpl.parseCandidateWindowDictionary(
            bridge.candidates(from: 0, limit: 20)
        )
        let result = evaluate(outputs: outputs, window: window, selectedRequestedSchema: true)
        bridge.clearComposition()
        return result
    }

    static func evaluate(
        outputs: [RimeOutput],
        window: RimeCandidateWindow,
        selectedRequestedSchema: Bool
    ) -> Result {
        let output = outputs.last ?? RimeOutput()
        let candidates =
            output.candidates.count >= window.candidates.count
            ? output.candidates
            : window.candidates
        return Result(
            selectedRequestedSchema: selectedRequestedSchema,
            compositionPresent: !(output.composition?.preeditText.isEmpty ?? true)
                || !(output.rawInput?.isEmpty ?? true),
            rawInputMatched: output.rawInput == "ni",
            candidateCount: candidates.count,
            hasHanCandidate: candidates.contains { containsHanScalar($0.text) },
            // Any host commit during the synthetic sequence makes the smoke unsafe.
            unexpectedCommit: outputs.contains { !($0.committedText?.isEmpty ?? true) }
        )
    }

    private static let failedResult = Result(
        selectedRequestedSchema: false,
        compositionPresent: false,
        rawInputMatched: false,
        candidateCount: 0,
        hasHanCandidate: false,
        unexpectedCommit: false
    )

    static func containsHanScalar(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x3400...0x4DBF, 0x4E00...0x9FFF, 0xF900...0xFAFF,
                0x20000...0x2FA1F, 0x30000...0x323AF:
                return true
            default:
                return false
            }
        }
    }
}

enum RimeSchemaDeploymentInputValidator {
    static func isReady(sharedDataURL: URL, userDataURL: URL, schemaID: String) -> Bool {
        guard isCanonicalSchemaID(schemaID) else { return false }
        let schemaURL = sharedDataURL.appendingPathComponent("\(schemaID).schema.yaml")
        let customURL = userDataURL.appendingPathComponent("default.custom.yaml")
        guard isNonEmptyRegularFile(schemaURL), isNonEmptyRegularFile(customURL) else { return false }
        guard let customYaml = try? String(contentsOf: customURL, encoding: .utf8) else { return false }
        return schemaList(in: customYaml).contains(schemaID)
    }

    private static func isNonEmptyRegularFile(_ url: URL) -> Bool {
        guard
            let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
            values.isRegularFile == true,
            let size = values.fileSize
        else { return false }
        return size > 0
    }

    private static func isCanonicalSchemaID(_ schemaID: String) -> Bool {
        !schemaID.isEmpty
            && schemaID.range(of: #"^[A-Za-z0-9_-]+$"#, options: .regularExpression) != nil
    }

    /// Reads only `patch/schema_list`; matching an unrelated YAML key must not authorize deployment.
    private static func schemaList(in yaml: String) -> Set<String> {
        var patchIndent: Int?
        var listIndent: Int?
        var result = Set<String>()
        for rawLine in yaml.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
            let indent = line.prefix { $0 == " " }.count

            if trimmed == "patch:" {
                patchIndent = indent
                listIndent = nil
                continue
            }
            if let currentPatchIndent = patchIndent, indent <= currentPatchIndent {
                reset(&patchIndent, &listIndent)
                continue
            }
            if patchIndent != nil, trimmed == "schema_list:" {
                listIndent = indent
                continue
            }
            if let currentListIndent = listIndent {
                guard indent > currentListIndent else {
                    reset(&patchIndent, &listIndent)
                    continue
                }
                let prefix = "- schema:"
                guard trimmed.hasPrefix(prefix) else { continue }
                let value = trimmed.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)
                if isCanonicalSchemaID(value) { result.insert(value) }
            }
        }
        return result
    }

    private static func reset(_ patchIndent: inout Int?, _ listIndent: inout Int?) {
        patchIndent = nil
        listIndent = nil
    }
}
