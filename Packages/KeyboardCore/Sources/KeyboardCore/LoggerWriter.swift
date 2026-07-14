import Foundation

struct LoggerPersistence: Sendable {
    let isCategoryEnabled: @Sendable (Logger.Category) -> Bool
    let readLines: @Sendable () -> [String]
    let persist: @Sendable (_ lines: [String], _ summary: String?) -> Void
    let clear: @Sendable () -> Void

    static let live = LoggerPersistence(
        isCategoryEnabled: { category in
            Logger.isLiveCategoryEnabled(category)
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

private struct BufferedLoggerRecord: Sendable {
    let timestamp: Date
    let level: Logger.Level
    let category: Logger.Category
    let message: String
}

enum LoggerWriterCommand: Sendable {
    case record(timestamp: Date, level: Logger.Level, category: Logger.Category, message: String)
    case requestFlush
    case suspendPersistence(@Sendable () -> Void)
    case resumePersistence(@Sendable () -> Void)
    case clear
    case snapshot(CheckedContinuation<LoggerWriterSnapshot, Never>)
}

private actor LoggerWriterWorker {
    /// Diagnostics are best-effort. A short delay coalesces rapid key-path events,
    /// while the batch limit prevents an enabled verbose session from growing
    /// without bound before persistence catches up.
    private static let flushDelay: TimeInterval = 0.25
    private static let maximumPendingRecordCount = 32

    private let configuration: LoggerWriterConfiguration
    private var records: [BufferedLoggerRecord] = []
    private var flushScheduled = false
    private var flushGeneration = 0
    private var isPersistenceSuspended = false

    init(configuration: LoggerWriterConfiguration) {
        self.configuration = configuration
    }

    func execute(_ command: LoggerWriterCommand) {
        switch command {
        case let .record(timestamp, level, category, message):
            guard !isPersistenceSuspended else { return }
            guard configuration.persistence.isCategoryEnabled(category) else { return }
            records.append(
                BufferedLoggerRecord(
                    timestamp: timestamp,
                    level: level,
                    category: category,
                    message: message
                )
            )
            if records.count >= Self.maximumPendingRecordCount {
                flushPendingRecords()
            } else {
                scheduleFlushIfNeeded()
            }
        case .requestFlush:
            // All earlier AsyncStream elements have already entered this actor.
            if isPersistenceSuspended {
                discardPendingRecords()
            } else {
                flushPendingRecords()
            }
        case .suspendPersistence(let completion):
            // Visibility suspension must leave no delayed App Group write behind.
            // Earlier commands have completed because this stream is ordered.
            discardPendingRecords()
            isPersistenceSuspended = true
            completion()
        case .resumePersistence(let completion):
            isPersistenceSuspended = false
            completion()
        case .clear:
            records.removeAll(keepingCapacity: true)
            invalidateScheduledFlush()
            configuration.persistence.clear()
        case .snapshot(let continuation):
            if isPersistenceSuspended {
                discardPendingRecords()
            } else {
                flushPendingRecords()
            }
            continuation.resume(
                returning: LoggerWriterSnapshot(
                    persistedLines: configuration.persistence.readLines()
                )
            )
        }
    }

    private func flushPendingRecords() {
        let pendingRecords = records
        records.removeAll(keepingCapacity: true)
        invalidateScheduledFlush()
        guard !pendingRecords.isEmpty else { return }

        // One formatter and one store read/write serve the whole batch.
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let newLines = pendingRecords.map { record in
            Logger.Entry(
                timestamp: formatter.string(from: record.timestamp),
                level: record.level,
                category: record.category,
                message: record.message
            ).description
        }

        var lines = configuration.persistence.readLines()
        lines.append(contentsOf: newLines)
        if lines.count > configuration.maxEntries {
            lines.removeFirst(lines.count - configuration.maxEntries)
        }
        configuration.persistence.persist(lines, lines.last)
    }

    private func scheduleFlushIfNeeded() {
        guard !isPersistenceSuspended else { return }
        guard !flushScheduled else { return }
        flushScheduled = true
        flushGeneration &+= 1
        let generation = flushGeneration
        let nanoseconds = UInt64(Self.flushDelay * 1_000_000_000)
        Task(priority: .utility) {
            try? await Task.sleep(nanoseconds: nanoseconds)
            self.flushIfStillScheduled(generation: generation)
        }
    }

    private func flushIfStillScheduled(generation: Int) {
        guard !isPersistenceSuspended, flushScheduled, generation == flushGeneration else { return }
        flushPendingRecords()
    }

    private func discardPendingRecords() {
        records.removeAll(keepingCapacity: true)
        invalidateScheduledFlush()
    }

    private func invalidateScheduledFlush() {
        flushScheduled = false
        flushGeneration &+= 1
    }
}

final class LoggerWriterHandle: Sendable {
    typealias Command = LoggerWriterCommand

    private let continuation: AsyncStream<LoggerWriterCommand>.Continuation

    init(configuration: LoggerWriterConfiguration) {
        let (stream, continuation) = AsyncStream<LoggerWriterCommand>.makeStream()
        self.continuation = continuation
        let worker = LoggerWriterWorker(configuration: configuration)
        Task.detached(priority: .utility) {
            for await command in stream {
                await worker.execute(command)
            }
        }
    }

    deinit {
        continuation.finish()
    }

    /// AsyncStream preserves submission order and returns immediately to UI callers.
    func submit(_ command: Command) {
        continuation.yield(command)
    }

    /// Lifecycle-only ordered barrier. It may wait for an earlier persistence call,
    /// but is never used on the key-input hot path.
    func suspendPersistence() {
        let completion = DispatchSemaphore(value: 0)
        continuation.yield(.suspendPersistence { completion.signal() })
        completion.wait()
    }

    func resumePersistence() {
        let completion = DispatchSemaphore(value: 0)
        continuation.yield(.resumePersistence { completion.signal() })
        completion.wait()
    }

    /// Test-only ordered barrier that observes all commands submitted before it.
    func snapshot() async -> LoggerWriterSnapshot {
        await withCheckedContinuation { snapshotContinuation in
            continuation.yield(.snapshot(snapshotContinuation))
        }
    }
}
