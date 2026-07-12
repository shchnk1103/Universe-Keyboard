import KeyboardCore
import SwiftUI

struct HomeTab: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model = TypingIntelligenceViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    todaySection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("首页")
            .onAppear { model.reload() }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                model.reload()
            }
        }
    }

    private var todaySection: some View {
        NavigationLink {
            TypingIntelligenceView()
        } label: {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("今日输入")
                            .font(.title3.weight(.semibold))
                        streakIndicator
                    }
                    Spacer(minLength: 12)
                    iconTile
                }

                if isStatisticsAvailable {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(model.todayCounts.committedGraphemeCount.formatted())
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("字符")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("今日已输入 \(model.todayCounts.committedGraphemeCount) 个字符")
                } else {
                    Text(todayUnavailableValue)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 0) {
                    breakdownMetric("中文", value: model.todayCounts.cjkCharacterCount)
                    Divider().frame(height: 42)
                    breakdownMetric("字母", value: model.todayCounts.latinLetterCount)
                    Divider().frame(height: 42)
                    breakdownMetric("Emoji", value: model.todayCounts.emojiCount)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("打开输入趋势、字符构成与数据管理")
    }

    private var isStatisticsAvailable: Bool {
        model.isEnabled && model.storeIssueDescription == nil
    }

    private var hasInputToday: Bool {
        isStatisticsAvailable && model.todayCounts.committedGraphemeCount > 0
    }

    private var displayedStreak: Int {
        isStatisticsAvailable ? model.homeStreak : 0
    }

    private var todayUnavailableValue: String {
        model.isEnabled ? "暂不可用" : "未开启"
    }

    private var streakIndicator: some View {
        HStack(spacing: 3) {
            Image(systemName: "flame.fill")
                .symbolEffect(.bounce, value: hasInputToday)
            Text(displayedStreak.formatted())
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(hasInputToday ? .orange : .secondary)
        .animation(.spring(duration: 0.32, bounce: 0.25), value: hasInputToday)
        .animation(.spring(duration: 0.32, bounce: 0.25), value: displayedStreak)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            hasInputToday
                ? "连续记录 \(displayedStreak) 天"
                : "今天尚未输入，连续记录 \(displayedStreak) 天"
        )
    }

    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color.blue)
            Image(systemName: "text.cursor")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 38, height: 38)
        .accessibilityHidden(true)
    }

    private func breakdownMetric(_ title: String, value: Int) -> some View {
        VStack(spacing: 3) {
            Text(value.formatted())
                .font(.title3.weight(.semibold).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(value) 个字符")
    }

}

#Preview {
    HomeTab()
}
