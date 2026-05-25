import Foundation

/// 统一日志系统。
///
/// - 单例模式：`Logger.shared`
/// - 线程安全：串行 DispatchQueue
/// - 内存环形缓冲（最多 500 条），批量刷新到共享 UserDefaults `rime_diag_log`
/// - 总开关：`logging_enabled`（默认 false，生产级安全）
/// - 格式：`[HH:mm:ss.SSS] [LEVEL] [CATEGORY] message`
public final class Logger: @unchecked Sendable {

    // MARK: - Nested types

    public enum Level: String, Comparable, CaseIterable, Sendable {
        case debug = "DEBUG"
        case info  = "INFO"
        case warning = "WARN"
        case error = "ERROR"

        public static func < (lhs: Level, rhs: Level) -> Bool { lhs._order < rhs._order }
        private var _order: Int {
            switch self {
            case .debug: return 0
            case .info:  return 1
            case .warning: return 2
            case .error: return 3
            }
        }
    }

    public enum Category: String, CaseIterable, Sendable {
        case general     = "GEN"
        case engine      = "ENGINE"
        case config      = "CONFIG"
        case deployment  = "DEPLOY"
        case performance = "PERF"
        case display     = "DISP"
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

    private static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
    public static let logKey = "rime_diag_log"
    public static let toggleKey = "logging_enabled"
    private static let maxEntries = 500
    private static let persistDelay: TimeInterval = 0.2

    // MARK: - Category toggle keys

    /// 每个分类的独立开关 key，存储在 App Group UserDefaults 中。
    /// 这些开关只在总开关 `logging_enabled` 打开后生效。
    public static func categoryToggleKey(for category: Category) -> String {
        "log_category_\(category.rawValue.lowercased())"
    }

    // MARK: - Singleton

    public static let shared = Logger()

    // MARK: - Private state

    private var buffer: [Entry] = []
    private let queue = DispatchQueue(label: "com.universekeyboard.logger", qos: .utility)
    private var pendingPersistWorkItem: DispatchWorkItem?
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    private init() {}

    // MARK: - Public API

    public func debug(_ message: String, category: Category = .general) {
        log(level: .debug, message: message, category: category)
    }

    public func info(_ message: String, category: Category = .general) {
        log(level: .info, message: message, category: category)
    }

    public func warning(_ message: String, category: Category = .general) {
        log(level: .warning, message: message, category: category)
    }

    public func error(_ message: String, category: Category = .general) {
        log(level: .error, message: message, category: category)
    }

    /// 记录性能计时。
    public func performance(_ message: String, durationMs: Double? = nil) {
        let msg: String
        if let d = durationMs {
            msg = "\(message) (\(String(format: "%.1f", d))ms)"
        } else {
            msg = message
        }
        log(level: .info, message: msg, category: .performance)
    }

    /// 日志是否启用。
    public var isEnabled: Bool {
        UserDefaults(suiteName: Self.appGroupID)?.bool(forKey: Self.toggleKey) ?? false
    }

    /// 指定分类的日志是否启用。总开关关闭时所有分类都为 false。
    /// 默认：所有分类都开启（当总开关打开时无需单独启用每个分类）。
    public func isCategoryEnabled(_ category: Category) -> Bool {
        guard isEnabled else { return false }
        let key = Self.categoryToggleKey(for: category)
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        // key 不存在时返回 true（默认全部开启）
        if defaults?.object(forKey: key) == nil { return true }
        return defaults?.bool(forKey: key) ?? true
    }

    /// 强制刷新缓冲到 UserDefaults。
    public func flush() {
        queue.sync {
            pendingPersistWorkItem?.cancel()
            pendingPersistWorkItem = nil
            persistBuffer()
        }
    }

    /// 读取所有缓冲条目（供主 App 诊断显示）。
    public func allLines() -> [String] {
        var lines: [String] = []
        queue.sync { lines = buffer.map(\.description) }
        return lines
    }

    /// 清空内存缓冲和 UserDefaults。
    public func clearAll() {
        queue.async { [weak self] in
            guard let self else { return }
            self.pendingPersistWorkItem?.cancel()
            self.pendingPersistWorkItem = nil
            self.buffer.removeAll()
            let defaults = UserDefaults(suiteName: Self.appGroupID)
            defaults?.removeObject(forKey: Self.logKey)
            defaults?.removeObject(forKey: "rime_diag_summary")
            defaults?.synchronize()
        }
    }

    // MARK: - Private

    private func log(level: Level, message: String, category: Category) {
        guard isCategoryEnabled(category) else { return }

        let date = Date()

        queue.async { [weak self] in
            guard let self else { return }
            let entry = Entry(
                timestamp: self.dateFormatter.string(from: date),
                level: level,
                category: category,
                message: message
            )
            self.buffer.append(entry)
            if self.buffer.count > Self.maxEntries {
                self.buffer.removeFirst(self.buffer.count - Self.maxEntries)
            }
            if level == .error {
                self.pendingPersistWorkItem?.cancel()
                self.pendingPersistWorkItem = nil
                self.persistBuffer()
            } else {
                self.schedulePersist()
            }
        }
    }

    /// 合并高频键入期间的写入，避免诊断日志反过来阻塞输入主线程。
    /// 该 work item 在独立队列运行，即使 UI/RIME 调用卡住，也会将此前的 BEGIN 记录写出。
    private func schedulePersist() {
        pendingPersistWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.pendingPersistWorkItem = nil
            self.persistBuffer()
        }
        pendingPersistWorkItem = workItem
        queue.asyncAfter(deadline: .now() + Self.persistDelay, execute: workItem)
    }

    private func persistBuffer() {
        let lines = buffer.map(\.description)
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        defaults?.set(lines.joined(separator: "\n"), forKey: Self.logKey)
        if let last = lines.last {
            defaults?.set(last, forKey: "rime_diag_summary")
        }
        defaults?.synchronize()
    }
}
