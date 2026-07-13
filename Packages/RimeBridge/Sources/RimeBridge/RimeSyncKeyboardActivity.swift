import Foundation

/// 主 App 与键盘扩展共享的轻量活动标记。
///
/// 标准 RIME 同步会维护用户词典，因此只能在键盘不再使用 RIME session 时执行。
/// 这个类型只交换时间戳，不读取或记录任何输入内容；键盘侧在生命周期和定时心跳中
/// 更新它，绝不放在按键处理路径。
public enum RimeSyncKeyboardActivity {
    public static let heartbeatKey = "rime_sync_keyboard_activity_heartbeat"
    public static let heartbeatValidity: TimeInterval = 75

    public static func recordVisibleKeyboard(
        in defaults: UserDefaults,
        now: Date = Date()
    ) {
        defaults.set(now, forKey: heartbeatKey)
    }

    public static func clearVisibleKeyboard(in defaults: UserDefaults) {
        defaults.removeObject(forKey: heartbeatKey)
    }

    /// 未来时间戳也视为活跃，避免用户调整系统时钟时错误地开始文件维护。
    public static func isKeyboardActive(
        in defaults: UserDefaults,
        now: Date = Date()
    ) -> Bool {
        guard let heartbeat = defaults.object(forKey: heartbeatKey) as? Date else {
            return false
        }
        return now.timeIntervalSince(heartbeat) < heartbeatValidity
    }
}
