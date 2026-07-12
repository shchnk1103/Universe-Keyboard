import Dispatch
import Foundation
import Synchronization

public enum TypingStatisticsStorageKey {
    public static let enabled = "typing_intelligence_enabled"
    public static let resetEpoch = "typing_intelligence_reset_epoch"
    public static let snapshotV1 = "typing_intelligence_snapshot_v1"
}

public struct TypingStatisticsDailyBucket: Codable, Equatable, Sendable {
    public let day: String
    public var counts: TypingStatisticsDelta

    public init(day: String, counts: TypingStatisticsDelta) {
        self.day = day
        self.counts = counts
    }
}

public struct TypingStatisticsSnapshotV1: Codable, Equatable, Sendable {
    public static let schemaVersion = 1

    public let version: Int
    public let resetEpoch: Int
    public let createdAt: Date
    public var updatedAt: Date
    public var totals: TypingStatisticsDelta
    public var dailyBuckets: [TypingStatisticsDailyBucket]
    public var graphemesBySource: [String: Int]

    public init(
        resetEpoch: Int,
        createdAt: Date,
        updatedAt: Date,
        totals: TypingStatisticsDelta = TypingStatisticsDelta(),
        dailyBuckets: [TypingStatisticsDailyBucket] = [],
        graphemesBySource: [String: Int] = [:]
    ) {
        version = Self.schemaVersion
        self.resetEpoch = resetEpoch
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.totals = totals
        self.dailyBuckets = dailyBuckets
        self.graphemesBySource = graphemesBySource
    }

    public static func empty(resetEpoch: Int, now: Date = Date()) -> Self {
        Self(resetEpoch: resetEpoch, createdAt: now, updatedAt: now)
    }
}

public enum TypingStatisticsStoreState: Equatable, Sendable {
    case ready(TypingStatisticsSnapshotV1)
    case unavailable
    case corrupted
    case unsupportedVersion(Int?)
}

/// Main-actor control surface used by the containing App. The Extension uses
/// `TypingStatisticsWriter` so persistence never blocks a key action.
@MainActor
public final class TypingStatisticsStore {
    private let defaults: UserDefaults?

    public init(defaults: UserDefaults?) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        defaults?.bool(forKey: TypingStatisticsStorageKey.enabled) ?? false
    }

    public var resetEpoch: Int {
        defaults?.integer(forKey: TypingStatisticsStorageKey.resetEpoch) ?? 0
    }

    public func setEnabled(_ enabled: Bool) {
        defaults?.set(enabled, forKey: TypingStatisticsStorageKey.enabled)
    }

    public func snapshot(now: Date = Date()) -> TypingStatisticsSnapshotV1 {
        switch loadState(now: now) {
        case .ready(let snapshot):
            return snapshot
        case .unavailable, .corrupted, .unsupportedVersion:
            return .empty(resetEpoch: resetEpoch, now: now)
        }
    }

    public func loadState(now: Date = Date()) -> TypingStatisticsStoreState {
        guard let defaults else { return .unavailable }
        guard let data = defaults.data(forKey: TypingStatisticsStorageKey.snapshotV1) else {
            return .ready(.empty(resetEpoch: resetEpoch, now: now))
        }
        guard let snapshot = try? JSONDecoder().decode(TypingStatisticsSnapshotV1.self, from: data) else {
            return .corrupted
        }
        guard snapshot.version == TypingStatisticsSnapshotV1.schemaVersion else {
            return .unsupportedVersion(snapshot.version)
        }
        guard snapshot.resetEpoch == resetEpoch else {
            // The reset epoch is authoritative. A stale delayed payload is
            // ignored and removed when the main App next observes it.
            defaults.removeObject(forKey: TypingStatisticsStorageKey.snapshotV1)
            return .ready(.empty(resetEpoch: resetEpoch, now: now))
        }
        return .ready(snapshot)
    }

    /// Advances the epoch before deleting the payload. A delayed Extension
    /// batch from an older epoch is therefore unable to restore cleared data.
    public func reset() {
        let nextEpoch = resetEpoch == Int.max ? 0 : resetEpoch + 1
        defaults?.set(nextEpoch, forKey: TypingStatisticsStorageKey.resetEpoch)
        defaults?.removeObject(forKey: TypingStatisticsStorageKey.snapshotV1)
    }
}

struct TypingStatisticsPersistence: Sendable {
    let readEpoch: @Sendable () -> Int
    let readSnapshotData: @Sendable () -> Data?
    let writeSnapshotData: @Sendable (Data) -> Void

    static func live(appGroupID: String) -> Self {
        Self(
            readEpoch: {
                UserDefaults(suiteName: appGroupID)?.integer(
                    forKey: TypingStatisticsStorageKey.resetEpoch
                ) ?? 0
            },
            readSnapshotData: {
                UserDefaults(suiteName: appGroupID)?.data(
                    forKey: TypingStatisticsStorageKey.snapshotV1
                )
            },
            writeSnapshotData: { data in
                UserDefaults(suiteName: appGroupID)?.set(
                    data,
                    forKey: TypingStatisticsStorageKey.snapshotV1
                )
            }
        )
    }
}

