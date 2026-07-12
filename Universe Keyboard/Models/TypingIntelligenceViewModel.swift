import Foundation
import KeyboardCore
import Observation

enum TypingStatisticsPeriod: String, CaseIterable, Identifiable {
    case today = "今日"
    case sevenDays = "7 天"
    case thirtyDays = "30 天"
    case allTime = "累计"

    var id: Self { self }

    var dayCount: Int? {
        switch self {
        case .today: 1
        case .sevenDays: 7
        case .thirtyDays: 30
        case .allTime: nil
        }
    }
}

struct TypingDailyPoint: Identifiable, Equatable {
    let day: String
    let date: Date
    let count: Int

    var id: String { day }
}

struct TypingCategorySummary: Identifiable, Equatable {
    let id: String
    let title: String
    let count: Int
    let colorName: String
}

@MainActor
@Observable
final class TypingIntelligenceViewModel {
    private let store: TypingStatisticsStore
    private let calendar: Calendar
    private let now: () -> Date

    var isEnabled = false
    var snapshot = TypingStatisticsSnapshotV1.empty(resetEpoch: 0)
    var storeState: TypingStatisticsStoreState = .ready(.empty(resetEpoch: 0))
    var selectedPeriod: TypingStatisticsPeriod = .sevenDays
    var showsClearConfirmation = false

    init(
        defaults: UserDefaults? = UserDefaults(suiteName: universeAppGroupID),
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        store = TypingStatisticsStore(defaults: defaults)
        self.calendar = calendar
        self.now = now
        reload()
    }

    func reload() {
        isEnabled = store.isEnabled
        storeState = store.loadState()
        if case .ready(let loadedSnapshot) = storeState {
            snapshot = loadedSnapshot
        }
    }

    func setEnabled(_ enabled: Bool) {
        store.setEnabled(enabled)
        isEnabled = enabled
    }

    func clearStatistics() {
        store.reset()
        reload()
        showsClearConfirmation = false
    }

    var selectedCounts: TypingStatisticsDelta {
        counts(for: selectedPeriod.dayCount)
    }

    var todayCounts: TypingStatisticsDelta {
        counts(for: 1)
    }

    private func counts(for dayCount: Int?) -> TypingStatisticsDelta {
        guard let dayCount else { return snapshot.totals }
        let allowedDays = Set((0..<dayCount).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: now()).map(dayIdentifier)
        })
        return snapshot.dailyBuckets.reduce(into: TypingStatisticsDelta()) { result, bucket in
            guard allowedDays.contains(bucket.day) else { return }
            result += bucket.counts
        }
    }

    var chartPoints: [TypingDailyPoint] {
        let visibleDays: Int
        switch selectedPeriod {
        case .today: visibleDays = 1
        case .sevenDays: visibleDays = 7
        case .thirtyDays, .allTime: visibleDays = 30
        }
        let countsByDay = Dictionary(
            snapshot.dailyBuckets.map { ($0.day, $0.counts.committedGraphemeCount) },
            uniquingKeysWith: +
        )
        return (0..<visibleDays).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now()) else { return nil }
            let day = dayIdentifier(date)
            return TypingDailyPoint(day: day, date: date, count: countsByDay[day] ?? 0)
        }
    }

    var categories: [TypingCategorySummary] {
        let counts = selectedCounts
        return [
            TypingCategorySummary(id: "cjk", title: "中文", count: counts.cjkCharacterCount, colorName: "primary"),
            TypingCategorySummary(id: "latin", title: "字母", count: counts.latinLetterCount, colorName: "blue"),
            TypingCategorySummary(id: "digit", title: "数字", count: counts.digitCount, colorName: "green"),
            TypingCategorySummary(id: "emoji", title: "Emoji", count: counts.emojiCount, colorName: "yellow"),
            TypingCategorySummary(
                id: "punctuation",
                title: "标点",
                count: counts.punctuationCount,
                colorName: "orange"
            ),
            TypingCategorySummary(
                id: "spacing",
                title: "空格与换行",
                count: counts.whitespaceCount + counts.newlineCount,
                colorName: "secondary"
            )
        ].filter { $0.count > 0 }
    }

    var activeDayCount: Int {
        snapshot.dailyBuckets.lazy.filter { $0.counts.committedGraphemeCount > 0 }.count
    }

    var currentStreak: Int {
        streak(endingAt: now())
    }

    /// 首页在今天尚未输入时，显示截至昨天最后一段连续记录的天数。
    var homeStreak: Int {
        guard todayCounts.committedGraphemeCount == 0 else { return currentStreak }
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now()) else { return 0 }
        return streak(endingAt: yesterday)
    }

    private func streak(endingAt date: Date) -> Int {
        let activeDays = Set(
            snapshot.dailyBuckets
                .filter { $0.counts.committedGraphemeCount > 0 }
                .map(\.day)
        )
        var streak = 0
        var cursor = date
        while activeDays.contains(dayIdentifier(cursor)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    var hasStatistics: Bool {
        snapshot.totals.committedGraphemeCount > 0
    }

    var storeIssueDescription: String? {
        switch storeState {
        case .ready:
            return nil
        case .unavailable:
            return "无法访问共享存储。键盘输入不受影响，请检查完全访问设置。"
        case .corrupted:
            return "本地统计无法读取。你可以清除数据后重新开始记录。"
        case .unsupportedVersion:
            return "这份统计来自更新的数据版本。请更新 App 后再查看。"
        }
    }

    var canClearStoreIssue: Bool {
        if case .corrupted = storeState { return true }
        return false
    }

    var formattedLastUpdate: String? {
        guard hasStatistics else { return nil }
        return snapshot.updatedAt.formatted(date: .abbreviated, time: .shortened)
    }

    private func dayIdentifier(_ date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}
