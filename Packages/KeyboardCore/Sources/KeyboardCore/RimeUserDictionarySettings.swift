import Foundation

/// RIME user dictionary learning switches for the built-in pinyin schemas.
///
/// These settings intentionally stay schema-specific. Different input schemes can
/// encode the same text differently, so sharing learned candidate order globally
/// would make the user's history ambiguous.
public struct RimeUserDictionarySettings: Equatable, Sendable {
    public static let lunaPinyinEnabledKey = "rime_user_dict_luna_pinyin_enabled"
    public static let rimeIceEnabledKey = "rime_user_dict_rime_ice_enabled"
    public static let pendingDeployKey = "rime_user_dict_pending_deploy"
    public static let deployedSignatureKey = "rime_user_dict_deployed_signature"

    public var lunaPinyinEnabled: Bool
    public var rimeIceEnabled: Bool

    public init(
        lunaPinyinEnabled: Bool = true,
        rimeIceEnabled: Bool = true
    ) {
        self.lunaPinyinEnabled = lunaPinyinEnabled
        self.rimeIceEnabled = rimeIceEnabled
    }

    public func isEnabled(for schemaID: String) -> Bool {
        switch schemaID {
        case "rime_ice":
            return rimeIceEnabled
        default:
            return lunaPinyinEnabled
        }
    }

    public func deploymentSignature() -> String {
        [
            "luna_pinyin=\(lunaPinyinEnabled ? 1 : 0)",
            "rime_ice=\(rimeIceEnabled ? 1 : 0)",
        ].joined(separator: ";")
    }
}
