import Foundation

/// Pure resolver for layout preference, per-layout scheme bindings, and readiness
/// → effective runtime selection (ADR 0026; amends ADR 0018 §2).
public struct RimeRuntimeSelection: Sendable, Equatable {
    /// Legacy / detail-page “current scheme” alias (often 26-key binding).
    public let baseSchemaID: String
    public let layoutStyle: KeyboardLayoutStyle
    public let t9ReadinessMatched: Bool
    /// Explicit 26-key slot binding when layout-bound mode is active.
    public let schemeBinding26: String?
    /// Explicit nine-key slot binding (usually `t9` when fog nine-key is ready).
    public let schemeBinding9: String?
    public let effectiveSchemaID: String
    public let effectiveLayoutStyle: KeyboardLayoutStyle
    public let usesT9InputSemantics: Bool

    /// Legacy ADR 0018 constructor: single global base + auto `t9` when ready.
    /// Prefer `resolve(..., schemeBinding26:schemeBinding9:)` for new call sites.
    public init(
        baseSchemaID: String,
        layoutStyle: KeyboardLayoutStyle,
        t9ReadinessMatched: Bool
    ) {
        self.init(
            baseSchemaID: baseSchemaID,
            layoutStyle: layoutStyle,
            t9ReadinessMatched: t9ReadinessMatched,
            schemeBinding26: nil,
            schemeBinding9: nil,
            useLayoutBoundBindings: false
        )
    }

    /// Layout-bound constructor (ADR 0026).
    public init(
        baseSchemaID: String,
        layoutStyle: KeyboardLayoutStyle,
        t9ReadinessMatched: Bool,
        schemeBinding26: String?,
        schemeBinding9: String?
    ) {
        self.init(
            baseSchemaID: baseSchemaID,
            layoutStyle: layoutStyle,
            t9ReadinessMatched: t9ReadinessMatched,
            schemeBinding26: schemeBinding26,
            schemeBinding9: schemeBinding9,
            useLayoutBoundBindings: true
        )
    }

    private init(
        baseSchemaID: String,
        layoutStyle: KeyboardLayoutStyle,
        t9ReadinessMatched: Bool,
        schemeBinding26: String?,
        schemeBinding9: String?,
        useLayoutBoundBindings: Bool
    ) {
        self.baseSchemaID = baseSchemaID
        self.layoutStyle = layoutStyle
        self.t9ReadinessMatched = t9ReadinessMatched
        self.schemeBinding26 = Self.normalizedSchemaID(schemeBinding26)
        self.schemeBinding9 = Self.normalizedSchemaID(schemeBinding9)

        if useLayoutBoundBindings {
            let resolved = Self.resolveLayoutBound(
                preferredLayout: layoutStyle,
                binding26: self.schemeBinding26 ?? Self.normalizedBase(baseSchemaID),
                binding9: self.schemeBinding9,
                t9ReadinessMatched: t9ReadinessMatched,
                fallbackBase: Self.normalizedBase(baseSchemaID)
            )
            self.effectiveSchemaID = resolved.schemaID
            self.effectiveLayoutStyle = resolved.layout
            self.usesT9InputSemantics = resolved.usesT9
        } else {
            // ADR 0018 migration path (no explicit bindings).
            let supportsNineKey = baseSchemaID == "rime_ice"
            if supportsNineKey, layoutStyle == .nineKey, t9ReadinessMatched {
                self.effectiveSchemaID = "t9"
                self.effectiveLayoutStyle = .nineKey
                self.usesT9InputSemantics = true
            } else {
                self.effectiveSchemaID = Self.normalizedBase(baseSchemaID)
                self.effectiveLayoutStyle = .twentySixKey
                self.usesT9InputSemantics = false
            }
        }
    }

    public static func resolve(
        baseSchemaID: String?,
        layoutRawValue: String?,
        readinessMarker: RimeT9ReadinessMarker?,
        onDiskFingerprint: String?,
        schemeBinding26: String? = nil,
        schemeBinding9: String? = nil
    ) -> RimeRuntimeSelection {
        let base = (baseSchemaID?.isEmpty == false) ? baseSchemaID! : "luna_pinyin"
        let layout = KeyboardLayoutStyle.resolve(layoutRawValue)
        let matched = RimeT9Readiness.isMatched(
            marker: readinessMarker,
            onDiskFingerprint: onDiskFingerprint
        )
        let hasExplicitBindings =
            normalizedSchemaID(schemeBinding26) != nil
            || normalizedSchemaID(schemeBinding9) != nil
        if hasExplicitBindings {
            return RimeRuntimeSelection(
                baseSchemaID: base,
                layoutStyle: layout,
                t9ReadinessMatched: matched,
                schemeBinding26: schemeBinding26,
                schemeBinding9: schemeBinding9
            )
        }
        return RimeRuntimeSelection(
            baseSchemaID: base,
            layoutStyle: layout,
            t9ReadinessMatched: matched
        )
    }

    /// Convenience for App Group defaults when on-disk fingerprint is supplied by the caller.
    public static func resolve(
        defaults: UserDefaults?,
        onDiskFingerprint: String?
    ) -> RimeRuntimeSelection {
        migrateLayoutBindingsIfNeeded(defaults: defaults, onDiskFingerprint: onDiskFingerprint)
        let base = defaults?.string(forKey: "rime_active_schema")
        let layoutRaw = defaults?.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let marker = RimeT9Readiness.load(from: defaults)
        let b26 = defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        let b9 = defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        return resolve(
            baseSchemaID: base,
            layoutRawValue: layoutRaw,
            readinessMarker: marker,
            onDiskFingerprint: onDiskFingerprint,
            schemeBinding26: b26,
            schemeBinding9: b9
        )
    }

