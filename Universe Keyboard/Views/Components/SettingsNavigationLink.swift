import SwiftUI

/// 可复用的设置导航行：图标 + 标题 + 副标题 + 箭头。
public struct SettingsNavigationLink<Destination: View>: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let imageColor: Color
    @ViewBuilder let destination: () -> Destination

    public init(
        systemImage: String,
        title: String,
        subtitle: String,
        imageColor: Color = .blue,
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
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(imageColor)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
