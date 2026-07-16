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
}
