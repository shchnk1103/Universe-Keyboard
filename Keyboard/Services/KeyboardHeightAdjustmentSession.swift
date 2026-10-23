import Foundation
import KeyboardCore

/// 扩展进程自己的偏好域；不访问 App Group，也不以完全访问为前提。
@MainActor
struct KeyboardHeightPreferenceStore {
    static let rowHeightKey = "keyboard_private_row_height"
    let defaults: UserDefaults

    func read() -> Int? { defaults.object(forKey: Self.rowHeightKey) as? Int }

    func write(_ value: Int?) {
        if let value {
            defaults.set(value, forKey: Self.rowHeightKey)
        } else {
            defaults.removeObject(forKey: Self.rowHeightKey)
        }
    }
}

/// 只接受整个文档恰好等于版本化标记；普通文字中的子串不会触发调节。
/// P4 的不可见输入承载器将使用此协议，本阶段只通过测试注入。
enum KeyboardHeightAdjustmentMarker {
    static let prefix = "universe-keyboard:height-adjustment:v1:"

    static func token(before: String?, after: String?) -> UUID? {
        let document = (before ?? "") + (after ?? "")
        guard document.hasPrefix(prefix), document.count == prefix.count + 36 else { return nil }
        return UUID(uuidString: String(document.dropFirst(prefix.count)))
    }
}

/// 只持久化协议 UUID 的消费记录，不保存活动会话、宿主标识或上下文文字。
/// 必须跨控制器/进程存活，否则确定后切换回来可能重放同一个页面标记。
@MainActor
struct KeyboardHeightAdjustmentTokenStore {
    static let consumedTokensKey = "keyboard_private_consumed_height_adjustment_tokens"
    let defaults: UserDefaults

    func consume(_ token: UUID) -> Bool {
        let identifier = token.uuidString
        var consumed = defaults.stringArray(forKey: Self.consumedTokensKey) ?? []
        guard !consumed.contains(identifier) else { return false }
        consumed.append(identifier)
        defaults.set(consumed, forKey: Self.consumedTokensKey)
        return true
    }
}

struct KeyboardHeightAdjustmentSession {
    let token: UUID
    let documentIdentifier: UUID
    let originalSettings: KeyboardHeightSettings
    var previewSettings: KeyboardHeightSettings
    var resetsSavedValue = false
}

enum KeyboardHeightAdjustmentExit: String {
    case confirmed, cancelled, pageLeft, hostChanged, keyboardSwitched, windowRemoved, disappeared
}
