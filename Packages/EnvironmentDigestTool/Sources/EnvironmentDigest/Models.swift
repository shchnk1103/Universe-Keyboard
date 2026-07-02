import Foundation

public enum DigestProfile: String, Codable, Sendable {
    case schema
    case sharedRuntime = "shared-runtime"
    case userConfiguration = "user-configuration"
    case effectiveConfiguration = "effective-configuration"
    case cleanState = "clean-state"
}

/// The caller must classify the supplied root. The tool cannot promote source or fixture bytes
/// into deployed-runtime evidence by inspecting a path name.
public enum RootProvenance: String, Codable, Sendable {
    case deployedRuntime = "deployed-runtime"
    case controlledFixture = "controlled-fixture"
    case sourceTree = "source-tree"
    case appBundle = "app-bundle"
    case archiveExtraction = "archive-extraction"
    case preferencesDatabase = "preferences-database"
    case temporary = "temporary"
    case backup
    case externalDownload = "external-download"
}

public enum EvidenceClassification: String, Codable, Sendable {
    case controlledFixture = "fixture-evidence-only"
    case captureBound = "caller-bound-capture-input"
}

public enum DigestFailureCode: String, Codable, Sendable {
    case missingRoot
    case missingRequiredInput
    case unreadableInput
    case unsupportedInput
    case forbiddenInput
    case nonRegularInput
    case symlinkInput
    case pathNormalizationCollision
    case inputChangedDuringRead
    case invalidCleanStateFact
    case mixedEnvironmentIdentity
    case wrongSchemaIdentity
}

public struct DigestFailure: Error, Equatable, Sendable, CustomStringConvertible {
    public let code: DigestFailureCode
    public let path: String?

    public init(_ code: DigestFailureCode, path: String? = nil) {
        self.code = code
        self.path = path
    }

    public var description: String {
        path.map { "\(code.rawValue): \($0)" } ?? code.rawValue
    }
}

public struct FileManifestEntry: Equatable, Sendable {
    public let contentDigest: String
    public let path: String
    public let size: UInt64
}

public struct ExclusionEntry: Equatable, Sendable {
    public let path: String
    public let reason: String
}

public struct DistributionArtifactApproval: Equatable, Sendable {
    public let path: String
    public let authority: String
    public let evidenceReference: String
    public let environmentIdentity: String

    public init(path: String, authority: String, evidenceReference: String, environmentIdentity: String) {
        self.path = path
        self.authority = authority
        self.evidenceReference = evidenceReference
        self.environmentIdentity = environmentIdentity
    }
}

public enum FactValue: Equatable, Sendable {
    case string(String)
    case bool(Bool)
    case integer(UInt64)
    case null
}

public struct CleanStateFact: Equatable, Sendable {
    public let name: String
    public let value: FactValue
    public let source: String
    public let environmentIdentity: String

    public init(name: String, value: FactValue, source: String, environmentIdentity: String) {
        self.name = name
        self.value = value
        self.source = source
        self.environmentIdentity = environmentIdentity
    }
}

public struct FilesystemDigestRequest: Sendable {
    public let profile: DigestProfile
    public let root: URL
    public let schemaIdentity: String
    public let environmentIdentity: String
    public let provenance: RootProvenance
    public let authorizedCaller: String
    public let sourceClassification: String
    public let implementationCommit: String
    public let distributionCustomPhraseApproval: DistributionArtifactApproval?
    public let explicitlyProhibitedPaths: Set<String>

    public init(
        profile: DigestProfile,
        root: URL,
        schemaIdentity: String = "rime_ice",
        environmentIdentity: String,
        provenance: RootProvenance,
        authorizedCaller: String,
        sourceClassification: String,
        implementationCommit: String,
        distributionCustomPhraseApproval: DistributionArtifactApproval? = nil,
        explicitlyProhibitedPaths: Set<String> = []
    ) {
        self.profile = profile
        self.root = root
        self.schemaIdentity = schemaIdentity
        self.environmentIdentity = environmentIdentity
        self.provenance = provenance
        self.authorizedCaller = authorizedCaller
        self.sourceClassification = sourceClassification
        self.implementationCommit = implementationCommit
        self.distributionCustomPhraseApproval = distributionCustomPhraseApproval
        self.explicitlyProhibitedPaths = explicitlyProhibitedPaths
    }
}

public struct ProvenanceEnvelope: Equatable, Sendable {
    public let toolVersion: String
    public let implementationCommit: String
    public let profile: DigestProfile
    public let authorizedCaller: String
    public let sourceClassification: String
    public let evidenceClassification: String
    public let environmentIdentity: String
    public let manifestDigest: String
    public let distributionArtifactApprovals: [DistributionArtifactApproval]
}

public struct DigestResult: Equatable, Sendable {
    public let profile: DigestProfile
    public let manifest: Data
    public let manifestDigest: String
    public let entries: [FileManifestEntry]
    public let exclusions: [ExclusionEntry]
    public let envelope: ProvenanceEnvelope
}
