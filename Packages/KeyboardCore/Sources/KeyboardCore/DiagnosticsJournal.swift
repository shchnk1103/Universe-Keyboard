import Darwin
import Foundation

/// `Diagnostics/v1/control.json` 的最小跨进程控制面。
/// 只有 Main App 能创建和推进它；writer 每个后台批次重新读取 generation，
/// 因而旧 writer 即使完成一个已开始的批次，也不会使已清空的数据重新可见。
public struct DiagnosticsJournalControl: Codable, Equatable, Sendable {
    public static let schemaVersion = 1

    public let schemaVersion: Int
    public let currentGeneration: UInt64

    public init(currentGeneration: UInt64) {
        schemaVersion = Self.schemaVersion
        self.currentGeneration = currentGeneration
    }
}

/// 某一 writer 对当前 generation 的短租约。它不是进程存活证明；Main App
/// 只能在持有同一 identity 的 advisory lock 后，结合过期时间决定是否尝试回收。
public struct DiagnosticsJournalLease: Codable, Equatable, Sendable {
    public static let schemaVersion = 1

    public let schemaVersion: Int
    public let generation: UInt64
    public let origin: DiagnosticEvent.Origin
    public let processInstanceID: UUID
    public let fence: UInt64
    public let renewedAt: Date
    public let expiresAt: Date

    public init(
        generation: UInt64,
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID,
        fence: UInt64,
        renewedAt: Date,
        expiresAt: Date
    ) {
        schemaVersion = Self.schemaVersion
        self.generation = generation
        self.origin = origin
        self.processInstanceID = processInstanceID
        self.fence = fence
        self.renewedAt = renewedAt
        self.expiresAt = expiresAt
    }
}

/// 回收器写入的不可覆盖墓碑。writer 在每次 append 前检查它，避免一个已被
/// 回收的旧进程在恢复后重新建立 lease 或继续向旧段追加。
public struct DiagnosticsJournalTombstone: Codable, Equatable, Sendable {
    public static let schemaVersion = 1

    public let schemaVersion: Int
    public let generation: UInt64
    public let origin: DiagnosticEvent.Origin
    public let processInstanceID: UUID
    public let fence: UInt64
    public let reclaimedAt: Date
    public let reason: Reason

    public enum Reason: String, Codable, Equatable, Sendable {
        case expiredLease
        case supersededGeneration
        case retentionAge
        case retentionCapacity
    }

    public init(
        generation: UInt64,
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID,
        fence: UInt64,
        reclaimedAt: Date,
        reason: Reason
    ) {
        schemaVersion = Self.schemaVersion
        self.generation = generation
        self.origin = origin
        self.processInstanceID = processInstanceID
        self.fence = fence
        self.reclaimedAt = reclaimedAt
        self.reason = reason
    }
}

public enum DiagnosticsJournalError: Error, Equatable, Sendable {
    case rootUnavailable
    case controlUnavailable
    case unsupportedControlVersion(Int)
    case invalidControl
    case writerIdentityMismatch
    case writerReclaimed
    case lifecycleCancelled
    case lockBusy
    case lockUnavailable
    case writeFailed
}

/// 主 App 查询当前 generation 时的不可变水位。UI 可以在这个快照上筛选、
/// 搜索和复制，而不会把之后到达的事件混进本次导出。
public struct DiagnosticsJournalSnapshot: Sendable {
    public let generation: UInt64
    public let events: [DiagnosticEvent]

    public init(generation: UInt64, events: [DiagnosticEvent]) {
        self.generation = generation
        self.events = events
    }
}

/// 一次查询的不可伪造 continuation。它只在 reader actor 的内存中索引已冻结的
/// segment watermark，不把路径或自由文本暴露给 UI，也不会跨进程持久化。
public struct DiagnosticsJournalPageCursor: Hashable, Sendable {
    fileprivate let queryID: UUID
}

/// 按“最新优先”返回的一页事件。分页起点固定在一次目录快照，后续 append
/// 不会悄悄混入当前查询；新事件会在下一次 begin query 的实时刷新中出现。
public struct DiagnosticsJournalPage: Sendable {
    public let generation: UInt64
    public let events: [DiagnosticEvent]
    public let nextCursor: DiagnosticsJournalPageCursor?

