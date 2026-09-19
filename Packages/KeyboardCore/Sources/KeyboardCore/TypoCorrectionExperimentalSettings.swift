import Foundation

/// Internal-only typo correction experiment settings.
///
/// These keys are intentionally separate from production correction behavior. In
/// Release builds they must not enable runtime experiments even if stale values
/// remain in App Group preferences from local validation.
public struct TypoCorrectionExperimentalSettings: Equatable, Sendable {
    public static let insertionEnabledKey = "typo_experimental_insertion_enabled"
    public static let transpositionEnabledKey = "typo_experimental_transposition_enabled"
    /// Debug-only performance control for the debounced contextual sidecar.
    /// Missing values intentionally preserve the current enabled behavior.
    public static let contextualCorrectionEnabledKey =
        "typo_experimental_contextual_correction_enabled"

    public var insertionEnabled: Bool
    public var transpositionEnabled: Bool
    public var contextualCorrectionEnabled: Bool

    public init(
        insertionEnabled: Bool = false,
        transpositionEnabled: Bool = false,
        contextualCorrectionEnabled: Bool = true
    ) {
        self.insertionEnabled = insertionEnabled
        self.transpositionEnabled = transpositionEnabled
        self.contextualCorrectionEnabled = contextualCorrectionEnabled
    }

    public var experimentalEdits: TypoCorrectionExperimentalEdits {
        var edits: TypoCorrectionExperimentalEdits = []
        if insertionEnabled {
            edits.insert(.insertion)
        }
        if transpositionEnabled {
            edits.insert(.transposition)
        }
        return edits
    }

    public static func load(from defaults: UserDefaults?) -> TypoCorrectionExperimentalSettings {
        #if DEBUG
            TypoCorrectionExperimentalSettings(
                insertionEnabled: defaults?.bool(forKey: insertionEnabledKey) ?? false,
                transpositionEnabled: defaults?.bool(forKey: transpositionEnabledKey) ?? false,
                contextualCorrectionEnabled: (defaults?.object(forKey: contextualCorrectionEnabledKey) as? Bool) ?? true
            )
        #else
            TypoCorrectionExperimentalSettings()
        #endif
    }
}
