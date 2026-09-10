import Foundation

/// Declarative layout claims for a scheme adapter (P1-1 registry surface).
///
/// P1-1 records **today’s product truth** only. Routing
/// `RimeRuntimeSelection.isNineKeyCapable` / `isTwentySixKeyCapable` through
/// adapters is **P1-2** — do not treat these fields as live call-site authority yet.
public struct SchemeLayoutCapability: Sendable, Equatable {
    /// Whether the canonical letter schema may appear in the 26-key picker.
    public let supportsTwentySixKey: Bool
    /// Whether this scheme **family** productizes nine-key (Ice via literal `t9`).
    /// Literal nine-key capability remains `schemaID == "t9"` today.
    public let supportsNineKey: Bool

    public init(supportsTwentySixKey: Bool, supportsNineKey: Bool) {
        self.supportsTwentySixKey = supportsTwentySixKey
        self.supportsNineKey = supportsNineKey
    }
}

/// Shared-default / Prelude policy id mirrored from today’s install hardcodes.
public enum SchemeSharedDefaultMode: String, Sendable, Equatable {
    /// Ice reference — private preset (`rime_ice_preset`) + include rewrite.
    case privatePreset
    /// Wanxiang P1 transitional skip / consume-Prelude shape (not end-state).
    case consumePrelude
    /// Luna builtin / Prelude exception.
    case builtinPrelude
}

/// Lua/OpenCC ownership strategy id (long-term dual: namedList + exactHash).
public enum SchemeOwnershipStrategyID: String, Sendable, Equatable {
    case namedList
    case exactHash
    case none
}

/// Thin per-scheme adapter bundle mirroring today’s hardcoded product answers.
///
/// P1-1 introduces registry lookup only. SharedDefault post-process (P1-3),
/// ownership install hooks (P1-4), and layout call-site routing (P1-2) come later.
public struct SchemeAdapter: Sendable, Equatable {
    /// Canonical letter-schema id (`rime_ice`, `wanxiang`, `luna_pinyin`).
    public let schemaID: String
    public let layout: SchemeLayoutCapability
    public let sharedDefaultMode: SchemeSharedDefaultMode
    public let ownershipStrategyID: SchemeOwnershipStrategyID
    /// Deterministic post-process revision, or `nil` when none applies (Luna / unknown).
    public let postProcessingRevision: String?
    public let supportsManagedFuzzyPinyin: Bool
    public let supportsProductAdvancedInput: Bool

    public init(
        schemaID: String,
        layout: SchemeLayoutCapability,
        sharedDefaultMode: SchemeSharedDefaultMode,
        ownershipStrategyID: SchemeOwnershipStrategyID,
        postProcessingRevision: String?,
        supportsManagedFuzzyPinyin: Bool,
        supportsProductAdvancedInput: Bool
    ) {
        self.schemaID = schemaID
        self.layout = layout
        self.sharedDefaultMode = sharedDefaultMode
        self.ownershipStrategyID = ownershipStrategyID
        self.postProcessingRevision = postProcessingRevision
        self.supportsManagedFuzzyPinyin = supportsManagedFuzzyPinyin
        self.supportsProductAdvancedInput = supportsProductAdvancedInput
    }
}

/// SchemaID → adapter registry reflecting Ice / Wanxiang / Luna hardcodes.
public enum SchemeAdapterRegistry {
    /// Ice family (`rime_ice`); nine-key productized via literal `t9` alias.
    public static let ice = SchemeAdapter(
        schemaID: "rime_ice",
        layout: SchemeLayoutCapability(supportsTwentySixKey: true, supportsNineKey: true),
        sharedDefaultMode: .privatePreset,
        ownershipStrategyID: .namedList,
        postProcessingRevision: "rime-ice-post-2",
        supportsManagedFuzzyPinyin: true,
        supportsProductAdvancedInput: true
    )

    /// Wanxiang: 26-key only; nine-key product claim stays false.
    public static let wanxiang = SchemeAdapter(
        schemaID: "wanxiang",
        layout: SchemeLayoutCapability(supportsTwentySixKey: true, supportsNineKey: false),
        sharedDefaultMode: .consumePrelude,
        ownershipStrategyID: .exactHash,
        postProcessingRevision: "wanxiang-post-1",
        supportsManagedFuzzyPinyin: false,
        supportsProductAdvancedInput: false
    )

    /// Luna builtin / Prelude exception.
    public static let luna = SchemeAdapter(
        schemaID: "luna_pinyin",
        layout: SchemeLayoutCapability(supportsTwentySixKey: true, supportsNineKey: false),
        sharedDefaultMode: .builtinPrelude,
        ownershipStrategyID: .none,
        postProcessingRevision: nil,
        supportsManagedFuzzyPinyin: true,
        supportsProductAdvancedInput: false
    )

    /// Canonical letter-schema id for adapter lookup (`t9` → Ice family).
    public static func normalizeSchemaID(_ raw: String) -> String {
        RimeSchemeCapabilityMatrix.normalizeSchemaID(raw)
    }

    /// Lookup by schema id. `t9` resolves to the Ice family adapter.
    public static func adapter(for schemaID: String) -> SchemeAdapter? {
        switch normalizeSchemaID(schemaID) {
        case "rime_ice":
            return ice
        case "wanxiang":
            return wanxiang
        case "luna_pinyin":
            return luna
        default:
            return nil
        }
    }

    /// Mirrors today’s `RimeRuntimeSelection.isNineKeyCapable` — only literal `t9`.
    public static func isNineKeyCapable(_ schemaID: String) -> Bool {
        schemaID == "t9"
    }

    /// Mirrors today’s `RimeRuntimeSelection.isTwentySixKeyCapable`.
    public static func isTwentySixKeyCapable(_ schemaID: String) -> Bool {
        normalizeSchemaID(schemaID) != "t9"
    }

    /// Post-process revision for known adapters; `nil` otherwise (same as today’s switch).
    public static func postProcessingRevision(for schemaID: String) -> String? {
        adapter(for: schemaID)?.postProcessingRevision
    }
}
