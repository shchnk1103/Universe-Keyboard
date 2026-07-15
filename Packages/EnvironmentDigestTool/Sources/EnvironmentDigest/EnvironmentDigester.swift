import Darwin
import Foundation

public struct EnvironmentDigester: Sendable {
    public static let toolVersion = "1.0.0"

    private let readFile: @Sendable (URL) throws -> Data

    public init() {
        readFile = { try Data(contentsOf: $0, options: [.mappedIfSafe]) }
    }

    init(readFile: @escaping @Sendable (URL) throws -> Data) {
        self.readFile = readFile
    }

    public func digest(_ request: FilesystemDigestRequest) throws -> DigestResult {
        guard request.profile != .cleanState else {
            throw DigestFailure(.forbiddenInput)
        }
        try validateRequest(request)

        let initialSnapshot = try inventorySnapshot(for: request, failure: .unreadableInput)
        let inventory = try inventory(for: request)
        let required = requiredPaths(for: request.profile)
        for path in required where !inventory.included.contains(where: { $0.path == path }) {
            throw DigestFailure(.missingRequiredInput, path: path)
        }
        if request.profile == .sharedRuntime, inventory.included.isEmpty {
            throw DigestFailure(.missingRequiredInput)
        }

        let entries = try inventory.included.map { candidate in
            try manifestEntry(for: candidate)
        }.sorted { CanonicalJSON.utf8LessThan($0.path, $1.path) }
        let finalSnapshot = try inventorySnapshot(for: request, failure: .inputChangedDuringRead)
        guard initialSnapshot == finalSnapshot else {
            throw DigestFailure(.inputChangedDuringRead)
        }

        let manifest = filesystemManifest(
            profile: request.profile,
            root: logicalRoot(for: request.profile),
            entries: entries
        )
        return result(
            profile: request.profile,
            manifest: manifest,
            entries: entries,
            exclusions: inventory.excluded,
            environmentIdentity: request.environmentIdentity,
            evidenceClassification: request.provenance == .controlledFixture
                ? EvidenceClassification.controlledFixture.rawValue
                : "caller-bound-deployed-input",
            authorizedCaller: request.authorizedCaller,
            sourceClassification: request.sourceClassification,
            implementationCommit: request.implementationCommit,
            distributionArtifactApprovals: request.distributionCustomPhraseApproval.map { [$0] } ?? []
        )
    }

    public func digestCleanState(
        facts: [CleanStateFact],
        authorizedCaller: String,
        sourceClassification: String,
        implementationCommit: String,
        evidenceClassification: EvidenceClassification
    ) throws -> DigestResult {
        let expected = Self.cleanStateNames
        guard facts.count == expected.count, Set(facts.map(\.name)) == expected else {
            throw DigestFailure(.invalidCleanStateFact)
        }
        guard let identity = facts.first?.environmentIdentity,
            !identity.isEmpty,
            facts.allSatisfy({ $0.environmentIdentity == identity })
        else {
            throw DigestFailure(.mixedEnvironmentIdentity)
        }

        let sortedFacts = facts.sorted { CanonicalJSON.utf8LessThan($0.name, $1.name) }
        try sortedFacts.forEach(validateCleanStateFact)
        let values = sortedFacts.map { fact -> CanonicalJSON.Value in
            var body: [String: CanonicalJSON.Value] = [
                "name": .string(fact.name),
                "source": .string(fact.source),
                "value": jsonValue(fact.value),
            ]
            if Self.digestFactNames.contains(fact.name), case let .string(digest) = fact.value {
                body["digest"] = .string(digest)
            }
            return .object(body)
        }
        let manifest = CanonicalJSON.encode(
            .object([
                "algorithm": .string("sha256"),
                "facts": .array(values),
                "manifestVersion": .string("1.0.0"),
                "profile": .string(DigestProfile.cleanState.rawValue),
                "root": .string("clean-state"),
            ]))
        return result(
            profile: .cleanState,
            manifest: manifest,
            entries: [],
            exclusions: [],
            environmentIdentity: identity,
            evidenceClassification: evidenceClassification.rawValue,
            authorizedCaller: authorizedCaller,
            sourceClassification: sourceClassification,
            implementationCommit: implementationCommit,
            distributionArtifactApprovals: []
        )
    }

