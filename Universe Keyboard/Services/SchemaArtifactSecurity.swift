import CryptoKit
import Foundation
import KeyboardCore

/// The probe is advisory reachability metadata; archive verification remains mandatory.
nonisolated enum SchemaSourceProbeResult: Equatable, Sendable {
    case available
    case rejected(DiagnosticEvent.SchemeSourceProbeFailure)
}

nonisolated protocol SchemaSourceSelecting: Sendable {
    func selectSource(from variants: [RimeSchemeSourceVariant], preferredSourceID: String?) async throws
        -> RimeSchemeSourceVariant
    func selectSource(
        from variants: [RimeSchemeSourceVariant], preferredSourceID: String?,
        onProbe: @escaping @Sendable (RimeSchemeSourceVariant, SchemaSourceProbeResult) -> Void
    ) async throws -> RimeSchemeSourceVariant
}

extension SchemaSourceSelecting {
    func selectSource(
        from variants: [RimeSchemeSourceVariant], preferredSourceID: String?,
        onProbe: @escaping @Sendable (RimeSchemeSourceVariant, SchemaSourceProbeResult) -> Void
    ) async throws -> RimeSchemeSourceVariant {
        try await selectSource(from: variants, preferredSourceID: preferredSourceID)
    }
}

nonisolated protocol SchemaSourceProbing: Sendable {
    func isReachable(_ variant: RimeSchemeSourceVariant) async throws -> Bool
    func probeSource(_ variant: RimeSchemeSourceVariant) async throws -> SchemaSourceProbeResult
}

extension SchemaSourceProbing {
    func probeSource(_ variant: RimeSchemeSourceVariant) async throws -> SchemaSourceProbeResult {
        try await isReachable(variant) ? .available : .rejected(.transport)
    }
}

/// At most two header-only probes race; cancelled losers never become failures.
nonisolated struct URLSessionSchemaSourceSelector: SchemaSourceSelecting {
    private let probe: any SchemaSourceProbing
    private let hedgeDelayNanoseconds: UInt64

    init(
        probe: any SchemaSourceProbing = URLSessionHEADSchemaSourceProbe(),
        hedgeDelayNanoseconds: UInt64 = 250_000_000
    ) {
        self.probe = probe
        self.hedgeDelayNanoseconds = hedgeDelayNanoseconds
    }

    func selectSource(from variants: [RimeSchemeSourceVariant], preferredSourceID: String?) async throws
        -> RimeSchemeSourceVariant
    {
        try await selectSource(from: variants, preferredSourceID: preferredSourceID, onProbe: { _, _ in })
    }

    func selectSource(
        from variants: [RimeSchemeSourceVariant], preferredSourceID: String?,
        onProbe: @escaping @Sendable (RimeSchemeSourceVariant, SchemaSourceProbeResult) -> Void
    ) async throws -> RimeSchemeSourceVariant {
        var ordered = variants
        if let preferredSourceID, let index = ordered.firstIndex(where: { $0.id == preferredSourceID }) {
            ordered.insert(ordered.remove(at: index), at: 0)
        }
        guard !ordered.isEmpty else { throw DownloadError.allSourcesUnavailable }
        return try await withThrowingTaskGroup(of: (RimeSchemeSourceVariant, SchemaSourceProbeResult).self) { group in
            for (index, variant) in ordered.prefix(2).enumerated() {
                group.addTask {
                    if index > 0 { try await Task.sleep(nanoseconds: self.hedgeDelayNanoseconds * UInt64(index)) }
                    let result = try await self.probe.probeSource(variant)
                    try Task.checkCancellation()
                    return (variant, result)
                }
            }
            var sawChangedArtifact = false
            while let (variant, result) = try await group.next() {
                try Task.checkCancellation()
                onProbe(variant, result)
                if result == .available {
                    group.cancelAll()
                    return variant
                }
                if result == .rejected(.archiveSize) { sawChangedArtifact = true }
            }
            // Mixed unavailable/changed sources still must not be presented as a network-only failure.
            throw sawChangedArtifact ? DownloadError.sourceArtifactChanged : DownloadError.allSourcesUnavailable
        }
    }
}

