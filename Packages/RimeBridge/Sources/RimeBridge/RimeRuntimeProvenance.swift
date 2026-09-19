import Foundation

/// A content-free digest for one file admitted by a scheme installation plan.
///
/// The receipt stores hashes and byte counts only. It never stores schema,
/// dictionary, user-input, candidate, or host text.
public struct RimeRuntimeProvenanceFile: Codable, Equatable, Sendable {
    public let relativePath: String
    public let byteCount: Int64
    public let sha256: String

    public init(relativePath: String, byteCount: Int64, sha256: String) {
        self.relativePath = relativePath
        self.byteCount = byteCount
        self.sha256 = sha256.lowercased()
    }
}

/// The post-deployment content identity of one plan-owned file set.
public struct RimeRuntimeProvenanceContent: Codable, Equatable, Sendable {
    public let files: [RimeRuntimeProvenanceFile]
    public let contentSHA256: String

    public init(files: [RimeRuntimeProvenanceFile], contentSHA256: String) {
        self.files = files
        self.contentSHA256 = contentSHA256.lowercased()
    }
}

/// The bounded identity passed from Main-App deployment to Extension queries.
///
/// This is intentionally smaller than the persisted receipt. A query event only
/// needs a stable receipt ID to bind itself to the separately captured receipt;
/// copying the full manifest into every event would add noise without improving
/// the provenance claim.
public struct RimeRuntimeProvenanceIdentity: Equatable, Sendable {
    public let receiptID: UUID
    public let schemeID: String
    public let activeSchemaID: String
    public let librimeVersion: String
    public let archiveSHA256: String?
    public let stagedContentSHA256: String?
    public let installedContentSHA256: String?

    public init(
        receiptID: UUID,
        schemeID: String,
        activeSchemaID: String,
        librimeVersion: String,
        archiveSHA256: String?,
        stagedContentSHA256: String?,
        installedContentSHA256: String?
    ) {
        self.receiptID = receiptID
        self.schemeID = schemeID
        self.activeSchemaID = activeSchemaID
        self.librimeVersion = librimeVersion
        self.archiveSHA256 = archiveSHA256
        self.stagedContentSHA256 = stagedContentSHA256
        self.installedContentSHA256 = installedContentSHA256
    }
}

