import KeyboardCore
import SwiftUI

/// 将底层 UTC 小时段呈现为用户熟悉的本地日历日期。日期切换会建立新的
/// immutable query，不在 View 内直接读取文件或维护分页 cursor。
struct DiagnosticsDayPicker: View {
    let days: [DiagnosticsLogDay]
    let selectedDay: DiagnosticsLogDay?
    let onSelect: (DiagnosticsLogDay) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.tight) {
            Label("日志日期", systemImage: "calendar")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing.screen)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(days) { day in
                        dayButton(day)
                    }
                }
                .padding(.horizontal, AppSpacing.screen)
            }
        }
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
    }

    private func dayButton(_ day: DiagnosticsLogDay) -> some View {
        let isSelected = day == selectedDay
        return Button {
            onSelect(day)
        } label: {
            VStack(spacing: 3) {
                Text(relativeTitle(for: day.range.start))
                    .font(.caption.weight(.semibold))
                Text(shortDate(for: day.range.start))
                    .font(.subheadline.monospacedDigit().weight(.medium))
            }
            .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
            .frame(minWidth: 76, minHeight: 48)
            .padding(.horizontal, 8)
            .background(
                isSelected
                    ? Color.primary
                    : Color(.secondarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous))
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(fullDate(for: day.range.start))
        .accessibilityValue(isSelected ? "已选择" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func relativeTitle(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "今天" }
        if Calendar.current.isDateInYesterday(date) { return "昨天" }
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter.string(from: date)
    }

    private func shortDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter.string(from: date)
    }

    private func fullDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
