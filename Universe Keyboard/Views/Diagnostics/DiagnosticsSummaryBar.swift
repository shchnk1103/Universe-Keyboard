import SwiftUI

struct DiagnosticsSummaryBar: View {
    let recordCount: Int
    let slowEventCount: Int
    let warningCount: Int
    let selectedFilter: DiagnosticsStore.SummaryFilter
    let onSelect: (DiagnosticsStore.SummaryFilter) -> Void

    var body: some View {
        HStack(spacing: 0) {
            DiagnosticsSummaryMetric(
                value: "\(recordCount)",
                label: "记录",
                isSelected: selectedFilter == .all,
                accessibilityLabel: "查看全部日志"
            ) {
                onSelect(.all)
            }
            Divider().frame(height: 28)
            DiagnosticsSummaryMetric(
                value: "\(slowEventCount)",
                label: "慢事件",
                color: slowEventCount > 0 ? .orange : .secondary,
                isSelected: selectedFilter == .slowEvents,
                accessibilityLabel: "查看慢事件日志"
            ) {
                onSelect(.slowEvents)
            }
            Divider().frame(height: 28)
            DiagnosticsSummaryMetric(
                value: "\(warningCount)",
                label: "警告",
                color: warningCount > 0 ? .red : .secondary,
                isSelected: selectedFilter == .warnings,
                accessibilityLabel: "查看警告日志"
            ) {
                onSelect(.warnings)
            }
        }
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
    }
}

private struct DiagnosticsSummaryMetric: View {
    let value: String
    let label: String
    var color: Color = .primary
    let isSelected: Bool
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                }
            }
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(value) 条")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