    public init(
        generation: UInt64,
        events: [DiagnosticEvent],
        nextCursor: DiagnosticsJournalPageCursor?
    ) {
        self.generation = generation
        self.events = events
        self.nextCursor = nextCursor
    }
}

/// 每个 process 独占自己的 JSONL 段。这个 actor 只在 utility writer 调用；
/// 键盘热路径必须只把 `DiagnosticEvent` 投递给上层有界队列。
public actor DiagnosticsJournalWriter {
    public static let segmentSizeLimitBytes = 1_024 * 1_024
    public static let leaseDuration: TimeInterval = 90

    private let rootURL: URL
    private let origin: DiagnosticEvent.Origin
    private var processInstanceID: UUID
    private let isMainAppWriter: Bool

    private var activeHour = ""
    private var activePart = 0
    private var activeByteCount = 0
    private var activeGeneration: UInt64?
    private var leaseFence: UInt64 = 0

    public init(
        rootURL: URL,
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID = UUID(),
        isMainAppWriter: Bool
    ) {
        self.rootURL = rootURL
        self.origin = origin
        self.processInstanceID = processInstanceID
        self.isMainAppWriter = isMainAppWriter
    }

    /// Main App 在 migration/首次写入前调用。Extension 永远不得借此创建根目录。
    public func prepareRootIfOwnedByMainApp() throws {
        guard isMainAppWriter else { throw DiagnosticsJournalError.rootUnavailable }
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)

        let controlURL = rootURL.appendingPathComponent("control.json")
        guard !FileManager.default.fileExists(atPath: controlURL.path) else { return }
        try writeControl(DiagnosticsJournalControl(currentGeneration: 1))
    }

    /// 清空先推进 generation；旧 generation 不会被新的 reader 查询。
    /// 清理旧段与 reclaim fence 由后续 Main-App retention coordinator 负责。
    @discardableResult
    public func advanceGenerationForClear() throws -> UInt64 {
        guard isMainAppWriter else { throw DiagnosticsJournalError.rootUnavailable }
        return try withExclusiveWriterLock { [self] in
            let current = try readControl()
            let next = current.currentGeneration == UInt64.max ? 1 : current.currentGeneration + 1

            // 当前 writer 自己持有同一 identity lock，因此这里可以把已经关闭的
            // open 段先封存，再推进 generation。这样保留策略永远不需要直接删除它。
            try sealActiveSegment()
            try writeControl(DiagnosticsJournalControl(currentGeneration: next))
            resetActiveSegment()
            return next
        }
    }

    /// 将一个已经完成隐私审查的有限批追加到当前 process 的独占段。
    /// 调用方必须保证 batch 不是无限积压的热路径工作。
    public func append(
        _ events: [DiagnosticEvent],
        isWritePermitted: @escaping @Sendable () -> Bool = { true }
    ) throws {
        guard !events.isEmpty else { return }
        guard events.allSatisfy({ $0.origin == origin }) else {
            throw DiagnosticsJournalError.writerIdentityMismatch
        }
        let normalizedEvents = events.map { event in
            DiagnosticEvent(
                utcTimestamp: event.utcTimestamp,
                monotonicNanoseconds: event.monotonicNanoseconds,
                origin: origin,
                processInstanceID: processInstanceID,
                localSequence: event.localSequence,
                appearanceID: event.appearanceID,
                actionSequence: event.actionSequence,
                code: event.code,
                level: event.level,
                category: event.category,
                fields: event.fields
            )
        }
        let hour = Self.hourStamp(for: normalizedEvents[0].utcTimestamp)
        let encodedLines = try normalizedEvents.map(Self.encodeLine)
        let byteCount = encodedLines.reduce(0) { $0 + $1.count }

        try withExclusiveWriterLock { [self] in
            // 生命周期的线性化点必须在实际取得 identity lock 之后。这样 suspend
            // 只能二选一：阻止本批进入 I/O，或让已开始的 lock-bound 批完成。
            guard isWritePermitted() else {
                throw DiagnosticsJournalError.lifecycleCancelled
            }
            // 必须在 lock 内重读 generation：clear 可以发生在上个批次之后。
            let control = try readControl()
            let requiresRotation =
                activeByteCount > 0
                && (activeGeneration != control.currentGeneration
                    || activeHour != hour
                    || activeByteCount + byteCount > Self.segmentSizeLimitBytes)
            if requiresRotation {
                try sealActiveSegment()
                activeByteCount = 0
                if activeHour != hour || activeGeneration != control.currentGeneration {
                    activeHour = hour
                    activePart = 0
                } else {
                    activePart += 1
                }
            }
            if activeByteCount == 0 {
                activeGeneration = control.currentGeneration
                activeHour = hour
            }
            let generationDirectory = rootURL.appendingPathComponent(
                "g\(control.currentGeneration)",
                isDirectory: true
            )
            try rejectReclaimedWriter(in: generationDirectory)
            try renewLease(for: control, in: generationDirectory)
            let openDirectory = generationDirectory.appendingPathComponent("open", isDirectory: true)
            do {
                try FileManager.default.createDirectory(at: openDirectory, withIntermediateDirectories: true)
                let segmentURL = openDirectory.appendingPathComponent(segmentFileName(hour: hour))
                if !FileManager.default.fileExists(atPath: segmentURL.path) {
                    FileManager.default.createFile(atPath: segmentURL.path, contents: nil)
                }
                let handle = try FileHandle(forWritingTo: segmentURL)
                defer { try? handle.close() }
                try handle.seekToEnd()
                for line in encodedLines {
                    try handle.write(contentsOf: line)
                }
                activeByteCount += byteCount
            } catch {
                throw DiagnosticsJournalError.writeFailed
            }
        }
    }

    /// reclaim tombstone 属于旧逻辑 writer identity；同一 Extension process 恢复时
    /// 必须生成新 identity，绝不删除或复用墓碑。
    public func rotateIdentityAfterReclaim() {
        processInstanceID = UUID()
        leaseFence = 0
        resetActiveSegment()
    }

    private func readControl() throws -> DiagnosticsJournalControl {
        let controlURL = rootURL.appendingPathComponent("control.json")
        guard FileManager.default.fileExists(atPath: controlURL.path) else {
            throw DiagnosticsJournalError.controlUnavailable
        }
        guard let data = try? Data(contentsOf: controlURL),
            let control = try? JSONDecoder().decode(DiagnosticsJournalControl.self, from: data)
        else {
            throw DiagnosticsJournalError.invalidControl
        }
        guard control.schemaVersion == DiagnosticsJournalControl.schemaVersion else {
            throw DiagnosticsJournalError.unsupportedControlVersion(control.schemaVersion)
        }
        return control
    }

    private func writeControl(_ control: DiagnosticsJournalControl) throws {
        let controlURL = rootURL.appendingPathComponent("control.json")
        do {
            let data = try JSONEncoder().encode(control)
            try data.write(to: controlURL, options: .atomic)
        } catch {
            throw DiagnosticsJournalError.writeFailed
        }
    }

    private func segmentFileName(hour: String) -> String {
        "\(origin.rawValue)-\(processInstanceID.uuidString)-\(hour)-\(activePart).jsonl"
    }

    private func resetActiveSegment() {
        activeHour = ""
        activePart = 0
        activeByteCount = 0
        activeGeneration = nil
    }

    /// writer 没有跨 batch 持有文件句柄，因此在同一 identity lock 内移动旧段即可
    /// 形成明确的关闭边界。只有 sealed 段可被正常 retention 删除。
    private func sealActiveSegment() throws {
        guard let activeGeneration, !activeHour.isEmpty else { return }
        let generationDirectory = rootURL.appendingPathComponent(
            "g\(activeGeneration)",
            isDirectory: true
        )
        let openURL =
            generationDirectory
            .appendingPathComponent("open", isDirectory: true)
            .appendingPathComponent(segmentFileName(hour: activeHour))
        guard FileManager.default.fileExists(atPath: openURL.path) else { return }
        let sealedDirectory = generationDirectory.appendingPathComponent("sealed", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: sealedDirectory, withIntermediateDirectories: true)
            let sealedURL = sealedDirectory.appendingPathComponent(openURL.lastPathComponent)
            guard !FileManager.default.fileExists(atPath: sealedURL.path) else {
                throw DiagnosticsJournalError.writeFailed
            }
            try FileManager.default.moveItem(at: openURL, to: sealedURL)
        } catch let error as DiagnosticsJournalError {
            throw error
        } catch {
            throw DiagnosticsJournalError.writeFailed
        }
    }

    /// Lease 与 append 共用同一把 identity lock。fence 只递增，因而后续的
    /// reclaim coordinator 可以把一次已经观察到的旧 lease 明确判定为过期版本。
    private func renewLease(
        for control: DiagnosticsJournalControl,
        in generationDirectory: URL
    ) throws {
        let leasesDirectory = generationDirectory.appendingPathComponent("leases", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: leasesDirectory, withIntermediateDirectories: true)
            let leaseURL = leasesDirectory.appendingPathComponent(leaseFileName())
            if let existingLease = try? readLease(at: leaseURL) {
                leaseFence = max(leaseFence, existingLease.fence)
            }
            leaseFence &+= 1
            let renewedAt = Date()
            let lease = DiagnosticsJournalLease(
                generation: control.currentGeneration,
                origin: origin,
                processInstanceID: processInstanceID,
                fence: leaseFence,
                renewedAt: renewedAt,
                expiresAt: renewedAt.addingTimeInterval(Self.leaseDuration)
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            try encoder.encode(lease).write(to: leaseURL, options: .atomic)
        } catch {
            throw DiagnosticsJournalError.writeFailed
        }
    }

    private func rejectReclaimedWriter(in generationDirectory: URL) throws {
        let reclaimedDirectory = generationDirectory.appendingPathComponent(
            "reclaimed",
            isDirectory: true
        )
        let tombstoneURL = reclaimedDirectory.appendingPathComponent(leaseFileName())
        guard !FileManager.default.fileExists(atPath: tombstoneURL.path) else {
            throw DiagnosticsJournalError.writerReclaimed
        }
    }

    private func readLease(at url: URL) throws -> DiagnosticsJournalLease {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let lease = try decoder.decode(DiagnosticsJournalLease.self, from: data)
        guard
            lease.schemaVersion == DiagnosticsJournalLease.schemaVersion,
            lease.origin == origin,
            lease.processInstanceID == processInstanceID
        else {
            throw DiagnosticsJournalError.writerIdentityMismatch
        }
        return lease
    }

    private func leaseFileName() -> String {
        "\(origin.rawValue)-\(processInstanceID.uuidString).json"
    }

    /// 这把稳定 lock 仅保护当前 writer identity 的 background batch。
    /// 它以 `LOCK_NB` 失败而非等待；未来 ingress 看到 `.lockBusy` 时只能
    /// 有界重试或记 drop，不能把等待传播到键盘热路径。
    private func withExclusiveWriterLock<T>(_ body: () throws -> T) throws -> T {
        try DiagnosticsJournalIdentityLock.withExclusiveLock(
            rootURL: rootURL,
            origin: origin,
            processInstanceID: processInstanceID,
            body
        )
    }

    private static func encodeLine(_ event: DiagnosticEvent) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var line = try encoder.encode(event)
        line.append(0x0A)
        return line
    }

    private static func hourStamp(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate]
        return String(formatter.string(from: date).prefix(13)).replacingOccurrences(of: "-", with: "")
    }
}