/// Main-App-owned receipt for the exact runtime generation consumed by the
/// keyboard Extension.
///
/// `stagedContentSHA256` is the catalog-bound pre-install identity. The
/// `installedContentSHA256` and `installedFiles` values are a separate live
/// post-deployment observation because Main-App post-processing and librime
/// deployment may transform the shared tree after staging.
public struct RimeRuntimeProvenanceReceipt: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 1

    public enum Source: String, Codable, Equatable, Sendable {
        case builtin
        case downloaded
    }

    public let schemaVersion: Int
    public let receiptID: UUID
    public let generatedAt: Date
    public let schemeID: String
    public let activeSchemaID: String
    public let source: Source
    public let sourceVariantID: String?
    public let upstreamRevision: String?
    public let artifactVersion: String?
    public let artifactIdentityID: String?
    public let stagedIdentityID: String?
    public let archiveSHA256: String?
    public let stagedContentSHA256: String?
    public let installedContentSHA256: String?
    public let installationPlanRevision: String?
    public let postProcessingRevision: String?
    public let luaAvailable: Bool
    public let librimeVersion: String
    public let runtimeSmokePassed: Bool
    public let luaRuntimeSmokePassed: Bool?
    public let installedFiles: [RimeRuntimeProvenanceFile]

    public init(
        receiptID: UUID = UUID(),
        generatedAt: Date = Date(),
        schemeID: String,
        activeSchemaID: String,
        source: Source,
        sourceVariantID: String? = nil,
        upstreamRevision: String? = nil,
        artifactVersion: String? = nil,
        artifactIdentityID: String? = nil,
        stagedIdentityID: String? = nil,
        archiveSHA256: String? = nil,
        stagedContentSHA256: String? = nil,
        installedContentSHA256: String? = nil,
        installationPlanRevision: String? = nil,
        postProcessingRevision: String? = nil,
        luaAvailable: Bool,
        librimeVersion: String,
        runtimeSmokePassed: Bool,
        luaRuntimeSmokePassed: Bool? = nil,
        installedFiles: [RimeRuntimeProvenanceFile] = []
    ) {
        schemaVersion = Self.currentSchemaVersion
        self.receiptID = receiptID
        self.generatedAt = generatedAt
        self.schemeID = schemeID
        self.activeSchemaID = activeSchemaID
        self.source = source
        self.sourceVariantID = sourceVariantID
        self.upstreamRevision = upstreamRevision
        self.artifactVersion = artifactVersion
        self.artifactIdentityID = artifactIdentityID
        self.stagedIdentityID = stagedIdentityID
        self.archiveSHA256 = archiveSHA256?.lowercased()
        self.stagedContentSHA256 = stagedContentSHA256?.lowercased()
        self.installedContentSHA256 = installedContentSHA256?.lowercased()
        self.installationPlanRevision = installationPlanRevision
        self.postProcessingRevision = postProcessingRevision
        self.luaAvailable = luaAvailable
        self.librimeVersion = librimeVersion
        self.runtimeSmokePassed = runtimeSmokePassed
        self.luaRuntimeSmokePassed = luaRuntimeSmokePassed
        self.installedFiles = installedFiles
    }

    /// Safe identity projection for Extension-side query events.
    public var identity: RimeRuntimeProvenanceIdentity {
        RimeRuntimeProvenanceIdentity(
            receiptID: receiptID,
            schemeID: schemeID,
            activeSchemaID: activeSchemaID,
            librimeVersion: librimeVersion,
            archiveSHA256: archiveSHA256,
            stagedContentSHA256: stagedContentSHA256,
            installedContentSHA256: installedContentSHA256
        )
    }

    /// Runtime receipt validation is deliberately stricter than JSON decoding.
    /// A malformed or stale receipt must become unavailable, never “best effort”.
    public var isValid: Bool {
        guard schemaVersion == Self.currentSchemaVersion,
            Self.isIdentifier(schemeID),
            Self.isIdentifier(activeSchemaID),
            Self.isIdentifier(librimeVersion),
            generatedAt.timeIntervalSince1970.isFinite,
            Self.hasValidFileSet(installedFiles)
        else { return false }

        switch source {
        case .builtin:
            return sourceVariantID == nil
                && upstreamRevision == nil
                && artifactVersion == nil
                && artifactIdentityID == nil
                && stagedIdentityID == nil
                && archiveSHA256 == nil
                && stagedContentSHA256 == nil
                && installationPlanRevision == nil
                && postProcessingRevision == nil
                && installedContentSHA256 == nil
                && installedFiles.isEmpty
                && runtimeSmokePassed
        case .downloaded:
            guard Self.isIdentifier(sourceVariantID),
                Self.isIdentifier(upstreamRevision),
                Self.isIdentifier(artifactVersion),
                Self.isIdentifier(artifactIdentityID),
                Self.isIdentifier(stagedIdentityID),
                Self.isIdentifier(installationPlanRevision),
                Self.isIdentifier(postProcessingRevision),
                Self.isSHA256(archiveSHA256),
                Self.isSHA256(stagedContentSHA256),
                Self.isSHA256(installedContentSHA256),
                !installedFiles.isEmpty
            else { return false }
            return runtimeSmokePassed
        }
    }

    private static func hasValidFileSet(_ files: [RimeRuntimeProvenanceFile]) -> Bool {
        guard files.count <= 4096 else { return false }
        var previousPath: String?
        for file in files {
            guard isRelativePath(file.relativePath),
                file.byteCount >= 0,
                isSHA256(file.sha256),
                previousPath == nil || previousPath! < file.relativePath
            else { return false }
            previousPath = file.relativePath
        }
        return true
    }

    private static func isIdentifier(_ value: String?) -> Bool {
        guard let value, (1...256).contains(value.utf8.count) else { return false }
        return value.unicodeScalars.allSatisfy { scalar in
            (48...57).contains(scalar.value)
                || (65...90).contains(scalar.value)
                || (97...122).contains(scalar.value)
                || scalar.value == 45
                || scalar.value == 46
                || scalar.value == 95
        }
    }

    private static func isRelativePath(_ value: String) -> Bool {
        guard (1...512).contains(value.utf8.count),
            !value.hasPrefix("/"),
            !value.hasSuffix("/"),
            !value.contains("//")
        else { return false }
        return value.split(separator: "/", omittingEmptySubsequences: false)
            .allSatisfy { !$0.isEmpty && $0 != "." && $0 != ".." }
    }

    private static func isSHA256(_ value: String?) -> Bool {
        guard let value, value.count == 64 else { return false }
        let allowed = CharacterSet(charactersIn: "0123456789abcdef")
        return value.unicodeScalars.allSatisfy(allowed.contains)
    }
}

/// Atomic persistence for the Main-App-owned runtime receipt.
public enum RimeRuntimeProvenanceStore {
    public static let fileName = "rime-runtime-provenance.json"

    public static func load(from userDataURL: URL) -> RimeRuntimeProvenanceReceipt? {
        let url = userDataURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url),
            let receipt = try? decode(data),
            receipt.isValid
        else { return nil }
        return receipt
    }

    public static func write(
        _ receipt: RimeRuntimeProvenanceReceipt,
        to userDataURL: URL
    ) throws {
        guard receipt.isValid else { throw RimeRuntimeProvenanceStoreError.invalidReceipt }
        try FileManager.default.createDirectory(
            at: userDataURL,
            withIntermediateDirectories: true
        )
        let data = try encode(receipt)
        try data.write(
            to: userDataURL.appendingPathComponent(fileName),
            options: .atomic
        )
    }

    /// Invalidates only the metadata receipt. RIME resources remain untouched;
    /// the next successful Main-App deployment must mint a new receipt.
    public static func invalidate(at userDataURL: URL) {
        try? FileManager.default.removeItem(
            at: userDataURL.appendingPathComponent(fileName)
        )
    }

    /// Convenience invalidation used by settings/deployment mutation paths.
    public static func invalidateInAppGroup() {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.DoubleShy0N.Universe-Keyboard"
            )
        else { return }
        invalidate(at: containerURL.appendingPathComponent("Rime/user", isDirectory: true))
    }

    private static func encode(_ receipt: RimeRuntimeProvenanceReceipt) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(receipt)
    }

    private static func decode(_ data: Data) throws -> RimeRuntimeProvenanceReceipt {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RimeRuntimeProvenanceReceipt.self, from: data)
    }
}

public enum RimeRuntimeProvenanceStoreError: Error {
    case invalidReceipt
}
