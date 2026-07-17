import KeyboardCore
import UIKit

extension KeyboardViewController {
    var keyboardBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 1)
                : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 1)
        }
    }

    var keyboardSurfaceHighlightColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.035)
                : UIColor.white.withAlphaComponent(0.08)
        }
    }

    var keyboardSurfaceFillColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 0.18)
                : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 0.10)
        }
    }

    var keyboardSurfaceMaterialTintColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 0.10)
                : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 0.06)
        }
    }

    var isExperimentalLiquidGlassMaterialEnabled: Bool {
        guard !UIAccessibility.isReduceTransparencyEnabled else { return false }
        return cachedLiquidGlassMaterialEnabled
    }

    var characterKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 62 / 255, green: 62 / 255, blue: 64 / 255, alpha: 1)
                : .white
        }
    }

    var functionKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 44 / 255, green: 44 / 255, blue: 46 / 255, alpha: 1)
                : UIColor(red: 174 / 255, green: 174 / 255, blue: 178 / 255, alpha: 1)
        }
    }

    var highlightedKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 92 / 255, green: 92 / 255, blue: 96 / 255, alpha: 1)
                : UIColor(red: 235 / 255, green: 235 / 255, blue: 237 / 255, alpha: 1)
        }
    }

    /// Records style on keyboard-owned buttons so touch feedback can restore it safely under Swift 6.
    func applyKeyStyle(_ style: KeyVisualStyle, to button: UIButton) {
        (button as? KeyboardKeyButton)?.visualStyle = style

        button.layer.cornerRadius = keyCornerRadius
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = false
        button.layer.borderWidth = 0.33
        button.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = (style == .character || style == .space) ? 0.18 : 0
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.setTitleColor(.label, for: .normal)
        button.tintColor = .label

        switch style {
        case .character:
            button.backgroundColor = characterKeyColor
            // Text labels only; SF Symbol keys re-apply symbol configuration separately.
            button.titleLabel?.font = .systemFont(ofSize: characterKeyTitlePointSize, weight: .regular)
        case .function:
            button.backgroundColor = functionKeyColor
            // Chinese / short labels (中、选拼音、123). Symbol buttons keep 22pt via applyFunctionKeySymbol.
            button.titleLabel?.font = .systemFont(ofSize: functionKeyTitlePointSize, weight: .regular)
        case .space:
            button.backgroundColor = characterKeyColor
            button.titleLabel?.font = .systemFont(ofSize: spaceKeyTitlePointSize, weight: .regular)
        case .returnKey:
            button.backgroundColor = functionKeyColor
            button.titleLabel?.font = .systemFont(ofSize: functionKeyTitlePointSize, weight: .regular)
        case .active:
            button.backgroundColor = .label
            button.setTitleColor(.systemBackground, for: .normal)
            button.tintColor = .systemBackground
            button.titleLabel?.font = .systemFont(ofSize: characterKeyTitlePointSize, weight: .semibold)
        }
    }

    func keyStyle(for button: UIButton) -> KeyVisualStyle? {
        (button as? KeyboardKeyButton)?.visualStyle
    }

    func backgroundForStyle(_ style: KeyVisualStyle) -> UIColor {
        switch style {
        case .character, .space:
            return characterKeyColor
        case .function, .returnKey:
            return functionKeyColor
        case .active:
            return .label
        }
    }

    func applyKeyboardSurfaceStyle() {
        // iOS 26/27 already provides the rounded keyboard container.
        // Keep our surface as a transparent layout container so we do not create
        // a second rounded frame or clip the always-visible bottom corners.
        keyboardSurfaceView.backgroundColor = .clear
        keyboardSurfaceView.layer.cornerRadius = 0
        keyboardSurfaceView.layer.cornerCurve = .continuous
        keyboardSurfaceView.layer.borderWidth = 0
        keyboardSurfaceView.layer.borderColor = nil
        keyboardSurfaceView.layer.masksToBounds = false

        keyboardSurfaceMaterialView.isUserInteractionEnabled = false
        keyboardSurfaceFillView.isUserInteractionEnabled = false

        if isExperimentalLiquidGlassMaterialEnabled {
            keyboardSurfaceMaterialView.effect = keyboardSurfaceMaterialEffect()
            keyboardSurfaceMaterialView.isHidden = false
            keyboardSurfaceFillView.backgroundColor = keyboardSurfaceMaterialTintColor
        } else {
            keyboardSurfaceMaterialView.effect = nil
            keyboardSurfaceMaterialView.isHidden = true
            keyboardSurfaceFillView.backgroundColor = .clear
        }

        keyboardSurfaceHighlightView.backgroundColor = .clear
        keyboardSurfaceHighlightView.isHidden = true
        keyboardSurfaceHighlightView.isUserInteractionEnabled = false
    }

    private func keyboardSurfaceMaterialEffect() -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .regular)
            effect.tintColor = keyboardSurfaceMaterialTintColor
            return effect
        }

        let style: UIBlurEffect.Style =
            traitCollection.userInterfaceStyle == .dark
            ? .systemUltraThinMaterialDark
            : .systemUltraThinMaterialLight
        return UIBlurEffect(style: style)
    }
}
