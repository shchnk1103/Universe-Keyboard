// swift-format-ignore-file
import Foundation

public extension RimeConfigTemplates {
    static let installationYaml = """
        distribution_code_name: "UniverseKeyboard"
        distribution_name: "Universe Keyboard"
        distribution_version: "1.0.0"
        installation_id: "universe-keyboard-ios"
        sync_dir: "sync"
        """

    static let lunaPinyinSchema = """
        schema:
          schema_id: luna_pinyin
          name: 朙月拼音
          version: "0.15"
          author:
            - RIME Developers

        switches:
          - name: ascii_mode
            reset: 0
            states: [ 中文, ABC ]
          - name: simplification
            reset: 1
            states: [ 漢字, 汉字 ]

        engine:
          processors:
            - ascii_composer
            - recognizer
            - key_binder
            - speller
            - punctuator
            - selector
            - navigator
            - express_editor
          segmentors:
            - ascii_segmentor
            - matcher
            - abc_segmentor
            - punct_segmentor
            - fallback_segmentor
          translators:
            - punct_translator
            - script_translator
          filters:
            - simplifier
            - uniquifier

        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          delimiter: " '"
          algebra:
            - erase/^xx$/
            - abbrev/^([a-z]).+$/$1/
            - abbrev/^([zcs]h).+$/$1/
            - derive/^([nl])ve$/$1ue/
            - derive/^([jqxy])u/$1v/
            - derive/un$/uen/
            - derive/ui$/uei/
            - derive/iu$/iou/
            - derive/([aeiou])ng$/$1gn/
            - derive/([dtngkhrzcs])o(u|ng)$/$1o/
            - derive/ong$/on/
            - derive/ao$/oa/
            - derive/([iu])a(o|ng?)$/a$1$2/

        translator:
          dictionary: luna_pinyin

        punctuator:
          import_preset: default

        key_binder:
          import_preset: default

        recognizer:
          import_preset: default

        simplifier:
          option_name: simplification
          opencc_config: opencc/t2s.json
          tips: none
        """

    /// 雾凇拼音最小可用 schema——用于替代被旧 Lua 剥离破坏的 rime_ice.schema.yaml。
    /// 基于 script_translator（非 Lua），挂载 rime_ice 词库 + melt_eng + custom_phrase + cn_en + radical_lookup。
    /// 不依赖 librime-lua，可独立产生候选词。
    static let rimeIceMinimalSchema = """
        schema:
          schema_id: rime_ice
          name: 雾凇拼音

        switches:
          - name: ascii_mode
            reset: 0
            states: [ 中, Ａ ]
          - name: simplification
            reset: 1
            states: [ 漢字, 汉字 ]

        engine:
          processors:
            - ascii_composer
            - recognizer
            - key_binder
            - speller
            - punctuator
            - selector
            - navigator
            - express_editor
          segmentors:
            - ascii_segmentor
            - matcher
            - abc_segmentor
            - punct_segmentor
            - fallback_segmentor
          translators:
            - punct_translator
            - script_translator
            - table_translator@custom_phrase
            - table_translator@melt_eng
            - table_translator@cn_en
          filters:
            - simplifier
            - uniquifier

        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          delimiter: " '"
          algebra:
            - erase/^xx$/
            - abbrev/^([a-z]).+$/$1/
            - abbrev/^([zcs]h).+$/$1/
            - derive/^([nl])ve$/$1ue/
            - derive/^([jqxy])u/$1v/
            - derive/^([nl])ue$/$1ve/
            - derive/^([jqxy])v/$1u/

        translator:
          dictionary: rime_ice
        """
}

/// PB-017：内置双拼方案变体。schema_id 沿用上游 RIME 命名（自然码为上游默认命名
/// `double_pinyin`，小鹤为 `double_pinyin_flypy`）。
public enum RimeShuangpinVariant: String, Sendable, CaseIterable {
    /// 小鹤双拼（上游 `double_pinyin_flypy`）。
    case flypy
    /// 自然码双拼（上游 `double_pinyin`）。
    case zrm

    public var schemaID: String {
        switch self {
        case .flypy:
            return "double_pinyin_flypy"
        case .zrm:
            return "double_pinyin"
        }
    }

    public var displayName: String {
        switch self {
        case .flypy:
            return "小鹤双拼"
        case .zrm:
            return "自然码双拼"
        }
    }

