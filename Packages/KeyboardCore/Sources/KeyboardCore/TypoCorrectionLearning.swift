import Foundation

public enum TypoCorrectionLearningStorageKey {
    public static let records = "typo_correction_learning_records"
}

public enum TypoCorrectionLearnedEditKind: String, Codable, Equatable, Sendable {
    case insertion
    case transposition
}

public struct TypoCorrectionLearningKey: Codable, Equatable, Hashable, Sendable {
    public let originalInput: String
    public let correctedInput: String
    public let candidateText: String
    public let editKind: TypoCorrectionLearnedEditKind

    public init?(correction: TypoCorrectionCommit) {
        guard correction.edits.count == 1,
            !correction.originalInput.isEmpty,
            !correction.correctedInput.isEmpty,
            !correction.committedText.isEmpty
        else { return nil }

        let assessment = TypoCorrectionAssessment.evaluate(
            title: correction.committedText,
            correction: correction,
            firstNormalCandidate: nil
        )
        guard assessment.isDisplayEligible else { return nil }

        switch assessment.reasonSummary {
        case .conservativeInsertion:
            editKind = .insertion
        case .adjacentTransposition:
            editKind = .transposition
        default:
            return nil
        }

        originalInput = correction.originalInput
        correctedInput = correction.correctedInput
        candidateText = correction.committedText
    }
}

public struct TypoCorrectionLearningRecord: Codable, Equatable, Sendable {
    public let key: TypoCorrectionLearningKey
    public let selectionCount: Int
    public let lastSelectedAt: Date

    public init(
        key: TypoCorrectionLearningKey,
        selectionCount: Int,
        lastSelectedAt: Date
    ) {
        self.key = key
        self.selectionCount = selectionCount
        self.lastSelectedAt = lastSelectedAt
    }
}

public struct TypoCorrectionLearningSnapshot: Equatable, Sendable {
    public static let empty = TypoCorrectionLearningSnapshot(records: [])

    public let records: [TypoCorrectionLearningRecord]
    private let recordsByKey: [TypoCorrectionLearningKey: TypoCorrectionLearningRecord]

    public init(records: [TypoCorrectionLearningRecord]) {
        self.records = records
        recordsByKey = Dictionary(records.map { ($0.key, $0) }, uniquingKeysWith: { current, candidate in
            candidate.lastSelectedAt > current.lastSelectedAt ? candidate : current
        })
    }

    public func selectionCount(for correction: TypoCorrectionCommit) -> Int {
        guard let key = TypoCorrectionLearningKey(correction: correction) else { return 0 }
        return recordsByKey[key]?.selectionCount ?? 0
    }
}

/// Local, bounded persistence for explicit typo-correction selections.
///
/// The store contains only correction-pair metadata. It does not record surrounding
/// text, upload telemetry, or write into RIME's user dictionary.
@MainActor
public final class TypoCorrectionLearningStore {
    public static let defaultMaximumRecordCount = 64
    public static let defaultRetentionInterval: TimeInterval = 90 * 24 * 60 * 60

    private let defaults: UserDefaults?
    private let maximumRecordCount: Int
    private let retentionInterval: TimeInterval

    public init(
        defaults: UserDefaults?,
        maximumRecordCount: Int = defaultMaximumRecordCount,
        retentionInterval: TimeInterval = defaultRetentionInterval
    ) {
        self.defaults = defaults
        self.maximumRecordCount = max(1, maximumRecordCount)
        self.retentionInterval = max(0, retentionInterval)
    }

    public func snapshot(now: Date = Date()) -> TypoCorrectionLearningSnapshot {
        TypoCorrectionLearningSnapshot(records: activeRecords(now: now))
    }

    @discardableResult
    public func recordSelection(
        _ correction: TypoCorrectionCommit,
        at date: Date = Date()
    ) -> TypoCorrectionLearningSnapshot {
        guard let key = TypoCorrectionLearningKey(correction: correction) else {
            return snapshot(now: date)
        }

        var records = activeRecords(now: date)
        let previousCount = records.first(where: { $0.key == key })?.selectionCount ?? 0
        records.removeAll { $0.key == key }
        records.append(
            TypoCorrectionLearningRecord(
                key: key,
                selectionCount: min(previousCount + 1, 99),
                lastSelectedAt: date
            )
        )
        records = Array(
            records
                .sorted { $0.lastSelectedAt > $1.lastSelectedAt }
                .prefix(maximumRecordCount)
        )
        persist(records)
        return TypoCorrectionLearningSnapshot(records: records)
    }

    public func reset() {
        defaults?.removeObject(forKey: TypoCorrectionLearningStorageKey.records)
    }

    private func activeRecords(now: Date) -> [TypoCorrectionLearningRecord] {
        guard let data = defaults?.data(forKey: TypoCorrectionLearningStorageKey.records),
            let records = try? JSONDecoder().decode([TypoCorrectionLearningRecord].self, from: data)
        else { return [] }

        let cutoff = now.addingTimeInterval(-retentionInterval)
        return records.filter {
            $0.selectionCount > 0 && $0.lastSelectedAt >= cutoff
        }
    }

    private func persist(_ records: [TypoCorrectionLearningRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults?.set(data, forKey: TypoCorrectionLearningStorageKey.records)
    }
}
