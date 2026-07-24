import SwiftUI

/// Compact value + label metric cell for home, dictionary overview, diagnostics, etc.
///
/// Optional `action` turns the cell into a selectable filter chip (diagnostics summary).
struct MetricCell: View {
    let value: String
    let label: String
    var valueFont: Font = .headline.monospacedDigit()
    var valueColor: Color = .primary
    var labelFont: Font = .caption
    var isSelected: Bool = false
    var accessibilityLabelText: String? = nil
    var accessibilityValueText: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        if let action {
            Button(action: action) {
                metricContent
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabelText ?? label)
            .accessibilityValue(accessibilityValueText ?? value)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        } else {
            metricContent
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabelText ?? "\(label) \(value)")
        }
    }

    private var metricContent: some View {
        VStack(spacing: AppSpacing.metric) {
            Text(value)
                .font(valueFont)
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .contentTransition(.numericText())
            Text(label)
                .font(labelFont)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, action == nil ? 0 : 5)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous)
                    .fill(Color.primary.opacity(0.08))
            }
        }
        .padding(.horizontal, action == nil ? 0 : 6)
    }
}
