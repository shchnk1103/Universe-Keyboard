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
        XCTAssertTrue(RimeConfigPostProcessor.shouldStripLua(),
                       "当 rime_lua_available 键缺失时，默认应该剥离 Lua")
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
}
