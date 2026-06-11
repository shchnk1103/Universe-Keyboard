import Foundation

/// Lightweight diagnostic facade for keyboard and deployment event logging.
///
/// Callers only enqueue immutable events. Filtering, buffering and persistence
/// are owned by one ordered background writer so the input path never reads
/// shared preferences or waits for disk-backed defaults.
public final class Logger: Sendable {

    // MARK: - Nested types

    public enum Level: String, Comparable, CaseIterable, Sendable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"

        public static func < (lhs: Level, rhs: Level) -> Bool { lhs.order < rhs.order }

        private var order: Int {
            switch self {
            case .debug: return 0
            case .info: return 1
            case .warning: return 2
            case .error: return 3
            }
        }
    }

    public enum Category: String, CaseIterable, Sendable {
        case general = "GEN"
        case engine = "ENGINE"
        case config = "CONFIG"
        case deployment = "DEPLOY"
        case performance = "PERF"
        case display = "DISP"
    }

    public struct Entry: CustomStringConvertible, Sendable {
        public let timestamp: String
        public let level: Level
        public let category: Category
        public let message: String

        public var description: String {
            "[\(timestamp)] [\(level.rawValue)] [\(category.rawValue)] \(message)"
        }
    }

    // MARK: - Constants

    static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
    public static let logKey = "rime_diag_log"
    public static let toggleKey = "logging_enabled"

    /// Category key stored in the App Group preferences. It is read only by the writer.
    public static func categoryToggleKey(for category: Category) -> String {
        "log_category_\(category.rawValue.lowercased())"
    }

    /// Returns the live App Group logging state for a category.
    ///
    /// This is intentionally separate from `Logger.shared.record`: hot UI probes can
    /// skip building diagnostic strings when the diagnostics app has logging disabled.
    public static func isLiveCategoryEnabled(_ category: Category) -> Bool {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard defaults?.bool(forKey: toggleKey) ?? false else { return false }
        let key = categoryToggleKey(for: category)
        guard defaults?.object(forKey: key) != nil else { return true }
        return defaults?.bool(forKey: key) ?? true
    }

    // MARK: - Lifetime

    public static let shared = Logger()

    private let writer: LoggerWriterHandle

    private init() {
        writer = LoggerWriterHandle(configuration: .live)
    }

    init(configuration: LoggerWriterConfiguration) {
        writer = LoggerWriterHandle(configuration: configuration)
    }

    // MARK: - Public API

    public func debug(_ message: String, category: Category = .general) {
        record(level: .debug, message: message, category: category)
    }

    public func info(_ message: String, category: Category = .general) {
        record(level: .info, message: message, category: category)
    }

    public func warning(_ message: String, category: Category = .general) {
        record(level: .warning, message: message, category: category)
    }

    public func error(_ message: String, category: Category = .general) {
        record(level: .error, message: message, category: category)
    }

    public func performance(_ message: String, durationMs: Double? = nil) {
        let message =
            if let durationMs {
                "\(message) (\(String(format: "%.1f", durationMs))ms)"
            } else {
                message
            }
        record(level: .info, message: message, category: .performance)
    }

    /// Requests background persistence after all events already submitted to the writer.
    ///
    /// The method intentionally does not promise synchronous durability: keyboard UI
    /// callbacks must not wait for App Group persistence.
    public func requestFlush() {
        writer.submit(.requestFlush)
    }

    /// Submits a non-blocking clear request. The diagnostics app reads the persisted store.
    public func clearAll() {
        writer.submit(.clear)
    }

    // MARK: - Test support

    func snapshotForTesting() -> LoggerWriterSnapshot {
        writer.snapshot()
    }

    // MARK: - Private

    private func record(level: Level, message: String, category: Category) {
        writer.submit(
            .record(
                timestamp: Date(),
                level: level,
                category: category,
                message: message
            )
        )
    }
}
