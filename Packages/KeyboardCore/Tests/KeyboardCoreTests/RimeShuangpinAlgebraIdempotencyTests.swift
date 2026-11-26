import XCTest

@testable import KeyboardCore

/// PB-017 PR-1：双拼 speller/algebra 规则引擎单测。
///
/// 「幂等性（同串两次变换结果一致）」：对同一输入串执行两次完整 algebra 规则链，
/// 输出必须逐位一致——防止规则叠加引入不确定或漂移的变换结果。
/// 说明：librime 只对全拼词库拼写执行一次 algebra，两次完整部署重放必须收敛到
/// 同一拼写集合；本套测试同时约束该确定性与双拼「两键一音节」的形状不变量。
final class RimeShuangpinAlgebraIdempotencyTests: XCTestCase {
    /// 覆盖声母（含 zh/ch/sh）× 韵母全家族 × 零声母的代表性全拼音节语料。
    static let syllables: [String] = [
        // 零声母
        "a", "ai", "an", "ang", "ao", "e", "ei", "en", "eng", "er", "o", "ou",
        // 单韵母与自我键位
        "yi", "ya", "ye", "yao", "you", "yan", "yin", "ying", "yu", "yue", "yuan", "yun", "yong",
        "wu", "wa", "wo", "wai", "wei", "wan", "wen", "wang", "weng",
        // j/q/x + u/v 家族（ü 派生）
        "ji", "jia", "jie", "jiao", "jiu", "jian", "jin", "jing", "jiang", "ju", "jue", "juan", "jun", "jiong",
        "qi", "qia", "que", "quan", "qun", "qiong", "xi", "xia", "xie", "xiao", "xiu", "xian", "xin",
        "xing", "xiang", "xu", "xue", "xuan", "xun", "xiong",
        // 平翘舌
        "zhu", "zhua", "zhuo", "zhuai", "zhui", "zhun", "zhuan", "zhuo", "zhong", "zhang", "zheng",
        "zhan", "zhen", "zhao", "zhou", "zhan", "zhuang",
        "chu", "chua", "chuo", "chuai", "chui", "chun", "chuan", "chong", "chang", "cheng", "chan",
        "chen", "chao", "chou", "chuang",
        "shu", "shua", "shuo", "shuai", "shui", "shun", "shuan", "shang", "sheng", "shan", "shen",
        "shao", "shou", "shuang",
        // 声母 × 多键韵母
        "ba", "bai", "ban", "bang", "bao", "bei", "ben", "beng", "bi", "bian", "biao", "bie", "bin",
        "bing", "bo", "bu",
        "pai", "pan", "pang", "pei", "pen", "peng", "pian", "piao", "pin", "ping", "pu", "po",
        "da", "dai", "dan", "dang", "dao", "de", "dei", "den", "deng", "di", "dia", "dian", "diao",
        "die", "ding", "diu", "dong", "dou", "du", "duan", "dui", "dun", "duo",
        "fa", "fan", "fang", "fei", "fen", "feng", "fo", "fou", "fu",
        "ga", "gai", "gan", "gang", "gao", "ge", "gei", "gen", "geng", "gong", "gou", "gu", "gua",
        "guai", "guan", "guang", "gui", "gun", "guo",
        "ha", "hai", "han", "hang", "hao", "he", "hei", "hen", "heng", "hong", "hou", "hu", "hua",
        "huai", "huan", "huang", "hui", "hun", "huo",
        "ka", "kai", "kan", "kang", "kao", "ke", "ken", "keng", "kong", "kou", "ku", "kua", "kuai",
        "kuan", "kuang", "kui", "kun", "kuo",
        "la", "lai", "lan", "lang", "lao", "le", "lei", "leng", "li", "lia", "lian", "liang", "liao",
        "lie", "lin", "ling", "liu", "lo", "long", "lou", "lu", "luan", "lun", "luo", "lv", "lve",
        "ma", "mai", "man", "mang", "mao", "me", "mei", "men", "meng", "mi", "mian", "miao", "mie",
        "min", "ming", "miu", "mo", "mou", "mu",
        "na", "nai", "nan", "nang", "nao", "ne", "nei", "nen", "neng", "ni", "nian", "niang", "niao",
        "nie", "nin", "ning", "niu", "nong", "nou", "nu", "nuan", "nuo", "nv", "nve",
        "sa", "sai", "san", "sang", "sao", "se", "sen", "seng", "song", "sou", "su", "suan", "sui",
        "sun", "suo",
        "za", "zai", "zan", "zang", "zao", "ze", "zei", "zen", "zeng", "zong", "zou", "zu", "zuan",
        "zui", "zun", "zuo",
        "cai", "can", "cang", "cao", "ce", "cen", "ceng", "cong", "cou", "cu", "cuan", "cui", "cun",
        "cuo",
        "ru", "rua", "ruan", "rui", "run", "ruo", "rang", "reng", "ri", "rong", "rou", "re", "ren",
        "reng", "rao", "ran",
        "ta", "tai", "tan", "tang", "tao", "te", "teng", "ti", "tian", "tiao", "tie", "ting", "tong",
        "tou", "tu", "tuan", "tui", "tun", "tuo",
    ]

