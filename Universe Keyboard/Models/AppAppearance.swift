import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "app_appearance"
    static let storage = UserDefaults(suiteName: universeAppGroupID)

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }

    var subtitle: String {
        switch self {
        case .system: return "自动匹配系统显示模式"
        case .light: return "始终使用白色界面"
        case .dark: return "始终使用黑色界面"
        }
    }

    var symbolName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    static func migrateLegacyPreferenceIfNeeded() {
        let standard = UserDefaults.standard
        guard storage?.object(forKey: storageKey) == nil,
              let legacyValue = standard.string(forKey: storageKey),
              AppAppearance(rawValue: legacyValue) != nil
        else {
            return
        }
        storage?.set(legacyValue, forKey: storageKey)
    }
}
