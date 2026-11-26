import XCTest

@testable import KeyboardCore

/// PB-017 PR-3：双拼设置接线的 KeyboardCore 门卫查询与部署产物辅助。
final class RimeShuangpinSettingsGateTests: XCTestCase {
    // MARK: - 双拼 schema 识别（纠错实验编辑 fail-closed 门卫查询）

    func testDoublePinyinSchemaIDDetection() {
        XCTAssertTrue(RimeShuangpinVariant.isDoublePinyinSchemaID("double_pinyin_flypy"))
        XCTAssertTrue(RimeShuangpinVariant.isDoublePinyinSchemaID("double_pinyin"))
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID(nil))
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID(""))
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID("t9"))
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID("rime_ice"))
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID("luna_pinyin"))
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID("wanxiang"))
        // 仅精确匹配，拒绝带空白或大小写漂移的近似串。
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID(" double_pinyin "))
        XCTAssertFalse(RimeShuangpinVariant.isDoublePinyinSchemaID("Double_Pinyin"))
    }

    // MARK: - 纠错实验编辑 fail-closed 门卫

    func testExperimentalEditsGateDisablesEditsUnderDoublePinyin() {
        let edits: TypoCorrectionExperimentalEdits = [.insertion, .transposition]
        XCTAssertEqual(
            TypoCorrectionExperimentalEdits.gatedForActiveSchema(edits, activeSchemaID: "double_pinyin_flypy"),
            [])
        XCTAssertEqual(
            TypoCorrectionExperimentalEdits.gatedForActiveSchema(edits, activeSchemaID: "double_pinyin"),
            [])
    }

    func testExperimentalEditsGatePreservesFullPinyinModes() {
        let edits: TypoCorrectionExperimentalEdits = [.insertion, .transposition]
        XCTAssertEqual(
            TypoCorrectionExperimentalEdits.gatedForActiveSchema(edits, activeSchemaID: "rime_ice"),
            edits)
        XCTAssertEqual(
            TypoCorrectionExperimentalEdits.gatedForActiveSchema(edits, activeSchemaID: "luna_pinyin"),
            edits)
        // 九宫格（T9 语义）与未知 / 缺失 schema 保持原有行为。
        XCTAssertEqual(
            TypoCorrectionExperimentalEdits.gatedForActiveSchema(edits, activeSchemaID: "t9"),
            edits)
        XCTAssertEqual(
            TypoCorrectionExperimentalEdits.gatedForActiveSchema(edits, activeSchemaID: nil),
            edits)
    }

    // MARK: - 模糊音后处理器双拼 fail-closed（cleanup-only，与万象同路径）

    private func makeFuzzyEnabledSettings() -> RimeFuzzyPinyinSettings {
        RimeFuzzyPinyinSettings(
            enabled: true,
            zhZEnabled: true,
            chCEnabled: true,
            shSEnabled: true,
            nLEnabled: true
        )
    }

    private func makeFuzzySchemaYAML(schemaID: String) -> String {
        """
        schema:
          schema_id: \(schemaID)
          name: Test

        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          algebra:
            - abbrev/^([a-z]).+$/$1/

        translator:
          dictionary: luna_pinyin
        """
    }

    func testFuzzyPostProcessorNeverInsertsManagedBlockIntoShuangpinSchemas() {
        let settings = makeFuzzyEnabledSettings()
        for schemaID in ["double_pinyin_flypy", "double_pinyin"] {
            let yaml = makeFuzzySchemaYAML(schemaID: schemaID)
            let result = RimeFuzzyPinyinPostProcessor.apply(settings: settings, to: yaml)
            XCTAssertEqual(result.status, .unchanged, schemaID)
            XCTAssertFalse(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker), schemaID)
        }
    }

    func testFuzzyPostProcessorStillRemovesStaleManagedBlockFromShuangpinSchemas() {
        let settings = makeFuzzyEnabledSettings()
        let yaml = makeFuzzySchemaYAML(schemaID: "double_pinyin_flypy")
            .replacingOccurrences(
                of: "- abbrev/^([a-z]).+$/$1/",
                with: """
                    - abbrev/^([a-z]).+$/$1/
                        # universe:fuzzy-pinyin begin
                        - derive/^z/z/
                        # universe:fuzzy-pinyin end
                    """)
        let result = RimeFuzzyPinyinPostProcessor.apply(settings: settings, to: yaml)
        XCTAssertEqual(result.status, .removed)
        XCTAssertFalse(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
    }

    func testFuzzyPostProcessorKeepsInsertingIntoSupportedFullPinyinHost() {
        let settings = makeFuzzyEnabledSettings()
        let yaml = makeFuzzySchemaYAML(schemaID: "rime_ice")
        let result = RimeFuzzyPinyinPostProcessor.apply(settings: settings, to: yaml)
        XCTAssertEqual(result.status, .updated)
        XCTAssertTrue(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
    }

    // MARK: - 共享目录物化辅助

    private func makeSharedDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-shuangpin-materialize-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func testMaterializeWritesShuangpinSchemaFollowingHostDictionary() throws {
        let dir = try makeSharedDir()
        defer { try? FileManager.default.removeItem(at: dir) }

        let flypyURL = try RimeConfigTemplates.materializeShuangpinSchema(
            variant: .flypy, baseSchemaID: "luna_pinyin", into: dir)
        XCTAssertEqual(flypyURL.lastPathComponent, "double_pinyin_flypy.schema.yaml")
        let flypyYAML = try String(contentsOf: flypyURL, encoding: .utf8)
        XCTAssertTrue(flypyYAML.contains("schema_id: double_pinyin_flypy"))
        XCTAssertTrue(flypyYAML.contains("dictionary: luna_pinyin"))

        let zrmURL = try RimeConfigTemplates.materializeShuangpinSchema(
            variant: .zrm, baseSchemaID: "rime_ice", into: dir)
        XCTAssertEqual(zrmURL.lastPathComponent, "double_pinyin.schema.yaml")
        let zrmYAML = try String(contentsOf: zrmURL, encoding: .utf8)
        XCTAssertTrue(zrmYAML.contains("schema_id: double_pinyin"))
        XCTAssertTrue(zrmYAML.contains("dictionary: rime_ice"))
    }

    func testMaterializeCreatesMissingSharedDirectoryAndSkipsIdenticalRewrite() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-shuangpin-materialize-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let shared = root.appendingPathComponent("Rime/shared", isDirectory: true)

        let url = try RimeConfigTemplates.materializeShuangpinSchema(
            variant: .flypy, baseSchemaID: "luna_pinyin", into: shared)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

        // 内容一致时不重写（保留部署后处理可能追加的合法内容）。人手篡改后再次物化恢复模板。
        try "corrupted".write(to: url, atomically: true, encoding: .utf8)
        let restored = try RimeConfigTemplates.materializeShuangpinSchema(
            variant: .flypy, baseSchemaID: "luna_pinyin", into: shared)
        XCTAssertEqual(
            try String(contentsOf: restored, encoding: .utf8),
            RimeConfigTemplates.shuangpinSchema(variant: .flypy, baseSchemaID: "luna_pinyin"))
    }

    func testShuangpinHostBaseSchemaIDsStayPinnedToBuiltinHosts() {
        XCTAssertEqual(RimeConfigTemplates.shuangpinHostBaseSchemaIDs, ["luna_pinyin", "rime_ice"])
    }

    // MARK: - 九宫格切换退出双拼语义（ADR 0026 槽位模型，无新逻辑）

    func testNineKeyBindingExitsShuangpinCapabilityGate() {
        let schemaID = RimeSchemeCapabilityMatrix.settingsCapabilitySchemaID(
            layoutStyle: .nineKey,
            schemeBinding26: "double_pinyin_flypy",
            schemeBinding9: "t9",
            activeSchemaID: "double_pinyin_flypy"
        )
        XCTAssertEqual(schemaID, "rime_ice")
        XCTAssertTrue(RimeSchemeCapabilityMatrix.profile(for: schemaID).supportsManagedFuzzyPinyin)
    }

    func testTwentySixKeyShuangpinBindingStaysFuzzyFailClosed() {
        for binding in ["double_pinyin_flypy", "double_pinyin"] {
            let schemaID = RimeSchemeCapabilityMatrix.settingsCapabilitySchemaID(
                layoutStyle: .twentySixKey,
                schemeBinding26: binding,
                schemeBinding9: nil,
                activeSchemaID: binding
            )
            XCTAssertEqual(schemaID, binding)
            XCTAssertFalse(RimeSchemeCapabilityMatrix.profile(for: schemaID).supportsManagedFuzzyPinyin)
        }
    }
}
