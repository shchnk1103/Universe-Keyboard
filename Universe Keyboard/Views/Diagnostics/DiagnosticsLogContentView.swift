import SwiftUI

struct DiagnosticsLogContentView: View {
    let hasLoggedLines: Bool
    let selectionDescription: String
    let filteredCount: Int
    let totalCount: Int
    let displayedLines: [String]
    let colorTokenForLine: (String) -> String

    var body: some View {
        if displayedLines.isEmpty {
            DiagnosticsEmptyStateView(hasLoggedLines: hasLoggedLines)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("\(selectionDescription) · 最新记录优先")
                        Spacer()
                        Text("\(filteredCount)/\(totalCount) 条")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                    ForEach(Array(displayedLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(color(for: colorTokenForLine(line)))
                            .textSelection(.enabled)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func color(for token: String) -> Color {
        switch token {
        case "error":
            return .red
        case "warning":
            return .orange
        case "primary":
            return .primary
        default:
            return .secondary
        }
    }
}

private struct DiagnosticsEmptyStateView: View {
    let hasLoggedLines: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.alignleft")
                .font(.largeTitle)
                .foregroundStyle(.secondary.opacity(0.4))
            Text(hasLoggedLines ? "当前筛选无匹配日志" : "暂无诊断日志")
                .font(.body)
                .foregroundStyle(.secondary)
            Text(
                hasLoggedLines
                    ? "尝试切换统计项、分类筛选或选择「全部」。"
                    : "在设置中开启「引擎诊断日志」开关，切换到键盘输入后返回此页面刷新。"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
}
