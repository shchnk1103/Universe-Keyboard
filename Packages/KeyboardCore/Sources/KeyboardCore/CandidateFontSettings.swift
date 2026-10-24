import CoreFoundation
import Foundation

/// 跨进程只保存档位；字体物化留给 UIKit，避免 Core 依赖显示环境。
public struct CandidateFontSettings: Equatable, Sendable {
    public static let storageKey = "keyboard_candidate_font_size"
    public let tier: Int

    public struct Policy: Equatable, Sendable {
        public let basePointSize: Double
        public let scalesWithBody: Bool
        public let maximumPointSize: Double?
    }

    public init(savedValue: Any? = nil) {
        // UserDefaults 的 object 可能桥接为 NSNumber。不能用 as? Int 接受 Bool 或整数浮点值。
        guard let number = savedValue as? NSNumber,
            CFGetTypeID(number) != CFBooleanGetTypeID(),
            ["c", "s", "i", "l", "q", "C", "S", "I", "L", "Q"].contains(String(cString: number.objCType)),
            (13...22).contains(number.doubleValue)
        else {
            tier = 17
            return
        }
        tier = number.intValue
    }

    public func policy(isComposition: Bool) -> Policy {
        Policy(
            basePointSize: Double(tier - (isComposition ? 2 : 0)),
            scalesWithBody: tier == 17,
            maximumPointSize: tier == 17 ? 28 : nil
        )
    }
}
