import SwiftUI

public enum BadgeStyle {
    case filled, tinted
}

public struct CapsuleBadge: View {
    let text: String
    let color: Color
    let style: BadgeStyle

    public init(text: String, color: Color, style: BadgeStyle = .tinted) {
        self.text = text
        self.color = color
        self.style = style
    }

    public var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(style == .filled ? color : color.opacity(0.12))
            .foregroundStyle(style == .filled ? Color(.systemBackground) : color)
            .clipShape(Capsule())
    }
}
