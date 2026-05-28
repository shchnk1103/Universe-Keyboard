import XCTest

@testable import KeyboardCore

final class LoggerTests: XCTestCase {

    // MARK: - Entry format

    func testEntryFormat() {
        let entry = Logger.Entry(
            timestamp: "12:30:00",
            level: .info,
            category: .engine,
            message: "test message"
        )
        let desc = entry.description
        XCTAssertTrue(desc.contains("[12:30:00]"))
        XCTAssertTrue(desc.contains("[INFO]"))
        XCTAssertTrue(desc.contains("[ENGINE]"))
        XCTAssertTrue(desc.contains("test message"))
    }

    // MARK: - Log levels

    func testLevelOrder() {
        XCTAssertLessThan(Logger.Level.debug, Logger.Level.info)
        XCTAssertLessThan(Logger.Level.info, Logger.Level.warning)
        XCTAssertLessThan(Logger.Level.warning, Logger.Level.error)
    }

    func testAllLevelsHaveRawValues() {
        for level in Logger.Level.allCases {
            XCTAssertFalse(level.rawValue.isEmpty)
        }
    }

    // MARK: - Categories

    func testAllCategoriesHaveRawValues() {
        for category in Logger.Category.allCases {
            XCTAssertFalse(category.rawValue.isEmpty)
        }
    }

    // MARK: - Singleton

    func testSingleton() {
        let a = Logger.shared
        let b = Logger.shared
        XCTAssertTrue(a === b)
    }

    // MARK: - Entry Sendable conformance

    func testEntryIsSendable() {
        let entry = Logger.Entry(
            timestamp: "00:00:00",
            level: .debug,
            category: .general,
            message: "sendable test"
        )
        // Compile-time check: Entry conforms to Sendable
        let _: any Sendable = entry
    }

    func testLoggerIsSendable() {
        let _: any Sendable = Logger.shared
    }

    // MARK: - Ordered writer

    func testFlushPersistsRecordsInSubmissionOrder() {
        let logger = makeLogger()

        logger.debug("BEGIN", category: .engine)
        logger.debug("END", category: .engine)
        logger.requestFlush()

        let snapshot = logger.snapshotForTesting()
        XCTAssertEqual(snapshot.persistedLines.count, 2)
        XCTAssertTrue(snapshot.persistedLines[0].hasSuffix("BEGIN"))
        XCTAssertTrue(snapshot.persistedLines[1].hasSuffix("END"))
    }

    func testWriterFiltersCategoriesAndKeepsRingBufferBounded() {
        let logger = makeLogger(maxEntries: 2) { category in
            category != .config
        }

        logger.info("hidden", category: .config)
        logger.info("first", category: .engine)
        logger.info("second", category: .engine)
        logger.info("third", category: .engine)
        logger.requestFlush()

        let snapshot = logger.snapshotForTesting()
        XCTAssertEqual(snapshot.persistedLines.count, 2)
        XCTAssertFalse(snapshot.persistedLines.joined().contains("hidden"))
        XCTAssertFalse(snapshot.persistedLines.joined().contains("first"))
        XCTAssertTrue(snapshot.persistedLines[0].hasSuffix("second"))
        XCTAssertTrue(snapshot.persistedLines[1].hasSuffix("third"))
    }

    func testRequestFlushDoesNotWaitForBlockedPersistence() {
        let persistenceStarted = DispatchSemaphore(value: 0)
        let allowPersistenceToFinish = DispatchSemaphore(value: 0)
        let suiteName = "LoggerTests.blocked.\(UUID().uuidString)"
        let logger = Logger(
            configuration: LoggerWriterConfiguration(
                persistence: LoggerPersistence(
                    isCategoryEnabled: { _ in true },
                    readLines: {
                        let text = UserDefaults(suiteName: suiteName)?.string(forKey: Logger.logKey) ?? ""
                        return text.isEmpty ? [] : text.components(separatedBy: "\n")
                    },
                    persist: { lines, _ in
                        UserDefaults(suiteName: suiteName)?
                            .set(lines.joined(separator: "\n"), forKey: Logger.logKey)
                        persistenceStarted.signal()
                        allowPersistenceToFinish.wait()
                    },
                    clear: {}
                )
            )
        )
        defer { UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName) }

        logger.info("event", category: .performance)
        let start = ContinuousClock.now
        logger.requestFlush()
        let submitDuration = start.duration(to: .now)

        XCTAssertLessThan(submitDuration, .milliseconds(50))
        XCTAssertEqual(persistenceStarted.wait(timeout: .now() + 1), .success)
        allowPersistenceToFinish.signal()
        let snapshot = logger.snapshotForTesting()
        XCTAssertTrue(snapshot.persistedLines[0].hasSuffix("event"))
    }

    private func makeLogger(
        maxEntries: Int = 500,
        isCategoryEnabled: @escaping @Sendable (Logger.Category) -> Bool = { _ in true }
    ) -> Logger {
        let suiteName = "LoggerTests.\(UUID().uuidString)"
        return Logger(
            configuration: LoggerWriterConfiguration(
                maxEntries: maxEntries,
                persistence: LoggerPersistence(
                    isCategoryEnabled: isCategoryEnabled,
                    readLines: {
                        let text = UserDefaults(suiteName: suiteName)?.string(forKey: Logger.logKey) ?? ""
                        return text.isEmpty ? [] : text.components(separatedBy: "\n")
                    },
                    persist: { lines, summary in
                        let defaults = UserDefaults(suiteName: suiteName)
                        defaults?.set(lines.joined(separator: "\n"), forKey: Logger.logKey)
                        defaults?.set(summary, forKey: "rime_diag_summary")
                    },
                    clear: {
                        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
                    }
                )
            )
        )
    }
}
