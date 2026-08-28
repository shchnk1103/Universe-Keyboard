import Foundation

/// Immutable ownership proof for one URLSession-produced temporary artifact.
/// Cleanup never accepts an unregistered URL by itself.
nonisolated struct SchemaOwnedTemporaryArtifact: Equatable, Sendable {
    let operationID: UUID
    let attemptID: UUID
    let sourceID: String
    let artifactID: UUID
    let localURL: URL
}

/// Process-local capability registry shared by the production downloader and
/// cleanup worker. Random identity fields alone are not cleanup authority.
actor SchemaTemporaryArtifactRegistry {
    static let live = SchemaTemporaryArtifactRegistry()

    private struct Key: Hashable {
        let operationID: UUID
        let attemptID: UUID
        let sourceID: String
        let artifactID: UUID
    }

    private var registrations: [Key: URL] = [:]

    func register(_ artifact: SchemaOwnedTemporaryArtifact) throws {
        let key = Self.key(for: artifact)
        guard registrations[key] == nil else {
            throw DownloadError.temporaryArtifactRegistrationFailed
        }
        registrations[key] = artifact.localURL.standardizedFileURL
    }

    /// Consumes the downloader's registration. Field-equal identities without
    /// this claim cannot authorize cleanup or fallback.
    func claim(_ artifact: SchemaOwnedTemporaryArtifact) -> SchemaTemporaryArtifactClaim? {
        let key = Self.key(for: artifact)
        guard registrations[key] == artifact.localURL.standardizedFileURL else { return nil }
        registrations.removeValue(forKey: key)
        return SchemaTemporaryArtifactClaim(artifact: artifact)
    }

    private static func key(for artifact: SchemaOwnedTemporaryArtifact) -> Key {
        Key(
            operationID: artifact.operationID,
            attemptID: artifact.attemptID,
            sourceID: artifact.sourceID,
            artifactID: artifact.artifactID
        )
    }
}

/// Proof that the downloader registered this exact artifact. Only the registry
/// can mint it, so a later receipt cannot be assembled from matching UUIDs.
nonisolated struct SchemaTemporaryArtifactClaim: Equatable, Sendable {
    fileprivate let artifact: SchemaOwnedTemporaryArtifact

    fileprivate init(artifact: SchemaOwnedTemporaryArtifact) {
        self.artifact = artifact
    }
}

nonisolated struct SchemaTemporaryCleanupReceipt: Equatable, Sendable {
    enum Outcome: Equatable, Sendable {
        case removed
        case alreadyAbsent
    }

    let operationID: UUID
    let attemptID: UUID
    let sourceID: String
    let artifactID: UUID
    let outcome: Outcome

    fileprivate init(claim: SchemaTemporaryArtifactClaim, outcome: Outcome) {
        let artifact = claim.artifact
        operationID = artifact.operationID
        attemptID = artifact.attemptID
        sourceID = artifact.sourceID
        artifactID = artifact.artifactID
        self.outcome = outcome
    }

    func provesRemoval(of artifact: SchemaOwnedTemporaryArtifact) -> Bool {
        let matchesArtifact =
            operationID == artifact.operationID
            && attemptID == artifact.attemptID
            && sourceID == artifact.sourceID
            && artifactID == artifact.artifactID
        switch outcome {
        case .removed, .alreadyAbsent:
            return matchesArtifact
        }
    }
}

/// Shared fail-closed remover for URLSession copies that never reached the
/// registry. Best-effort `try?` is not sufficient on these branches.
nonisolated enum SchemaTemporaryFile {
    static func removeAndVerifyAbsent(_ url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error as CocoaError where error.code == .fileNoSuchFile {
            return
        } catch {
            throw DownloadError.temporaryCleanupFailed
        }
        guard !FileManager.default.fileExists(atPath: url.path) else {
            throw DownloadError.temporaryCleanupFailed
        }
    }
}

nonisolated protocol SchemaTemporaryArtifactCleaning: Sendable {
    func removeAndVerifyAbsent(_ artifact: SchemaOwnedTemporaryArtifact) async throws
        -> SchemaTemporaryCleanupReceipt
}

/// Dedicated fail-closed cleanup worker used before integrity fallback. General
/// end-of-operation housekeeping remains best effort and is intentionally
/// separate from this correctness barrier.
nonisolated struct FileSystemSchemaTemporaryArtifactCleaner: SchemaTemporaryArtifactCleaning {
    private let registry: SchemaTemporaryArtifactRegistry
    private let removeItem: @Sendable (URL) throws -> Void
    private let itemExists: @Sendable (URL) throws -> Bool

    init(
        registry: SchemaTemporaryArtifactRegistry = .live,
        removeItem: @escaping @Sendable (URL) throws -> Void = {
            try FileManager.default.removeItem(at: $0)
        },
        itemExists: @escaping @Sendable (URL) throws -> Bool = {
            do {
                _ = try $0.resourceValues(forKeys: [.isRegularFileKey])
                return true
            } catch let error as CocoaError
                where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile
            {
                return false
            }
        }
    ) {
        self.registry = registry
        self.removeItem = removeItem
        self.itemExists = itemExists
    }

    func removeAndVerifyAbsent(_ artifact: SchemaOwnedTemporaryArtifact) async throws
        -> SchemaTemporaryCleanupReceipt
    {
        guard let claim = await registry.claim(artifact) else {
            throw DownloadError.temporaryCleanupFailed
        }
        return try await Task.detached(priority: .utility) {
            let outcome: SchemaTemporaryCleanupReceipt.Outcome
            do {
                try removeItem(artifact.localURL)
                outcome = .removed
            } catch let error as CocoaError where error.code == .fileNoSuchFile {
                outcome = .alreadyAbsent
            } catch {
                throw DownloadError.temporaryCleanupFailed
            }

            do {
                guard try !itemExists(artifact.localURL) else {
                    throw DownloadError.temporaryCleanupFailed
                }
            } catch {
                if let error = error as? DownloadError { throw error }
                throw DownloadError.temporaryCleanupFailed
            }

            return SchemaTemporaryCleanupReceipt(
                claim: claim,
                outcome: outcome
            )
        }.value
    }
}
