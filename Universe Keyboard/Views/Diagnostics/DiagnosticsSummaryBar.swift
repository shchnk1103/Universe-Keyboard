import SwiftUI

struct DiagnosticsSummaryBar: View {
    let recordCount: Int
    let slowEventCount: Int
    let warningCount: Int
    let selectedFilter: DiagnosticsStore.SummaryFilter
    let onSelect: (DiagnosticsStore.SummaryFilter) -> Void

    var body: some View {
        HStack(spacing: 0) {
            MetricCell(
                value: "\(recordCount)",
                label: "记录",
                valueFont: .headline.monospacedDigit(),
                isSelected: selectedFilter == .all,
                accessibilityLabelText: "查看全部日志",
                accessibilityValueText: "\(recordCount) 条",
                action: { onSelect(.all) }
            )
            Divider().frame(height: 28)
            MetricCell(
                value: "\(slowEventCount)",
                label: "慢事件",
                valueFont: .headline.monospacedDigit(),
                valueColor: slowEventCount > 0 ? .orange : .secondary,
                isSelected: selectedFilter == .slowEvents,
                accessibilityLabelText: "查看慢事件日志",
                accessibilityValueText: "\(slowEventCount) 条",
                action: { onSelect(.slowEvents) }
            )
            Divider().frame(height: 28)
            MetricCell(
                value: "\(warningCount)",
                label: "警告",
                valueFont: .headline.monospacedDigit(),
                valueColor: warningCount > 0 ? .red : .secondary,
                isSelected: selectedFilter == .warnings,
                accessibilityLabelText: "查看警告日志",
                accessibilityValueText: "\(warningCount) 条",
                action: { onSelect(.warnings) }
            )
        }
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
    }
}
