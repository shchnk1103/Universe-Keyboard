import CoreFoundation
import Foundation

/// Content-independent settings for ordinary character keys.
public struct CharacterKeyStyle: Equatable, Sendable {
    public enum ChineseCase: String, Sendable { case upper, lower }
    public enum EnglishCase: String, Sendable { case followShift, upper, lower }
    public static let sizeKey = "keyboard_character_font_size"
    public static let boldKey = "keyboard_character_font_bold"
    public static let chinese26Key = "keyboard_label_case_chinese26"
    public static let chinese9Key = "keyboard_label_case_chinese9"
    public static let english26Key = "keyboard_label_case_english26"

    public let size: Int
    public let bold: Bool
    public let chinese26: ChineseCase
    public let chinese9: ChineseCase
    public let english26: EnglishCase

    public init(defaults: UserDefaults? = nil) {
        size = CandidateFontSettings(savedValue: defaults?.object(forKey: Self.sizeKey)).tier
        if let value = defaults?.object(forKey: Self.boldKey) as? NSNumber,
            CFGetTypeID(value) == CFBooleanGetTypeID()
        {
            bold = value.boolValue
        } else {
            bold = false
        }
        chinese26 = defaults?.string(forKey: Self.chinese26Key).flatMap(ChineseCase.init(rawValue:)) ?? .upper
        chinese9 = defaults?.string(forKey: Self.chinese9Key).flatMap(ChineseCase.init(rawValue:)) ?? .upper
        english26 = defaults?.string(forKey: Self.english26Key).flatMap(EnglishCase.init(rawValue:)) ?? .followShift
    }

    public static func saveSize(_ size: Int, defaults: UserDefaults?) {
        if size == 17 {
            defaults?.removeObject(forKey: sizeKey)
        } else {
            defaults?.set(size, forKey: sizeKey)
        }
    }

    public enum Layout: Sendable { case chinese26, chinese9, english26 }

    public func displayTitle(_ key: String, layout: Layout, shifted: Bool) -> String {
        switch layout {
        case .chinese26: return chinese26 == .upper ? key.uppercased() : key.lowercased()
        case .chinese9: return chinese9 == .upper ? key.uppercased() : key.lowercased()
        case .english26:
            switch english26 {
            case .upper: return key.uppercased()
            case .lower: return key.lowercased()
            case .followShift: return shifted ? key.uppercased() : key.lowercased()
            }
        }
    }

    public func inputPayload(_ key: String, layout: Layout, shifted: Bool) -> String {
        switch layout {
        case .chinese26:
            guard key.unicodeScalars.count == 1, let scalar = key.unicodeScalars.first,
                (65...90).contains(scalar.value) || (97...122).contains(scalar.value)
            else { return key }
            return key.lowercased()
        case .chinese9: return key
        case .english26: return displayTitle(key, layout: layout, shifted: shifted)
        }
    }
}
