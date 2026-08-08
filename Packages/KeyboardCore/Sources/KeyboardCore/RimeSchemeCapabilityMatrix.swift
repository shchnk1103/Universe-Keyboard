import Foundation

/// Product-facing capability profile for a RIME scheme in main-App settings.
///
/// This is honesty for **what Universe productizes**, not a full inventory of
/// upstream Lua/grammar. Prefer extending this matrix over hardcoding
/// `rime_ice` in each settings view (TD-010).
public struct RimeSchemeCapabilityProfile: Equatable, Sendable {
    public let schemaID: String
    /// Universe-managed fuzzy algebra post-process is claimed for this scheme.
    public let supportsManagedFuzzyPinyin: Bool
    /// Product advanced-input switches (fog `date_translator` matrix) apply.
    public let supportsProductAdvancedInput: Bool

    public init(
        schemaID: String,
        supportsManagedFuzzyPinyin: Bool,
        supportsProductAdvancedInput: Bool
    ) {
        self.schemaID = schemaID
        self.supportsManagedFuzzyPinyin = supportsManagedFuzzyPinyin
        self.supportsProductAdvancedInput = supportsProductAdvancedInput
    }
}

public enum RimeSchemeCapabilityMatrix {
    /// Canonical letter-schema id for capability lookup (`t9` → fog family).
    public static func normalizeSchemaID(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "luna_pinyin" }
        if trimmed == "t9" { return "rime_ice" }
        return trimmed
    }

    public static func profile(for schemaID: String) -> RimeSchemeCapabilityProfile {
        let id = normalizeSchemaID(schemaID)
        switch id {
        case "rime_ice":
            return RimeSchemeCapabilityProfile(
                schemaID: id,
                supportsManagedFuzzyPinyin: true,
                supportsProductAdvancedInput: true
            )
        case "luna_pinyin":
            // Built-in: fuzzy algebra post-process is supported; no fog advanced-input matrix.
            return RimeSchemeCapabilityProfile(
                schemaID: id,
                supportsManagedFuzzyPinyin: true,
                supportsProductAdvancedInput: false
            )
        case "wanxiang":
            // V1 product claim: 万象 base is installable full-pinyin; managed fuzzy /
            // fog-style advanced input not productized (Human smoke; TD-011 later).
            return RimeSchemeCapabilityProfile(
                schemaID: id,
                supportsManagedFuzzyPinyin: false,
                supportsProductAdvancedInput: false
            )
        default:
            return RimeSchemeCapabilityProfile(
                schemaID: id,
                supportsManagedFuzzyPinyin: false,
                supportsProductAdvancedInput: false
            )
        }
    }

    /// Resolve which scheme settings pages should gate against (layout-bound).
    public static func settingsCapabilitySchemaID(
        layoutStyle: KeyboardLayoutStyle,
        schemeBinding26: String?,
        schemeBinding9: String?,
        activeSchemaID: String?
    ) -> String {
        switch layoutStyle {
        case .nineKey:
            let nine = schemeBinding9.flatMap { $0.isEmpty ? nil : $0 } ?? "t9"
            return normalizeSchemaID(nine)
        case .twentySixKey:
            if let binding = schemeBinding26, !binding.isEmpty {
                return normalizeSchemaID(binding)
            }
            return normalizeSchemaID(activeSchemaID ?? "luna_pinyin")
        }
    }
}
