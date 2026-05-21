import UIKit
import KeyboardCore

extension KeyboardType {
    static func from(uiKeyboardType type: UIKeyboardType?) -> KeyboardType {
        switch type {
        case .emailAddress:          return .emailAddress
        case .URL:                   return .URL
        case .webSearch:             return .webSearch
        case .default:               return .default
        case .none:                  return .default
        case .asciiCapable:          return .default
        case .numbersAndPunctuation: return .default
        case .numberPad:             return .default
        case .phonePad:              return .default
        case .namePhonePad:          return .default
        case .decimalPad:            return .default
        case .twitter:               return .default
        case .asciiCapableNumberPad: return .default
        @unknown default:            return .other
        }
    }
}