    private func validateRequest(_ request: FilesystemDigestRequest) throws {
        guard request.schemaIdentity == "rime_ice" else {
            throw DigestFailure(.wrongSchemaIdentity)
        }
        guard !request.environmentIdentity.isEmpty,
            !request.authorizedCaller.isEmpty,
            !request.sourceClassification.isEmpty,
            isCommit(request.implementationCommit)
        else {
            throw DigestFailure(.mixedEnvironmentIdentity)
        }
        switch request.provenance {
        case .deployedRuntime, .controlledFixture:
            break
        default:
            throw DigestFailure(.forbiddenInput)
        }
        if let approval = request.distributionCustomPhraseApproval {
            guard request.profile == .sharedRuntime,
                approval.path == "custom_phrase.txt",
                !approval.authority.isEmpty,
                !approval.evidenceReference.isEmpty,
                approval.environmentIdentity == request.environmentIdentity
            else {
                throw DigestFailure(.mixedEnvironmentIdentity, path: "custom_phrase.txt")
            }
        }
        try validateRoot(request.root)
    }

    private func validateRoot(_ root: URL) throws {
        var info = stat()
        guard lstat(root.path, &info) == 0 else {
            throw DigestFailure(.missingRoot)
        }
        let kind = info.st_mode & S_IFMT
        guard kind != S_IFLNK else { throw DigestFailure(.symlinkInput) }
        guard kind == S_IFDIR else { throw DigestFailure(.nonRegularInput) }
        guard FileManager.default.isReadableFile(atPath: root.path) else {
            throw DigestFailure(.unreadableInput)
        }
    }

    private struct Candidate {
        let url: URL
        let path: String
    }

    private struct Inventory {
        var included: [Candidate]
        var excluded: [ExclusionEntry]
    }

    private func inventory(for request: FilesystemDigestRequest) throws -> Inventory {
        let keys: [URLResourceKey] = [.isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey]
        var enumerationFailed = false
        guard
            let enumerator = FileManager.default.enumerator(
                at: request.root,
                includingPropertiesForKeys: keys,
                options: [],
                errorHandler: { _, _ in
                    enumerationFailed = true
                    return false
                }
            )
        else {
            throw DigestFailure(.unreadableInput)
        }

        var discovered: [(url: URL, path: String, isDirectory: Bool, isSymlink: Bool)] = []
        while let item = enumerator.nextObject() as? URL {
            let path = relativePath(of: item, under: request.root)
            let values: URLResourceValues
            do {
                values = try item.resourceValues(forKeys: Set(keys))
            } catch {
                throw DigestFailure(.unreadableInput, path: path)
            }
            let isDirectory = values.isDirectory == true
            let isSymlink = values.isSymbolicLink == true
            discovered.append((item, path, isDirectory, isSymlink))
            if isSymlink {
                enumerator.skipDescendants()
            }
        }
        if enumerationFailed {
            throw DigestFailure(.unreadableInput)
        }

        try validateNormalization(discovered.map(\.path))
        var inventory = Inventory(included: [], excluded: [])
        for item in discovered {
            try validatePath(item.path)
            if item.isSymlink {
                throw DigestFailure(.symlinkInput, path: item.path)
            }
            if let reason = exclusion(for: item.path, isDirectory: item.isDirectory) {
                inventory.excluded.append(.init(path: item.path, reason: reason))
                continue
            }
            if item.isDirectory { continue }
            if request.explicitlyProhibitedPaths.contains(item.path) {
                inventory.excluded.append(.init(path: item.path, reason: "user-or-host-text"))
                continue
            }
            try ensureUnambiguousRegularFile(item.url, path: item.path)
            guard isIncluded(item.path, profile: request.profile) else {
                throw DigestFailure(.unsupportedInput, path: item.path)
            }
            if request.profile == .sharedRuntime,
                item.path == "custom_phrase.txt",
                request.distributionCustomPhraseApproval == nil
            {
                throw DigestFailure(.forbiddenInput, path: item.path)
            }
            inventory.included.append(Candidate(url: item.url, path: item.path))
        }
        inventory.excluded.sort { CanonicalJSON.utf8LessThan($0.path, $1.path) }
        return inventory
    }

    private func ensureUnambiguousRegularFile(_ url: URL, path: String) throws {
        var info = stat()
        guard lstat(url.path, &info) == 0 else {
            throw DigestFailure(.inputChangedDuringRead, path: path)
        }
        guard info.st_mode & S_IFMT == S_IFREG else {
            throw DigestFailure(.nonRegularInput, path: path)
        }
        guard info.st_nlink == 1 else {
            throw DigestFailure(.nonRegularInput, path: path)
        }
    }

    private struct FileIdentity: Equatable {
        let device: dev_t
        let inode: ino_t
        let size: off_t
        let modifiedSeconds: Int
        let modifiedNanoseconds: Int
    }

    private struct InventorySnapshotEntry: Equatable {
        let path: String
        let classification: String
        let metadata: InventorySnapshotMetadata?
    }

