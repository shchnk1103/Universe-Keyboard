import CryptoKit
import Foundation

nonisolated protocol SchemaSourceSelecting: Sendable {
    func selectSource(
        from variants: [RimeSchemeSourceVariant],
        preferredSourceID: String?
    ) async throws -> RimeSchemeSourceVariant
}

nonisolated protocol SchemaSourceProbing: Sendable {
    func isReachable(_ variant: RimeSchemeSourceVariant) async throws -> Bool
}

/// Performs a bounded, header-only reachability race after user download intent.
/// It does not infer location or run a separate payload speed test.
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

    func selectSource(
        from variants: [RimeSchemeSourceVariant],
        preferredSourceID: String?
    ) async throws -> RimeSchemeSourceVariant {
        var ordered = variants
        if let preferredSourceID,
            let preferredIndex = ordered.firstIndex(where: { $0.id == preferredSourceID })
        {
            ordered.insert(ordered.remove(at: preferredIndex), at: 0)
        }
        guard !ordered.isEmpty else { throw DownloadError.allSourcesUnavailable }

        // The product contract caps source probing at two concurrent requests.
        // Current manifests contain exactly two variants; keeping the cap here
        // prevents a future manifest expansion from silently increasing traffic.
        let candidates = Array(ordered.prefix(2))

        return try await withThrowingTaskGroup(of: RimeSchemeSourceVariant?.self) { group in
            for (index, variant) in candidates.enumerated() {
                group.addTask {
                    if index > 0 {
                        try await Task.sleep(
                            nanoseconds: self.hedgeDelayNanoseconds * UInt64(index)
                        )
                    }
                    return try await self.probe.isReachable(variant) ? variant : nil
                }
            }

            while let candidate = try await group.next() {
                if let candidate {
                    group.cancelAll()
                    return candidate
                }
            }
            throw DownloadError.allSourcesUnavailable
        }
    }
}

nonisolated struct URLSessionHEADSchemaSourceProbe: SchemaSourceProbing {
    func isReachable(_ variant: RimeSchemeSourceVariant) async throws -> Bool {
        var request = URLRequest(url: variant.downloadURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            try Task.checkCancellation()
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let finalHost = httpResponse.url?.host?.lowercased(),
                variant.allowedRedirectHosts.contains(finalHost)
            else {
                return false
            }

            let contentLength = response.expectedContentLength
            return contentLength <= 0 || contentLength == variant.expectedByteCount
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return false
        }
    }
}

nonisolated struct SchemaArtifactVerifier: Sendable {
    func verifyArchive(
        at archiveURL: URL,
        source: RimeSchemeSourceVariant
    ) throws -> String {
        let values = try archiveURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard values.isRegularFile == true else {
            throw DownloadError.corruptArchive
        }
        let actualByteCount = Int64(values.fileSize ?? -1)
        guard actualByteCount == source.expectedByteCount else {
            throw DownloadError.integrityMismatch
        }

        let digest = try sha256(of: archiveURL)
        guard digest == source.archiveSHA256.lowercased() else {
            throw DownloadError.integrityMismatch
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
    func verifyArchive(at archiveURL: URL, source: RimeSchemeSourceVariant) throws -> String
    func stagedContentSHA256(
        in extractionDirectory: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws -> String
}

extension SchemaArtifactVerifier: SchemaArtifactVerifying {}
