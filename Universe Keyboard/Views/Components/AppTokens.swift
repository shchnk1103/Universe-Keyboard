import CoreGraphics
import SwiftUI

// MARK: - Layout tokens (semantic, not a Tailwind ladder)

/// Corner radii for main-app chrome. Prefer these over raw numbers in shared components.
enum AppRadius {
    /// Home / settings cards, `InfoSection`, navigation rows.
    static let card: CGFloat = 14
    /// Icon tiles, metric selection chips, small continuous controls.
    static let control: CGFloat = 8
    /// Slightly softer large icon tiles on home headers.
    static let iconTileLarge: CGFloat = 10
}

/// Spacing scale for main-app grouped lists and cards.
enum AppSpacing {
    /// Screen horizontal / vertical padding for scroll roots.
    static let screen: CGFloat = 16
    /// Vertical gap between major home/settings blocks.
    static let section: CGFloat = 20
    /// Settings groups can sit slightly looser than home.
    static let sectionLoose: CGFloat = 22
    /// Default inner padding for `AppCard` / settings rows.
    static let card: CGFloat = 14
    /// Comfort padding for primary home cards.
    static let cardComfort: CGFloat = 18
    /// Vertical padding inside compact settings rows.
    static let cardRowVertical: CGFloat = 10
    /// Spacing inside a `SettingsGroup` stack.
    static let group: CGFloat = 10
    /// Icon-to-label / row internal gap.
    static let row: CGFloat = 12
    /// Tight stack inside empty states and metric columns.
    static let tight: CGFloat = 10
    /// Metric value↔label gap.
    static let metric: CGFloat = 3
    /// Home card entrance rise (points).
    static let entranceRise: CGFloat = 10
    /// Empty-state vertical padding.
    static let emptyVertical: CGFloat = 24
}

/// Icon tile sizes for `AppIconTile`.
enum AppIconSize {
    static let standard: CGFloat = 30
    static let large: CGFloat = 38
    static let standardSymbol: CGFloat = 16
    static let largeSymbol: CGFloat = 18
}
