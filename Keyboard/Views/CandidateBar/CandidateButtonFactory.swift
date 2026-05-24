import UIKit
import KeyboardCore

/// 候选按钮工厂 — 使用 UIButton.Configuration（iOS 15+）创建候选词按钮。
///
/// Apple 文档推荐使用 UIButton.Configuration 而非直接设置 titleLabel 属性，
/// 因为配置系统会自动处理高亮/禁用/选中等状态的视觉转换。
///
/// 关键设计决策：使用 `titleTextAttributesTransformer` 而非 `attributedTitle`
/// ─────────────────────────────────────────────────────────────────────────
/// UIButton.Configuration 同时有 `title` 和 `attributedTitle` 两个属性。
/// 如果使用 attributedTitle，它会覆盖 title，导致通过 `sender.configuration?.title`
/// 读取候选文字时返回 nil。
///
/// titleTextAttributesTransformer 是一个闭包，在按钮需要渲染标题时被调用。
/// 它接收当前状态的 AttributeContainer，返回修改后的版本。
/// 这保持了 configuration.title 的可读性，同时允许自定义字体和颜色。
///
/// 候选词类型视觉区分：
///   - .candidate（可选择的候选词）：16pt 字体，.label 颜色
///   - .composition（拼音组合/正输入中）：14pt 字体，.secondaryLabel 颜色
///   - 第一个候选词（推荐候选）：加粗 + 高亮背景圆角
struct CandidateButtonFactory {

    /// 创建候选词按钮（用于候选栏和展开面板）。
    ///
    /// - Parameters:
    ///   - title: 候选词文字
    ///   - kind: 候选类型（.candidate / .composition / .placeholder）
    ///   - color: 文字颜色（.label 用于候选词，.secondaryLabel 用于拼音组合）
    ///   - bold: 是否加粗（第一个候选词为 true）
    ///   - height: 按钮高度（候选栏为 candidateBarHeight，展开面板为 rowHeight）
    ///   - highlighted: 是否显示高亮背景（第一个候选词为 true）
    /// - Returns: 配置完成的 UIButton
    static func makeCandidateButton(
        title: String,
        kind: CandidateKind,
        color: UIColor,
        bold: Bool = false,
        height: CGFloat,
        highlighted: Bool = false
    ) -> UIButton {
        let button = UIButton(
            configuration: candidateConfiguration(
                title: title,
                kind: kind,
                color: color,
                bold: bold,
                highlighted: highlighted
            ),
            primaryAction: nil   // 使用 addTarget 手动绑定 action（更灵活）
        )
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }

    /// 配置已有按钮的新样式（用于需要更新 title 的场景）。
    static func configureCandidateButton(
        _ button: UIButton,
        title: String,
        kind: CandidateKind,
        color: UIColor,
        bold: Bool = false,
        highlighted: Bool = false
    ) {
        button.configuration = candidateConfiguration(
            title: title,
            kind: kind,
            color: color,
            bold: bold,
            highlighted: highlighted
        )
        // tag 存储 CandidateKind.rawValue → insertCandidate 可识别候选类型
        button.tag = kind.rawValue
    }

    // MARK: - Private

    /// 构建 UIButton.Configuration。
    ///
    /// 配置要点：
    ///   - .plain() 风格：无默认背景，外观完全由我们控制
    ///   - contentInsets：水平 12pt padding，让文字不贴边缘
    ///   - titleTextAttributesTransformer：动态设置字体大小、粗细和颜色
    ///     （每次按钮状态变化时重新调用）
    private static func candidateConfiguration(
        title: String,
        kind: CandidateKind,
        color: UIColor,
        bold: Bool,
        highlighted: Bool
    ) -> UIButton.Configuration {
        // 拼音组合（.composition）用 14pt；候选词用 16pt
        let fontSize: CGFloat = kind == .composition ? 14 : 16
        // 第一个候选词用 semibold 粗细，其他用 regular
        let weight: UIFont.Weight = bold ? .semibold : .regular

        var config = UIButton.Configuration.plain()
        config.title = title
        // 水平 12pt 内边距，让候选字不紧贴按钮边缘
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

        // 第一个候选词的高亮背景（类似原生键盘的首选候选）
        if highlighted {
            config.background.backgroundColor = UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 116 / 255, green: 117 / 255, blue: 121 / 255, alpha: 1)
                    : UIColor.white.withAlphaComponent(0.92)
            }
            config.background.cornerRadius = 8
        }

        // Apple 推荐的标题样式设置方式：
        // titleTextAttributesTransformer 接收当前 AttributeContainer，
        // 返回修改后的版本。这不会影响 configuration.title 本身。
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var container = container
            container.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
            container.foregroundColor = color
            return container
        }

        return config
    }
}