    /// 上游官方 speller/algebra 规则链（rime/rime-double-pinyin 原样收录；
    /// `abbrev` 上游注释未启用，不收录）。
    public var upstreamAlgebra: [String] {
        switch self {
        case .flypy:
            return [
                "erase/^xx$/",
                "derive/^([jqxy])u$/$1v/",
                "derive/^([aoe])([ioun])$/$1$1$2/",
                "xform/^([aoe])(ng)?$/$1$1$2/",
                "xform/iu$/Q/",
                "xform/(.)ei$/$1W/",
                "xform/uan$/R/",
                "xform/[uv]e$/T/",
                "xform/un$/Y/",
                "xform/^sh/U/",
                "xform/^ch/I/",
                "xform/^zh/V/",
                "xform/uo$/O/",
                "xform/ie$/P/",
                "xform/i?ong$/S/",
                "xform/ing$|uai$/K/",
                "xform/(.)ai$/$1D/",
                "xform/(.)en$/$1F/",
                "xform/(.)eng$/$1G/",
                "xform/[iu]ang$/L/",
                "xform/(.)ang$/$1H/",
                "xform/ian$/M/",
                "xform/(.)an$/$1J/",
                "xform/(.)ou$/$1Z/",
                "xform/[iu]a$/X/",
                "xform/iao$/N/",
                "xform/(.)ao$/$1C/",
                "xform/ui$/V/",
                "xform/in$/B/",
                "xlit/QWRTYUIOPSDFGHJKLZXCVBNM/qwrtyuiopsdfghjklzxcvbnm/",
            ]
        case .zrm:
            return [
                "erase/^xx$/",
                "derive/^([jqxy])u$/$1v/",
                "derive/^([aoe])([ioun])$/$1$1$2/",
                "xform/^([aoe])(ng)?$/$1$1$2/",
                "xform/iu$/Q/",
                "xform/[iu]a$/W/",
                "xform/[uv]an$/R/",
                "xform/[uv]e$/T/",
                "xform/ing$|uai$/Y/",
                "xform/^sh/U/",
                "xform/^ch/I/",
                "xform/^zh/V/",
                "xform/uo$/O/",
                "xform/[uv]n$/P/",
                "xform/i?ong$/S/",
                "xform/[iu]ang$/D/",
                "xform/(.)en$/$1F/",
                "xform/(.)eng$/$1G/",
                "xform/(.)ang$/$1H/",
                "xform/ian$/M/",
                "xform/(.)an$/$1J/",
                "xform/iao$/C/",
                "xform/(.)ao$/$1K/",
                "xform/(.)ai$/$1L/",
                "xform/(.)ei$/$1Z/",
                "xform/ie$/X/",
                "xform/ui$/V/",
                "xform/(.)ou$/$1B/",
                "xform/in$/N/",
                "xlit/QWRTYUIOPSDFGHMJCKLZXVBN/qwrtyuiopsdfghmjcklzxvbn/",
            ]
        }
    }
}

public extension RimeConfigTemplates {
    /// 双拼模板可复用词库的宿主 base schema 集合（跟随当前激活宿主，不新增词库文件）。
    static let shuangpinHostBaseSchemaIDs: [String] = ["luna_pinyin", "rime_ice"]

    /// 生成内置最小双拼 schema 模板（PB-017 PR-1）。
    ///
    /// 与 luna_pinyin / rime_ice 内置最小模板同构：替换 speller/algebra 为上游官方
    /// 双拼映射（`RimeShuangpinVariant.upstreamAlgebra`），`dictionary` 段原样复用
    /// 宿主词库（跟随 `baseSchemaID`），不新增词库文件、不新增 downloadableSchemes。
    /// 纯 Swift、无 UIKit、无扩展侧部署（ADR 0001）。未知宿主按朙月形态兜底。
    static func shuangpinSchema(
        variant: RimeShuangpinVariant,
        baseSchemaID: String
    ) -> String {
        let isIceHost = baseSchemaID == "rime_ice"
        var lines: [String] = [
            "schema:",
            "  schema_id: \(variant.schemaID)",
            "  name: \(variant.displayName)",
            "  version: \"1.0\"",
            "  author:",
            "    - Universe Keyboard built-in template (PB-017, upstream double pinyin layout)",
            "",
            "switches:",
            "  - name: ascii_mode",
            "    reset: 0",
            isIceHost ? "    states: [ 中, Ａ ]" : "    states: [ 中文, ABC ]",
            "  - name: simplification",
            "    reset: 1",
            "    states: [ 漢字, 汉字 ]",
            "",
            "engine:",
            "  processors:",
            "    - ascii_composer",
            "    - recognizer",
            "    - key_binder",
            "    - speller",
            "    - punctuator",
            "    - selector",
            "    - navigator",
            "    - express_editor",
            "  segmentors:",
            "    - ascii_segmentor",
            "    - matcher",
            "    - abc_segmentor",
            "    - punct_segmentor",
            "    - fallback_segmentor",
            "  translators:",
            "    - punct_translator",
            "    - script_translator",
        ]
        if isIceHost {
            lines += [
                "    - table_translator@custom_phrase",
                "    - table_translator@melt_eng",
                "    - table_translator@cn_en",
            ]
        }
        lines += [
            "  filters:",
            "    - simplifier",
            "    - uniquifier",
            "",
            "speller:",
            "  alphabet: zyxwvutsrqponmlkjihgfedcba",
            "  delimiter: \" '\"",
            "  algebra:",
        ]
        lines += variant.upstreamAlgebra.map { "    - \($0)" }
        lines += [
            "",
            "translator:",
            "  dictionary: \(baseSchemaID)",
        ]
        if !isIceHost {
            lines += [
                "",
                "punctuator:",
                "  import_preset: default",
                "",
                "key_binder:",
                "  import_preset: default",
                "",
                "recognizer:",
                "  import_preset: default",
                "",
                "simplifier:",
                "  option_name: simplification",
                "  opencc_config: opencc/t2s.json",
                "  tips: none",
            ]
        }
        return lines.joined(separator: "\n")
    }
}
