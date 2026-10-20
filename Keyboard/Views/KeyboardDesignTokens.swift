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

    enum ExpandedCandidates {
        static let rowHeight: CGFloat = 42
        // Center the shorter first row on the compact row's text baseline.
        static let contentInsets = UIEdgeInsets(
            top: (CandidateBar.normalCellHeight - rowHeight) / 2,
            left: CandidateBar.horizontalPadding, bottom: 6, right: CandidateBar.trailingContentPadding)
        static let itemSpacing: CGFloat = 0
        static let minimumReadableExtent: CGFloat = 12
        static let minimumReadableFraction: CGFloat = 0.2
        static let expandDuration: TimeInterval = 0.18
        static let collapseDuration: TimeInterval = 0.16
    }

    enum T9PinyinBar {
        static let visibleHeight: CGFloat = 34
    }

    enum CandidateActionAppearance {
        static let materialStyle: UIBlurEffect.Style = .systemMaterial
        static let tintOpacity: CGFloat = 0.72
        static let edgeFadeWidth: CGFloat = 10
        static let controlDiameter: CGFloat = 36
        static var controlBackgroundInsets: UIEdgeInsets {
            let vertical = (CandidateBar.totalHeight - controlDiameter) / 2
            let horizontal = (CandidateBar.actionZoneWidth - controlDiameter) / 2
            return UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }
        static var controlCornerRadius: CGFloat { controlDiameter / 2 }
        static var symbolColor: UIColor { .secondaryLabel }

        static var backgroundColor: UIColor {
            UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 1)
                    : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 1)
            }
        }
    }
}
