import Foundation

/// PB-017 PR-2：双拼 26 键键帽副标映射表（纯数据，`static let` 静态字面量构建）。
///
/// 数据来源：`RimeShuangpinVariant.upstreamAlgebra`（rime/rime-double-pinyin 上游
/// 官方规则链）。每个 26 键字符键在激活双拼方案下的副标 = 该键承载的韵母/声母
/// 缩写；一条规则命中多个韵母时（如小鹤 `i?ong`、`ing|uai`、`[iu]ang`）取规则
/// 模式的首个展开（[iu]/[uv] 按括号内首个字符展开；[uv]e 按 ü 的双拼拼写记
/// `ve`）。A/E 两键在两方案中均无映射韵母，副标为空字符串（渲染层整键隐藏）。
/// 单测独立复核该推导与 `upstreamAlgebra` 的逐键一致性。
public struct ShuangpinLegendTable: Sendable, Equatable {
    /// 小写键位字母 → 副标字符串（空串表示无副标，渲染层隐藏）。
    public let sublegends: [String: String]

    public init(sublegends: [String: String]) {
        self.sublegends = sublegends
    }

    /// 按小鹤双拼（`double_pinyin_flypy`）官方映射构建。
    public static let flypy = ShuangpinLegendTable(sublegends: [
        "q": "iu",
        "w": "ei",
        "e": "",
        "r": "uan",
        "t": "ve",
        "y": "un",
        "u": "sh",
        "i": "ch",
        "o": "uo",
        "p": "ie",
        "a": "",
        "s": "ong",
        "d": "ai",
        "f": "en",
        "g": "eng",
        "h": "ang",
        "j": "an",
        "k": "ing",
        "l": "iang",
        "z": "ou",
        "x": "ia",
        "c": "ao",
        "v": "zh",
        "b": "in",
        "n": "iao",
        "m": "ian",
    ])

    /// 按自然码双拼（上游 `double_pinyin`）官方映射构建。
    public static let zrm = ShuangpinLegendTable(sublegends: [
        "q": "iu",
        "w": "ia",
        "e": "",
        "r": "uan",
        "t": "ve",
        "y": "ing",
        "u": "sh",
        "i": "ch",
        "o": "uo",
        "p": "un",
        "a": "",
        "s": "ong",
        "d": "iang",
        "f": "en",
        "g": "eng",
        "h": "ang",
        "j": "an",
        "k": "ao",
        "l": "ai",
        "z": "ei",
        "x": "ie",
        "c": "iao",
        "v": "zh",
        "b": "ou",
        "n": "in",
        "m": "ian",
    ])

    /// 键位全集（QWERTY 26 键，小写）。
    public static let allKeys: [String] = Array("qwertyuiopasdfghjklzxcvbnm").map(String.init)

    /// 26 键映射完整性：任意方案的表必须覆盖全部 26 键。
    public func coversAllTwentySixKeys() -> Bool {
        Set(sublegends.keys) == Set(Self.allKeys)
    }

    /// 按双拼变体取表。
    public static func table(for variant: RimeShuangpinVariant) -> ShuangpinLegendTable {
        switch variant {
        case .flypy:
            return .flypy
        case .zrm:
            return .zrm
        }
    }

    /// 按 26 键槽位激活的 schema ID 取表（非双拼 schema 返回 nil）。
    public static func table(forSchemaID schemaID: String?) -> ShuangpinLegendTable? {
        guard let schemaID else { return nil }
        for variant in RimeShuangpinVariant.allCases where variant.schemaID == schemaID {
            return table(for: variant)
        }
        return nil
    }

    /// 单键副标；键位不存在或无副标返回 nil（渲染层隐藏）。
    public func sublegend(for key: String) -> String? {
        guard let legend = sublegends[key.lowercased()], !legend.isEmpty else { return nil }
        return legend
    }
}
