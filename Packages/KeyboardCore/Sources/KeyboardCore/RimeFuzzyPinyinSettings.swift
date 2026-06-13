import Foundation

/// Traditional RIME fuzzy pinyin settings.
///
/// This is separate from typo correction. It only generates deterministic
/// `speller/algebra` derive rules for the active RIME schema.
public struct RimeFuzzyPinyinSettings: Equatable, Sendable {
    public static let zhZKey = "rime_fuzzy_zh_z_enabled"
    public static let chCKey = "rime_fuzzy_ch_c_enabled"
    public static let shSKey = "rime_fuzzy_sh_s_enabled"
    public static let nLKey = "rime_fuzzy_n_l_enabled"

    public var zhZEnabled: Bool
    public var chCEnabled: Bool
    public var shSEnabled: Bool
    public var nLEnabled: Bool

    public init(
        zhZEnabled: Bool = true,
        chCEnabled: Bool = true,
        shSEnabled: Bool = true,
        nLEnabled: Bool = true
    ) {
        self.zhZEnabled = zhZEnabled
        self.chCEnabled = chCEnabled
        self.shSEnabled = shSEnabled
        self.nLEnabled = nLEnabled
    }

    public var hasEnabledRules: Bool {
        zhZEnabled || chCEnabled || shSEnabled || nLEnabled
    }

    public var algebraRules: [String] {
        var rules: [String] = []
        if zhZEnabled {
            rules.append("derive/^zh/z/")
            rules.append("derive/^z/zh/")
        }
        if chCEnabled {
            rules.append("derive/^ch/c/")
            rules.append("derive/^c/ch/")
        }
        if shSEnabled {
            rules.append("derive/^sh/s/")
            rules.append("derive/^s/sh/")
        }
        if nLEnabled {
            rules.append("derive/^n/l/")
            rules.append("derive/^l/n/")
        }
        return rules
    }
}
