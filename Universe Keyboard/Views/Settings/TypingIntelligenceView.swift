import Charts
import KeyboardCore
import SwiftUI

struct TypingIntelligenceView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model = TypingIntelligenceViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                controlSection

                if model.isEnabled {
                    if let issue = model.storeIssueDescription {
                        storeIssueSection(issue)
                    } else if model.hasStatistics {
                        periodPicker
                        overviewSection
                        trendSection
                        compositionSection
                        activitySection
                    } else {
                        emptySection
                    }
                } else {
                    disabledSection
                }

                privacySection
                if model.hasStatistics || model.canClearStoreIssue {
                    dataControlSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 78)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("输入洞察")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { model.reload() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            model.reload()
        }
        .confirmationDialog(
            "清除全部输入洞察？",
            isPresented: $model.showsClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("清除全部数据", role: .destructive) {
                model.clearStatistics()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作会永久删除所有本地聚合统计，无法撤销。")
        }
    }

    private var controlSection: some View {
        section(title: "输入洞察") {
            HStack(spacing: 12) {
                icon("chart.xyaxis.line", foreground: .white, background: .black)
                VStack(alignment: .leading, spacing: 3) {
                    Text("记录本地输入统计")
                        .font(.body)
                    Text(model.isEnabled ? "正在设备上聚合，不保存输入内容" : "关闭时不会产生新的统计")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Toggle("", isOn: Binding(
                    get: { model.isEnabled },
                    set: { model.setEnabled($0) }
                ))
                .labelsHidden()
            }
            .padding(14)
        }
    }

    private var periodPicker: some View {
        Picker("统计范围", selection: $model.selectedPeriod) {
            ForEach(TypingStatisticsPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var overviewSection: some View {
        section(title: model.selectedPeriod.rawValue) {
            HStack(spacing: 0) {
                metric(
                    value: model.selectedCounts.committedGraphemeCount.formatted(),
                    label: "已提交字符"
                )
                Divider().frame(height: 44)
                metric(value: model.currentStreak.formatted(), label: "连续天数")
            }
            .padding(.vertical, 16)
        }
    }

    private var trendSection: some View {
        section(title: "输入趋势") {
            Chart(model.chartPoints) { point in
                BarMark(
                    x: .value("日期", point.date, unit: .day),
                    y: .value("字符", point.count)
                )
                .foregroundStyle(Color.primary.opacity(0.82))
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: model.chartPoints.count > 7 ? 5 : 7)) { _ in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(.secondary.opacity(0.18))
                    AxisValueLabel()
                }
            }
            .frame(height: 180)
            .padding(14)
            .accessibilityLabel("每日输入字符趋势")
        }
    }

    private var compositionSection: some View {
        section(title: "字符构成") {
            VStack(spacing: 12) {
                ForEach(model.categories) { category in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(color(named: category.colorName))
                            .frame(width: 8, height: 8)
                        Text(category.title)
                            .font(.subheadline)
                        Spacer()
                        Text(category.count.formatted())
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
        }
    }

    private var activitySection: some View {
        section(title: "活动") {
            VStack(spacing: 0) {
                KeyValueRow(
                    title: "有记录的天数",
                    value: "\(model.activeDayCount) 天",
                    horizontalPadding: AppSpacing.card,
                    verticalPadding: AppSpacing.card
                )
                Divider().padding(.leading, AppSpacing.card)
                KeyValueRow(
                    title: "最近更新",
                    value: model.formattedLastUpdate ?? "—",
                    horizontalPadding: AppSpacing.card,
                    verticalPadding: AppSpacing.card
                )
            }
        }
    }

    private var emptySection: some View {
        section(title: "等待统计") {
            EmptyStateView(
                systemImage: "keyboard",
                title: "开始使用 Universe Keyboard",
                message: "开启完全访问后，键盘会把已提交字符转换为本地聚合统计。输入内容不会被保存。",
                symbolFont: .system(size: 30, weight: .medium),
                titleFont: .headline,
                messageFont: .subheadline,
                verticalPadding: 28,
                horizontalPadding: 24
            )
        }
    }

    private func storeIssueSection(_ message: String) -> some View {
        section(title: "统计不可用") {
            VStack(alignment: .leading, spacing: 10) {
                Label("暂时无法显示输入洞察", systemImage: "exclamationmark.triangle")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }

    private var disabledSection: some View {
        section(title: "功能已关闭") {
            VStack(alignment: .leading, spacing: 10) {
                Label("不会记录新的统计", systemImage: "pause.circle")
                    .font(.headline)
                Text("已有统计会保留在设备上。你可以重新开启，或在下方永久清除。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }

    private var privacySection: some View {
        section(title: "隐私") {
            VStack(alignment: .leading, spacing: 12) {
                privacyRow("不保存输入内容", icon: "text.badge.xmark")
                privacyRow("不记录使用的 App", icon: "app.badge.checkmark")
                privacyRow("不上传或同步", icon: "icloud.slash")
                privacyRow("只保留不可逆聚合", icon: "lock.shield")
            }
            .padding(14)
        }
    }

    private var dataControlSection: some View {
        section(title: "数据管理") {
            Button(role: .destructive) {
                model.showsClearConfirmation = true
            } label: {
                Label("清除全部输入洞察", systemImage: "trash")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
            }
        }
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        SettingsGroup(title: title, contentSpacing: 8) {
            AppCard(horizontalPadding: 0, verticalPadding: 0) {
                content()
            }
        }
    }

    private func metric(value: String, label: String) -> some View {
        MetricCell(
            value: value,
            label: label,
            valueFont: .title2.weight(.semibold).monospacedDigit()
        )
    }

    private func privacyRow(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline)
            .foregroundStyle(.primary)
    }

    private func icon(_ name: String, foreground: Color, background: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(background)
            Image(systemName: name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(foreground)
        }
        .frame(width: 30, height: 30)
    }

    private func color(named name: String) -> Color {
        switch name {
        case "blue": .blue
        case "green": .green
        case "yellow": .yellow
        case "orange": .orange
        case "secondary": .secondary
        default: .primary
        }
    }
}

#Preview {
    NavigationStack {
        TypingIntelligenceView()
    }
}