private struct PendingTypingStatisticsBatch: Sendable {
    var epoch: Int?
    var totals = TypingStatisticsDelta()
    var daily: [String: TypingStatisticsDelta] = [:]
    var graphemesBySource: [String: Int] = [:]
    var latestDate: Date?
    var flushScheduled = false

    var isEmpty: Bool {
        totals.committedGraphemeCount == 0
    }

    mutating func merge(
        delta: TypingStatisticsDelta,
        source: CommittedTextSource,
        day: String,
        date: Date,
        epoch: Int
    ) {
        if self.epoch != epoch {
            self = Self()
            self.epoch = epoch
        }
        totals += delta
        daily[day, default: TypingStatisticsDelta()] += delta
        graphemesBySource[source.rawValue, default: 0] += delta.committedGraphemeCount
        latestDate = max(latestDate ?? date, date)
    }
}

/// Coalesces content-free deltas and persists them on one utility queue.
/// The committed text itself never enters this type.
@available(macOS 15.0, *)
public final class TypingStatisticsWriter: Sendable {
    private static let maximumDailyBucketCount = 365

    private let queue: DispatchQueue
    private let pending = Mutex(PendingTypingStatisticsBatch())
    private let persistence: TypingStatisticsPersistence
    private let flushDelay: TimeInterval
    private let automaticallySchedulesFlush: Bool

    public init(appGroupID: String, flushDelay: TimeInterval = 1) {
        queue = DispatchQueue(
            label: "com.universekeyboard.typing-intelligence",
            qos: .utility
        )
        persistence = .live(appGroupID: appGroupID)
        self.flushDelay = max(0, flushDelay)
        automaticallySchedulesFlush = true
    }

    init(
        persistence: TypingStatisticsPersistence,
        flushDelay: TimeInterval = 0,
        automaticallySchedulesFlush: Bool = false
    ) {
        queue = DispatchQueue(
            label: "com.universekeyboard.typing-intelligence.tests",
            qos: .utility
        )
        self.persistence = persistence
        self.flushDelay = max(0, flushDelay)
        self.automaticallySchedulesFlush = automaticallySchedulesFlush
    }

    public func record(
        _ delta: TypingStatisticsDelta,
        source: CommittedTextSource,
        at date: Date,
        resetEpoch: Int,
        calendar: Calendar = .current
    ) {
        guard delta.committedGraphemeCount > 0 else { return }
        let day = Self.dayIdentifier(for: date, calendar: calendar)
        let shouldSchedule = pending.withLock { batch in
            batch.merge(
                delta: delta,
                source: source,
                day: day,
                date: date,
                epoch: resetEpoch
            )
            guard !batch.flushScheduled else { return false }
            batch.flushScheduled = true
            return true
        }

        guard shouldSchedule, automaticallySchedulesFlush else { return }
        queue.asyncAfter(deadline: .now() + flushDelay) {
            self.flushPendingBatch()
        }
    }

    public func requestFlush() {
        queue.async {
            self.flushPendingBatch()
        }
    }

    func flushSynchronouslyForTesting() {
        queue.sync {
            flushPendingBatch()
        }
    }

    private func flushPendingBatch() {
        let batch = pending.withLock { pending -> PendingTypingStatisticsBatch in
            let batch = pending
            pending = PendingTypingStatisticsBatch()
            return batch
        }
        guard !batch.isEmpty, let epoch = batch.epoch else { return }
        guard persistence.readEpoch() == epoch else { return }

        let decoder = JSONDecoder()
        let existing = persistence.readSnapshotData().flatMap {
            try? decoder.decode(TypingStatisticsSnapshotV1.self, from: $0)
        }
        let now = batch.latestDate ?? Date()
        var snapshot: TypingStatisticsSnapshotV1
        if let existing,
           existing.version == TypingStatisticsSnapshotV1.schemaVersion,
           existing.resetEpoch == epoch
        {
            snapshot = existing
        } else {
            snapshot = .empty(resetEpoch: epoch, now: now)
        }

        snapshot.totals += batch.totals
        snapshot.updatedAt = max(snapshot.updatedAt, now)
        for (source, count) in batch.graphemesBySource {
            snapshot.graphemesBySource[source, default: 0] += count
        }

        var buckets = Dictionary(
            snapshot.dailyBuckets.map { ($0.day, $0.counts) },
            uniquingKeysWith: { current, additional in
                var merged = current
                merged += additional
                return merged
            }
        )
        for (day, delta) in batch.daily {
            buckets[day, default: TypingStatisticsDelta()] += delta
        }
        snapshot.dailyBuckets = buckets
            .map { TypingStatisticsDailyBucket(day: $0.key, counts: $0.value) }
            .sorted { $0.day < $1.day }
        if snapshot.dailyBuckets.count > Self.maximumDailyBucketCount {
            snapshot.dailyBuckets.removeFirst(
                snapshot.dailyBuckets.count - Self.maximumDailyBucketCount
            )
        }

        guard persistence.readEpoch() == epoch else { return }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        guard persistence.readEpoch() == epoch else { return }
        persistence.writeSnapshotData(data)
    }

    private static func dayIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}
