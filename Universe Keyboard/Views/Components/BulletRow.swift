import SwiftUI

public enum BulletStyle {
    case dot, checkmark
}

public struct BulletRow: View {
    let text: String
    let style: BulletStyle
    let bulletColor: Color

    public init(text: String, style: BulletStyle = .dot, bulletColor: Color = .primary) {
        self.text = text
        self.style = style
        self.bulletColor = bulletColor
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            switch style {
            case .dot:
                Text("•")
                    .foregroundStyle(bulletColor)
            case .checkmark:
                Image(systemName: "checkmark")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
                    .frame(width: 16)
            }
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
