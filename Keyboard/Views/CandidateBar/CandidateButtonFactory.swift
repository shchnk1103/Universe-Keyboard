import UIKit
import KeyboardCore

/// 候选按钮工厂，创建 UIButtonConfiguration 风格的按钮。
/// 拼音组合使用比候选词小一号的字体（14pt vs 16pt），视觉上区分"输入中"和"可选择"。
///
/// 关键设计决策：使用 `titleTextAttributesTransformer` 而非 `attributedTitle`。
/// `attributedTitle` 会覆盖 `title`，导致 `sender.configuration?.title` 返回 nil。
struct CandidateButtonFactory {

    static func makeCandidateButton(
        title: String,
        kind: CandidateKind,
        color: UIColor,
        bold: Bool = false,
        height: CGFloat
    ) -> UIButton {
        let fontSize: CGFloat = kind == .composition ? 14 : 16
        let weight: UIFont.Weight = bold ? .bold : .regular

        var config = UIButton.Configuration.plain()
        config.title = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var container = container
            container.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
            container.foregroundColor = color
            return container
        }

        let button = UIButton(configuration: config, primaryAction: nil)
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }
}
