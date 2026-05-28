import KeyboardCore

extension RimeEngineImpl {
    /// Tests a loaded schema with "ni"; a loaded schema with no candidates is unusable for typing.
    func functionalTestCandidates() -> Int {
        _ = bridge.processKey(0x006E, modifiers: 0)
        let output = parseOutput(bridge.processKey(0x0069, modifiers: 0))
        bridge.clearComposition()
        return output.candidates.count
    }

    @discardableResult
    func selectAndVerifySchema(_ schemaID: String, fallback: String) -> String? {
        let requested = bridge.selectSchema(schemaID)
        let actual = bridge.currentSchemaID()
        guard actual == schemaID else {
            Logger.shared.warning(
                requested
                    ? "selectSchema('\(schemaID)') returned true but currentSchemaID is '\(actual)'"
                    : "selectSchema('\(schemaID)') returned false",
                category: .engine
            )
            return fallbackToWorkingSchema(from: schemaID, fallback: fallback)
        }

        let candidateCount = functionalTestCandidates()
        guard candidateCount > 0 else {
            Logger.shared.warning(
                "Schema '\(schemaID)' loaded but produces no candidates for 'ni'",
                category: .engine
            )
            return fallbackToWorkingSchema(from: schemaID, fallback: fallback)
        }

        Logger.shared.info(
            "Schema '\(schemaID)' functional: 'ni' produced \(candidateCount) candidates",
            category: .engine
        )
        return actual
    }

    func fallbackToWorkingSchema(from schemaID: String, fallback: String) -> String? {
        if fallback != schemaID, bridge.selectSchema(fallback), bridge.currentSchemaID() == fallback {
            let candidateCount = functionalTestCandidates()
            if candidateCount > 0 {
                Logger.shared.info(
                    "Fallback to '\(fallback)' functional (\(candidateCount) candidates)",
                    category: .engine
                )
                return fallback
            }
        }

        let schemaIDs = bridge.availableSchemas().components(separatedBy: ", ").compactMap {
            $0.components(separatedBy: " — ").first
        }
        for candidateID in schemaIDs where candidateID != schemaID && candidateID != fallback {
            guard bridge.selectSchema(candidateID), functionalTestCandidates() > 0 else { continue }
            Logger.shared.info("Fallback to '\(candidateID)' functional", category: .engine)
            return bridge.currentSchemaID()
        }

        Logger.shared.error("All schema fallbacks failed. Engine will not produce candidates.", category: .engine)
        return bridge.currentSchemaID()
    }
}