    private struct InventorySnapshotMetadata: Equatable {
        let kind: mode_t
        let device: dev_t
        let inode: ino_t
        let size: off_t
        let modifiedSeconds: Int
        let modifiedNanoseconds: Int
    }

    private func inventorySnapshot(
        for request: FilesystemDigestRequest,
        failure: DigestFailureCode
    ) throws -> [InventorySnapshotEntry] {
        let root = request.root
        var entries: [InventorySnapshotEntry] = [
            try snapshotEntry(for: root, path: "", classification: "root", captureMetadata: true, failure: failure)
        ]
        var enumerationFailed = false
        guard
            let enumerator = FileManager.default.enumerator(
                at: root,
                includingPropertiesForKeys: [.isSymbolicLinkKey],
                options: [],
                errorHandler: { _, _ in
                    enumerationFailed = true
                    return false
                }
            )
        else {
            throw DigestFailure(failure)
        }
        while let item = enumerator.nextObject() as? URL {
            let path = relativePath(of: item, under: root)
            let values: URLResourceValues
            do {
                values = try item.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
            } catch {
                throw DigestFailure(failure, path: path)
            }
            let exclusionReason =
                exclusion(for: path, isDirectory: values.isDirectory == true)
                ?? (request.explicitlyProhibitedPaths.contains(path) ? "user-or-host-text" : nil)
            entries.append(
                try snapshotEntry(
                    for: item,
                    path: path,
                    classification: exclusionReason.map { "excluded:\($0)" } ?? "observed",
                    captureMetadata: exclusionReason == nil,
                    failure: failure
                ))
            if values.isSymbolicLink == true {
                enumerator.skipDescendants()
            }
        }
        guard !enumerationFailed else { throw DigestFailure(failure) }
        return entries.sorted { CanonicalJSON.utf8LessThan($0.path, $1.path) }
    }

    private func snapshotEntry(
        for url: URL,
        path: String,
        classification: String,
        captureMetadata: Bool,
        failure: DigestFailureCode
    ) throws -> InventorySnapshotEntry {
        guard captureMetadata else {
            return InventorySnapshotEntry(path: path, classification: classification, metadata: nil)
        }
        var info = stat()
        guard lstat(url.path, &info) == 0 else {
            throw DigestFailure(failure, path: path.isEmpty ? nil : path)
        }
        return InventorySnapshotEntry(
            path: path,
            classification: classification,
            metadata: InventorySnapshotMetadata(
                kind: info.st_mode & S_IFMT,
                device: info.st_dev,
                inode: info.st_ino,
                size: info.st_size,
                modifiedSeconds: info.st_mtimespec.tv_sec,
                modifiedNanoseconds: info.st_mtimespec.tv_nsec
            )
        )
    }

    private func identity(of url: URL, path: String) throws -> FileIdentity {
        var info = stat()
        guard lstat(url.path, &info) == 0 else {
            throw DigestFailure(.inputChangedDuringRead, path: path)
        }
        guard info.st_mode & S_IFMT == S_IFREG, info.st_nlink == 1 else {
            throw DigestFailure(.nonRegularInput, path: path)
        }
        return FileIdentity(
            device: info.st_dev,
            inode: info.st_ino,
            size: info.st_size,
            modifiedSeconds: info.st_mtimespec.tv_sec,
            modifiedNanoseconds: info.st_mtimespec.tv_nsec
        )
    }

    private func manifestEntry(for candidate: Candidate) throws -> FileManifestEntry {
        let before = try identity(of: candidate.url, path: candidate.path)
        let data: Data
        do {
            data = try readFile(candidate.url)
        } catch {
            throw DigestFailure(.unreadableInput, path: candidate.path)
        }
        let after = try identity(of: candidate.url, path: candidate.path)
        guard before == after, UInt64(data.count) == UInt64(after.size) else {
            throw DigestFailure(.inputChangedDuringRead, path: candidate.path)
        }
        return FileManifestEntry(
            contentDigest: SHA256Digest.hex(data),
            path: candidate.path,
            size: UInt64(data.count)
        )
    }

    private func filesystemManifest(
        profile: DigestProfile,
        root: String,
        entries: [FileManifestEntry]
    ) -> Data {
        let values = entries.map { entry in
            CanonicalJSON.Value.object([
                "contentDigest": .string(entry.contentDigest),
                "path": .string(entry.path),
                "size": .integer(entry.size),
                "type": .string("file"),
            ])
        }
        return CanonicalJSON.encode(
            .object([
                "algorithm": .string("sha256"),
                "entries": .array(values),
                "manifestVersion": .string("1.0.0"),
                "profile": .string(profile.rawValue),
                "root": .string(root),
            ]))
    }

