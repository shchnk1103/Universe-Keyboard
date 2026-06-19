// swift-format-ignore-file
import XCTest

@testable import KeyboardCore

final class RimeConfigPostProcessorBasicTests: XCTestCase {
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

    func testStripLuaSegmentor() {
        let yaml = """
            segmentors:
              - lua_segmentor@some_segmentor
              - abc_segmentor
            """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertFalse(result.contains("lua_segmentor"))
        XCTAssertTrue(result.contains("abc_segmentor"))
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
        XCTAssertTrue(result.contains("lua:"))
        XCTAssertTrue(result.contains("script_translator"))
    }

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
        let yaml = """
            speller:
              alphabet: zyxwvutsrqponmlkjihgfedcba
              initials: bpmfdtnlgkhjqxzcsryw
              delimiter: " '"
            """
        let result = RimeConfigPostProcessor.stripLuaDependencies(from: yaml)
        XCTAssertTrue(result.contains("initials: bpmfdtnlgkhjqxzcsryw"), "普通方案的 initials 应该保留")
    }
}
