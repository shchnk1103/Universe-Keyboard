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
