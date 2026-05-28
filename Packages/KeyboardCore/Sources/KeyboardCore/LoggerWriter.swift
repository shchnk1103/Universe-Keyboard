import Foundation

struct LoggerPersistence: Sendable {
    let isCategoryEnabled: @Sendable (Logger.Category) -> Bool
    let readLines: @Sendable () -> [String]
    let persist: @Sendable (_ lines: [String], _ summary: String?) -> Void
    let clear: @Sendable () -> Void

    static let live = LoggerPersistence(
        isCategoryEnabled: { category in
            let defaults = UserDefaults(suiteName: Logger.appGroupID)
            guard defaults?.bool(forKey: Logger.toggleKey) ?? false else { return false }
            let key = Logger.categoryToggleKey(for: category)
            guard defaults?.object(forKey: key) != nil else { return true }
            return defaults?.bool(forKey: key) ?? true
        },
        readLines: {
            let text = UserDefaults(suiteName: Logger.appGroupID)?.string(forKey: Logger.logKey) ?? ""
            return text.isEmpty ? [] : text.components(separatedBy: "\n")
        },
        persist: { lines, summary in
            let defaults = UserDefaults(suiteName: Logger.appGroupID)
            defaults?.set(lines.joined(separator: "\n"), forKey: Logger.logKey)
            if let summary {
                defaults?.set(summary, forKey: "rime_diag_summary")
            } else {
                defaults?.removeObject(forKey: "rime_diag_summary")
            }
            defaults?.synchronize()
        },
        clear: {
            let defaults = UserDefaults(suiteName: Logger.appGroupID)
            defaults?.removeObject(forKey: Logger.logKey)
            defaults?.removeObject(forKey: "rime_diag_summary")
            defaults?.synchronize()
        }
    )
}

struct LoggerWriterConfiguration: Sendable {
    let maxEntries: Int
    let persistence: LoggerPersistence

    init(maxEntries: Int = 500, persistence: LoggerPersistence) {
        self.maxEntries = maxEntries
        self.persistence = persistence
    }

    static let live = LoggerWriterConfiguration(persistence: .live)
}

struct LoggerWriterSnapshot: Sendable {
    let persistedLines: [String]
}

struct LoggerWriterHandle: Sendable {
    enum Command: Sendable {
        case record(timestamp: Date, level: Logger.Level, category: Logger.Category, message: String)
        case requestFlush
        case clear
    }

    private let queue = DispatchQueue(label: "com.universekeyboard.logger", qos: .utility)
    private let configuration: LoggerWriterConfiguration

    init(configuration: LoggerWriterConfiguration) {
        self.configuration = configuration
    }

    /// All production commands enter the same FIFO queue and return immediately.
    func submit(_ command: Command) {
        queue.async {
            execute(command)
        }
    }

    /// Only test support waits for the FIFO queue to drain before observing persisted data.
    func snapshot() -> LoggerWriterSnapshot {
        queue.sync {
            LoggerWriterSnapshot(persistedLines: configuration.persistence.readLines())
        }
    }

    private func execute(_ command: Command) {
        switch command {
        case let .record(timestamp, level, category, message):
            guard configuration.persistence.isCategoryEnabled(category) else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            let entry = Logger.Entry(
                timestamp: formatter.string(from: timestamp),
                level: level,
                category: category,
                message: message
            )
            var lines = configuration.persistence.readLines()
            lines.append(entry.description)
            if lines.count > configuration.maxEntries {
                lines.removeFirst(lines.count - configuration.maxEntries)
            }
            configuration.persistence.persist(lines, lines.last)
        case .requestFlush:
            // Previous FIFO commands have already persisted before this barrier executes.
            break
        case .clear:
            configuration.persistence.clear()
        }
    }
}
