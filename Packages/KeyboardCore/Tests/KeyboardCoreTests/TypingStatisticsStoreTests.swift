import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

private struct InMemoryTypingPersistenceState: Sendable {
    var epoch = 0
    var data: Data?
}

@available(macOS 15.0, *)
private final class InMemoryTypingPersistence: Sendable {
    private let state = Mutex(InMemoryTypingPersistenceState())

    var epoch: Int {
        get { state.withLock { $0.epoch } }
        set { state.withLock { $0.epoch = newValue } }
    }

    var data: Data? {
        get { state.withLock { $0.data } }
        set { state.withLock { $0.data = newValue } }
    }

    var configuration: TypingStatisticsPersistence {
        TypingStatisticsPersistence(
            readEpoch: { self.epoch },
            readSnapshotData: { self.data },
            writeSnapshotData: { self.data = $0 }
        )
    }
}

@available(macOS 15.0, *)
final class TypingStatisticsWriterTests: XCTestCase {
    func testWriterCoalescesDeltasIntoOneBoundedSnapshot() throws {
        let persistence = InMemoryTypingPersistence()
        let writer = makeWriter(persistence: persistence)
        let date = try XCTUnwrap(utcCalendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 11,
            hour: 12
        )))

        writer.record(
            TypingStatisticsClassifier.classify("你好"),
            source: .candidate,
            at: date,
            resetEpoch: 0,
            calendar: utcCalendar
        )
        writer.record(
            TypingStatisticsClassifier.classify(" A"),
            source: .key,
            at: date,
            resetEpoch: 0,
            calendar: utcCalendar
        )
        writer.flushSynchronouslyForTesting()

        let snapshot = try decodedSnapshot(from: persistence)
        XCTAssertEqual(snapshot.totals.committedGraphemeCount, 4)
        XCTAssertEqual(snapshot.totals.cjkCharacterCount, 2)
        XCTAssertEqual(snapshot.totals.latinLetterCount, 1)
        XCTAssertEqual(snapshot.totals.whitespaceCount, 1)
        XCTAssertEqual(snapshot.dailyBuckets.map(\.day), ["2026-07-11"])
        XCTAssertEqual(snapshot.graphemesBySource[CommittedTextSource.candidate.rawValue], 2)
        XCTAssertEqual(snapshot.graphemesBySource[CommittedTextSource.key.rawValue], 2)
        let persistedJSON = String(data: try XCTUnwrap(persistence.data), encoding: .utf8)
        XCTAssertFalse(try XCTUnwrap(persistedJSON).contains("你好"))
        XCTAssertFalse(try XCTUnwrap(persistedJSON).contains(" A"))
    }

    func testResetEpochRejectsAStaleQueuedBatch() {
        let persistence = InMemoryTypingPersistence()
        let writer = makeWriter(persistence: persistence, flushDelay: 60)

        writer.record(
            TypingStatisticsClassifier.classify("private text is not persisted"),
            source: .key,
            at: Date(),
            resetEpoch: 0
        )
        persistence.epoch = 1
        writer.flushSynchronouslyForTesting()

        XCTAssertNil(persistence.data)
    }

    func testWriterKeepsOnlyMostRecent365DailyBuckets() {
        let persistence = InMemoryTypingPersistence()
        let writer = makeWriter(persistence: persistence, flushDelay: 60)
        let start = Date(timeIntervalSince1970: 0)

        for offset in 0..<366 {
            let date = utcCalendar.date(byAdding: .day, value: offset, to: start)!
            writer.record(
                TypingStatisticsClassifier.classify("a"),
                source: .key,
                at: date,
                resetEpoch: 0,
                calendar: utcCalendar
            )
        }
        writer.flushSynchronouslyForTesting()

        let snapshot = try! decodedSnapshot(from: persistence)
        XCTAssertEqual(snapshot.dailyBuckets.count, 365)
        XCTAssertEqual(snapshot.totals.committedGraphemeCount, 366)
        XCTAssertEqual(snapshot.dailyBuckets.first?.day, "1970-01-02")
    }

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func makeWriter(
        persistence: InMemoryTypingPersistence,
        flushDelay: TimeInterval = 0
    ) -> TypingStatisticsWriter {
        TypingStatisticsWriter(
            persistence: persistence.configuration,
            flushDelay: flushDelay,
            automaticallySchedulesFlush: false
        )
    }

    private func decodedSnapshot(
        from persistence: InMemoryTypingPersistence
    ) throws -> TypingStatisticsSnapshotV1 {
        let data = try XCTUnwrap(persistence.data)
        return try JSONDecoder().decode(TypingStatisticsSnapshotV1.self, from: data)
    }
}

@MainActor
final class TypingStatisticsStoreTests: XCTestCase {
    func testCollectionIsDisabledByDefaultAndResetAdvancesEpoch() {
        let suiteName = "TypingStatisticsStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = TypingStatisticsStore(defaults: defaults)

        XCTAssertFalse(store.isEnabled)
        XCTAssertEqual(store.resetEpoch, 0)

        store.setEnabled(true)
        store.reset()

        XCTAssertTrue(store.isEnabled)
        XCTAssertEqual(store.resetEpoch, 1)
        XCTAssertEqual(store.snapshot().resetEpoch, 1)
        XCTAssertEqual(store.snapshot().totals.committedGraphemeCount, 0)
    }

    func testCorruptedPayloadIsReportedInsteadOfPresentedAsEmpty() {
        let suiteName = "TypingStatisticsStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(Data("not-json".utf8), forKey: TypingStatisticsStorageKey.snapshotV1)
        let store = TypingStatisticsStore(defaults: defaults)

        XCTAssertEqual(store.loadState(), .corrupted)
    }
}
