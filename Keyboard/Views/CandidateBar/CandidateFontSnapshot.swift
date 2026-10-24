import KeyboardCore
import UIKit

/// 同一 appearance 的字体输入；渲染和测量只通过这里物化 UIFont。
/// 默认档分别缩放15/17并各自封顶，不能用“缩放后减2”替代。
struct CandidateFontSnapshot {
    let settings: CandidateFontSettings
    let traits: UITraitCollection

    init(settings: CandidateFontSettings = CandidateFontSettings(), traits: UITraitCollection) {
        self.settings = settings
        self.traits = traits
    }

    func titleFont(kind: CandidateKind, preferred: Bool) -> UIFont {
        let policy = settings.policy(isComposition: kind == .composition)
        let base = UIFont.systemFont(
            ofSize: CGFloat(policy.basePointSize),
            weight: preferred ? .semibold : .regular)
        guard policy.scalesWithBody, let maximum = policy.maximumPointSize else { return base }
        return UIFontMetrics(forTextStyle: .body).scaledFont(
            for: base, maximumPointSize: CGFloat(maximum), compatibleWith: traits)
    }

    var correctionHintFont: UIFont {
        UIFontMetrics(forTextStyle: .caption1).scaledFont(
            for: .systemFont(ofSize: 13, weight: .semibold), maximumPointSize: 18, compatibleWith: traits)
    }
}
