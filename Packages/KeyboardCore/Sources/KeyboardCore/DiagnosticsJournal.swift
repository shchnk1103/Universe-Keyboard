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
    case diskFull
    case ioFailure
    /// P0 写入失败的兼容错误。新代码会尽可能归类为 `diskFull` 或 `ioFailure`。
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
/// segment manifest 与已解码事件，不把路径或自由文本暴露给 UI，也不会跨进程持久化。
public struct DiagnosticsJournalPageCursor: Hashable, Sendable {
    fileprivate let queryID: UUID
}

/// Main App 日历查询使用的半开 UTC 范围。事件仍保存 UTC；本地日期只在
/// reader 与 UI 映射，不改变 writer 的文件 ownership。
public struct DiagnosticsJournalDateRange: Hashable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    fileprivate func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}

/// 日期发现与 generation 必须来自同一次稳定 manifest，避免 Main App 把
/// “读取失败”误判为空目录，也避免后续查询无法说明日期目录对应哪个 generation。
public struct DiagnosticsJournalDateCatalog: Sendable {
    public let generation: UInt64
    public let ranges: [DiagnosticsJournalDateRange]

    public init(generation: UInt64, ranges: [DiagnosticsJournalDateRange]) {
        self.generation = generation
        self.ranges = ranges
    }
}

/// 分页查询的受控结束状态。调用方必须把失效状态与“没有更多日志”区别展示，
/// 不能在 clear 或 reader 重建后静默把旧 cursor 当成空结果。
public enum DiagnosticsJournalPageStatus: Sendable, Equatable {
    /// 当前快照仍有更早记录可以读取。
    case hasMore
    /// 当前快照已正常读完。
    case completed
    /// 查询开始后 control generation 已推进；旧 cursor 不再代表当前日志视图。
    case invalidatedByGeneration
    /// 快照中的段在下一页前被 reclaim 或被非同一文件替换；必须刷新重新建立水位。
    case invalidatedByReclaim
    /// cursor 只在 reader actor 内存中有效，已被消费、失效或来自另一 reader。
    case cursorUnavailable
    /// 为保证严格排序，创建快照需要读取完整 segment，但超过本次受控预算。
    case snapshotExceedsReadBudget
    /// 为保证复制和内存边界，冻结快照超过允许的事件总数。
    case snapshotExceedsEventBudget
    /// 完整日期快照超预算后返回的有界最近窗口；内容有观察价值但不完整。
    case partialRecentWindow
    /// 枚举、移动或读取段时无法保持同一份 segment manifest；必须刷新重试。
    case snapshotUnavailable
    /// control 或 journal 根目录不可用；调用方不得把它降级为 legacy 成功读取。
    case journalUnavailable
}

/// 按“最新优先”返回的一页事件。分页起点固定在一次目录快照，后续 append
/// 不会悄悄混入当前查询；新事件会在下一次 begin query 的实时刷新中出现。
public struct DiagnosticsJournalPage: Sendable {
    public let generation: UInt64
    public let events: [DiagnosticEvent]
    public let nextCursor: DiagnosticsJournalPageCursor?
    public let status: DiagnosticsJournalPageStatus

