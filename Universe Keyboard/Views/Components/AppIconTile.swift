import SwiftUI
import UIKit

/// Neutral grayscale icon tile for main-app lists and cards.
///
/// Phase-1 visual language stays black / white / gray. Soft fill + primary
/// symbol adapts to light and dark without a brand accent color.
struct AppIconTile: View {
    let systemImage: String
    var size: CGFloat = AppIconSize.standard
    var cornerRadius: CGFloat = AppRadius.control
    var symbolPointSize: CGFloat = AppIconSize.standardSymbol

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var increasedContrast = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    AppSilverToken.fillStyle(
                        AppSilverToken.resolved(
                            .tileFill,
                            reduceTransparency: reduceTransparency,
                            increaseContrast: increasedContrast)))
            Image(systemName: systemImage)
                .font(.system(size: symbolPointSize, weight: .semibold))
                .foregroundStyle(.primary)
                .symbolRenderingMode(.monochrome)
        }
        .frame(width: size, height: size)
        .silverIncreasedContrast($increasedContrast)
        .accessibilityHidden(true)
    }
}
