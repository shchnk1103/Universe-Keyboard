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
    FileHandle.standardError.write(
        try EvidenceArtifactEncoder.provenance(envelope: result.envelope, exclusions: result.exclusions))
} catch let failure as DigestFailure {
    FileHandle.standardError.write(try EvidenceArtifactEncoder.failure(failure))
    exit(2)
} catch {
    FileHandle.standardError.write(Data("unreadableInput\n".utf8))
    exit(2)
}