    private func result(
        profile: DigestProfile,
        manifest: Data,
        entries: [FileManifestEntry],
        exclusions: [ExclusionEntry],
        environmentIdentity: String,
        evidenceClassification: String,
        authorizedCaller: String,
        sourceClassification: String,
        implementationCommit: String,
        distributionArtifactApprovals: [DistributionArtifactApproval]
    ) -> DigestResult {
        let digest = SHA256Digest.hex(manifest)
        return DigestResult(
            profile: profile,
            manifest: manifest,
            manifestDigest: digest,
            entries: entries,
            exclusions: exclusions,
            envelope: ProvenanceEnvelope(
                toolVersion: Self.toolVersion,
                implementationCommit: implementationCommit,
                profile: profile,
                authorizedCaller: authorizedCaller,
                sourceClassification: sourceClassification,
                evidenceClassification: evidenceClassification,
                environmentIdentity: environmentIdentity,
                manifestDigest: digest,
                distributionArtifactApprovals: distributionArtifactApprovals
            )
        )
    }

    private func validateCleanStateFact(_ fact: CleanStateFact) throws {
        guard fact.source == requiredSource(for: fact.name) else {
            throw DigestFailure(.invalidCleanStateFact, path: fact.name)
        }
        switch fact.name {
        case "main_app_rebuilt", "app_reinstalled", "extension_reinstalled",
            "deployment_recreated", "extension_process_restarted":
            guard case .bool = fact.value else { throw DigestFailure(.invalidCleanStateFact, path: fact.name) }
        case "unfinished_composition":
            try requireString(fact, allowed: ["absent", "present"])
        case "typo_learning_state":
            try requireString(fact, allowed: ["empty", "declared-scenario"])
        case "rime_user_state":
            try requireString(fact, allowed: ["clean-fixture", "preserved"])
        case "experiment_flags.insertion", "experiment_flags.transposition",
            "experiment_flags.typo_partial_commit":
            guard case .bool = fact.value else { throw DigestFailure(.invalidCleanStateFact, path: fact.name) }
        case _ where Self.digestFactNames.contains(fact.name):
            guard case let .string(value) = fact.value,
                value.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil
            else {
                throw DigestFailure(.invalidCleanStateFact, path: fact.name)
            }
        default:
            throw DigestFailure(.invalidCleanStateFact, path: fact.name)
        }
    }

    private func requiredSource(for name: String) -> String? {
        switch name {
        case "main_app_rebuilt": "capture_procedure"
        case "app_reinstalled", "extension_reinstalled", "extension_process_restarted": "device_observed"
        case "deployment_recreated": "runtime_observed"
        case "unfinished_composition", "experiment_flags.insertion", "experiment_flags.transposition",
            "experiment_flags.typo_partial_commit":
            "extension_runtime_observed"
        case "typo_learning_state", "rime_user_state", "schema_digest", "shared_runtime_digest",
            "user_configuration_digest", "effective_configuration_digest":
            "verified_manifest"
        default: nil
        }
    }

    private func isCommit(_ value: String) -> Bool {
        value.range(of: "^[0-9a-f]{40}$", options: .regularExpression) != nil
    }

    private func requireString(_ fact: CleanStateFact, allowed: Set<String>) throws {
        guard case let .string(value) = fact.value, allowed.contains(value) else {
            throw DigestFailure(.invalidCleanStateFact, path: fact.name)
        }
    }

    private func jsonValue(_ value: FactValue) -> CanonicalJSON.Value {
        switch value {
        case let .string(value): .string(value)
        case let .bool(value): .bool(value)
        case let .integer(value): .integer(value)
        case .null: .null
        }
    }

    private func relativePath(of url: URL, under root: URL) -> String {
        let rootPath = root.standardizedFileURL.path
        let path = url.standardizedFileURL.path
        return String(path.dropFirst(rootPath.count + 1))
    }

    func validatePath(_ path: String) throws {
        guard !path.isEmpty,
            !path.hasPrefix("/"),
            !path.hasSuffix("/"),
            !path.contains("\\"),
            !path.contains("\0"),
            !path.contains("\t"),
            !path.contains("\r"),
            !path.contains("\n"),
            !path.split(separator: "/", omittingEmptySubsequences: false).contains(where: {
                $0 == "." || $0 == ".." || $0.isEmpty
            }),
            Array(path.utf8) == Array(path.precomposedStringWithCanonicalMapping.utf8)
        else {
            throw DigestFailure(.unsupportedInput, path: path)
        }
    }

