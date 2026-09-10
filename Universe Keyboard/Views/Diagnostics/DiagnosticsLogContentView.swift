import SwiftUI

struct DiagnosticsLogContentView: View {
    let hasLoggedLines: Bool
    let isRefreshing: Bool
    let showsInlineRefreshProgress: Bool
    let selectionDescription: String
    let filteredCount: Int
    let totalCount: Int
    let displayedLines: [String]
    let exportLimitMessage: String?
    let hasMorePages: Bool
    let isLoadingMore: Bool
    let pagingNotice: String?
    let isPartialWindow: Bool
    let colorTokenForLine: (String) -> String
    let onLoadMore: () -> Void
    @State private var runtimeRouteDetail: DiagnosticsRuntimeRouteDetail?

    var body: some View {
        if displayedLines.isEmpty && isRefreshing {
            DiagnosticsLoadingStateView()
        } else if displayedLines.isEmpty {
            VStack(spacing: 12) {
                if let pagingNotice {
                    DiagnosticsNoticeView(message: pagingNotice)
                        .padding(.horizontal, AppSpacing.screen)
                }
                DiagnosticsEmptyStateView(
                    hasLoggedLines: hasLoggedLines,
                    isPartialWindow: isPartialWindow
                )
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("\(selectionDescription) · 最新记录优先")
                        Spacer()
                        if showsInlineRefreshProgress {
                            ProgressView()
                                .controlSize(.small)
                                .accessibilityLabel("正在更新诊断日志")
                        }
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
                        diagnosticsLine(line)
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
            .sheet(item: $runtimeRouteDetail) { detail in
                DiagnosticsRuntimeRouteDetailSheet(items: detail.items)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private func diagnosticsLine(_ line: String) -> some View {
        let detailItems = DiagnosticsEventDisplayFormatter.runtimeRouteDetailItems(from: line)
        if let detailItems {
            Button {
                runtimeRouteDetail = DiagnosticsRuntimeRouteDetail(items: detailItems)
            } label: {
                Text(line)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(color(for: colorTokenForLine(line)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.plain)
            .accessibilityHint("显示运行时路由的有限字段")
        } else {
            Text(line)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(color(for: colorTokenForLine(line)))
                .textSelection(.enabled)
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

private struct DiagnosticsRuntimeRouteDetail: Identifiable {
    let id = UUID()
    let items: [(title: String, value: String)]
}

private struct DiagnosticsRuntimeRouteDetailSheet: View {
    let items: [(title: String, value: String)]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(items, id: \.title) { item in
                    KeyValueRow(title: item.title, value: item.value)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("运行时路由")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成", action: dismiss.callAsFunction)
                }
            }
        }
    }
}

private struct DiagnosticsNoticeView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            Text(message)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.caption)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct DiagnosticsLoadingStateView: View {
    var body: some View {
        VStack(spacing: AppSpacing.tight) {
            ProgressView()
            Text("正在加载诊断日志")
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            Text("正在读取本地记录，这不是空日志。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
        .padding(.vertical, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("正在加载诊断日志")
    }
}

private struct DiagnosticsEmptyStateView: View {
    let hasLoggedLines: Bool
    let isPartialWindow: Bool

    var body: some View {
        EmptyStateView(
            systemImage: "text.alignleft",
            title: emptyTitle,
            message: emptyMessage,
            symbolFont: .largeTitle,
            symbolOpacity: 0.4,
            titleFont: .body,
            messageFont: .caption,
            verticalPadding: 24,
            horizontalPadding: 40
        )
        .frame(maxHeight: .infinity)
    }

    private var emptyTitle: String {
        if hasLoggedLines { return "当前筛选无匹配日志" }
        if isPartialWindow { return "当前窗口暂无可展示记录" }
        return "暂无诊断日志"
    }

    private var emptyMessage: String {
        if hasLoggedLines {
            return "尝试切换统计项、分类筛选或选择「全部」。"
        }
        if isPartialWindow {
            return "完整日志仍保留在设备上，但当前安全读取窗口没有解码出完整记录。"
        }
        return "在设置中开启「记录诊断数据」开关，切换到键盘输入后返回此页面刷新。"
    }
}
