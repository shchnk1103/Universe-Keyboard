import CryptoKit
import Foundation

/// Isolated rewrite experiment. This type neither installs resources nor registers a scheme.
public enum LunaT9SchemaCompatibility {
    public enum RewriteError: Error {
        case invalidUTF8
        case anchorCount(Int)
        case sourceIdentityMismatch
        case outputIdentityMismatch
    }

    public static let sourceSHA256 =
        "668b4d4957e4cc8f9cea32ed3f08f0ecf4a7be8cdba058700507487bd96dd5c7"
    public static let outputSHA256 =
        "4ace88759d55296c6c8e3ff078ec14474dc307dca73ecefd5eb94eb96ef7cf27"

    /// Accept only the reviewed source bytes; upstream changes require a new review.
    public static func rewrite(_ source: Data) throws -> Data {
        guard var text = String(data: source, encoding: .utf8) else {
            throw RewriteError.invalidUTF8
        }
        // Check all anchors before replacing anything, so malformed input fails closed.
        for (index, rule) in replacements.enumerated() {
            guard text.components(separatedBy: rule.source).count == 2 else {
                throw RewriteError.anchorCount(index)
            }
        }
        guard digest(source) == sourceSHA256 else {
            throw RewriteError.sourceIdentityMismatch
        }
        for rule in replacements {
            text = text.replacingOccurrences(of: rule.source, with: rule.target)
        }
        let output = Data(text.utf8)
        guard digest(output) == outputSHA256 else {
            throw RewriteError.outputIdentityMismatch
        }
        return output
    }

    private static func digest(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    // Algebra is copied verbatim from the frozen variant, including comments and spacing.
    private static let replacements: [(source: String, target: String)] = [
        (
            #"""
              schema_id: luna_pinyin

            """#,
            #"""
              schema_id: luna_pinyin_t9

            """#
        ),
        (
            #"""
              alphabet: zyxwvutsrqponmlkjihgfedcba

            """#,
            #"""
              alphabet: "zyxwvutsrqponmlkjihgfedcba23456789"

            """#
        ),
        (
            #"""
              algebra:
                __patch:
                  - pinyin:/abbreviation
                  - pinyin:/spelling_correction
                  - pinyin:/key_correction

            """#,
            #"""
              algebra:
                  - abbrev/^([a-z]).+$/$1/           # 簡拼（首字母）
                  - abbrev/^([zcs]h).+$/$1/          # 簡拼（zh, ch, sh）
                  - derive/^([nl])ve$/$1ue/correction  # nüe = nue, lüe = lue
                  - derive/^([jqxy])u/$1v/correction   # ju = jü
                  - derive/un$/uen/correction          # gun = guen
                  - derive/ui$/uei/correction          # gui = guei
                  - derive/iu$/iou/correction          # jiu = jiou
                  - derive/([aeiou])ng$/$1gn/correction           # dagn => dang
                  - derive/([dtngkhrzcs])o(u|ng)$/$1o/correction  # zho => zhong|zhou
                  - derive/ong$/on/correction                     # zhonguo => zhong guo
                  - derive/ao$/oa/correction                      # hoa => hao
                  - derive/([iu])a(o|ng?)$/a$1$2/correction       # tain => tian
                  - derive/[abc]/2/
                  - derive/[def]/3/
                  - derive/[hgi]/4/
                  - derive/[jkl]/5/
                  - derive/[omn]/6/
                  - derive/[pqrs]/7/
                  - derive/[tuv]/8/
                  - derive/[wxyz]/9/

            """#
        ),
        (
            #"""
            __patch:
              # 使用八股文語言模型
              - grammar:/hant?
              # 用家自選配置
              - luna_pinyin.custom:/patch?

            """#,
            #"""
            __patch:
              # 使用八股文語言模型
              - grammar:/hant?
              # 用家自選配置
              - luna_pinyin.custom:/patch?
              - luna_pinyin_t9.custom:/patch?

            """#
        ),
        (
            #"""
            translator:
              dictionary: luna_pinyin

            """#,
            #"""
            translator:
              dictionary: luna_pinyin
              prism: luna_pinyin_t9
              spelling_hints: 8

            """#
        ),
    ]
}
