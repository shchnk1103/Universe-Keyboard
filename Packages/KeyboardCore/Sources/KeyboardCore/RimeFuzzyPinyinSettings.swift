import Foundation

/// Traditional RIME fuzzy pinyin settings.
///
/// This is separate from typo correction. It only generates deterministic
/// `speller/algebra` derive rules for the active RIME schema.
public struct RimeFuzzyPinyinSettings: Equatable, Sendable {
    public static let enabledKey = "rime_fuzzy_enabled"
    public static let zhZKey = "rime_fuzzy_zh_z_enabled"
    public static let chCKey = "rime_fuzzy_ch_c_enabled"
    public static let shSKey = "rime_fuzzy_sh_s_enabled"
    public static let nLKey = "rime_fuzzy_n_l_enabled"
    public static let pendingDeployKey = "rime_fuzzy_pending_deploy"
    public static let deployedSignatureKey = "rime_fuzzy_deployed_signature"

    public var enabled: Bool
    public var zhZEnabled: Bool
    public var chCEnabled: Bool
    public var shSEnabled: Bool
    public var nLEnabled: Bool

    public init(
        enabled: Bool = true,
        zhZEnabled: Bool = true,
        chCEnabled: Bool = true,
        shSEnabled: Bool = true,
        nLEnabled: Bool = true
    ) {
        self.enabled = enabled
        self.zhZEnabled = zhZEnabled
        self.chCEnabled = chCEnabled
        self.shSEnabled = shSEnabled
        self.nLEnabled = nLEnabled
    }

    public var hasEnabledRules: Bool {
        enabled && (zhZEnabled || chCEnabled || shSEnabled || nLEnabled)
    }

    public var algebraRules: [String] {
        guard enabled else { return [] }
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

    public func deploymentSignature(activeSchemaID: String) -> String {
        [
            "schema=\(activeSchemaID)",
            "enabled=\(enabled ? 1 : 0)",
            "zh_z=\(zhZEnabled ? 1 : 0)",
            "ch_c=\(chCEnabled ? 1 : 0)",
            "sh_s=\(shSEnabled ? 1 : 0)",
            "n_l=\(nLEnabled ? 1 : 0)",
        ].joined(separator: ";")
    }
}
