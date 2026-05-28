// swift-format-ignore-file
import XCTest

@testable import KeyboardCore

final class RimeConfigPostProcessorRepairTests: XCTestCase {
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
        RimeConfigPostProcessor.repairSchemaIfNeeded(at: "/tmp/nonexistent_rime_test.yaml")
    }

    func testOldStripperDamageRepair() {
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

        let oldStripped = original.components(separatedBy: "\n")
            .filter { line in
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if trimmedLine.contains("lua_translator@") || trimmedLine.contains("lua_filter@") { return false }
                if trimmedLine.hasPrefix("- lua_translator") || trimmedLine.hasPrefix("- lua_filter")
                    || trimmedLine.hasPrefix("- lua_processor")
                {
                    return false
                }
                return true
            }
            .joined(separator: "\n")

        XCTAssertTrue(oldStripped.contains("initials:"), "旧剥离后 initials 仍在")
        XCTAssertTrue(oldStripped.contains("date_locale: zh"), "旧剥离后孤行仍在")

        let repaired = RimeConfigPostProcessor.stripLuaDependencies(from: original)
        XCTAssertFalse(repaired.contains("initials: zyxwvutsrqponmlkjihgfedcba"), "新剥离后 initials 被移除")
        XCTAssertFalse(repaired.contains("date_locale: zh"), "新剥离后孤行被移除")
        XCTAssertFalse(repaired.contains("lua_translator@"), "新剥离后 Lua 引用被移除")
        XCTAssertTrue(repaired.contains("script_translator"), "script_translator 保留")
        XCTAssertTrue(repaired.contains("table_translator@custom_phrase"), "table_translator 保留")
        XCTAssertTrue(RimeConfigPostProcessor.validateStrippedSchema(repaired), "修复后 schema 有效")
    }
}
