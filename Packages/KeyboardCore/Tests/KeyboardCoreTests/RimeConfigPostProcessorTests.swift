import XCTest
@testable import KeyboardCore

final class RimeConfigPostProcessorTests: XCTestCase {

    // MARK: - Basic stripping

    func testStripLuaTranslator() {
        let yaml = """
        translators:
          - lua_translator@date_translator
          - script_translator
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("lua_translator@date_translator"))
        XCTAssertTrue(result.contains("script_translator"))
    }

    func testStripLuaFilter() {
        let yaml = """
        filters:
          - lua_filter@corrector
          - uniquifier
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("lua_filter@corrector"))
        XCTAssertTrue(result.contains("uniquifier"))
    }

    func testStripLuaProcessor() {
        let yaml = """
        processors:
          - lua_processor@some_proc
          - key_binder
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("lua_processor"))
        XCTAssertTrue(result.contains("key_binder"))
    }

    func testMixedLuaAndNonLua() {
        let yaml = """
        translators:
          - lua_translator@date
          - script_translator
          - lua_translator@lunar
          - table_translator
        filters:
          - lua_filter@v_filter
          - simplifier
          - uniquifier
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("lua_translator@date"))
        XCTAssertFalse(result.contains("lua_translator@lunar"))
        XCTAssertFalse(result.contains("lua_filter@v_filter"))
        XCTAssertTrue(result.contains("script_translator"))
        XCTAssertTrue(result.contains("table_translator"))
        XCTAssertTrue(result.contains("simplifier"))
        XCTAssertTrue(result.contains("uniquifier"))
    }

    func testNoLuaEntriesUntouched() {
        let yaml = """
        engine:
          translators:
            - script_translator
            - table_translator
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertEqual(result, yaml)
    }

    func testEmptyString() {
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: "")
        XCTAssertEqual(result, "")
    }

    func testOnlyLuaEntries() {
        let yaml = """
        translators:
          - lua_translator@date
          - lua_translator@lunar
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("lua_translator@"))
    }

    // MARK: - Multi-line YAML

    func testMultiLineLuaEntryStripsContinuationLines() {
        let yaml = """
        translators:
          - lua_translator@date_translator
            option: format
            extra: value
          - script_translator
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("lua_translator"))
        XCTAssertFalse(result.contains("option: format"), "缩进续行应该被剥离")
        XCTAssertFalse(result.contains("extra: value"), "缩进续行应该被剥离")
        XCTAssertTrue(result.contains("script_translator"))
    }

    func testCompactArraySyntaxWithLua() {
        let yaml = "translators: [lua_translator@date, script_translator, lua_translator@lunar]"
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        // 紧凑数组语法无法逐行处理——整行被移除。rime-ice schema 不使用此格式。
        XCTAssertFalse(result.contains("lua_translator"))
    }

    func testDanglingLuaConfigKey() {
        let yaml = """
        lua:
          some_config: true
        engine:
          translators:
            - script_translator
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        // lua: config key at top level should remain (it's not a list item)
        XCTAssertTrue(result.contains("lua:"))
        XCTAssertTrue(result.contains("script_translator"))
    }

    // MARK: - Validation

    func testValidateStrippedSchemaValid() {
        let yaml = """
        engine:
          translators:
            - script_translator
        """
        XCTAssertTrue(RimeConfigPostProcessor.validateStrippedSchema(yaml))
    }

    func testValidateStrippedSchemaTableTranslator() {
        let yaml = """
        engine:
          translators:
            - table_translator
        """
        XCTAssertTrue(RimeConfigPostProcessor.validateStrippedSchema(yaml))
    }

    func testValidateStrippedSchemaInvalid() {
        let yaml = """
        engine:
          translators:
            - lua_translator@date
            - lua_translator@lunar
        """
        let stripped = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(RimeConfigPostProcessor.validateStrippedSchema(stripped))
    }

    func testValidateEmptySchema() {
        XCTAssertFalse(RimeConfigPostProcessor.validateStrippedSchema(""))
    }

    // MARK: - shouldStripLua

    func testShouldStripLuaWhenKeyMissing() {
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        defaults?.removeObject(forKey: "rime_lua_available")
        XCTAssertFalse(RimeConfigPostProcessor.shouldStripLua(),
                       "当 rime_lua_available 键缺失时，默认认为 Lua 可用（librime-lua 已链接）")
    }

    func testShouldStripLuaWhenFalse() {
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        defaults?.set(false, forKey: "rime_lua_available")
        XCTAssertTrue(RimeConfigPostProcessor.shouldStripLua())
    }

    func testShouldStripLuaWhenTrue() {
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        defaults?.set(true, forKey: "rime_lua_available")
        XCTAssertFalse(RimeConfigPostProcessor.shouldStripLua(),
                        "当 rime_lua_available 为 true 时，不应该剥离 Lua")
        defaults?.removeObject(forKey: "rime_lua_available")
    }

    // MARK: - initials stripping

    func testStripInitialsWithAllLetters() {
        let yaml = """
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          initials: zyxwvutsrqponmlkjihgfedcba
          delimiter: " '"
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("initials:"), "包含全字母的 initials 行应该被移除")
        XCTAssertTrue(result.contains("alphabet:"), "alphabet 行应该保留")
    }

    func testStripInitialsWithNormalInitials() {
        // 小鹤双拼等方案的 initials 只包含声母，不应该被移除
        let yaml = """
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          initials: bpmfdtnlgkhjqxzcsryw
          delimiter: " '"
        """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertTrue(result.contains("initials: bpmfdtnlgkhjqxzcsryw"), "普通方案的 initials 应该保留")
    }

    // MARK: - repairSchemaIfNeeded

    func testRepairDoesNotTouchCorrectLuaSchema() {
        let tmpFile = NSTemporaryDirectory() + "rime_test_correct.yaml"
        let correctSchema = """
        engine:
          translators:
            - lua_translator@*date_translator
            - script_translator
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          initials: zyxwvutsrqponmlkjihgfedcba
        """
        try? correctSchema.write(toFile: tmpFile, atomically: true, encoding: .utf8)
        RimeConfigPostProcessor.repairSchemaIfNeeded(at: tmpFile)
        let result = String(data: (try! Data(contentsOf: URL(fileURLWithPath: tmpFile))), encoding: .utf8)!
        XCTAssertEqual(result, correctSchema, "包含 Lua 引用的正确 schema 不应该被修改")
        try? FileManager.default.removeItem(atPath: tmpFile)
    }

    func testRepairFixesOldStrippedSchema() {
        let tmpFile = NSTemporaryDirectory() + "rime_test_stripped.yaml"
        // 模拟旧剥离代码的真实产物：Lua 引用已被删除，孤行 date_locale: zh 残留，
        // 破坏性 initials 保留，script_translator + table_translator 保留
        let strippedSchema = """
        engine:
          translators:
            - punct_translator
            - script_translator
            date_locale: zh
            - table_translator@custom_phrase
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          initials: zyxwvutsrqponmlkjihgfedcba
        translator:
          dictionary: rime_ice
        """
        try? strippedSchema.write(toFile: tmpFile, atomically: true, encoding: .utf8)
        RimeConfigPostProcessor.repairSchemaIfNeeded(at: tmpFile)
        let result = String(data: (try! Data(contentsOf: URL(fileURLWithPath: tmpFile))), encoding: .utf8)!
        XCTAssertFalse(result.contains("initials: zyxwvutsrqponmlkjihgfedcba"), "修复后破坏性 initials 应该被移除")
        XCTAssertFalse(result.contains("date_locale: zh"), "修复后孤行应该被移除")
        XCTAssertTrue(result.contains("script_translator"), "script_translator 应该保留")
        XCTAssertTrue(result.contains("table_translator@custom_phrase"), "table_translator 应该保留")
        XCTAssertTrue(result.contains("alphabet:"), "alphabet 应该保留")
        try? FileManager.default.removeItem(atPath: tmpFile)
    }

    func testRepairSkipsSchemaWithoutDamagingInitials() {
        let tmpFile = NSTemporaryDirectory() + "rime_test_normal.yaml"
        let schema = """
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          delimiter: " '"
        translator:
          dictionary: rime_ice
        """
        try? schema.write(toFile: tmpFile, atomically: true, encoding: .utf8)
        RimeConfigPostProcessor.repairSchemaIfNeeded(at: tmpFile)
        let result = try? String(contentsOfFile: tmpFile, encoding: .utf8)
        XCTAssertEqual(result, schema, "没有破坏性 initials 的 schema 不应该被修改")
        try? FileManager.default.removeItem(atPath: tmpFile)
    }

    func testRepairRemovesOrphanWithoutInitials() {
        let tmpFile = NSTemporaryDirectory() + "rime_test_orphan_only.yaml"
        // 模拟第一次修复已移除 initials，但孤行 date_locale: zh 仍残留
        let schema = """
        engine:
          translators:
            - punct_translator
            - script_translator
            date_locale: zh
            - table_translator@custom_phrase
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
        translator:
          dictionary: rime_ice
        """
        try? schema.write(toFile: tmpFile, atomically: true, encoding: .utf8)
        RimeConfigPostProcessor.repairSchemaIfNeeded(at: tmpFile)
        let result = String(data: (try! Data(contentsOf: URL(fileURLWithPath: tmpFile))), encoding: .utf8)!
        XCTAssertFalse(result.contains("date_locale: zh"), "孤行应该被移除（即使没有 initials）")
        XCTAssertTrue(result.contains("script_translator"), "script_translator 应该保留")
        try? FileManager.default.removeItem(atPath: tmpFile)
    }

    func testRepairHandlesMissingFile() {
        // 不应该崩溃
        RimeConfigPostProcessor.repairSchemaIfNeeded(at: "/tmp/nonexistent_rime_test.yaml")
    }

    // MARK: - Full old-stripper simulation

    func testOldStripperDamageRepair() {
        // 模拟完整的旧剥离→修复流程
        let original = """
        engine:
          processors:
            - lua_processor@*select_character
            - ascii_composer
            - speller
          translators:
            - punct_translator
            - script_translator
            - lua_translator@*date_translator
              date_locale: zh
            - lua_translator@*lunar
            - table_translator@custom_phrase
          filters:
            - lua_filter@*corrector
            - uniquifier
        speller:
          initials: zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA
          alphabet: zyxwvutsrqponmlkjihgfedcba
        translator:
          dictionary: rime_ice
        """

        // Step 1: 模拟旧剥离（只删 Lua 行，不处理续行和 initials）
        let oldStripped = original.components(separatedBy: "\n")
            .filter { line in
                let t = line.trimmingCharacters(in: .whitespaces)
                if t.contains("lua_translator@") || t.contains("lua_filter@") { return false }
                if t.hasPrefix("- lua_translator") || t.hasPrefix("- lua_filter") || t.hasPrefix("- lua_processor") { return false }
                return true
            }
            .joined(separator: "\n")

        // 验证旧剥离后有问题
        XCTAssertTrue(oldStripped.contains("initials:"), "旧剥离后 initials 仍在")
        XCTAssertTrue(oldStripped.contains("date_locale: zh"), "旧剥离后孤行仍在")

        // Step 2: 用新代码修复
        let repaired = RimeConfigPostProcessor.stripLuaDependencies(from: original)
        XCTAssertFalse(repaired.contains("initials: zyxwvutsrqponmlkjihgfedcba"), "新剥离后 initials 被移除")
        XCTAssertFalse(repaired.contains("date_locale: zh"), "新剥离后孤行被移除")
        XCTAssertFalse(repaired.contains("lua_translator@"), "新剥离后 Lua 引用被移除")
        XCTAssertTrue(repaired.contains("script_translator"), "script_translator 保留")
        XCTAssertTrue(repaired.contains("table_translator@custom_phrase"), "table_translator 保留")
        XCTAssertTrue(RimeConfigPostProcessor.validateStrippedSchema(repaired), "修复后 schema 有效")
    }
}