    func validateNormalization(_ paths: [String]) throws {
        var normalized = Set<[UInt8]>()
        for path in paths {
            let value = path.precomposedStringWithCanonicalMapping
            guard normalized.insert(Array(value.utf8)).inserted else {
                throw DigestFailure(.pathNormalizationCollision, path: value)
            }
        }
    }

    private func logicalRoot(for profile: DigestProfile) -> String {
        switch profile {
        case .schema, .sharedRuntime: "Rime/shared"
        case .userConfiguration: "Rime/user"
        case .effectiveConfiguration: "Rime/shared/build"
        case .cleanState: "clean-state"
        }
    }

    private func requiredPaths(for profile: DigestProfile) -> Set<String> {
        switch profile {
        case .schema, .effectiveConfiguration: ["rime_ice.schema.yaml"]
        case .userConfiguration: ["default.custom.yaml", "rime_ice.custom.yaml"]
        case .sharedRuntime, .cleanState: []
        }
    }

    private func isIncluded(_ path: String, profile: DigestProfile) -> Bool {
        switch profile {
        case .schema, .effectiveConfiguration:
            path == "rime_ice.schema.yaml"
        case .userConfiguration:
            path == "default.custom.yaml" || path == "rime_ice.custom.yaml"
        case .sharedRuntime:
            sharedRuntimeIncludes(path)
        case .cleanState:
            false
        }
    }

    private func sharedRuntimeIncludes(_ path: String) -> Bool {
        let components = path.split(separator: "/").map(String.init)
        if components.count == 1 {
            return path.hasSuffix(".yaml") || path.hasSuffix(".txt")
        }
        guard let first = components.first, let last = components.last else { return false }
        switch first {
        case "build": return last.hasSuffix(".yaml") || last.hasSuffix(".bin")
        case "cn_dicts", "en_dicts": return last.hasSuffix(".yaml")
        case "lua": return last.hasSuffix(".lua")
        case "opencc": return last.hasSuffix(".json") || last.hasSuffix(".ocd2")
        default: return false
        }
    }

    private func exclusion(for path: String, isDirectory: Bool) -> String? {
        let components = path.split(separator: "/").map(String.init)
        let name = components.last ?? path
        let ancestorDirectories = isDirectory ? components : Array(components.dropLast())
        let directoryNames = Set(ancestorDirectories)
        if ancestorDirectories.contains(where: { $0.hasSuffix(".userdb") })
            || name.hasSuffix(".userdb") || name.contains(".userdb.")
        {
            return "user-learning"
        }
        if directoryNames.contains("sync") { return "sync-data" }
        if name == "user.yaml" { return "runtime-user-metadata" }
        if components.first == "logs" || name.hasSuffix(".log") { return "runtime-log" }
        if components.first == ".cache" || components.first == "cache" { return "runtime-cache" }
        if components.first == "tmp" || components.first == "temp"
            || [".tmp", ".temp", ".partial", ".download", ".swp"].contains(where: name.hasSuffix) || name.hasSuffix("~")
        {
            return "temporary"
        }
        if [".lock", ".pid", ".socket"].contains(where: name.hasSuffix) { return "process-state" }
        if [".bak", ".backup"].contains(where: name.hasSuffix)
            || components.first == "user_dictionary_backups"
        {
            return "backup"
        }
        if components.first == "crash" || components.first == "crashes" || name.hasSuffix(".crash")
            || name.hasSuffix(".ips")
        {
            return "crash-report"
        }
        if components.first == "telemetry" || components.first == "analytics" { return "telemetry" }
        if components.first == "diagnostics" || components.first == "reports"
            || [".trace", ".memgraph"].contains(where: name.hasSuffix)
        {
            return "generated-diagnostic"
        }
        if components.first == "credentials" || components.first == "secrets"
            || [".key", ".pem", ".p12", ".mobileprovision"].contains(where: name.hasSuffix)
        {
            return "credential"
        }
        return nil
    }

    static let digestFactNames: Set<String> = [
        "schema_digest", "shared_runtime_digest", "user_configuration_digest", "effective_configuration_digest",
    ]

    static let cleanStateNames: Set<String> = [
        "main_app_rebuilt", "app_reinstalled", "extension_reinstalled", "deployment_recreated",
        "extension_process_restarted", "unfinished_composition", "typo_learning_state", "rime_user_state",
        "experiment_flags.insertion", "experiment_flags.transposition", "experiment_flags.typo_partial_commit",
        "schema_digest", "shared_runtime_digest", "user_configuration_digest", "effective_configuration_digest",
    ]
}
