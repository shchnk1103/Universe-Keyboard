import Foundation

/// Stable keyboard layout preference stored in the App Group.
///
/// Missing, undecodable or unknown raw values always resolve to `.twentySixKey`.
public enum KeyboardLayoutStyle: String, Codable, Sendable, Equatable, CaseIterable {
    case twentySixKey = "twenty_six_key"
    case nineKey = "nine_key"

    public static let defaultStyle: KeyboardLayoutStyle = .twentySixKey

    public static func resolve(_ rawValue: String?) -> KeyboardLayoutStyle {
        guard let rawValue, let style = KeyboardLayoutStyle(rawValue: rawValue) else {
            return .defaultStyle
        }
        return style
    }
}

public enum KeyboardLayoutSettingsKey {
    /// Stable App Group key for `KeyboardLayoutStyle.rawValue`.
    public static let layoutStyle = "keyboard_layout_style"
}