    private func transformer(variant: RimeShuangpinVariant, baseSchemaID: String) -> RimeSchemaAlgebraTransformer {
        RimeSchemaAlgebraTransformer(
            schemaYaml: RimeConfigTemplates.shuangpinSchema(variant: variant, baseSchemaID: baseSchemaID)
        )
    }

    /// 幂等性口径：同串两次变换结果一致（两次完整规则链重放收敛到同一拼写集合）。
    func testSameStringTransformedTwiceYieldsIdenticalResult() {
        for variant in RimeShuangpinVariant.allCases {
            for host in ["luna_pinyin", "rime_ice"] {
                let transformer = self.transformer(variant: variant, baseSchemaID: host)
                for syllable in Self.syllables {
                    let first = transformer.transform([syllable])
                    let second = transformer.transform([syllable])
                    XCTAssertEqual(first, second, "\(variant.rawValue)@\(host): \(syllable)")
                }
            }
        }
    }

    /// 独立解析的两份规则引擎对同一语料给出一致结果（无隐藏可变状态）。
    func testIndependentTransformerInstancesAgree() {
        for variant in RimeShuangpinVariant.allCases {
            let first = transformer(variant: variant, baseSchemaID: "luna_pinyin")
            let second = transformer(variant: variant, baseSchemaID: "rime_ice")
            for syllable in Self.syllables {
                XCTAssertEqual(first.transform([syllable]), second.transform([syllable]), syllable)
            }
        }
    }

    /// 双拼形状不变量：全部输出拼写 ≤ 2 键且为小写字母（「两键一音节」）。
    func testTransformedSpellingsStayWithinTwoLowercaseKeys() {
        for variant in RimeShuangpinVariant.allCases {
            let transformer = self.transformer(variant: variant, baseSchemaID: "luna_pinyin")
            for syllable in Self.syllables {
                let output = transformer.transform([syllable])
                for spelling in output {
                    XCTAssertTrue(
                        spelling.count <= 2 && spelling.allSatisfy { $0.isLetter && $0.isLowercase },
                        "\(variant.rawValue): \(syllable) → \(output)"
                    )
                }
            }
        }
    }

