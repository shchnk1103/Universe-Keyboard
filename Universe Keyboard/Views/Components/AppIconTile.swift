import SwiftUI

/// Neutral grayscale icon tile for main-app lists and cards.
///
/// Phase-1 visual language stays black / white / gray. Soft fill + primary
/// symbol adapts to light and dark without a brand accent color.
struct AppIconTile: View {
    let systemImage: String
    var size: CGFloat = AppIconSize.standard
    var cornerRadius: CGFloat = AppRadius.control
    var symbolPointSize: CGFloat = AppIconSize.standardSymbol

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(.tertiarySystemFill))
            Image(systemName: systemImage)
                .font(.system(size: symbolPointSize, weight: .semibold))
                .foregroundStyle(.primary)
                .symbolRenderingMode(.monochrome)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
