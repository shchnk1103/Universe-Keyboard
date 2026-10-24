import Foundation
import KeyboardCore
import Observation

/// 仅使用主 App 的共享设置；不可回退到键盘扩展的私有偏好域。
@Observable
final class CandidateFontSettingsPageModel {
    static let tiers = 13...22
    static let sliderRange = Double(tiers.lowerBound)...Double(tiers.upperBound)
    static let sliderStep = 1.0
    private(set) var tier: Int
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = UserDefaults(suiteName: universeAppGroupID)) {
        self.defaults = defaults
        tier = CandidateFontSettings(savedValue: defaults?.object(forKey: CandidateFontSettings.storageKey)).tier
    }

    var accessibilityValue: String { tier == 17 ? "默认" : "\(tier) 点" }

    func select(_ tier: Int) {
        guard Self.tiers.contains(tier) else { return }
        self.tier = tier
        if tier == 17 {
            // 默认不是固定 17pt：删除保存值，保留系统动态字号语义。
            defaults?.removeObject(forKey: CandidateFontSettings.storageKey)
        } else {
            defaults?.set(tier, forKey: CandidateFontSettings.storageKey)
        }
    }
}

nonisolated enum CandidateFontSettingsCopy {
    static let title = "候选字大小"
    static let subtitle = "调整键盘候选词的字号"
    static let footer = "更改在键盘下次出现时生效。选择“默认”时跟随系统“更大字体”设置。"
    static let preview = "只读示例：ni hao，你好，您好，你们"
}
