import XCTest

@testable import KeyboardCore

final class RimeConfigStaticTemplatesTests: XCTestCase {
    func testInstallationYaml() {
        let yaml = RimeConfigTemplates.installationYaml
        XCTAssertTrue(yaml.contains("UniverseKeyboard"))
        XCTAssertTrue(yaml.contains("Universe Keyboard"))
        XCTAssertTrue(yaml.contains("universe-keyboard-ios"))
        XCTAssertTrue(yaml.contains("distribution_version"))
    }

    func testInstallationYamlContainsRequiredKeys() {
        let yaml = RimeConfigTemplates.installationYaml
        for key in [
            "distribution_code_name", "distribution_name", "distribution_version", "installation_id", "sync_dir",
        ] {
            XCTAssertTrue(yaml.contains(key), "Missing key: \(key)")
        }
    }

    func testLunaPinyinSchemaContainsEngine() {
        let schema = RimeConfigTemplates.lunaPinyinSchema
        XCTAssertTrue(schema.contains("schema_id: luna_pinyin"))
        XCTAssertTrue(schema.contains("engine:"))
        XCTAssertTrue(schema.contains("processors:"))
        XCTAssertTrue(schema.contains("segmentors:"))
        XCTAssertTrue(schema.contains("translators:"))
        XCTAssertTrue(schema.contains("filters:"))
    }

    func testLunaPinyinSchemaContainsSpeller() {
        let schema = RimeConfigTemplates.lunaPinyinSchema
        XCTAssertTrue(schema.contains("speller:"))
        XCTAssertTrue(schema.contains("alphabet:"))
        XCTAssertTrue(schema.contains("delimiter:"))
        XCTAssertTrue(schema.contains("algebra:"))
    }

    func testLunaPinyinSchemaContainsSimplifier() {
        let schema = RimeConfigTemplates.lunaPinyinSchema
        XCTAssertTrue(schema.contains("simplifier:"))
        XCTAssertTrue(schema.contains("opencc_config: opencc/t2s.json"))
    }

    func testLunaPinyinSchemaContainsSwitches() {
        let schema = RimeConfigTemplates.lunaPinyinSchema
        XCTAssertTrue(schema.contains("ascii_mode"))
        XCTAssertTrue(schema.contains("simplification"))
        XCTAssertTrue(schema.contains("中文"))
        XCTAssertTrue(schema.contains("ABC"))
    }

    func testOpenccT2S() {
        let json = RimeConfigTemplates.openccT2S
        XCTAssertTrue(json.contains("Traditional Chinese to Simplified Chinese"))
        XCTAssertTrue(json.contains("TSPhrases.ocd2"))
        XCTAssertTrue(json.contains("TSCharacters.ocd2"))
        XCTAssertTrue(json.contains("mmseg"))
    }

    func testOpenccS2T() {
        let json = RimeConfigTemplates.openccS2T
        XCTAssertTrue(json.contains("Simplified Chinese to Traditional Chinese"))
        XCTAssertTrue(json.contains("STPhrases.ocd2"))
        XCTAssertTrue(json.contains("STCharacters.ocd2"))
    }

    func testOpenccConfigsAreValidJson() {
        let t2sData = RimeConfigTemplates.openccT2S.data(using: .utf8)!
        let t2s = try? JSONSerialization.jsonObject(with: t2sData) as? [String: Any]
        XCTAssertNotNil(t2s)
        XCTAssertEqual(t2s?["name"] as? String, "Traditional Chinese to Simplified Chinese")

        let s2tData = RimeConfigTemplates.openccS2T.data(using: .utf8)!
        let s2t = try? JSONSerialization.jsonObject(with: s2tData) as? [String: Any]
        XCTAssertNotNil(s2t)
        XCTAssertEqual(s2t?["name"] as? String, "Simplified Chinese to Traditional Chinese")
    }

    func testFallbackDictContainsHeader() {
        let dict = RimeConfigTemplates.fallbackDict
        XCTAssertTrue(dict.contains("name: luna_pinyin"))
        XCTAssertTrue(dict.contains("sort: by_weight"))
        XCTAssertTrue(dict.contains("use_preset_vocabulary: true"))
    }

    func testFallbackDictContainsEntries() {
        let dict = RimeConfigTemplates.fallbackDict
        XCTAssertTrue(dict.contains("的"), "Should contain 的")
        XCTAssertTrue(dict.contains("我们"), "Should contain 我们")
        XCTAssertTrue(dict.contains("谢谢"), "Should contain 谢谢")
        XCTAssertTrue(dict.contains("测试"), "Should contain 测试")
        XCTAssertTrue(dict.contains("wo men"))
        XCTAssertTrue(dict.contains("xie xie"))
        XCTAssertTrue(dict.contains("ce shi"))
    }

    func testFallbackDictHasCorrectSeparator() {
        let dict = RimeConfigTemplates.fallbackDict
        XCTAssertTrue(dict.contains("---"))
        XCTAssertTrue(dict.contains("..."))
    }
}
