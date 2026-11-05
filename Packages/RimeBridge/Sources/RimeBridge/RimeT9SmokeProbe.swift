import Foundation
import KeyboardCore

/// Main-App deployment smoke for a registered nine-key schema.
public enum RimeT9SmokeProbe {
    /// When set, `selectAndConfirm` returns this result and does not open an engine.
    /// Production leaves it nil. Tests clear it before returning.
    nonisolated(unsafe) public static var selectAndConfirmHook: ((String, String, String) -> Bool)?

    /// Fog path: schema `t9`, input `64`.
    public static func verify(
        sharedDataDir: String,
        userDataDir: String
    ) -> Bool {
        verify(
            sharedDataDir: sharedDataDir,
            userDataDir: userDataDir,
            schemaID: "t9",
            input: NineKeySchemeRegistry.smokeInput(for: "t9") ?? "64"
        )
    }

    /// Selects `schemaID` and types `input`. Requires a non-empty candidate page,
    /// the raw input, a matching delete, and at least one validated comment among
    /// the first candidates. The first candidate's comment may be empty.
    public static func verify(
        sharedDataDir: String,
        userDataDir: String,
        schemaID: String,
        input: String
    ) -> Bool {
        guard NineKeySchemeRegistry.scheme(schemaID) != nil, !input.isEmpty else { return false }
        let engine = RimeEngineImpl(sharedDataDir: sharedDataDir, userDataDir: userDataDir)
        let selected = engine.bridge.selectSchema(schemaID) && engine.bridge.currentSchemaID() == schemaID
        guard selected else {
            engine.suspendForVisibilityChange()
            return false
        }
        engine.resetSession()
        var output = RimeOutput()
        for scalar in input.unicodeScalars {
            output = engine.processKey(String(scalar))
        }
        let afterDelete = engine.deleteBackward()
        let passed = evaluationPasses(
            raw: output.rawInput ?? "",
            expectedRaw: input,
            candidates: output.candidates,
            rawAfterDelete: afterDelete.rawInput ?? "",
            expectedAfterDelete: String(input.dropLast())
        )
        engine.suspendForVisibilityChange()
        return passed
    }

    /// Opens the engine, selects `schemaID`, confirms `currentSchemaID()`, then suspends.
    public static func selectAndConfirm(
        sharedDataDir: String,
        userDataDir: String,
        schemaID: String
    ) -> Bool {
        if let selectAndConfirmHook {
            return selectAndConfirmHook(sharedDataDir, userDataDir, schemaID)
        }
        let engine = RimeEngineImpl(sharedDataDir: sharedDataDir, userDataDir: userDataDir)
        let selected = engine.bridge.selectSchema(schemaID) && engine.bridge.currentSchemaID() == schemaID
        engine.suspendForVisibilityChange()
        return selected
    }

    static func evaluationPasses(
        raw: String,
        expectedRaw: String,
        candidates: [RimeCandidate],
        rawAfterDelete: String,
        expectedAfterDelete: String
    ) -> Bool {
        let commentOK = candidates.prefix(8).contains { candidate in
            guard let comment = candidate.comment else { return false }
            return T9PreeditResolver.validatedSource(comment) != nil
        }
        return raw == expectedRaw && !candidates.isEmpty && commentOK
            && rawAfterDelete == expectedAfterDelete
    }
}
