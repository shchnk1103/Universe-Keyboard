import Foundation

/// Declarative layout claims for a scheme adapter (P1-2 live authority).
///
/// Product nine-key capability is the **literal** schema id listed in
/// `nineKeySchemaIDs` on a family that claims `supportsNineKey` (Ice → `t9`).
/// Family letter ids (`rime_ice`) stay non-capable for nine-key bindings.
public struct SchemeLayoutCapability: Sendable, Equatable {
    /// Whether the canonical letter schema may appear in the 26-key picker.
    public let supportsTwentySixKey: Bool
    /// Whether this scheme **family** productizes nine-key (Ice via literal `t9`).
    public let supportsNineKey: Bool
    /// Literal nine-key schema ids productized by this family (Ice: `["t9"]`).
    public let nineKeySchemaIDs: [String]

    public init(
        supportsTwentySixKey: Bool,
        supportsNineKey: Bool,
        nineKeySchemaIDs: [String] = []
    ) {
        self.supportsTwentySixKey = supportsTwentySixKey
        self.supportsNineKey = supportsNineKey
        self.nineKeySchemaIDs = nineKeySchemaIDs
    }
}

/// Shared-default / Prelude policy id mirrored from today’s install hardcodes.
public enum SchemeSharedDefaultMode: String, Sendable, Equatable {
    /// Ice reference — private preset (`rime_ice_preset`) + include rewrite.
    case privatePreset
    /// Historical transitional skip / consume-Prelude shape (not end-state).
    case consumePrelude
    /// Luna builtin / Prelude exception.
    case builtinPrelude
}

/// SharedDefault post-extract applicator (P1-3 / P2 live authority).
///
/// Ice and Wanxiang `privatePreset` rewrite toward a private preset file and
/// never overwrite Prelude `default.yaml`. Luna stays `builtinPrelude` (no-op).
public protocol SchemeSharedDefaultApplying: Sendable {
    var mode: SchemeSharedDefaultMode { get }
    func applyPostExtract(in extractionDirectory: URL) throws
}

/// Lua/OpenCC ownership strategy id (long-term dual: namedList + exactHash).
public enum SchemeOwnershipStrategyID: String, Sendable, Equatable {
    case namedList
    case exactHash
    case none
}

/// Thin per-scheme adapter bundle mirroring today’s hardcoded product answers.
///
/// P1-2 routes layout capability queries through this registry.
/// P1-3 routes SharedDefault post-extract through `sharedDefaultMode` + applicator lookup.
/// P1-4 routes uninstall / checkpoint ownership through `ownershipStrategyID` + ResourceOwnership.
/// P1-5 routes Ice uninstall layout fallback through `SchemeUninstallHooks` / `onUninstallPrepare`.
/// P3 routes Ice T9 sanitize / pre-deploy ensure through `SchemePostExtractHooks`.
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
        layout: SchemeLayoutCapability(
            supportsTwentySixKey: true,
            supportsNineKey: true,
            nineKeySchemaIDs: ["t9"]
        ),
        sharedDefaultMode: .privatePreset,
        ownershipStrategyID: .namedList,
        postProcessingRevision: "rime-ice-post-2",
        supportsManagedFuzzyPinyin: true,
        supportsProductAdvancedInput: true
    )

    /// Wanxiang: 26-key only; nine-key product claim stays false.
    /// SharedDefault is Ice-shaped `privatePreset` (`wanxiang_preset`); ownership stays `exactHash`.
    public static let wanxiang = SchemeAdapter(
        schemaID: "wanxiang",
        layout: SchemeLayoutCapability(
            supportsTwentySixKey: true,
            supportsNineKey: false,
            nineKeySchemaIDs: []
        ),
        sharedDefaultMode: .privatePreset,
        ownershipStrategyID: .exactHash,
        postProcessingRevision: "wanxiang-post-2",
        supportsManagedFuzzyPinyin: false,
        supportsProductAdvancedInput: false
    )

    /// Luna builtin / Prelude exception.
    public static let luna = SchemeAdapter(
        schemaID: "luna_pinyin",
        layout: SchemeLayoutCapability(
            supportsTwentySixKey: true,
            supportsNineKey: false,
            nineKeySchemaIDs: []
        ),
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

    /// Product nine-key capability via LayoutCapability (Ice-only `t9` today).
    ///
    /// Literal id must appear in the family’s `nineKeySchemaIDs` **and** the
    /// family must claim `supportsNineKey`. Letter ids (`rime_ice`) stay false.
    public static func isNineKeyCapable(_ schemaID: String) -> Bool {
        guard let adapter = adapter(for: schemaID), adapter.layout.supportsNineKey else {
            return false
        }
        return adapter.layout.nineKeySchemaIDs.contains(schemaID)
    }

    /// 26-key picker capability via LayoutCapability.
    ///
    /// Known adapters use `supportsTwentySixKey`. Unknown schemes stay `true`
    /// (today’s hardcode: anything whose normalized base is not the literal
    /// nine-key id — which after `t9`→Ice mapping is effectively always true).
    public static func isTwentySixKeyCapable(_ schemaID: String) -> Bool {
        if let adapter = adapter(for: schemaID) {
            return adapter.layout.supportsTwentySixKey
        }
        return true
    }

    /// Family-level nine-key productization for letter-base migration paths.
    ///
    /// True only when `schemaID` is the family’s **letter** id (not `t9` alias)
    /// and the adapter claims `supportsNineKey`. Preserves ADR 0018
    /// `baseSchemaID == "rime_ice"` answers.
    public static func familySupportsNineKey(_ schemaID: String) -> Bool {
        guard let adapter = adapter(for: schemaID), adapter.layout.supportsNineKey else {
            return false
        }
        return adapter.schemaID == schemaID
    }

    /// Post-process revision for known adapters; `nil` otherwise (same as today’s switch).
    public static func postProcessingRevision(for schemaID: String) -> String? {
        adapter(for: schemaID)?.postProcessingRevision
    }

    /// SharedDefault applicator for schemes whose mode requires post-extract rewrite.
    ///
    /// Ice (`privatePreset`) → `RimeIceSharedDefaultAdapter`.
    /// Wanxiang (`privatePreset`) → `RimeWanxiangSharedDefaultAdapter` (never Ice).
    /// Luna (`builtinPrelude`) / transitional `consumePrelude` → `nil` (no-op).
    public static func sharedDefaultApplicator(for schemaID: String) -> (
        any SchemeSharedDefaultApplying
    )? {
        guard let adapter = adapter(for: schemaID) else { return nil }
        switch adapter.sharedDefaultMode {
        case .privatePreset:
            switch adapter.schemaID {
            case "rime_ice":
                return RimeIceSharedDefaultAdapter.shared
            case "wanxiang":
                return RimeWanxiangSharedDefaultAdapter.shared
            default:
                return nil
            }
        case .consumePrelude, .builtinPrelude:
            return nil
        }
    }

    /// Applies SharedDefault post-extract when an applicator is registered.
    /// Ice → `rime_ice_preset.yaml`; Wanxiang → `wanxiang_preset.yaml`.
    public static func applySharedDefaultPostExtract(
        for schemaID: String,
        in extractionDirectory: URL
    ) throws {
        try sharedDefaultApplicator(for: schemaID)?.applyPostExtract(in: extractionDirectory)
    }
}
