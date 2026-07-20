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
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                Text("今日输入")
                    .font(.title3.weight(.semibold))
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
    }

    private var isStatisticsAvailable: Bool {
        model.isEnabled && model.storeIssueDescription == nil
    }

    private var todayUnavailableValue: String {
        model.isEnabled ? "暂不可用" : "未开启"
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
