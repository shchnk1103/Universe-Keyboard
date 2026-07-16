import Foundation

/// Pure resolver for base scheme, layout preference and T9 readiness → effective runtime selection.
public struct RimeRuntimeSelection: Sendable, Equatable {
    public let baseSchemaID: String
    public let layoutStyle: KeyboardLayoutStyle
    public let t9ReadinessMatched: Bool
    public let effectiveSchemaID: String
    public let effectiveLayoutStyle: KeyboardLayoutStyle
    public let usesT9InputSemantics: Bool

    public init(
        baseSchemaID: String,
        layoutStyle: KeyboardLayoutStyle,
        t9ReadinessMatched: Bool
    ) {
        self.baseSchemaID = baseSchemaID
        self.layoutStyle = layoutStyle
        self.t9ReadinessMatched = t9ReadinessMatched

        let supportsNineKey = baseSchemaID == "rime_ice"
        if supportsNineKey, layoutStyle == .nineKey, t9ReadinessMatched {
            self.effectiveSchemaID = "t9"
            self.effectiveLayoutStyle = .nineKey
            self.usesT9InputSemantics = true
        } else {
            self.effectiveSchemaID = baseSchemaID
            self.effectiveLayoutStyle = .twentySixKey
            self.usesT9InputSemantics = false
        }
    }

    public static func resolve(
        baseSchemaID: String?,
        layoutRawValue: String?,
        readinessMarker: RimeT9ReadinessMarker?,
        onDiskFingerprint: String?
    ) -> RimeRuntimeSelection {
        let base = (baseSchemaID?.isEmpty == false) ? baseSchemaID! : "luna_pinyin"
        let layout = KeyboardLayoutStyle.resolve(layoutRawValue)
        let matched = RimeT9Readiness.isMatched(
            marker: readinessMarker,
            onDiskFingerprint: onDiskFingerprint
        )
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
        let base = defaults?.string(forKey: "rime_active_schema")
        let layoutRaw = defaults?.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let marker = RimeT9Readiness.load(from: defaults)
        return resolve(
            baseSchemaID: base,
            layoutRawValue: layoutRaw,
            readinessMarker: marker,
            onDiskFingerprint: onDiskFingerprint
        )
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
        // Only keep T9 chrome/semantics when both requested and actually selected.
        if usesT9InputSemantics, actual == "t9" {
            return self
        }
        // Fail closed: never keep T9 chrome/semantics when the engine is not on t9.
        // Prefer the schema librime actually selected for the non-T9 lifecycle.
        let closedBase: String
        if actual == "t9" {
            // Unexpected: t9 selected without a matched request — still fail closed to base 26-key.
            closedBase = baseSchemaID == "t9" ? "rime_ice" : baseSchemaID
        } else {
            closedBase = actual
        }
        return RimeRuntimeSelection(
            baseSchemaID: closedBase,
            layoutStyle: .twentySixKey,
            t9ReadinessMatched: false
        )
    }
}
