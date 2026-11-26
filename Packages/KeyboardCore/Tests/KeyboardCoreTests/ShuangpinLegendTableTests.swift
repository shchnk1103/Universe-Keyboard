import XCTest

@testable import KeyboardCore

/// PB-017 PR-2：双拼键帽副标映射表单测。
///
/// 数据正确性用两道独立闸门把关：
/// 1. 测试内第二份字面量表（防手滑改坏源表）；
/// 2. 副标字符必须能在 `RimeShuangpinVariant.upstreamAlgebra` 对应键的规则
///    模式中找到（防源表与上游官方规则链脱钩）。
final class ShuangpinLegendTableTests: XCTestCase {
    /// 小写键位全集。
    private static let keys = Array("qwertyuiopasdfghjklzxcvbnm").map(String.init)

    /// 测试侧独立维护的期望副标（与 ShuangpinLegendTable 推导规则一致：
    /// 多韵母键取规则模式首个展开；[uv]e 按 ü 的双拼拼写记 `ve`；
    /// A/E 两键无映射韵母，为空）。
    private static let expectedFlypy: [String: String] = [
        "q": "iu", "w": "ei", "e": "", "r": "uan", "t": "ve", "y": "un",
        "u": "sh", "i": "ch", "o": "uo", "p": "ie", "a": "", "s": "ong",
        "d": "ai", "f": "en", "g": "eng", "h": "ang", "j": "an", "k": "ing",
        "l": "iang", "z": "ou", "x": "ia", "c": "ao", "v": "zh", "b": "in",
        "n": "iao", "m": "ian",
    ]
    private static let expectedZrm: [String: String] = [
        "q": "iu", "w": "ia", "e": "", "r": "uan", "t": "ve", "y": "ing",
        "u": "sh", "i": "ch", "o": "uo", "p": "un", "a": "", "s": "ong",
        "d": "iang", "f": "en", "g": "eng", "h": "ang", "j": "an", "k": "ao",
        "l": "ai", "z": "ei", "x": "ie", "c": "iao", "v": "zh", "b": "ou",
        "n": "in", "m": "ian",
    ]

    func testFlypyCoversAllTwentySixKeysAndMatchesExpectedMapping() {
        XCTAssertTrue(ShuangpinLegendTable.flypy.coversAllTwentySixKeys())
        for key in Self.keys {
            XCTAssertEqual(
                ShuangpinLegendTable.flypy.sublegends[key], Self.expectedFlypy[key],
                "flypy 键 \(key) 副标与期望不符")
        }
    }

    func testZrmCoversAllTwentySixKeysAndMatchesExpectedMapping() {
        XCTAssertTrue(ShuangpinLegendTable.zrm.coversAllTwentySixKeys())
        for key in Self.keys {
            XCTAssertEqual(
                ShuangpinLegendTable.zrm.sublegends[key], Self.expectedZrm[key],
                "zrm 键 \(key) 副标与期望不符")
        }
    }

    /// 副标字符必须能在 `upstreamAlgebra` 中映射到该键的规则模式里找到。
    /// （xlit 源/目标按位恒等，规则目标大写字母即键位大写。）
    func testLegendsAreGroundedInUpstreamAlgebra() {
        for (variant, table) in [
            (RimeShuangpinVariant.flypy, ShuangpinLegendTable.flypy),
            (RimeShuangpinVariant.zrm, ShuangpinLegendTable.zrm),
        ] {
            for key in Self.keys {
                guard let legend = table.sublegend(for: key) else { continue }
                let patternLetters = Self.algebraPatternLetters(for: key, in: variant.upstreamAlgebra)
                XCTAssertFalse(
                    patternLetters.isEmpty,
                    "\(variant.rawValue) 缺少映射到键 \(key) 的 algebra 规则")
                for char in legend {
                    XCTAssertTrue(
                        patternLetters.contains(char),
                        "\(variant.rawValue) 键 \(key) 副标 `\(legend)` 的 `\(char)` 不在其 algebra 规则 \(patternLetters) 中")
                }
            }
        }
    }

    /// 提取映射到指定键的 algebra 规则模式中的拼音字母集合。
    /// 规则两种形态：`xform/<pattern>/<TARGET>/`（如 `^sh/U/`）与
    /// 带捕获组替换 `xform/(.)ei$/$1W/`（目标大写字母在替换段）。
    private static func algebraPatternLetters(for key: String, in algebra: [String]) -> Set<Character> {
        let target = Character(key.uppercased())
        var letters = Set<Character>()
        for rule in algebra {
            guard rule.hasPrefix("xform/") else { continue }
            let parts = rule.dropFirst("xform/".count).split(separator: "/", omittingEmptySubsequences: false)
            guard parts.count >= 2 else { continue }
            let replacement = parts[1]
            guard replacement.contains(target) else { continue }
            for char in parts[0] where char.isLetter && char.isLowercase {
                letters.insert(char)
            }
        }
        return letters
    }

    func testSublegendHidesEmptyAndUnknownKeys() {
        XCTAssertNil(ShuangpinLegendTable.flypy.sublegend(for: "a"))
        XCTAssertNil(ShuangpinLegendTable.flypy.sublegend(for: "e"))
        XCTAssertNil(ShuangpinLegendTable.flypy.sublegend(for: "1"))
        XCTAssertEqual(ShuangpinLegendTable.flypy.sublegend(for: "Q"), "iu")
        XCTAssertEqual(ShuangpinLegendTable.flypy.sublegend(for: "q"), "iu")
    }

    func testTableForSchemaIDMatchesVariantsAndRejectsOthers() {
        XCTAssertEqual(
            ShuangpinLegendTable.table(forSchemaID: RimeShuangpinVariant.flypy.schemaID), .flypy)
        XCTAssertEqual(
            ShuangpinLegendTable.table(forSchemaID: RimeShuangpinVariant.zrm.schemaID), .zrm)
        XCTAssertNil(ShuangpinLegendTable.table(forSchemaID: "luna_pinyin"))
        XCTAssertNil(ShuangpinLegendTable.table(forSchemaID: "t9"))
        XCTAssertNil(ShuangpinLegendTable.table(forSchemaID: nil))
    }

    func testSublegendSettingsKeyLiteralAndShape() {
        // 登记进共享设置键枚举，业务代码不得散落裸字符串。
        XCTAssertEqual(
            KeyboardLayoutSettingsKey.shuangpinSublegendEnabled,
            "keyboard.shuangpin.sublegendEnabled")
        // 表为值类型 Sendable 纯数据，两个方案表互不相等且与键位全集对齐。
        XCTAssertNotEqual(ShuangpinLegendTable.flypy, .zrm)
        XCTAssertEqual(ShuangpinLegendTable.allKeys.count, 26)
    }
}
