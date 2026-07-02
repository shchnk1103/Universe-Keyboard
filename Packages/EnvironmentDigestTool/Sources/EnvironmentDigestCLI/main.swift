import EnvironmentDigest
import Foundation

private struct Arguments {
    let profile: DigestProfile
    let root: URL
    let environmentIdentity: String
    let provenance: RootProvenance
    let authorizedCaller: String
    let sourceClassification: String
    let implementationCommit: String
    let customPhraseApproval: DistributionArtifactApproval?

    init(_ values: [String]) throws {
        func value(after flag: String) -> String? {
            guard let index = values.firstIndex(of: flag), values.indices.contains(index + 1) else { return nil }
            return values[index + 1]
        }
        guard let profileValue = value(after: "--profile"),
            let profile = DigestProfile(rawValue: profileValue), profile != .cleanState,
            let rootValue = value(after: "--root"),
            let identity = value(after: "--environment-identity"),
            let provenanceValue = value(after: "--provenance"),
            let provenance = RootProvenance(rawValue: provenanceValue),
            let caller = value(after: "--authorized-caller"),
            let source = value(after: "--source-classification"),
            let commit = value(after: "--implementation-commit")
        else {
            throw DigestFailure(.forbiddenInput)
        }
        self.profile = profile
        root = URL(fileURLWithPath: rootValue, isDirectory: true)
        environmentIdentity = identity
        self.provenance = provenance
        authorizedCaller = caller
        sourceClassification = source
        implementationCommit = commit
        let approvalAuthority = value(after: "--custom-phrase-approval-authority")
        let approvalEvidence = value(after: "--custom-phrase-approval-evidence")
        if approvalAuthority != nil || approvalEvidence != nil {
            guard let approvalAuthority, let approvalEvidence else {
                throw DigestFailure(.forbiddenInput, path: "custom_phrase.txt")
            }
            customPhraseApproval = DistributionArtifactApproval(
                path: "custom_phrase.txt",
                authority: approvalAuthority,
                evidenceReference: approvalEvidence,
                environmentIdentity: identity
            )
        } else {
            customPhraseApproval = nil
        }
    }
}

private func envelopeJSON(_ envelope: ProvenanceEnvelope, exclusions: [ExclusionEntry]) throws -> Data {
    let object: [String: Any] = [
        "authorizedCaller": envelope.authorizedCaller,
        "environmentIdentity": envelope.environmentIdentity,
        "evidenceClassification": envelope.evidenceClassification,
        "exclusions": exclusions.map { ["path": $0.path, "reason": $0.reason] },
        "distributionArtifactApprovals": envelope.distributionArtifactApprovals.map {
            [
                "authority": $0.authority,
                "environmentIdentity": $0.environmentIdentity,
                "evidenceReference": $0.evidenceReference,
                "path": $0.path,
            ]
        },
        "implementationCommit": envelope.implementationCommit,
        "manifestDigest": envelope.manifestDigest,
        "profile": envelope.profile.rawValue,
        "sourceClassification": envelope.sourceClassification,
        "toolVersion": envelope.toolVersion,
    ]
    return try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
}

do {
    let arguments = try Arguments(Array(CommandLine.arguments.dropFirst()))
    let request = FilesystemDigestRequest(
        profile: arguments.profile,
        root: arguments.root,
        environmentIdentity: arguments.environmentIdentity,
        provenance: arguments.provenance,
        authorizedCaller: arguments.authorizedCaller,
        sourceClassification: arguments.sourceClassification,
        implementationCommit: arguments.implementationCommit,
        distributionCustomPhraseApproval: arguments.customPhraseApproval
    )
    let result = try EnvironmentDigester().digest(request)
    FileHandle.standardOutput.write(result.manifest)
    FileHandle.standardError.write(try envelopeJSON(result.envelope, exclusions: result.exclusions))
    FileHandle.standardError.write(Data("\n".utf8))
} catch let failure as DigestFailure {
    let path = failure.path.map { ":\($0)" } ?? ""
    FileHandle.standardError.write(Data("\(failure.code.rawValue)\(path)\n".utf8))
    exit(2)
} catch {
    FileHandle.standardError.write(Data("unreadableInput\n".utf8))
    exit(2)
}
