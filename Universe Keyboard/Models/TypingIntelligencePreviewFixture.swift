#if DEBUG
import Foundation
import KeyboardCore

enum TypingIntelligencePreviewFixture {
    static let launchArgument = "--typing-intelligence-preview"

    static func installIfRequested(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        defaults: UserDefaults? = UserDefaults(suiteName: universeAppGroupID),
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        guard arguments.contains(launchArgument), let defaults else { return }

        var totals = TypingStatisticsDelta()
        var buckets: [TypingStatisticsDailyBucket] = []
        for offset in (0..<14).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { continue }
            let dailyTotal = 420 + ((13 - offset) * 73) % 860
            var counts = TypingStatisticsDelta()
            counts.committedGraphemeCount = dailyTotal
            counts.cjkCharacterCount = dailyTotal * 58 / 100
            counts.latinLetterCount = dailyTotal * 18 / 100
            counts.digitCount = dailyTotal * 5 / 100
            counts.emojiCount = dailyTotal * 7 / 100
            counts.punctuationCount = dailyTotal * 8 / 100
            counts.whitespaceCount = dailyTotal
                - counts.cjkCharacterCount
                - counts.latinLetterCount
                - counts.digitCount
                - counts.emojiCount
                - counts.punctuationCount
            totals += counts
            buckets.append(TypingStatisticsDailyBucket(day: dayIdentifier(date, calendar: calendar), counts: counts))
        }

        let snapshot = TypingStatisticsSnapshotV1(
            resetEpoch: defaults.integer(forKey: TypingStatisticsStorageKey.resetEpoch),
            createdAt: calendar.date(byAdding: .day, value: -13, to: now) ?? now,
            updatedAt: now,
            totals: totals,
            dailyBuckets: buckets,
            graphemesBySource: [
                CommittedTextSource.candidate.rawValue: totals.cjkCharacterCount,
                CommittedTextSource.key.rawValue: totals.latinLetterCount,
                CommittedTextSource.emoji.rawValue: totals.emojiCount,
            ]
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(true, forKey: TypingStatisticsStorageKey.enabled)
        defaults.set(data, forKey: TypingStatisticsStorageKey.snapshotV1)
    }

    private static func dayIdentifier(_ date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}
#endif
