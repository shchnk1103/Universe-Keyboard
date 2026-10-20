import UIKit

/// Local presentation parameters for the compact keyboard header, not input state.
enum KeyboardDesignTokens {
    enum CandidateBar {
        static let totalHeight: CGFloat = 46
        static var normalCellHeight: CGFloat { totalHeight }
        static let actionZoneWidth: CGFloat = 56
        static let actionSymbolSize: CGFloat = 22
        static let minimumTouchSize: CGFloat = 44
        static let horizontalPadding: CGFloat = 6
        static let trailingContentPadding: CGFloat = 8
    }

    enum T9PinyinBar {
        static let visibleHeight: CGFloat = 34
    }

    enum CandidateActionAppearance {
        static let materialStyle: UIBlurEffect.Style = .systemMaterial
        static let tintOpacity: CGFloat = 0.72

        static var backgroundColor: UIColor {
            UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 1)
                    : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 1)
            }
        }
    }
}
