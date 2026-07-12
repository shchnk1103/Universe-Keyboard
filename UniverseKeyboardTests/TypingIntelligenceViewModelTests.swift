import KeyboardCore
import XCTest

@testable import Universe_Keyboard

@MainActor
final class TypingIntelligenceViewModelTests: XCTestCase {
    func testPeriodSummaryChartAndStreakUsePersistedDailyAggregates() throws {
        let suiteName = "TypingIntelligenceViewModelTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 11,
            hour: 12
        )))
        var today = TypingStatisticsDelta()
        today.committedGraphemeCount = 12
        today.cjkCharacterCount = 8
        today.latinLetterCount = 4
        var yesterday = TypingStatisticsDelta()
        yesterday.committedGraphemeCount = 5
        yesterday.emojiCount = 2
        yesterday.punctuationCount = 3
        let snapshot = TypingStatisticsSnapshotV1(
            resetEpoch: 0,
            createdAt: now,
            updatedAt: now,
            totals: {
                var total = today
                total += yesterday
                return total
            }(),
            dailyBuckets: [
                TypingStatisticsDailyBucket(day: "2026-07-10", counts: yesterday),
                TypingStatisticsDailyBucket(day: "2026-07-11", counts: today),
            ]
        )
        defaults.set(true, forKey: TypingStatisticsStorageKey.enabled)
        defaults.set(
            try JSONEncoder().encode(snapshot),
            forKey: TypingStatisticsStorageKey.snapshotV1
        )

        let model = TypingIntelligenceViewModel(
            defaults: defaults,
            calendar: calendar,
            now: { now }
        )
        model.selectedPeriod = .sevenDays

        XCTAssertTrue(model.isEnabled)
        XCTAssertEqual(model.selectedCounts.committedGraphemeCount, 17)
        XCTAssertEqual(model.chartPoints.suffix(2).map(\.count), [5, 12])
        XCTAssertEqual(model.currentStreak, 2)
        XCTAssertEqual(model.homeStreak, 2)
        XCTAssertEqual(model.activeDayCount, 2)
        XCTAssertEqual(model.categories.map(\.title), ["中文", "字母", "Emoji", "标点"])
        XCTAssertEqual(model.todayCounts.committedGraphemeCount, 12)
        XCTAssertEqual(model.todayCounts.cjkCharacterCount, 8)
    }

    func testClearAdvancesEpochAndRemovesVisibleStatistics() throws {
        let suiteName = "TypingIntelligenceViewModelTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        var totals = TypingStatisticsDelta()
        totals.committedGraphemeCount = 3
        let snapshot = TypingStatisticsSnapshotV1(
            resetEpoch: 0,
            createdAt: Date(),
            updatedAt: Date(),
            totals: totals
        )
        defaults.set(try JSONEncoder().encode(snapshot), forKey: TypingStatisticsStorageKey.snapshotV1)
        let model = TypingIntelligenceViewModel(defaults: defaults)

        model.clearStatistics()

        XCTAssertFalse(model.hasStatistics)
        XCTAssertEqual(defaults.integer(forKey: TypingStatisticsStorageKey.resetEpoch), 1)
        XCTAssertNil(defaults.data(forKey: TypingStatisticsStorageKey.snapshotV1))
    }

    func testHomeStreakKeepsYesterdayRunWhenTodayHasNoInput() throws {
        let suiteName = "TypingIntelligenceViewModelTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 11,
            hour: 12
        )))
        var counts = TypingStatisticsDelta()
        counts.committedGraphemeCount = 1
        let snapshot = TypingStatisticsSnapshotV1(
            resetEpoch: 0,
            createdAt: now,
            updatedAt: now,
            totals: {
                var total = counts
                total += counts
                return total
            }(),
            dailyBuckets: [
                TypingStatisticsDailyBucket(day: "2026-07-09", counts: counts),
                TypingStatisticsDailyBucket(day: "2026-07-10", counts: counts),
            ]
        )
        defaults.set(true, forKey: TypingStatisticsStorageKey.enabled)
        defaults.set(
            try JSONEncoder().encode(snapshot),
            forKey: TypingStatisticsStorageKey.snapshotV1
        )

        let model = TypingIntelligenceViewModel(
            defaults: defaults,
            calendar: calendar,
            now: { now }
        )

        XCTAssertEqual(model.todayCounts.committedGraphemeCount, 0)
        XCTAssertEqual(model.currentStreak, 0)
        XCTAssertEqual(model.homeStreak, 2)
    }
}
