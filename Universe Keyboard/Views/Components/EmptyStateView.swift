import SwiftUI

/// Centered empty / placeholder surface used across main-app lists and detail pages.
///
/// Prefer this over per-feature private empty views when the pattern is
/// SF Symbol + title + optional secondary message.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    var message: String? = nil
    var symbolFont: Font = .title2
    var symbolOpacity: Double = 1
    var titleFont: Font = .headline
    var messageFont: Font = .footnote
    var verticalPadding: CGFloat = AppSpacing.emptyVertical
    var horizontalPadding: CGFloat = AppSpacing.screen

    var body: some View {
        VStack(spacing: AppSpacing.tight) {
            Image(systemName: systemImage)
                .font(symbolFont)
                .foregroundStyle(.secondary.opacity(symbolOpacity))
                .accessibilityHidden(true)
            Text(title)
                .font(titleFont)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            if let message, !message.isEmpty {
                Text(message)
                    .font(messageFont)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .accessibilityElement(children: .combine)
    }
}
