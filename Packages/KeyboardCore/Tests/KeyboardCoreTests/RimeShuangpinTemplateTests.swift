import XCTest

@testable import KeyboardCore

/// PB-017 PR-1：双拼内置模板部署产物单测。
///
/// 验证 `RimeConfigTemplates.shuangpinSchema(variant:baseSchemaID:)` 生成的
/// 最小 schema 模板与 luna_pinyin / rime_ice 内置模板同构：
/// speller/algebra 为双拼映射，`dictionary` 段复用宿主词库，不新增词库文件。
final class RimeShuangpinTemplateTests: XCTestCase {
    func testFlypyTemplateDeploymentArtifactWithLunaHost() {
        let yaml = RimeConfigTemplates.shuangpinSchema(variant: .flypy, baseSchemaID: "luna_pinyin")

        XCTAssertTrue(yaml.contains("schema_id: double_pinyin_flypy"), yaml)
        XCTAssertTrue(yaml.contains("name: 小鹤双拼"), yaml)
        XCTAssertTrue(yaml.contains("engine:"), yaml)
        XCTAssertTrue(yaml.contains("script_translator"), yaml)
        XCTAssertTrue(yaml.contains("speller:"), yaml)
        XCTAssertTrue(yaml.contains("algebra:"), yaml)
        // 小鹤官方 speller/algebra 签名规则（zh→V / 韵母键位 / 大写中间态 xlit 回小写）。
        XCTAssertTrue(yaml.contains("- xform/^zh/V/"), yaml)
        XCTAssertTrue(yaml.contains("- xform/^ch/I/"), yaml)
        XCTAssertTrue(yaml.contains("- xform/^sh/U/"), yaml)
        XCTAssertTrue(yaml.contains("- xform/iao$/N/"), yaml)
        XCTAssertTrue(yaml.contains("- xlit/QWRTYUIOPSDFGHJKLZXCVBNM/qwrtyuiopsdfghjklzxcvbnm/"), yaml)
        XCTAssertTrue(yaml.contains("dictionary: luna_pinyin"), yaml)
        XCTAssertTrue(yaml.contains("simplifier:"), yaml)
    }

    func testFlypyTemplateDeploymentArtifactWithIceHost() {
        let yaml = RimeConfigTemplates.shuangpinSchema(variant: .flypy, baseSchemaID: "rime_ice")

        XCTAssertTrue(yaml.contains("schema_id: double_pinyin_flypy"), yaml)
        XCTAssertTrue(yaml.contains("dictionary: rime_ice"), yaml)
        // 雾凇宿主形态：与 rimeIceMinimalSchema 同构（script_translator + table_translator 组）。
        XCTAssertTrue(yaml.contains("table_translator@custom_phrase"), yaml)
        XCTAssertTrue(yaml.contains("table_translator@melt_eng"), yaml)
        XCTAssertTrue(yaml.contains("table_translator@cn_en"), yaml)
        XCTAssertTrue(yaml.contains("- xform/^zh/V/"), yaml)
    }

    func testZrmTemplateDeploymentArtifactWithLunaHost() {
        let yaml = RimeConfigTemplates.shuangpinSchema(variant: .zrm, baseSchemaID: "luna_pinyin")

        // 自然码为上游默认命名，schema_id 即 double_pinyin。
        XCTAssertTrue(yaml.contains("schema_id: double_pinyin"), yaml)
        XCTAssertTrue(yaml.contains("name: 自然码双拼"), yaml)
        XCTAssertTrue(yaml.contains("- xform/^zh/V/"), yaml)
        XCTAssertTrue(yaml.contains("- xform/[iu]ang$/D/"), yaml)
        XCTAssertTrue(yaml.contains("- xlit/QWRTYUIOPSDFGHMJCKLZXVBN/qwrtyuiopsdfghmjcklzxvbn/"), yaml)
        XCTAssertTrue(yaml.contains("dictionary: luna_pinyin"), yaml)
        XCTAssertTrue(yaml.contains("simplifier:"), yaml)
    }

    func testZrmTemplateDeploymentArtifactWithIceHost() {
        let yaml = RimeConfigTemplates.shuangpinSchema(variant: .zrm, baseSchemaID: "rime_ice")

        XCTAssertTrue(yaml.contains("schema_id: double_pinyin"), yaml)
        XCTAssertTrue(yaml.contains("dictionary: rime_ice"), yaml)
        XCTAssertTrue(yaml.contains("table_translator@melt_eng"), yaml)
    }

    /// 词库零重复：dictionary 段只声明宿主词库，不得新增任何词库文件。
    func testDictionaryReusesHostLexiconWithoutNewDictionaryFiles() {
        for variant in RimeShuangpinVariant.allCases {
            for host in ["luna_pinyin", "rime_ice"] {
                let yaml = RimeConfigTemplates.shuangpinSchema(variant: variant, baseSchemaID: host)
                let dictionaryLines =
                    yaml
                    .components(separatedBy: "\n")
                    .filter { $0.trimmingCharacters(in: .whitespaces).hasPrefix("dictionary:") }
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                XCTAssertEqual(dictionaryLines, ["dictionary: \(host)"], "\(variant.rawValue) @ \(host)")
                // 宿主词库之外的 dictionary 引用（自建词库）不得出现。
                XCTAssertFalse(yaml.contains("dictionary: double_pinyin"), yaml)
            }
        }
    }

    func testVariantMetadataMatchesUpstreamNaming() {
        XCTAssertEqual(RimeShuangpinVariant.flypy.schemaID, "double_pinyin_flypy")
        XCTAssertEqual(RimeShuangpinVariant.zrm.schemaID, "double_pinyin")
        XCTAssertEqual(RimeShuangpinVariant.allCases.count, 2)
    }
}