nonisolated struct URLSessionHEADSchemaSourceProbe: SchemaSourceProbing {
    private let response: @Sendable (URLRequest) async throws -> URLResponse

    init(
        response: @escaping @Sendable (URLRequest) async throws -> URLResponse = { request in
            let (_, response) = try await URLSession.shared.data(for: request)
            return response
        }
    ) {
        self.response = response
    }

    func isReachable(_ variant: RimeSchemeSourceVariant) async throws -> Bool {
        try await probeSource(variant) == .available
    }

    func probeSource(_ variant: RimeSchemeSourceVariant) async throws -> SchemaSourceProbeResult {
        var request = URLRequest(url: variant.downloadURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        do {
            let response = try await response(request)
            try Task.checkCancellation()
            guard let http = response as? HTTPURLResponse else { return .rejected(.nonHTTP) }
            guard (200...299).contains(http.statusCode) else { return .rejected(.httpStatus) }
            guard let host = http.url?.host?.lowercased(), variant.allowedRedirectHosts.contains(host) else {
                return .rejected(.redirectHost)
            }
            let count = response.expectedContentLength
            guard count <= 0 || count == variant.expectedByteCount else { return .rejected(.archiveSize) }
            return .available
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            try Task.checkCancellation()
            return .rejected(.transport)
        }
    }
}

nonisolated struct SchemaArtifactVerifier: Sendable {
    func verifyArchive(
        at archiveURL: URL,
        source: RimeSchemeSourceVariant
    ) throws -> String {
        try verifyArchiveSize(at: archiveURL, source: source)
        return try verifyArchiveDigest(at: archiveURL, source: source)
    }

    func verifyArchiveSize(at archiveURL: URL, source: RimeSchemeSourceVariant) throws {
        let values = try archiveURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard values.isRegularFile == true else {
            throw DownloadError.corruptArchive
        }
        let actualByteCount = Int64(values.fileSize ?? -1)
        guard actualByteCount == source.expectedByteCount else {
            throw DownloadError.integrityMismatch(
                .archiveSize(expected: source.expectedByteCount, actual: actualByteCount)
            )
        }
    }

    func verifyArchiveDigest(at archiveURL: URL, source: RimeSchemeSourceVariant) throws -> String {
        let digest = try sha256(of: archiveURL)
        guard digest == source.archiveSHA256.lowercased() else {
            throw DownloadError.integrityMismatch(
                .archiveDigest(expected: source.archiveSHA256.lowercased(), actual: digest)
            )
        }
        return digest
    }

    /// Hashes exactly the files admitted by the installation allowlist after
    /// deterministic schema post-processing. Path, byte count and file bytes
    /// are all bound into the receipt so source variants cannot hide drift.
    func stagedContentSHA256(
        in extractionDirectory: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws -> String {
        let fileManager = FileManager.default
        guard
            let enumerator = fileManager.enumerator(
                at: extractionDirectory,
                includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )
        else {
            throw DownloadError.corruptArchive
        }

        var admittedFiles: [(relativePath: String, url: URL, byteCount: UInt64)] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(
                forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]
            )
            if values.isSymbolicLink == true {
                throw DownloadError.corruptArchive
            }
            guard values.isRegularFile == true else { continue }

            let relativePath = try plan.normalizedRelativePath(
                for: fileURL,
                under: extractionDirectory
            )
            guard plan.shouldInstall(relativePath: relativePath, luaAvailable: luaAvailable) else {
                continue
            }
            admittedFiles.append(
                (relativePath, fileURL, UInt64(values.fileSize ?? 0))
            )
        }

        guard admittedFiles.contains(where: { $0.relativePath == plan.schemaFileName }) else {
            throw DownloadError.corruptArchive
        }

        var hasher = SHA256()
        for file in admittedFiles.sorted(by: { $0.relativePath < $1.relativePath }) {
            hasher.update(data: Data(file.relativePath.utf8))
            hasher.update(data: Data([0]))
            var byteCount = file.byteCount.bigEndian
            withUnsafeBytes(of: &byteCount) { hasher.update(bufferPointer: $0) }
            try update(&hasher, withContentsOf: file.url)
            hasher.update(data: Data([0]))
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func sha256(of url: URL) throws -> String {
        var hasher = SHA256()
        try update(&hasher, withContentsOf: url)
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func update(_ hasher: inout SHA256, withContentsOf url: URL) throws {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        while let data = try handle.read(upToCount: 1_048_576), !data.isEmpty {
            hasher.update(data: data)
        }
    }
}

nonisolated protocol SchemaArtifactVerifying: Sendable {
    func verifyArchiveSize(at archiveURL: URL, source: RimeSchemeSourceVariant) throws
    func verifyArchiveDigest(at archiveURL: URL, source: RimeSchemeSourceVariant) throws -> String
    func stagedContentSHA256(
        in extractionDirectory: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws -> String
}

extension SchemaArtifactVerifier: SchemaArtifactVerifying {}
