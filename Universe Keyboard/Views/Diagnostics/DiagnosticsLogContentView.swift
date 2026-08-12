import SwiftUI

struct DiagnosticsLogContentView: View {
    let hasLoggedLines: Bool
    let selectionDescription: String
    let filteredCount: Int
    let totalCount: Int
    let displayedLines: [String]
    let exportLimitMessage: String?
    let hasMorePages: Bool
    let isLoadingMore: Bool
    let pagingNotice: String?
    let colorTokenForLine: (String) -> String
    let onLoadMore: () -> Void

    var body: some View {
        if displayedLines.isEmpty {
            VStack(spacing: 12) {
                if let pagingNotice {
                    DiagnosticsNoticeView(message: pagingNotice)
                        .padding(.horizontal, AppSpacing.screen)
                }
                DiagnosticsEmptyStateView(hasLoggedLines: hasLoggedLines)
            }
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

                    if let exportLimitMessage {
                        Text(exportLimitMessage)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    if let pagingNotice {
                        DiagnosticsNoticeView(message: pagingNotice)
                    }

                    ForEach(Array(displayedLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(color(for: colorTokenForLine(line)))
                            .textSelection(.enabled)
                    }

                    if hasMorePages {
                        Button(action: onLoadMore) {
                            if isLoadingMore {
                                ProgressView()
                            } else {
                                Label("加载更早记录", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            }
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
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

private struct DiagnosticsNoticeView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .accessibilityHidden(true)
            Text(message)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.caption)
        .foregroundStyle(.orange)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct DiagnosticsEmptyStateView: View {
    let hasLoggedLines: Bool

    var body: some View {
        EmptyStateView(
            systemImage: "text.alignleft",
            title: hasLoggedLines ? "当前筛选无匹配日志" : "暂无诊断日志",
            message: hasLoggedLines
                ? "尝试切换统计项、分类筛选或选择「全部」。"
                : "在设置中开启「引擎诊断日志」开关，切换到键盘输入后返回此页面刷新。",
            symbolFont: .largeTitle,
            symbolOpacity: 0.4,
            titleFont: .body,
            messageFont: .caption,
            verticalPadding: 24,
            horizontalPadding: 40
        )
        .frame(maxHeight: .infinity)
    }
}