    /// Idempotent migration: write per-layout bindings once from legacy single-base state.
    public static func migrateLayoutBindingsIfNeeded(
        defaults: UserDefaults?,
        onDiskFingerprint: String?
    ) {
        guard let defaults else { return }
        let existing26 = defaults.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        let existing9 = defaults.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        if normalizedSchemaID(existing26) != nil || normalizedSchemaID(existing9) != nil {
            return
        }
        let base = defaults.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        let normalizedBase = normalizedBase(base)
        defaults.set(normalizedBase, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        let marker = RimeT9Readiness.load(from: defaults)
        let matched = RimeT9Readiness.isMatched(
            marker: marker,
            onDiskFingerprint: onDiskFingerprint
        )
        if matched {
            defaults.set("t9", forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        }
    }

    /// Persist a 26-key scheme binding and optionally alias legacy active schema.
    public static func setSchemeBinding26(_ schemaID: String, defaults: UserDefaults?) {
        guard let defaults, let id = normalizedSchemaID(schemaID) else { return }
        let stored = id == "t9" ? "rime_ice" : id
        defaults.set(stored, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        defaults.set(stored, forKey: "rime_active_schema")
    }

    /// Persist a nine-key scheme binding (`t9` for fog nine-key).
    public static func setSchemeBinding9(_ schemaID: String, defaults: UserDefaults?) {
        guard let defaults, let id = normalizedSchemaID(schemaID) else { return }
        guard isNineKeyCapable(id) else { return }
        defaults.set(id, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
    }

    /// V1: only compatible `t9` is nine-key capable.
    public static func isNineKeyCapable(_ schemaID: String) -> Bool {
        schemaID == "t9"
    }

    /// Schemes that may appear in the 26-key picker (V1 catalog).
    public static func isTwentySixKeyCapable(_ schemaID: String) -> Bool {
        let id = normalizedBase(schemaID)
        return id != "t9"
    }

    /// Observable chrome + input policy derived from a realized selection.
    /// Extension caches these three fields together; they must transition as one unit.
    public struct Surface: Sendable, Equatable {
        public let layoutStyle: KeyboardLayoutStyle
        public let usesT9InputSemantics: Bool
        /// Chrome readiness flag; fail-closed realized selection clears it with semantics.
        public let t9ReadinessMatched: Bool

        public init(from selection: RimeRuntimeSelection) {
            self.layoutStyle = selection.effectiveLayoutStyle
            self.usesT9InputSemantics = selection.usesT9InputSemantics
            self.t9ReadinessMatched = selection.usesT9InputSemantics
        }
    }

    public var surface: Surface { Surface(from: self) }

    /// Reconcile the readiness-derived **request** with the schema librime actually selected.
    ///
    /// If T9 was requested but not actually selected, force 26-key chrome and input semantics
    /// for this runtime lifecycle (fail closed). Does not mutate App Group preferences.
    public func reconciled(withActualSchemaID actualSchemaID: String?) -> RimeRuntimeSelection {
        let actual = (actualSchemaID?.isEmpty == false) ? actualSchemaID! : baseSchemaID
        if usesT9InputSemantics, actual == "t9" {
            return self
        }
        let closedBase: String
        if actual == "t9" {
            closedBase = baseSchemaID == "t9" ? "rime_ice" : Self.normalizedBase(baseSchemaID)
        } else {
            closedBase = Self.normalizedBase(actual)
        }
        if schemeBinding26 != nil || schemeBinding9 != nil {
            return RimeRuntimeSelection(
                baseSchemaID: closedBase,
                layoutStyle: .twentySixKey,
                t9ReadinessMatched: false,
                schemeBinding26: schemeBinding26 ?? closedBase,
                schemeBinding9: schemeBinding9
            )
        }
        return RimeRuntimeSelection(
            baseSchemaID: closedBase,
            layoutStyle: .twentySixKey,
            t9ReadinessMatched: false
        )
    }

    // MARK: - Private

    private static func resolveLayoutBound(
        preferredLayout: KeyboardLayoutStyle,
        binding26: String,
        binding9: String?,
        t9ReadinessMatched: Bool,
        fallbackBase: String
    ) -> (schemaID: String, layout: KeyboardLayoutStyle, usesT9: Bool) {
        if preferredLayout == .nineKey {
            if let binding9,
               isNineKeyCapable(binding9),
               binding9 == "t9",
               t9ReadinessMatched
            {
                return ("t9", .nineKey, true)
            }
            // Fail closed to 26-key chrome + letter scheme.
            let letter = isTwentySixKeyCapable(binding26) ? binding26 : fallbackBase
            return (normalizedBase(letter), .twentySixKey, false)
        }
        let letter = isTwentySixKeyCapable(binding26) ? binding26 : fallbackBase
        return (normalizedBase(letter), .twentySixKey, false)
    }

    private static func normalizedSchemaID(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func normalizedBase(_ raw: String) -> String {
        let id = normalizedSchemaID(raw) ?? "luna_pinyin"
        return id == "t9" ? "rime_ice" : id
    }
}
