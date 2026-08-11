import Foundation
import KeyboardCore

/// Main App 对 `Diagnostics/v1` 的唯一目录维护入口。Keyboard Extension 不引用
/// 这个类型：它只追加自己的有限事件，绝不枚举、回收或删除共享目录。
actor DiagnosticsJournalRetentionCoordinator {
    struct Policy: Sendable {
        static let standard = Policy(
            maximumAge: 7 * 24 * 60 * 60,
            maximumTotalBytes: 100 * 1_024 * 1_024
        )

        let maximumAge: TimeInterval
        let maximumTotalBytes: Int
    }

    struct Report: Equatable, Sendable {
        var deletedSealedSegmentCount = 0
        var recoveredOpenSegmentCount = 0
        var skippedBusyLeaseCount = 0
        var skippedActiveLeaseCount = 0
        var deferredFailureCount = 0
    }

    private enum SegmentKind {
        case open
        case sealed
    }

    private struct Segment {
        let url: URL
        let kind: SegmentKind
        let byteCount: Int
        let modifiedAt: Date
        let writerIdentity: WriterIdentity?
    }

    private struct WriterIdentity {
        let origin: DiagnosticEvent.Origin
        let processInstanceID: UUID
    }

    private let rootURL: URL
    private let policy: Policy

    init(rootURL: URL, policy: Policy = .standard) {
        self.rootURL = rootURL
        self.policy = policy
    }

    /// 先把确认过期的 writer 转为 sealed/recovered，再执行普通保留删除。
    /// 任一 I/O 失败均保守保留文件；容量因活动 open 段暂时超限是允许状态。
    func runReclaim(now: Date = Date()) -> Report {
        guard FileManager.default.fileExists(atPath: rootURL.path) else { return Report() }
        do {
            return try DiagnosticsJournalIdentityLock.withSharedSnapshotFence(rootURL: rootURL) { [self] in
                runReclaimWhileFenced(now: now)
            }
        } catch {
            var report = Report()
            report.deferredFailureCount = 1
            return report
        }
    }

    private func runReclaimWhileFenced(now: Date) -> Report {
        var report = Report()

        for generationDirectory in generationDirectories() {
            recoverExpiredLeases(
                in: generationDirectory,
                now: now,
                report: &report
            )
        }

        var segments = sealedAndOpenSegments(report: &report)
        let cutoff = now.addingTimeInterval(-policy.maximumAge)
        for segment in segments where segment.kind == .sealed && segment.modifiedAt < cutoff {
            if deleteSealed(segment, report: &report) {
                segments.removeAll { $0.url == segment.url }
            }
        }

        var totalBytes = segments.reduce(0) { $0 + $1.byteCount }
        for segment
            in segments
            .filter({ $0.kind == .sealed })
            .sorted(by: { $0.modifiedAt < $1.modifiedAt })
        where totalBytes > policy.maximumTotalBytes {
            if deleteSealed(segment, report: &report) {
                totalBytes -= segment.byteCount
            }
        }
        return report
    }

    private func recoverExpiredLeases(
        in generationDirectory: URL,
        now: Date,
        report: inout Report
    ) {
        let leasesDirectory = generationDirectory.appendingPathComponent("leases", isDirectory: true)
        guard
            let leaseURLs = try? FileManager.default.contentsOfDirectory(
                at: leasesDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        else {
            return
        }

        for leaseURL in leaseURLs where leaseURL.pathExtension == "json" {
            guard let observedLease = decodeLease(at: leaseURL) else {
                report.deferredFailureCount += 1
                continue
            }
            guard observedLease.expiresAt < now else {
                report.skippedActiveLeaseCount += 1
                continue
            }

            do {
                try DiagnosticsJournalIdentityLock.withExclusiveLock(
                    rootURL: rootURL,
                    origin: observedLease.origin,
                    processInstanceID: observedLease.processInstanceID
                ) { [self] in
                    guard let currentLease = decodeLease(at: leaseURL) else {
                        return
                    }
                    guard
                        currentLease == observedLease,
                        let generation = generationNumber(for: generationDirectory),
                        currentLease.generation == generation,
                        currentLease.expiresAt < now
                    else {
                        report.skippedActiveLeaseCount += 1
                        return
                    }
                    guard readControl() != nil else {
                        report.deferredFailureCount += 1
                        return
                    }

                    let reclaimedDirectory = generationDirectory.appendingPathComponent(
                        "reclaimed",
                        isDirectory: true
                    )
                    let tombstoneURL = reclaimedDirectory.appendingPathComponent(leaseURL.lastPathComponent)
                    if let tombstone = decodeTombstone(at: tombstoneURL) {
                        guard tombstoneMatches(tombstone, lease: currentLease) else {
                            report.deferredFailureCount += 1
                            return
                        }
                    } else if FileManager.default.fileExists(atPath: tombstoneURL.path) {
                        report.deferredFailureCount += 1
                        return
                    } else {
                        let tombstone = DiagnosticsJournalTombstone(
                            generation: currentLease.generation,
                            origin: currentLease.origin,
                            processInstanceID: currentLease.processInstanceID,
                            fence: currentLease.fence,
                            reclaimedAt: now,
                            reason: .expiredLease
                        )
                        try writeTombstone(tombstone, to: tombstoneURL)
                    }

                    // 墓碑已经阻止旧 writer 复活。即使前一次移动中断，本次也可
                    // 幂等地续做剩余的 open 段，然后最后才撤销 lease。
                    let recoveredCount = try moveOpenSegmentsToRecoveredSeal(
                        for: currentLease,
                        in: generationDirectory
                    )
                    try FileManager.default.removeItem(at: leaseURL)
                    report.recoveredOpenSegmentCount += recoveredCount
                }
            } catch DiagnosticsJournalError.lockBusy {
                report.skippedBusyLeaseCount += 1
            } catch {
                report.deferredFailureCount += 1
            }
        }
    }

    private func generationDirectories() -> [URL] {
        guard
            let directories = try? FileManager.default.contentsOfDirectory(
                at: rootURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
        else {
            return []
        }
        return directories.filter {
            $0.lastPathComponent.dropFirst().allSatisfy(\.isNumber)
                && $0.lastPathComponent.hasPrefix("g")
        }
    }

    private func generationNumber(for directory: URL) -> UInt64? {
        UInt64(directory.lastPathComponent.dropFirst())
    }

    private func sealedAndOpenSegments(report: inout Report) -> [Segment] {
        var segments: [Segment] = []
        for generationDirectory in generationDirectories() {
            for (name, kind) in [("open", SegmentKind.open), ("sealed", SegmentKind.sealed)] {
                let directory = generationDirectory.appendingPathComponent(name, isDirectory: true)
                guard
                    let files = try? FileManager.default.contentsOfDirectory(
                        at: directory,
                        includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
                        options: [.skipsHiddenFiles]
                    )
                else {
                    continue
                }
                for file in files where file.pathExtension == "jsonl" {
                    do {
                        let values = try file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                        guard let byteCount = values.fileSize, let modifiedAt = values.contentModificationDate else {
                            report.deferredFailureCount += 1
                            continue
                        }
                        segments.append(
                            Segment(
                                url: file,
                                kind: kind,
                                byteCount: byteCount,
                                modifiedAt: modifiedAt,
                                writerIdentity: writerIdentity(for: file)
                            )
                        )
                    } catch {
                        report.deferredFailureCount += 1
                    }
                }
            }
        }
        return segments
    }

    private func deleteSealed(_ segment: Segment, report: inout Report) -> Bool {
        guard let writerIdentity = segment.writerIdentity else {
            report.deferredFailureCount += 1
            return false
        }
        do {
            try DiagnosticsJournalIdentityLock.withExclusiveLock(
                rootURL: rootURL,
                origin: writerIdentity.origin,
                processInstanceID: writerIdentity.processInstanceID
            ) {
                // 封存段是 writer 的终态，但仍在同一 stable identity lock 内
                // 复核其位置；这样 retention 不会与同一 identity 的 seal/reclaim
                // 交叉删除一个已被替换或移动的路径。
                guard FileManager.default.fileExists(atPath: segment.url.path) else {
                    throw DiagnosticsJournalError.ioFailure
                }
                try FileManager.default.removeItem(at: segment.url)
            }
            report.deletedSealedSegmentCount += 1
            return true
        } catch DiagnosticsJournalError.lockBusy {
            report.skippedBusyLeaseCount += 1
            return false
        } catch {
            report.deferredFailureCount += 1
            return false
        }
    }

    private func writerIdentity(for segmentURL: URL) -> WriterIdentity? {
        var name = segmentURL.deletingPathExtension().lastPathComponent
        if name.hasPrefix("recovered-") {
            name.removeFirst("recovered-".count)
        }
        for origin in DiagnosticEvent.Origin.allCases {
            let prefix = "\(origin.rawValue)-"
            guard name.hasPrefix(prefix) else { continue }
            let remaining = name.dropFirst(prefix.count)
            guard remaining.count >= 36 else { return nil }
            let uuidText = String(remaining.prefix(36))
            guard let processInstanceID = UUID(uuidString: uuidText) else { return nil }
            return WriterIdentity(origin: origin, processInstanceID: processInstanceID)
        }
        return nil
    }

    private func moveOpenSegmentsToRecoveredSeal(
        for lease: DiagnosticsJournalLease,
        in generationDirectory: URL
    ) throws -> Int {
        let openDirectory = generationDirectory.appendingPathComponent("open", isDirectory: true)
        guard FileManager.default.fileExists(atPath: openDirectory.path) else { return 0 }
        let sealedDirectory = generationDirectory.appendingPathComponent("sealed", isDirectory: true)
        try FileManager.default.createDirectory(at: sealedDirectory, withIntermediateDirectories: true)
        let prefix = "\(lease.origin.rawValue)-\(lease.processInstanceID.uuidString)-"
        let files = try FileManager.default.contentsOfDirectory(
            at: openDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        var movedCount = 0
        for file in files where file.pathExtension == "jsonl" && file.lastPathComponent.hasPrefix(prefix) {
            let recoveredURL = sealedDirectory.appendingPathComponent("recovered-\(file.lastPathComponent)")
            guard !FileManager.default.fileExists(atPath: recoveredURL.path) else {
                throw DiagnosticsJournalError.writeFailed
            }
            try FileManager.default.moveItem(at: file, to: recoveredURL)
            movedCount += 1
        }
        return movedCount
    }

    private func readControl() -> DiagnosticsJournalControl? {
        let url = rootURL.appendingPathComponent("control.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(DiagnosticsJournalControl.self, from: data)
    }

    private func decodeLease(at url: URL) -> DiagnosticsJournalLease? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(DiagnosticsJournalLease.self, from: data)
    }

    private func decodeTombstone(at url: URL) -> DiagnosticsJournalTombstone? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(DiagnosticsJournalTombstone.self, from: data)
    }

    private func tombstoneMatches(
        _ tombstone: DiagnosticsJournalTombstone,
        lease: DiagnosticsJournalLease
    ) -> Bool {
        tombstone.schemaVersion == DiagnosticsJournalTombstone.schemaVersion
            && tombstone.generation == lease.generation
            && tombstone.origin == lease.origin
            && tombstone.processInstanceID == lease.processInstanceID
            && tombstone.fence == lease.fence
    }

    private func writeTombstone(_ tombstone: DiagnosticsJournalTombstone, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(tombstone).write(to: url, options: .atomic)
    }
}
