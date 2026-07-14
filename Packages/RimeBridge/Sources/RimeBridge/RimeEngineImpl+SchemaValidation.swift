import KeyboardCore

struct RimeStartupSchemaSelectionResult: Equatable {
    let selectedSchemaID: String?
    let usedSchemaEnumeration: Bool
}

enum RimeStartupSchemaSelector {
    static func select(
        requested: String,
        fallback: String,
        attempt: (String) -> Bool,
        availableSchemaIDs: () -> [String]
    ) -> RimeStartupSchemaSelectionResult {
        if attempt(requested) {
            return RimeStartupSchemaSelectionResult(
                selectedSchemaID: requested,
                usedSchemaEnumeration: false
            )
        }

        if fallback != requested, attempt(fallback) {
            return RimeStartupSchemaSelectionResult(
                selectedSchemaID: fallback,
                usedSchemaEnumeration: false
            )
        }

        for candidateID in availableSchemaIDs() where candidateID != requested && candidateID != fallback {
            guard attempt(candidateID) else { continue }
            return RimeStartupSchemaSelectionResult(
                selectedSchemaID: candidateID,
                usedSchemaEnumeration: true
            )
        }

        return RimeStartupSchemaSelectionResult(
            selectedSchemaID: nil,
            usedSchemaEnumeration: true
        )
    }
}

extension RimeEngineImpl {
    /// 冷启动快速路径：只验证 schema 选择结果，不输入测试文本。
    /// 完整候选功能检查由主 App 部署诊断和运行时恢复路径承担。
    func selectSchemaForStartup(_ schemaID: String, fallback: String) -> String? {
        let result = RimeStartupSchemaSelector.select(
            requested: schemaID,
            fallback: fallback,
            attempt: selectSchemaIfAvailable,
            availableSchemaIDs: { [bridge] in
                bridge.availableSchemas().components(separatedBy: ", ").compactMap {
                    $0.components(separatedBy: " — ").first
                }
            }
        )

        guard let selectedSchemaID = result.selectedSchemaID else {
            Logger.shared.error("No selectable schema is available for startup.", category: .engine)
            return nil
        }

        if selectedSchemaID != schemaID {
            Logger.shared.warning(
                "Startup schema '\(schemaID)' could not be selected; using '\(selectedSchemaID)'"
                    + (result.usedSchemaEnumeration ? " after fallback enumeration" : ""),
                category: .engine
            )
        }
        return selectedSchemaID
    }

    private func selectSchemaIfAvailable(_ schemaID: String) -> Bool {
        bridge.selectSchema(schemaID) && bridge.currentSchemaID() == schemaID
    }

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
        return nil
    }
}
