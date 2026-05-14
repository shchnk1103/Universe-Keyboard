import UIKit
import KeyboardCore

extension KeyboardType {
    static func from(uiKeyboardType type: UIKeyboardType?) -> KeyboardType {
        switch type {
        case .emailAddress: return .emailAddress
        case .URL:          return .URL
        case .webSearch:    return .webSearch
        case .default:      return .default
        case .none:         return .default
        @unknown default:   return .other
        }
    }
}
