import SwiftUI

/// 可复用的设置导航行：灰阶图标 + 标题 + 副标题 + 弱 chevron。
public struct SettingsNavigationLink<Destination: View>: View {
    let systemImage: String
    let title: String
    let subtitle: String
    /// Kept for call-site compatibility; phase-1 tiles are neutral grayscale.
    let imageColor: Color
    @ViewBuilder let destination: () -> Destination

    public init(
        systemImage: String,
        title: String,
        subtitle: String,
        imageColor: Color = .primary,
        destination: @escaping () -> Destination
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.imageColor = imageColor
        self.destination = destination
    }

    public var body: some View {
        NavigationLink(destination: destination) {
            AppCard {
                HStack(spacing: 12) {
                    AppIconTile(systemImage: systemImage)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(AppPressableButtonStyle())
    }
}
