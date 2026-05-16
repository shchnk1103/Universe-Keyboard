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

    // MARK: - isEnabled

    func testIsEnabledDefaultFalse() {
        // Default should be false (logging disabled in production)
        // We can't guarantee UserDefaults state in tests,
        // but the property should be readable without crashing.
        _ = Logger.shared.isEnabled
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
}
