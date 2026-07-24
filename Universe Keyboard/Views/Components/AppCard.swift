import SwiftUI

/// Grouped secondary-background card used by Home and Settings list chrome.
///
/// Defaults come from `AppRadius` / `AppSpacing` (phase-1 list polish).
struct AppCard<Content: View>: View {
    var horizontalPadding: CGFloat = AppSpacing.card
    var verticalPadding: CGFloat = AppSpacing.cardRowVertical
    var cornerRadius: CGFloat = AppRadius.card
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// Settings-style section: footnote title, content stack, optional caption footer.
struct SettingsGroup<Content: View>: View {
    let title: String
    var footer: String? = nil
    var contentSpacing: CGFloat = AppSpacing.group
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(nil)
                .padding(.horizontal, 4)

            content()

            if let footer, !footer.isEmpty {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                    .padding(.top, 2)
            }
        }
    }
}

/// Leading `AppIconTile` + trailing content row (toggles, sliders, etc.).
struct SettingsIconRow<Content: View>: View {
    let systemImage: String
    var tileSize: CGFloat = AppIconSize.standard
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.row) {
            AppIconTile(systemImage: systemImage, size: tileSize)
            content()
        }
    }
}
