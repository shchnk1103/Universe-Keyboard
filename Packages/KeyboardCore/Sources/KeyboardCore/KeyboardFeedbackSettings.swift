import Foundation

public enum KeyboardFeedbackEvent: Sendable {
    case tap
    case modeEnter
    case `repeat`
    case commit
    case preview
}

public enum KeyboardFeedbackLevel: Int, CaseIterable, Identifiable, Sendable {
    case light = 1
    case softer = 2
    case normal = 3
    case stronger = 4
    case heavy = 5

    public static let defaultLevel: KeyboardFeedbackLevel = .normal

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .light: return "轻"
        case .softer: return "较轻"
        case .normal: return "正常"
        case .stronger: return "较重"
        case .heavy: return "重"
        }
    }

    public var detail: String {
        switch self {
        case .light: return "最轻的反馈，适合安静环境。"
        case .softer: return "略明显，但保持克制。"
        case .normal: return "默认强度，适合日常输入。"
        case .stronger: return "更清晰的按键确认感。"
        case .heavy: return "最明显的反馈。"
        }
    }

    public var hapticIntensity: Double {
        switch self {
        case .light: return 0.35
        case .softer: return 0.5
        case .normal: return 0.65
        case .stronger: return 0.82
        case .heavy: return 1.0
        }
    }

    public static func clamped(_ rawValue: Int) -> KeyboardFeedbackLevel {
        KeyboardFeedbackLevel(rawValue: min(max(rawValue, 1), 5)) ?? .defaultLevel
    }

    public static func migratedLevel(from rawValue: Any?) -> KeyboardFeedbackLevel {
        let value: Double
        if let rawValue = rawValue as? Double {
            value = rawValue
        } else if let rawValue = rawValue as? Float {
            value = Double(rawValue)
        } else if let rawValue = rawValue as? NSNumber {
            value = rawValue.doubleValue
        } else {
            return .defaultLevel
        }

        switch value {
        case ..<0.25: return .light
        case ..<0.45: return .softer
        case ..<0.7: return .normal
        case ..<0.9: return .stronger
        default: return .heavy
        }
    }
}

public enum KeyboardFeedbackSettingsKey {
    public static let keyClickEnabled = "key_click_enabled"
    public static let hapticEnabled = "haptic_enabled"
    public static let hapticLevel = "haptic_level"
    public static let legacyHapticIntensity = "haptic_intensity"
}

public enum KeyboardFeedbackSettingsMigration {
    public static func migrateLegacyLevelsIfNeeded(in defaults: UserDefaults?) {
        guard let defaults else { return }

        if defaults.object(forKey: KeyboardFeedbackSettingsKey.hapticLevel) == nil {
            let level = KeyboardFeedbackLevel.migratedLevel(
                from: defaults.object(forKey: KeyboardFeedbackSettingsKey.legacyHapticIntensity)
            )
            defaults.set(level.rawValue, forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        }
    }
}
