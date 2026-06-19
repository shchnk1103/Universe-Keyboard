import Foundation

/// User-facing advanced input features that may be provided by a RIME scheme.
///
/// These are product features, not implementation names. A feature can map to
/// one or more upstream RIME components during deployment.
public enum RimeAdvancedInputFeature: String, CaseIterable, Identifiable, Sendable {
    case dateTime
    case lunar
    case calculator
    case numberConversion
    case unicode
    case uuid
    case vMode
    case search
    case correction
    case longWordCandidates
    case pinyinCandidateFilter
    case englishCandidateFilter
    case selectCharacter
    case autoCapitalization

    public var id: String { rawValue }

    public var componentNames: [String] {
        switch self {
        case .dateTime:
            return ["date_translator"]
        case .lunar:
            return ["lunar"]
        case .calculator:
            return ["calc_translator"]
        case .numberConversion:
            return ["number_translator"]
        case .unicode:
            return ["unicode"]
        case .uuid:
            return ["uuid"]
        case .vMode:
            return ["v_filter"]
        case .search:
            return ["search"]
        case .correction:
            return ["corrector"]
        case .longWordCandidates:
            return ["long_word_filter"]
        case .pinyinCandidateFilter:
            return ["pin_cand_filter"]
        case .englishCandidateFilter:
            return ["reduce_english_filter"]
        case .selectCharacter:
            return ["select_character"]
        case .autoCapitalization:
            return ["autocap_filter"]
        }
    }
}

public struct RimeAdvancedInputSettings: Equatable, Sendable {
    public static let masterEnabledKey = "rime_advanced_input_enabled"
    public static let pendingDeployKey = "rime_advanced_input_pending_deploy"
    public static let deployedSignatureKey = "rime_advanced_input_deployed_signature"

    public var masterEnabled: Bool
    public var featureEnabled: [RimeAdvancedInputFeature: Bool]

    public init(
        masterEnabled: Bool = true,
        featureEnabled: [RimeAdvancedInputFeature: Bool] = [:]
    ) {
        self.masterEnabled = masterEnabled
        self.featureEnabled = featureEnabled
    }

    public static func enabledKey(for feature: RimeAdvancedInputFeature) -> String {
        "rime_advanced_input_\(feature.rawValue)_enabled"
    }

    public func isEnabled(_ feature: RimeAdvancedInputFeature) -> Bool {
        featureEnabled[feature] ?? true
    }

    public func disabledComponentNames(supportedFeatures: Set<RimeAdvancedInputFeature>) -> Set<String> {
        guard masterEnabled else {
            return Set(supportedFeatures.flatMap(\.componentNames))
        }

        return Set(
            supportedFeatures
                .filter { !isEnabled($0) }
                .flatMap(\.componentNames)
        )
    }

    public func deploymentSignature(
        activeSchemaID: String,
        supportedFeatures: Set<RimeAdvancedInputFeature>
    ) -> String {
        let featureParts = RimeAdvancedInputFeature.allCases.map { feature in
            let supported = supportedFeatures.contains(feature) ? 1 : 0
            let enabled = isEnabled(feature) ? 1 : 0
            return "\(feature.rawValue)=\(enabled):\(supported)"
        }

        return ([
            "schema=\(activeSchemaID)",
            "master=\(masterEnabled ? 1 : 0)",
        ] + featureParts).joined(separator: ";")
    }
}

