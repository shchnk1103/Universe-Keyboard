import SwiftUI

/// Left title + trailing value row for status and detail lists.
struct KeyValueRow: View {
    let title: String
    let value: String
    var valueColor: Color = .secondary
    var titleFont: Font = .subheadline
    var valueFont: Font = .subheadline
    var horizontalPadding: CGFloat = 0
    var verticalPadding: CGFloat = 0

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.row) {
            Text(title)
                .font(titleFont)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 8)
            Text(value)
                .font(valueFont)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)，\(value)")
    }
}