    public init(
        generation: UInt64,
        events: [DiagnosticEvent],
        nextCursor: DiagnosticsJournalPageCursor?,
        status: DiagnosticsJournalPageStatus
    ) {
        self.generation = generation
        self.events = events
        self.nextCursor = nextCursor
        self.status = status
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
        return try DiagnosticsJournalIdentityLock.withSharedSnapshotFence(rootURL: rootURL) { [self] in
            try withExclusiveWriterLock {
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
                fields: event.fields,
                schemeDeliveryPayload: event.schemeDeliveryPayload
            )
        }
        let hour = Self.hourStamp(for: normalizedEvents[0].utcTimestamp)
        let encodedLines = try normalizedEvents.map(Self.encodeLine)
        let byteCount = encodedLines.reduce(0) { $0 + $1.count }

        try DiagnosticsJournalIdentityLock.withSharedSnapshotFence(rootURL: rootURL) { [self] in
            try withExclusiveWriterLock {
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
                    throw Self.writeFailure(for: error)
                }
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
            throw Self.writeFailure(for: error)
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
            throw Self.writeFailure(for: error)
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
            throw Self.writeFailure(for: error)
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

    /// 仅把系统已经提供的空间耗尽错误标记为 `diskFull`；其它文件写入、编码或
    /// 文件协调问题统一收敛为 `ioFailure`，避免把未知错误文本写进 journal。
    private static func writeFailure(for error: Error) -> DiagnosticsJournalError {
        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain,
            nsError.code == CocoaError.Code.fileWriteOutOfSpace.rawValue
        {
            return .diskFull
        }
        if nsError.domain == NSPOSIXErrorDomain, nsError.code == Int(ENOSPC) {
            return .diskFull
        }
        return .ioFailure
    }
}

/// 这是跨进程的 fence，不是本进程的并发控制。每个 writer/reclaimer 仍须在
/// 自己的 utility 串行执行器上使用它，且持锁期间不能跨 `await`。
public enum DiagnosticsJournalIdentityLock {
    public struct Identity: Hashable, Sendable {
        public let origin: DiagnosticEvent.Origin
        public let processInstanceID: UUID

        public init(origin: DiagnosticEvent.Origin, processInstanceID: UUID) {
            self.origin = origin
            self.processInstanceID = processInstanceID
        }
    }

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

    /// 所有改变 generation、writer membership、lease 或 segment 的操作都先取得
    /// shared fence；Reader 以独占 fence 捕获 manifest，因此“成员集合 + 水位”有
    /// 一个真实的全局冻结点。两种模式都使用非阻塞 flock，绝不把等待带回输入路径。
    public static func withSharedSnapshotFence<T>(
        rootURL: URL,
        _ body: () throws -> T
    ) throws -> T {
        try withSnapshotFence(rootURL: rootURL, lockOperation: LOCK_SH | LOCK_NB, body)
    }

    public static func withExclusiveSnapshotFence<T>(
        rootURL: URL,
        _ body: () throws -> T
    ) throws -> T {
        try withSnapshotFence(rootURL: rootURL, lockOperation: LOCK_EX | LOCK_NB, body)
    }

    /// Reader 以稳定排序同时申请当前 generation 已知 writer 的 lock。任何一个
    /// busy 都立即放弃，避免与 writer/reclaim 形成等待环；Extension 从不调用它。
    public static func withExclusiveLocks<T>(
        rootURL: URL,
        identities: [Identity],
        _ body: () throws -> T
    ) throws -> T {
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

        let sortedIdentities = Array(Set(identities)).sorted {
            let lhsKey = "\($0.origin.rawValue)-\($0.processInstanceID.uuidString)"
            let rhsKey = "\($1.origin.rawValue)-\($1.processInstanceID.uuidString)"
            return lhsKey < rhsKey
        }
        var descriptors: [Int32] = []
        do {
            for identity in sortedIdentities {
                let lockURL = locksDirectory.appendingPathComponent(
                    "\(identity.origin.rawValue)-\(identity.processInstanceID.uuidString).lock"
                )
                let descriptor = open(lockURL.path, O_RDWR | O_CREAT | O_CLOEXEC, S_IRUSR | S_IWUSR)
                guard descriptor >= 0 else { throw DiagnosticsJournalError.lockUnavailable }
                descriptors.append(descriptor)

                guard flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
                    let lockError = errno
                    if lockError == EWOULDBLOCK || lockError == EAGAIN || lockError == EACCES {
                        throw DiagnosticsJournalError.lockBusy
                    }
                    throw DiagnosticsJournalError.lockUnavailable
                }
            }
        } catch {
            for descriptor in descriptors.reversed() {
                _ = flock(descriptor, LOCK_UN)
                _ = close(descriptor)
            }
            throw error
        }
        defer {
            for descriptor in descriptors.reversed() {
                _ = flock(descriptor, LOCK_UN)
                _ = close(descriptor)
            }
        }
        return try body()
    }

    private static func withSnapshotFence<T>(
        rootURL: URL,
        lockOperation: Int32,
        _ body: () throws -> T
    ) throws -> T {
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
        let lockURL = locksDirectory.appendingPathComponent("snapshot.lock")
        let descriptor = open(lockURL.path, O_RDWR | O_CREAT | O_CLOEXEC, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw DiagnosticsJournalError.lockUnavailable }
        defer { _ = close(descriptor) }

        guard flock(descriptor, lockOperation) == 0 else {
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
    public static let maximumActivePageQueries = 4

    private let rootURL: URL
    private var pageQueries: [UUID: PageQuery] = [:]
    private var pageQueryOrder: [UUID] = []
    private let snapshotCaptureHook: (@Sendable () -> Void)?

    private struct PageQuery: Sendable {
        let generation: UInt64
        let manifest: [SegmentManifest]
        let events: [DiagnosticEvent]
        var nextEventIndex = 0
    }

    /// 路径只保留在 reader actor 内部。`fileSystemNumber` 把“同名新文件”与
    /// “writer seal 后移动的同一个文件”区分开，使 cursor 能在 reclaim 后失效。
    private struct SegmentManifest: Equatable, Sendable {
        let url: URL
        let originalFileName: String
        let fileSystemNumber: UInt64
        let byteWatermark: Int
        let hourStartUTC: Date?
    }

    private enum PageSnapshotResult {
        case events([DiagnosticEvent], [SegmentManifest])
        case exceedsReadBudget
        case exceedsEventBudget
        case unavailable
    }

    private struct CompleteLine {
        let data: Data
        let startOffset: Int
    }

    public init(
        rootURL: URL,
        snapshotCaptureHook: (@Sendable () -> Void)? = nil
    ) {
        self.rootURL = rootURL
        self.snapshotCaptureHook = snapshotCaptureHook
    }

    /// 从当前 generation 的 UTC 小时段推导本地日历范围。它只在 Main App
    /// repository 使用，不要求 writer 创建或共享“每日文件”。
    public func availableDateCatalog(
        timeZone: TimeZone = .current
    ) throws -> DiagnosticsJournalDateCatalog {
        let control = try readControl()
        let generationDirectory = generationDirectory(for: control.currentGeneration)
        guard
            let manifest = try stableSegmentManifest(
                in: generationDirectory,
                generation: control.currentGeneration
            )
        else {
            throw DiagnosticsJournalError.lockBusy
        }

        let hourStarts = manifest.compactMap(\.hourStartUTC)
        guard hourStarts.count == manifest.count else {
            throw DiagnosticsJournalError.ioFailure
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        var dayStarts = Set<Date>()
        for hourStart in hourStarts {
            dayStarts.insert(calendar.startOfDay(for: hourStart))
            // 某些时区的本地午夜不落在 UTC 整点（例如 UTC+05:30）。同一个
            // UTC 小时段可能跨越两个本地日期，因此两端都必须进入日期索引。
            let hourLastMoment = hourStart.addingTimeInterval(60 * 60 - 0.001)
            dayStarts.insert(calendar.startOfDay(for: hourLastMoment))
        }
        let ranges: [DiagnosticsJournalDateRange] = dayStarts.sorted(by: >).compactMap { start in
            guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }
            return DiagnosticsJournalDateRange(start: start, end: end)
        }
        return DiagnosticsJournalDateCatalog(
            generation: control.currentGeneration,
            ranges: ranges
        )
    }

    public func availableDateRanges(
        timeZone: TimeZone = .current
    ) throws -> [DiagnosticsJournalDateRange] {
        try availableDateCatalog(timeZone: timeZone).ranges
    }

    public func latest(
        maximumEventCount: Int = defaultMaximumEventCount,
        maximumReadBytes: Int = defaultMaximumReadBytes
    ) throws -> DiagnosticsJournalSnapshot {
        guard maximumEventCount > 0, maximumReadBytes > 0 else {
            return DiagnosticsJournalSnapshot(generation: 0, events: [])
        }

        let effectiveEventLimit = min(maximumEventCount, Self.defaultMaximumEventCount)
        let effectiveReadBudget = min(maximumReadBytes, Self.defaultMaximumReadBytes)

        let control = try readControl()
        let generationDirectory = rootURL.appendingPathComponent(
            "g\(control.currentGeneration)",
            isDirectory: true
        )
        let segmentURLs = try segmentURLs(in: generationDirectory)
        var readBytes = 0
        var events: [DiagnosticEvent] = []

        for url in segmentURLs {
            guard readBytes < effectiveReadBudget else { break }
            let remainingBytes = effectiveReadBudget - readBytes
            let tail = try readTail(at: url, maximumBytes: remainingBytes)
            readBytes += tail.data.count
            events.append(contentsOf: decodeCompleteLines(from: tail))
            if events.count >= effectiveEventLimit {
                break
            }
        }

        let newestFirst = events.sorted(by: Self.isNewer)
        return DiagnosticsJournalSnapshot(
            generation: control.currentGeneration,
            events: Array(newestFirst.prefix(effectiveEventLimit))
        )
    }

    /// 创建一个以当前 generation 和每段字节水位冻结的“最新优先”分页查询。
    /// 页面只会读取有限窗口；保留目录再大也不会被一次性解码进 UI 内存。
    public func beginPage(
        in dateRange: DiagnosticsJournalDateRange? = nil,
        maximumEventCount: Int = 500,
        maximumReadBytes: Int = defaultMaximumReadBytes
    ) throws -> DiagnosticsJournalPage {
        guard maximumEventCount > 0, maximumReadBytes > 0 else {
            return DiagnosticsJournalPage(
                generation: 0,
                events: [],
                nextCursor: nil,
                status: .completed
            )
        }
        let control = try readControl()
        let effectivePageSize = min(maximumEventCount, Self.defaultMaximumEventCount)
        let effectiveReadBudget = min(maximumReadBytes, Self.defaultMaximumReadBytes)
        let queryID = UUID()
        let snapshot = try pageSnapshot(
            generation: control.currentGeneration,
            dateRange: dateRange,
            maximumReadBytes: effectiveReadBudget
        )
        let events: [DiagnosticEvent]
        let manifest: [SegmentManifest]
        switch snapshot {
        case let .events(snapshotEvents, snapshotManifest):
            events = snapshotEvents
            manifest = snapshotManifest
        case .exceedsReadBudget:
            return DiagnosticsJournalPage(
                generation: control.currentGeneration,
                events: [],
                nextCursor: nil,
                status: .snapshotExceedsReadBudget
            )
        case .exceedsEventBudget:
            return DiagnosticsJournalPage(
                generation: control.currentGeneration,
                events: [],
                nextCursor: nil,
                status: .snapshotExceedsEventBudget
            )
        case .unavailable:
            return DiagnosticsJournalPage(
                generation: control.currentGeneration,
                events: [],
                nextCursor: nil,
                status: .snapshotUnavailable
            )
        }
        insertPageQuery(
            queryID,
            query: PageQuery(
                generation: control.currentGeneration,
                manifest: manifest,
                events: events.sorted(by: Self.isNewer)
            )
        )
        return try readPage(
            queryID: queryID,
            maximumEventCount: effectivePageSize,
            maximumReadBytes: effectiveReadBudget
        )
    }

    /// 严格日期快照超预算时使用的有界最近窗口。每个相关段获得一份尾读预算，
    /// 避免某个 writer 独占全部 5 MiB；调用方必须持续展示“不完整”状态。
    public func recentPreview(
        in dateRange: DiagnosticsJournalDateRange,
        maximumEventCount: Int = 500,
        maximumReadBytes: Int = defaultMaximumReadBytes
    ) throws -> DiagnosticsJournalPage {
        guard maximumEventCount > 0, maximumReadBytes > 0 else {
            return DiagnosticsJournalPage(
                generation: 0,
                events: [],
                nextCursor: nil,
                status: .partialRecentWindow
            )
        }
        let control = try readControl()
        let generationDirectory = generationDirectory(for: control.currentGeneration)
        guard
            let manifest = try stableSegmentManifest(
                in: generationDirectory,
                generation: control.currentGeneration
            )
        else {
            return DiagnosticsJournalPage(
                generation: control.currentGeneration,
                events: [],
                nextCursor: nil,
                status: .snapshotUnavailable
            )
        }
        let scopedManifest = manifest.filter { segmentIntersects($0, dateRange: dateRange) }
        snapshotCaptureHook?()
        let effectiveReadBudget = min(maximumReadBytes, Self.defaultMaximumReadBytes)
        let effectiveEventLimit = min(maximumEventCount, Self.defaultMaximumEventCount)
        var remainingBytes = effectiveReadBudget
        var events: [DiagnosticEvent] = []

        for (index, segment) in scopedManifest.enumerated() {
            guard remainingBytes > 0 else { break }
            guard let resolvedURL = try resolve(segment, in: generationDirectory) else { continue }
            let remainingSegments = scopedManifest.count - index
            let segmentBudget = max(1, remainingBytes / max(remainingSegments, 1))
            let startOffset = max(0, segment.byteWatermark - segmentBudget)
            let lines = try completeLines(
                at: resolvedURL,
                startOffset: startOffset,
                endOffset: segment.byteWatermark
            )
            remainingBytes -= segment.byteWatermark - startOffset
            events.append(
                contentsOf: lines.compactMap { decodeEvent(from: $0.data) }.filter {
                    dateRange.contains($0.utcTimestamp)
                }
            )
        }
        guard
            try readControl().currentGeneration == control.currentGeneration,
            try manifestIsStillAvailable(scopedManifest, in: generationDirectory)
        else {
            return DiagnosticsJournalPage(
                generation: control.currentGeneration,
                events: [],
                nextCursor: nil,
                status: .snapshotUnavailable
            )
        }
        return DiagnosticsJournalPage(
            generation: control.currentGeneration,
            events: Array(events.sorted(by: Self.isNewer).prefix(effectiveEventLimit)),
            nextCursor: nil,
            status: .partialRecentWindow
        )
    }

    /// 继续同一冻结水位。若用户清空了日志，旧 cursor 立即失效，绝不把旧
    /// generation 的记录混入新的诊断页。
    public func nextPage(
        after cursor: DiagnosticsJournalPageCursor,
        maximumEventCount: Int = 500,
        maximumReadBytes: Int = defaultMaximumReadBytes
    ) throws -> DiagnosticsJournalPage {
        guard maximumEventCount > 0, maximumReadBytes > 0 else {
            return DiagnosticsJournalPage(
                generation: 0,
                events: [],
                nextCursor: nil,
                status: .completed
            )
        }
        return try readPage(
            queryID: cursor.queryID,
            maximumEventCount: min(maximumEventCount, Self.defaultMaximumEventCount),
            maximumReadBytes: min(maximumReadBytes, Self.defaultMaximumReadBytes)
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

    private func readPage(
        queryID: UUID,
        maximumEventCount: Int,
        maximumReadBytes: Int
    ) throws -> DiagnosticsJournalPage {
        guard var query = pageQueries[queryID] else {
            return DiagnosticsJournalPage(
                generation: 0,
                events: [],
                nextCursor: nil,
                status: .cursorUnavailable
            )
        }
        let currentGeneration = try readControl().currentGeneration
        guard currentGeneration == query.generation else {
            removePageQuery(queryID)
            return DiagnosticsJournalPage(
                generation: currentGeneration,
                events: [],
                nextCursor: nil,
                status: .invalidatedByGeneration
            )
        }

        guard try manifestIsStillAvailable(query.manifest, in: generationDirectory(for: query.generation)) else {
            removePageQuery(queryID)
            return DiagnosticsJournalPage(
                generation: query.generation,
                events: [],
                nextCursor: nil,
                status: .invalidatedByReclaim
            )
        }

        // `maximumReadBytes` 已在 beginPage 创建不可变快照时使用。这里仅对内存
        // 快照切页，既不会读取后来 append 的数据，也不会因 segment 被封存/删除
        // 而改变既有 query 的顺序。
        _ = maximumReadBytes
        let endIndex = min(query.nextEventIndex + maximumEventCount, query.events.count)
        let events = Array(query.events[query.nextEventIndex..<endIndex])
        query.nextEventIndex = endIndex
        let hasMore = query.nextEventIndex < query.events.count
        if hasMore {
            pageQueries[queryID] = query
        } else {
            removePageQuery(queryID)
        }
        return DiagnosticsJournalPage(
            generation: query.generation,
            events: events,
            nextCursor: hasMore ? DiagnosticsJournalPageCursor(queryID: queryID) : nil,
            status: hasMore ? .hasMore : .completed
        )
    }

    /// 枚举两次得到完全一致的 identity+watermark manifest 后，第二次枚举结束
    /// 即是逻辑冻结点：之后 append 的字节不在 watermark 内，新建段也不在
    /// manifest 内。若 writer/retention 使两次观察不稳定，安全地要求刷新。
    private func pageSnapshot(
        generation: UInt64,
        dateRange: DiagnosticsJournalDateRange?,
        maximumReadBytes: Int
    ) throws -> PageSnapshotResult {
        let generationDirectory = generationDirectory(for: generation)
        guard
            let manifest = try stableSegmentManifest(
                in: generationDirectory,
                generation: generation
            )
        else {
            return .unavailable
        }
        let scopedManifest: [SegmentManifest]
        if let dateRange {
            scopedManifest = manifest.filter { segmentIntersects($0, dateRange: dateRange) }
        } else {
            scopedManifest = manifest
        }
        snapshotCaptureHook?()
        var remainingBytes = maximumReadBytes
        var events: [DiagnosticEvent] = []
        for segment in scopedManifest {
            guard segment.byteWatermark <= remainingBytes else {
                return .exceedsReadBudget
            }
            guard let resolvedURL = try resolve(segment, in: generationDirectory) else {
                return .unavailable
            }
            let lines = try completeLines(
                at: resolvedURL,
                startOffset: 0,
                endOffset: segment.byteWatermark
            )
            remainingBytes -= segment.byteWatermark
            let decoded = lines.compactMap { decodeEvent(from: $0.data) }
            if let dateRange {
                events.append(contentsOf: decoded.filter { dateRange.contains($0.utcTimestamp) })
            } else {
                events.append(contentsOf: decoded)
            }
            guard events.count <= Self.defaultMaximumEventCount else {
                return .exceedsEventBudget
            }
        }
        guard try readControl().currentGeneration == generation else {
            return .unavailable
        }
        return .events(events, scopedManifest)
    }

    private func stableSegmentManifest(
        in generationDirectory: URL,
        generation: UInt64
    ) throws -> [SegmentManifest]? {
        for _ in 0..<2 {
            let manifest: [SegmentManifest]? = try DiagnosticsJournalIdentityLock.withExclusiveSnapshotFence(
                rootURL: rootURL
            ) { () throws -> [SegmentManifest]? in
                guard try readControl().currentGeneration == generation else { return nil }
                let observedIdentities = try writerIdentities(in: generationDirectory)
                return try DiagnosticsJournalIdentityLock.withExclusiveLocks(
                    rootURL: rootURL,
                    identities: Array(observedIdentities)
                ) {
                    // 所有 writer/reclaimer 都持 shared snapshot fence 后才改变
                    // membership 或段内容；持有 exclusive fence 时，这个复核和
                    // manifest 读取之间不会有新 writer 加入或旧 writer 追加。
                    guard try writerIdentities(in: generationDirectory) == observedIdentities else {
                        return nil
                    }
                    return try segmentManifest(in: generationDirectory)
                }
            }
            if let manifest { return manifest }
        }
        return nil
    }

    private func writerIdentities(
        in generationDirectory: URL
    ) throws -> Set<DiagnosticsJournalIdentityLock.Identity> {
        var identities = Set<DiagnosticsJournalIdentityLock.Identity>()
        for segmentURL in try segmentURLs(in: generationDirectory) {
            guard let identity = writerIdentity(for: segmentURL) else {
                throw DiagnosticsJournalError.ioFailure
            }
            identities.insert(identity)
        }

        let leasesDirectory = generationDirectory.appendingPathComponent("leases", isDirectory: true)
        guard FileManager.default.fileExists(atPath: leasesDirectory.path) else { return identities }
        let leaseURLs = try FileManager.default.contentsOfDirectory(
            at: leasesDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        for leaseURL in leaseURLs where leaseURL.pathExtension == "json" {
            let lease = try decoder.decode(DiagnosticsJournalLease.self, from: Data(contentsOf: leaseURL))
            guard
                let generation = generationDirectoryNumber(for: generationDirectory),
                lease.generation == generation
            else {
                throw DiagnosticsJournalError.writerIdentityMismatch
            }
            identities.insert(
                DiagnosticsJournalIdentityLock.Identity(
                    origin: lease.origin,
                    processInstanceID: lease.processInstanceID
                )
            )
        }
        return identities
    }

    private func writerIdentity(
        for segmentURL: URL
    ) -> DiagnosticsJournalIdentityLock.Identity? {
        var name = segmentURL.deletingPathExtension().lastPathComponent
        if name.hasPrefix("recovered-") {
            name.removeFirst("recovered-".count)
        }
        for origin in DiagnosticEvent.Origin.allCases {
            let prefix = "\(origin.rawValue)-"
            guard name.hasPrefix(prefix) else { continue }
            let remaining = name.dropFirst(prefix.count)
            guard remaining.count >= 36, let processInstanceID = UUID(uuidString: String(remaining.prefix(36)))
            else {
                return nil
            }
            return DiagnosticsJournalIdentityLock.Identity(
                origin: origin,
                processInstanceID: processInstanceID
            )
        }
        return nil
    }

    private func generationDirectoryNumber(for directory: URL) -> UInt64? {
        UInt64(directory.lastPathComponent.dropFirst())
    }

    private func segmentManifest(in generationDirectory: URL) throws -> [SegmentManifest] {
        try segmentURLs(in: generationDirectory).map { url in
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            guard
                let number = attributes[.systemFileNumber] as? NSNumber,
                let byteCount = attributes[.size] as? NSNumber
            else {
                throw DiagnosticsJournalError.ioFailure
            }
            return SegmentManifest(
                url: url,
                originalFileName: url.lastPathComponent,
                fileSystemNumber: number.uint64Value,
                byteWatermark: byteCount.intValue,
                hourStartUTC: segmentHourStartUTC(for: url)
            )
        }
    }

    private func segmentIntersects(
        _ segment: SegmentManifest,
        dateRange: DiagnosticsJournalDateRange
    ) -> Bool {
        guard let hourStart = segment.hourStartUTC else { return false }
        let hourEnd = hourStart.addingTimeInterval(60 * 60)
        return hourStart < dateRange.end && hourEnd > dateRange.start
    }

    private func segmentHourStartUTC(for url: URL) -> Date? {
        var name = url.deletingPathExtension().lastPathComponent
        if name.hasPrefix("recovered-") {
            name.removeFirst("recovered-".count)
        }
        for origin in DiagnosticEvent.Origin.allCases {
            let identityPrefixLength = origin.rawValue.count + 1 + 36 + 1
            guard name.hasPrefix("\(origin.rawValue)-"), name.count > identityPrefixLength else { continue }
            let hourStartIndex = name.index(name.startIndex, offsetBy: identityPrefixLength)
            let remainder = name[hourStartIndex...]
            guard let partSeparator = remainder.lastIndex(of: "-") else { return nil }
            let stamp = String(remainder[..<partSeparator])
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyyMMdd'T'HH"
            return formatter.date(from: stamp)
        }
        return nil
    }

    private func resolve(
        _ manifest: SegmentManifest,
        in generationDirectory: URL
    ) throws -> URL? {
        for current in try segmentManifest(in: generationDirectory)
        where current.fileSystemNumber == manifest.fileSystemNumber {
            // 只接受 writer 的同名 open↔sealed 移动，或 reclaim 产生的
            // `recovered-` 前缀。inode 被文件系统复用给无关新段时，不能把它
            // 误判为冻结快照的原段。
            guard isAcceptedMove(from: manifest.originalFileName, to: current.originalFileName) else {
                continue
            }
            guard current.byteWatermark >= manifest.byteWatermark else { return nil }
            return current.url
        }
        return nil
    }

    private func isAcceptedMove(from originalFileName: String, to currentFileName: String) -> Bool {
        currentFileName == originalFileName || currentFileName == "recovered-\(originalFileName)"
    }

    private func manifestIsStillAvailable(
        _ manifest: [SegmentManifest],
        in generationDirectory: URL
    ) throws -> Bool {
        for segment in manifest where try resolve(segment, in: generationDirectory) == nil {
            return false
        }
        return true
    }

    private func insertPageQuery(_ queryID: UUID, query: PageQuery) {
        while pageQueryOrder.count >= Self.maximumActivePageQueries {
            removePageQuery(pageQueryOrder.removeFirst())
        }
        pageQueries[queryID] = query
        pageQueryOrder.append(queryID)
    }

    private func removePageQuery(_ queryID: UUID) {
        pageQueries.removeValue(forKey: queryID)
        pageQueryOrder.removeAll { $0 == queryID }
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