/// 这是跨进程的 fence，不是本进程的并发控制。每个 writer/reclaimer 仍须在
/// 自己的 utility 串行执行器上使用它，且持锁期间不能跨 `await`。
public enum DiagnosticsJournalIdentityLock {
    public static func withExclusiveLock<T>(
        rootURL: URL,
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID,
        _ body: () throws -> T
    ) throws -> T {
        // Extension 可以创建自己的 lock 文件，但不能因写日志而补建整个 root。
        guard FileManager.default.fileExists(atPath: rootURL.path) else {
            throw DiagnosticsJournalError.rootUnavailable
        }
        let locksDirectory = rootURL.appendingPathComponent("locks", isDirectory: true)
        if !FileManager.default.fileExists(atPath: locksDirectory.path) {
            do {
                try FileManager.default.createDirectory(
                    at: locksDirectory,
                    withIntermediateDirectories: false
                )
            } catch {
                throw DiagnosticsJournalError.lockUnavailable
            }
        }

        let lockURL = locksDirectory.appendingPathComponent(
            "\(origin.rawValue)-\(processInstanceID.uuidString).lock"
        )
        let descriptor = open(lockURL.path, O_RDWR | O_CREAT | O_CLOEXEC, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw DiagnosticsJournalError.lockUnavailable }
        defer { _ = close(descriptor) }

        guard flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            if errno == EWOULDBLOCK || errno == EAGAIN || errno == EACCES {
                throw DiagnosticsJournalError.lockBusy
            }
            throw DiagnosticsJournalError.lockUnavailable
        }
        defer { _ = flock(descriptor, LOCK_UN) }
        return try body()
    }
}