    /// 小鹤官方键位抽查（zh→V、ch→I、sh→U；韵母 Q iu / W ei / R uan / T ue / Y un / O uo /
    /// P ie / S ong / D ai / F en / G eng / H ang / J an / K uai-ing / L uang-iang /
    /// Z ou / X ia-ua / C ao / V ui / B in / N iao / M ian）。
    func testUpstreamFlypyMappings() {
        let transformer = transformer(variant: .flypy, baseSchemaID: "luna_pinyin")
        let expected: [String: String] = [
            "zhuang": "vl", "shuang": "ul", "chuang": "il", "niang": "nl", "xiang": "xl",
            "jian": "jm", "jiao": "jn", "jiu": "jq", "jin": "jb", "jing": "jk", "jia": "jx",
            "jie": "jp", "juan": "jr", "jun": "jy", "jue": "jt", "jiong": "js",
            "xiong": "xs", "yue": "yt", "yun": "yy", "yuan": "yr", "ying": "yk",
            "shai": "ud", "chui": "iv", "zhu": "vu", "shu": "uu", "chu": "iu",
            "sha": "ua", "gua": "gx", "hua": "hx", "shuai": "uk", "kuai": "kk",
            "song": "ss", "dai": "dd", "fei": "fw", "gou": "gz", "kou": "kz",
            "meng": "mg", "heng": "hg", "lang": "lh", "tang": "th",
        ]
        for (syllable, code) in expected {
            let output = transformer.transform([syllable])
            XCTAssertTrue(output.contains(code), "\(syllable) → \(output), 期望含 \(code)")
        }
        // 零声母：全拼二字母韵母保留 + 键位派生双形态。
        XCTAssertEqual(transformer.transform(["ang"]), ["ah"])
        XCTAssertEqual(transformer.transform(["eng"]), ["eg"])
        XCTAssertTrue(transformer.transform(["ai"]).contains("ai"))
        XCTAssertTrue(transformer.transform(["ai"]).contains("ad"))
        // ü 派生：ju 保留全拼并派生 jv。
        XCTAssertTrue(transformer.transform(["ju"]).contains("jv"))
        XCTAssertTrue(transformer.transform(["ju"]).contains("ju"))
        // erase：xx 被擦除。
        XCTAssertTrue(transformer.transform(["xx"]).isEmpty)
    }

    /// 自然码官方键位抽查（zh→V、ch→I、sh→U；韵母 Q iu / W ia-ua / R uan / T ue /
    /// Y ing-uai / P un / S ong / D uang-iang / L ai / Z ei / X ie / V ui / B ou /
    /// N in / M ian / C iao / K ao / J an / F en / G eng / H ang）。
    func testUpstreamZrmMappings() {
        let transformer = transformer(variant: .zrm, baseSchemaID: "luna_pinyin")
        let expected: [String: String] = [
            "zhuang": "vd", "shuang": "ud", "chuang": "id", "niang": "nd", "xiang": "xd",
            "jian": "jm", "jiao": "jc", "jiu": "jq", "jin": "jn", "jing": "jy", "jia": "jw",
            "jie": "jx", "juan": "jr", "jun": "jp", "jue": "jt",
            "xiong": "xs", "yue": "yt", "yun": "yp", "yuan": "yr", "ying": "yy",
            "shai": "ul", "chui": "iv", "zhu": "vu", "shu": "uu", "chu": "iu",
            "sha": "ua", "gua": "gw", "hua": "hw", "shuai": "uy", "kuai": "ky",
            "song": "ss", "dai": "dl", "fei": "fz", "gou": "gb", "kou": "kb",
            "meng": "mg", "heng": "hg", "lang": "lh", "tang": "th",
        ]
        for (syllable, code) in expected {
            let output = transformer.transform([syllable])
            XCTAssertTrue(output.contains(code), "\(syllable) → \(output), 期望含 \(code)")
        }
        XCTAssertEqual(transformer.transform(["ang"]), ["ah"])
        XCTAssertEqual(transformer.transform(["eng"]), ["eg"])
        XCTAssertTrue(transformer.transform(["ai"]).contains("ai"))
        XCTAssertTrue(transformer.transform(["ai"]).contains("al"))
        XCTAssertTrue(transformer.transform(["ju"]).contains("jv"))
        XCTAssertTrue(transformer.transform(["xx"]).isEmpty)
    }
}
