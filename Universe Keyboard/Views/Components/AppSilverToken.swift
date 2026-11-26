import SwiftUI
import UIKit

/// 主 App 四层银色点缀纯令牌（PB-015-PR1-STYLE-TOKENS-001，PR-1 规范先行）。
///
/// 银色是灰阶内的金属质感层，**不是 brand accent**：只允许出现在 `Layer` 枚举的
/// 四个层级（描边 / 图标底纹 / 选中描边 / 滑轨），不参与文字渲染（无 `accentText`
/// 符号），不进入 Keyboard 扩展（Keyboard Extension Color 规则零变更）。
///
/// 解析为纯静态函数（先例：`AppActionButtonChrome`），行为契约：
/// - 浅色 / 深色成对解析：base 一律取系统动态 `UIColor`（separator、tertiarySystemFill、
///   label 等），浅深两态各自有值，调用点无需手写色值；
/// - Reduce Transparency 开启：关闭渐变，退化为纯 base 灰阶（无信息损失）；
/// - Increase Contrast 开启：切换为 `Color(.opaqueSeparator)`。
enum AppSilverToken {
    /// 四层银的层级（令牌表冻结为恰好这四项；严禁扩展出文字色令牌）。
    enum Layer: String, CaseIterable, Sendable {
        /// 卡片 / 行描边（0.5pt 叠加层）。
        case hairline
        /// 图标底纹填充（tertiary fill 之上的顶部亮银渐变）。
        case tileFill
        /// 选中态描边（`Color(.label)` @ 25%，1pt）。
        case activePill
        /// 滑轨（复用 hairline 渐变结构）。
        case sliderTrack
    }

    /// 单层解析结果：正常态为 `gradient`（base 之上叠顶部亮银，叠加层不是替换色）；
    /// Reduce Transparency / Increase Contrast 降级为 `solid` 纯灰阶。
    /// `UIColor` 不可变且线程安全，`@unchecked Sendable` 成立；相等性用手写
    /// nonisolated `==`（合成 conformance 会继承 UIKit 的 MainActor 隔离，
    /// 在 SWIFT_STRICT_CONCURRENCY=complete 下不可用）。
    enum Resolved: Equatable, @unchecked Sendable {
        case gradient(base: UIColor, topLight: UIColor)
        case solid(UIColor)

        nonisolated static func == (lhs: Resolved, rhs: Resolved) -> Bool {
            switch (lhs, rhs) {
            case let (.gradient(lhsBase, lhsTop), .gradient(rhsBase, rhsTop)):
                return lhsBase == rhsBase && lhsTop == rhsTop
            case let (.solid(lhsColor), .solid(rhsColor)):
                return lhsColor == rhsColor
            default:
                return false
            }
        }
    }

    /// 正常态各层的 base 灰阶（动态色，浅/深成对）。
    nonisolated static func baseColor(_ layer: Layer) -> UIColor {
        switch layer {
        case .hairline, .sliderTrack:
            return .separator
        case .tileFill:
            return .tertiarySystemFill
        case .activePill:
            return .label
        }
    }

    /// 正常态渐变顶部亮银（hairline/sliderTrack 3%、tileFill 4%，顶部入光）。
    nonisolated static func gradientTopLight(_ layer: Layer) -> UIColor {
        switch layer {
        case .tileFill:
            return UIColor.white.withAlphaComponent(0.04)
        case .hairline, .sliderTrack:
            return UIColor.white.withAlphaComponent(0.03)
        case .activePill:
            // activePill 是纯描边色，无渐变；返回值仅供 gradientTopLight 对称性测试。
            return UIColor.white.withAlphaComponent(0.0)
        }
    }

    /// 该层在当前辅助功能设置下是否使用渐变银层。
    nonisolated static func usesGradient(
        _ layer: Layer,
        reduceTransparency: Bool,
        increaseContrast: Bool = false
    ) -> Bool {
        guard !reduceTransparency, !increaseContrast else { return false }
        return layer != .activePill
    }

    /// 统一解析入口（纯函数，供组件层与单测共用）。
    nonisolated static func resolved(
        _ layer: Layer,
        reduceTransparency: Bool,
        increaseContrast: Bool
    ) -> Resolved {
        if increaseContrast {
            return .solid(.opaqueSeparator)
        }
        if reduceTransparency {
            return .solid(baseColor(layer))
        }
        switch layer {
        case .activePill:
            return .solid(baseColor(layer).withAlphaComponent(0.25))
        case .hairline, .tileFill, .sliderTrack:
            return .gradient(base: baseColor(layer), topLight: gradientTopLight(layer))
        }
    }
}