/// Main-App 专用的最新事件读取器。它只读取当前 generation，并对单个 JSONL
/// 段执行受字节预算限制的尾读；Extension 不得使用这个类型枚举日志目录。
public actor DiagnosticsJournalReader {
    /// UI 的实时查询水位与复制安全上限一致。它不是 journal 的保留上限；
    /// 历史段仍完整留在文件中，后续 offset pagination 可继续读取更早记录。
    public static let defaultMaximumEventCount = 10_000
    public static let defaultMaximumReadBytes = 5 * 1_024 * 1_024

    private let rootURL: URL
    private var pageQueries: [UUID: PageQuery] = [:]

    private struct PageSegment: Sendable {
        let fileName: String
        let preferredDirectory: String
        let byteWatermark: Int
        var readEndOffset: Int
    }

    private struct PageQuery: Sendable {
        let generation: UInt64
        var segments: [PageSegment]
        var nextSegmentIndex = 0
    }

    private struct CompleteLine {
        let data: Data
        let startOffset: Int
    }

    public init(rootURL: URL) {
        self.rootURL = rootURL
    }

    public func latest(
        maximumEventCount: Int = defaultMaximumEventCount,
        maximumReadBytes: Int = defaultMaximumReadBytes
    ) throws -> DiagnosticsJournalSnapshot {
        guard maximumEventCount > 0, maximumReadBytes > 0 else {
            return DiagnosticsJournalSnapshot(generation: 0, events: [])
        }

        let control = try readControl()
        let generationDirectory = rootURL.appendingPathComponent(
            "g\(control.currentGeneration)",
            isDirectory: true
        )
        let segmentURLs = try segmentURLs(in: generationDirectory)
        var readBytes = 0
        var events: [DiagnosticEvent] = []

        for url in segmentURLs {
            guard readBytes < maximumReadBytes else { break }
            let remainingBytes = maximumReadBytes - readBytes
            let tail = try readTail(at: url, maximumBytes: remainingBytes)
            readBytes += tail.data.count
            events.append(contentsOf: decodeCompleteLines(from: tail))
            if events.count >= maximumEventCount {
                break
            }
        }

        let newestFirst = events.sorted(by: Self.isNewer)
        return DiagnosticsJournalSnapshot(
            generation: control.currentGeneration,
            events: Array(newestFirst.prefix(maximumEventCount))
        )
    }

    /// 创建一个以当前 generation 和每段字节水位冻结的“最新优先”分页查询。
    /// 页面只会读取有限窗口；保留目录再大也不会被一次性解码进 UI 内存。
    public func beginPage(
        maximumEventCount: Int = 500,
        maximumReadBytes: Int = 512 * 1_024
    ) throws -> DiagnosticsJournalPage {
        guard maximumEventCount > 0, maximumReadBytes > 0 else {
            return DiagnosticsJournalPage(generation: 0, events: [], nextCursor: nil)
        }
        let control = try readControl()
        let queryID = UUID()
        pageQueries[queryID] = PageQuery(
            generation: control.currentGeneration,
            segments: try pageSegments(in: generationDirectory(for: control.currentGeneration))
        )
        return try readPage(
            queryID: queryID,
            maximumEventCount: maximumEventCount,
            maximumReadBytes: maximumReadBytes
        )
    }

    /// 继续同一冻结水位。若用户清空了日志，旧 cursor 立即失效，绝不把旧
    /// generation 的记录混入新的诊断页。
    public func nextPage(
        after cursor: DiagnosticsJournalPageCursor,
        maximumEventCount: Int = 500,
        maximumReadBytes: Int = 512 * 1_024
    ) throws -> DiagnosticsJournalPage {
        guard maximumEventCount > 0, maximumReadBytes > 0 else {
            return DiagnosticsJournalPage(generation: 0, events: [], nextCursor: nil)
        }
        return try readPage(
            queryID: cursor.queryID,
            maximumEventCount: maximumEventCount,
            maximumReadBytes: maximumReadBytes
        )
    }

    private func readControl() throws -> DiagnosticsJournalControl {
        let controlURL = rootURL.appendingPathComponent("control.json")
        guard FileManager.default.fileExists(atPath: controlURL.path) else {
            throw DiagnosticsJournalError.controlUnavailable
        }
        guard let data = try? Data(contentsOf: controlURL),
            let control = try? JSONDecoder().decode(DiagnosticsJournalControl.self, from: data)
        else {
            throw DiagnosticsJournalError.invalidControl
        }
        guard control.schemaVersion == DiagnosticsJournalControl.schemaVersion else {
            throw DiagnosticsJournalError.unsupportedControlVersion(control.schemaVersion)
        }
        return control
    }

    private func segmentURLs(in generationDirectory: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let directories = ["open", "sealed"]
        var urls: [URL] = []
        for directory in directories {
            let url = generationDirectory.appendingPathComponent(directory, isDirectory: true)
            guard fileManager.fileExists(atPath: url.path) else { continue }
            let files = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            urls.append(contentsOf: files.filter { $0.pathExtension == "jsonl" })
        }
        return urls.sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
    }

    private func generationDirectory(for generation: UInt64) -> URL {
        rootURL.appendingPathComponent("g\(generation)", isDirectory: true)
    }

    private func pageSegments(in generationDirectory: URL) throws -> [PageSegment] {
        let fileManager = FileManager.default
        var segments: [PageSegment] = []
        for directoryName in ["open", "sealed"] {
            let directory = generationDirectory.appendingPathComponent(directoryName, isDirectory: true)
            guard fileManager.fileExists(atPath: directory.path) else { continue }
            let files = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            for file in files where file.pathExtension == "jsonl" {
                guard let byteCount = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                    continue
                }
                segments.append(
                    PageSegment(
                        fileName: file.lastPathComponent,
                        preferredDirectory: directoryName,
                        byteWatermark: byteCount,
                        readEndOffset: byteCount
                    )
                )
            }
        }
        return segments.sorted(by: { $0.fileName > $1.fileName })
    }

    private func readPage(
        queryID: UUID,
        maximumEventCount: Int,
        maximumReadBytes: Int
    ) throws -> DiagnosticsJournalPage {
        guard var query = pageQueries[queryID] else {
            return DiagnosticsJournalPage(generation: 0, events: [], nextCursor: nil)
        }
        let currentGeneration = try readControl().currentGeneration
        guard currentGeneration == query.generation else {
            pageQueries.removeValue(forKey: queryID)
            return DiagnosticsJournalPage(generation: currentGeneration, events: [], nextCursor: nil)
        }

        var remainingBytes = maximumReadBytes
        var events: [DiagnosticEvent] = []
        while events.count < maximumEventCount,
            remainingBytes > 0,
            query.nextSegmentIndex < query.segments.count
        {
            var segment = query.segments[query.nextSegmentIndex]
            guard segment.readEndOffset > 0 else {
                query.nextSegmentIndex += 1
                continue
            }
            guard let url = resolve(segment: segment, generation: query.generation) else {
                segment.readEndOffset = 0
                query.segments[query.nextSegmentIndex] = segment
                continue
            }

            let chunkByteCount = min(segment.readEndOffset, remainingBytes)
            let chunkStart = segment.readEndOffset - chunkByteCount
            let lines = try completeLines(
                at: url,
                startOffset: chunkStart,
                endOffset: segment.readEndOffset
            )
            remainingBytes -= chunkByteCount
            guard !lines.isEmpty else {
                segment.readEndOffset = chunkStart
                query.segments[query.nextSegmentIndex] = segment
                continue
            }

            let availableCount = min(maximumEventCount - events.count, lines.count)
            let oldestSelectedIndex = lines.count - availableCount
            let selected = lines[oldestSelectedIndex...]
            events.append(
                contentsOf: selected.reversed().compactMap { decodeEvent(from: $0.data) }
            )
            segment.readEndOffset = lines[oldestSelectedIndex].startOffset
            query.segments[query.nextSegmentIndex] = segment
        }

        let hasMore =
            query.nextSegmentIndex < query.segments.count
            && query.segments[query.nextSegmentIndex...].contains { $0.readEndOffset > 0 }
        if hasMore {
            pageQueries[queryID] = query
        } else {
            pageQueries.removeValue(forKey: queryID)
        }
        return DiagnosticsJournalPage(
            generation: query.generation,
            events: events,
            nextCursor: hasMore ? DiagnosticsJournalPageCursor(queryID: queryID) : nil
        )
    }

    private func resolve(segment: PageSegment, generation: UInt64) -> URL? {
        let generationDirectory = generationDirectory(for: generation)
        let directories = [segment.preferredDirectory, "open", "sealed"]
        for directoryName in directories {
            let url =
                generationDirectory
                .appendingPathComponent(directoryName, isDirectory: true)
                .appendingPathComponent(segment.fileName)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return nil
    }

    private func completeLines(
        at url: URL,
        startOffset: Int,
        endOffset: Int
    ) throws -> [CompleteLine] {
        guard endOffset > startOffset else { return [] }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        try handle.seek(toOffset: UInt64(startOffset))
        let data = try handle.read(upToCount: endOffset - startOffset) ?? Data()
        var result: [CompleteLine] = []
        var lineStart = data.startIndex
        let firstLineMayBePartial = startOffset > 0
        for index in data.indices where data[index] == 0x0A {
            if !(firstLineMayBePartial && lineStart == data.startIndex) {
                result.append(
                    CompleteLine(
                        data: data.subdata(in: lineStart..<index),
                        startOffset: startOffset + lineStart
                    )
                )
            }
            lineStart = data.index(after: index)
        }
        return result
    }

    private func decodeEvent(from data: Data) -> DiagnosticEvent? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(DiagnosticEvent.self, from: data)
    }

    private func readTail(at url: URL, maximumBytes: Int) throws -> (data: Data, startsMidLine: Bool) {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let byteCount = (attributes[.size] as? NSNumber)?.intValue ?? 0
        let readByteCount = min(byteCount, maximumBytes)
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        if byteCount > readByteCount {
            try handle.seek(toOffset: UInt64(byteCount - readByteCount))
        }
        let data = try handle.readToEnd() ?? Data()
        return (data, byteCount > readByteCount)
    }

    private func decodeCompleteLines(
        from tail: (data: Data, startsMidLine: Bool)
    ) -> [DiagnosticEvent] {
        var lines = tail.data.split(separator: 0x0A, omittingEmptySubsequences: true)
        if tail.startsMidLine, !lines.isEmpty {
            lines.removeFirst()
        }
        if tail.data.last != 0x0A, !lines.isEmpty {
            lines.removeLast()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return lines.compactMap { try? decoder.decode(DiagnosticEvent.self, from: Data($0)) }
    }

    private static func isNewer(_ lhs: DiagnosticEvent, _ rhs: DiagnosticEvent) -> Bool {
        if lhs.utcTimestamp != rhs.utcTimestamp { return lhs.utcTimestamp > rhs.utcTimestamp }
        if lhs.monotonicNanoseconds != rhs.monotonicNanoseconds {
            return lhs.monotonicNanoseconds > rhs.monotonicNanoseconds
        }
        if lhs.processInstanceID != rhs.processInstanceID {
            return lhs.processInstanceID.uuidString > rhs.processInstanceID.uuidString
        }
        return lhs.localSequence > rhs.localSequence
    }
}
