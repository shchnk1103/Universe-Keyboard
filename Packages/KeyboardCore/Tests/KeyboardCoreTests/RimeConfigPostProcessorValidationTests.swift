// swift-format-ignore-file
import XCTest

@testable import KeyboardCore

final class RimeConfigPostProcessorValidationTests: XCTestCase {
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

    func testShouldStripLuaWhenKeyMissing() {
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        defaults?.removeObject(forKey: "rime_lua_available")
        XCTAssertFalse(
            RimeConfigPostProcessor.shouldStripLua(),
            "当 rime_lua_available 键缺失时，默认认为 Lua 可用（librime-lua 已链接）"
        )
    }

    func testShouldStripLuaWhenFalse() {
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        defaults?.set(false, forKey: "rime_lua_available")
        XCTAssertTrue(RimeConfigPostProcessor.shouldStripLua())
    }

    func testShouldStripLuaWhenTrue() {
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        defaults?.set(true, forKey: "rime_lua_available")
        XCTAssertFalse(RimeConfigPostProcessor.shouldStripLua(), "当 rime_lua_available 为 true 时，不应该剥离 Lua")
        defaults?.removeObject(forKey: "rime_lua_available")
    }
}
