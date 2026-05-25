import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import KeyboardCore

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

/// 键盘诊断日志子页面。
/// 顶部固定刷新 + 清空按钮，含分类筛选器。
struct DiagnosticsView: View {
    private enum SummaryFilter {
        case all
        case slowEvents
        case warnings
    }

    @State private var lines: [String] = []
    @State private var isRefreshing = false
    @State private var isClearing = false
    @State private var showClearConfirm = false
    @State private var selectedSummaryFilter: SummaryFilter = .all
    @State private var selectedCategory: Logger.Category? = nil

    /// 显示的分类标签（含 "全部"）
    private let filterOptions: [(String, Logger.Category?)] = [
        ("全部", nil),
        ("性能", .performance),
        ("画面", .display),
        ("引擎", .engine),
        ("配置", .config),
        ("部署", .deployment),
        ("通用", .general),
    ]

    /// 按选中分类过滤后的行
    private var filteredLines: [String] {
        let scopedLines: [String]
        switch selectedSummaryFilter {
        case .all:
            scopedLines = lines
        case .slowEvents:
            scopedLines = lines.filter(isSlowEvent)
        case .warnings:
            scopedLines = lines.filter(isWarning)
        }

        guard let category = selectedCategory else { return scopedLines }
        let tag = "[\(category.rawValue)]"
        return scopedLines.filter { $0.contains(tag) }
    }

    private var displayedLines: [String] {
        Array(filteredLines.reversed())
    }

    private var slowEventCount: Int {
        lines.filter(isSlowEvent).count
    }

    private var warningCount: Int {
        lines.filter(isWarning).count
    }

    private var selectionDescription: String {
        switch (selectedSummaryFilter, selectedCategory) {
        case (.all, nil):
            return "全部日志"
        case (.slowEvents, nil):
            return "慢事件"
        case (.warnings, nil):
            return "警告"
        case (.all, .some(let category)):
            return "\(category.rawValue) 分类"
        case (.slowEvents, .some(let category)):
            return "慢事件 · \(category.rawValue)"
        case (.warnings, .some(let category)):
            return "警告 · \(category.rawValue)"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !lines.isEmpty {
                summaryBar
            }

            // 分类筛选
            if !lines.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterOptions, id: \.0) { label, category in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedSummaryFilter = .all
                                    selectedCategory = category
                                }
                            } label: {
                                Text(label)
                                    .font(.caption)
                                    .fontWeight(selectedCategory == category ? .semibold : .regular)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        selectedCategory == category
                                            ? Color.primary.opacity(0.14)
                                            : Color(.systemGray5)
                                    )
                                    .foregroundStyle(
                                        selectedCategory == category
                                            ? .primary
                                            : .secondary
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(.bar)

                Divider()
            }

            // 日志内容
            if displayedLines.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.alignleft")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text(lines.isEmpty ? "暂无诊断日志" : "当前筛选无匹配日志")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text(lines.isEmpty
                         ? "在设置中开启「引擎诊断日志」开关，切换到键盘输入后返回此页面刷新。"
                         : "尝试切换统计项、分类筛选或选择「全部」。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("\(selectionDescription) · 最新记录优先")
                            Spacer()
                            Text("\(filteredLines.count)/\(lines.count) 条")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)

                        ForEach(Array(displayedLines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(colorForLine(line))
                                .textSelection(.enabled)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle("键盘诊断")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: refresh) {
                    if isRefreshing {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .accessibilityLabel("刷新日志")
                .disabled(isRefreshing)

                Button(action: copyLog) {
                    Image(systemName: "doc.on.doc")
                }
                .accessibilityLabel("复制当前日志")
                .disabled(filteredLines.isEmpty)

                Button(role: .destructive, action: { showClearConfirm = true }) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("清空日志")
                .disabled(lines.isEmpty || isClearing)
            }
        }
        .alert("确认清空", isPresented: $showClearConfirm) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive, action: performClear)
        } message: {
            Text("清空后诊断日志将永久删除，无法恢复。")
        }
        .onAppear { loadLog() }
    }

    private var summaryBar: some View {
        HStack(spacing: 0) {
            SummaryMetric(
                value: "\(lines.count)",
                label: "记录",
                isSelected: selectedSummaryFilter == .all,
                accessibilityLabel: "查看全部日志"
            ) {
                selectSummaryFilter(.all)
            }
            Divider().frame(height: 28)
            SummaryMetric(
                value: "\(slowEventCount)",
                label: "慢事件",
                color: slowEventCount > 0 ? .orange : .secondary,
                isSelected: selectedSummaryFilter == .slowEvents,
                accessibilityLabel: "查看慢事件日志"
            ) {
                selectSummaryFilter(.slowEvents)
            }
            Divider().frame(height: 28)
            SummaryMetric(
                value: "\(warningCount)",
                label: "警告",
                color: warningCount > 0 ? .red : .secondary,
                isSelected: selectedSummaryFilter == .warnings,
                accessibilityLabel: "查看警告日志"
            ) {
                selectSummaryFilter(.warnings)
            }
        }
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
    }

    // MARK: - Line coloring

    private func colorForLine(_ line: String) -> Color {
        if line.contains("[ERROR]") { return .red }
        if line.contains("[WARN]")  { return .orange }
        if line.contains("[PERF]")  { return .primary }
        if line.contains("[DISP]")  { return .secondary }
        return .secondary
    }

    // MARK: - Actions

    private func isSlowEvent(_ line: String) -> Bool {
        line.contains("SLOW ")
    }

    private func isWarning(_ line: String) -> Bool {
        line.contains("[WARN]") || line.contains("[ERROR]")
    }

    private func selectSummaryFilter(_ filter: SummaryFilter) {
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedSummaryFilter = filter
            selectedCategory = nil
        }
    }

    private func loadLog() {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else {
            lines = []
            return
        }
        lines = log.components(separatedBy: "\n")
    }

    private func copyLog() {
        UIPasteboard.general.string = filteredLines.joined(separator: "\n")
    }

    private func refresh() {
        isRefreshing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            loadLog()
            isRefreshing = false
        }
    }

    private func performClear() {
        isClearing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let defaults = UserDefaults(suiteName: appGroupID)
            defaults?.removeObject(forKey: "rime_diag_log")
            defaults?.removeObject(forKey: "rime_diag_summary")
            defaults?.synchronize()
            lines = []
            isClearing = false
        }
    }
}

private struct SummaryMetric: View {
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

#Preview {
    NavigationStack {
        DiagnosticsView()
    }
}
