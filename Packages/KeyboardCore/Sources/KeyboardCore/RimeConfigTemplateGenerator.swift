// swift-format-ignore-file
import Foundation

/// RIME 配置模板 — 生成 YAML 配置字符串。
/// 纯逻辑，不依赖 App Group 或 FileManager。
public struct RimeConfigTemplates {

    /// 生成 default.yaml 内容。
    /// - Parameters:
    ///   - activeSchemaID: 当前激活的方案 ID
    ///   - rimeIceInstalled: 是否安装了 雾凇拼音
    ///   - pageSize: 每页候选数
    public static func generateDefaultYaml(
        activeSchemaID: String,
        rimeIceInstalled: Bool,
        pageSize: Int
    ) -> String {
        let schemaList = schemaListYaml(rimeIceInstalled: rimeIceInstalled)

        return """
            config_version: "0.1"

            schema_list:
            \(schemaList)
            switcher:
              caption: "[方案选单]"
              hotkeys:
                - "Control+grave"
                - "F4"

            menu:
              page_size: \(pageSize)
              alternative_select_keys: "123456789"

            ascii_composer:
              switch_key:
                Shift_L: commit_code
                Shift_R: commit_code

            key_binder:
              import_preset: default

            punctuator:
              full_shape:
                " ": { commit: "　" }
                ",": { commit: "，" }
                ".": { commit: "。" }
                "<": [ "《", "〈", "«", "‹" ]
                ">": [ "》", "〉", "»", "›" ]
                "/": [ "／", "÷" ]
                "?": { commit: "？" }
                ";": { commit: "；" }
                ":": { commit: "：" }
                '''': { pair: [ "‘", "’" ] }
                '"': { pair: [ "“", "”" ] }
                '\\': [ "、", "＼" ]
                "|": [ "·", "｜", "§", "¦" ]
                "`": "｀"
                "~": "～"
                "!": { commit: "！" }
                "@": [ "＠", "☯" ]
                "#": [ "＃", "⌘" ]
                "%": [ "％", "°", "℃" ]
                "$": [ "￥", "$", "€", "£", "¥", "¢", "¤" ]
                "^": { commit: "……" }
                "&": "＆"
                "*": [ "＊", "·", "・", "×", "※", "❂" ]
                "(": "（"
                ")": "）"
                "-": "－"
                "_": "——"
                "+": "＋"
                "=": "＝"
                "[": [ "「", "【", "〔", "［" ]
                "]": [ "」", "】", "〕", "］" ]
                "{": [ "『", "〖", "｛" ]
                "}": [ "』", "〗", "｝" ]
              half_shape:
                ",": { commit: "，" }
                ".": { commit: "。" }
                "<": [ "《", "〈", "«", "‹" ]
                ">": [ "》", "〉", "»", "›" ]
                "/": [ "/", "／", "÷" ]
                "?": { commit: "？" }
                ";": { commit: "；" }
                ":": { commit: "：" }
                '''': { pair: [ "‘", "’" ] }
                '"': { pair: [ "“", "”" ] }
                '\\': [ "、", '\\' ]
                "|": [ "·", "|", "｜", "§", "¦" ]
                "`": "`"
                "~": "~"
                "!": { commit: "！" }
                "@": "@"
                "#": "#"
                "%": "%"
                "$": [ "￥", "$", "€", "£", "¥", "¢", "¤" ]
                "^": { commit: "……" }
                "&": "&"
                "*": [ "*", "·", "・", "×", "※", "❂" ]
                "(": "（"
                ")": "）"
                "-": "-"
                "_": "——"
                "+": "+"
                "=": "="
                "[": [ "「", "【", "〔", "[" ]
                "]": [ "」", "】", "〕", "]" ]
                "{": [ "『", "〖", "{" ]
                "}": [ "』", "〗", "}" ]

            recognizer:
              import_preset: default
            """
    }

    private static func schemaListYaml(rimeIceInstalled: Bool) -> String {
        var schemaList = """
              - schema: luna_pinyin
                name: 朙月拼音
            """

        if rimeIceInstalled {
            schemaList +=
                "\n" + """
                      - schema: rime_ice
                        name: 雾凇拼音
                      - schema: t9
                        name: 中文九键
                    """
        }

        return schemaList
    }
}
