import Foundation
import KeyboardCore

/// Main-App deployment smoke for compatible T9 schema.
public enum RimeT9SmokeProbe {
    public static func verify(
        sharedDataDir: String,
        userDataDir: String
    ) -> Bool {
        let engine = RimeEngineImpl(sharedDataDir: sharedDataDir, userDataDir: userDataDir)
        let selected = engine.bridge.selectSchema("t9") && engine.bridge.currentSchemaID() == "t9"
        guard selected else {
            engine.suspendForVisibilityChange()
            return false
        }
        engine.resetSession()
        var output = engine.processKey("6")
        output = engine.processKey("4")
        let raw = output.rawInput ?? ""
        let ok = raw == "64" && !output.candidates.isEmpty
        let afterDelete = engine.deleteBackward()
        let deleteOK = (afterDelete.rawInput ?? "") == "6"
        engine.suspendForVisibilityChange()
        return ok && deleteOK
    }
}
