import Foundation
import Observation

/// 主 App 只管理页面的进入标记与焦点，不读取键盘偏好或完全访问状态。
@Observable
final class KeyboardHeightAdjustmentPageSession {
    private(set) var marker: String?
    @ObservationIgnored weak var inputHost: KeyboardHeightInputHostView?

    func beginIfNeeded() {
        guard marker == nil else { return }
        reopen()
    }

    func reopen() {
        inputHost?.stop()
        marker = KeyboardHeightSettingsCopy.markerPrefix + UUID().uuidString
        inputHost?.update(marker: marker)
    }

    func end() {
        marker = nil
        inputHost?.stop()
    }
}

enum KeyboardHeightSettingsCopy {
    static let title = "键盘高度"
    static let fullAccessExplanation = "开启完全访问可让设置更可靠；未开启也能调节并保存。"
    static let instructions = "在下方键盘中拖动调节高度，点击“确定”保存或“取消”放弃。"
    static let keyboardHint = "若未出现调节控件，请切换到 Universe Keyboard。收起后可重新打开调节键盘。"
    // 与已提交的 P3 协议逐字一致；不通过共享存储传递或读取行高。
    static let markerPrefix = "universe-keyboard:height-adjustment:v1:"
}
