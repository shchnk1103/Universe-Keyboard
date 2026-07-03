import Foundation

public enum EvidenceArtifactEncoder {
    public static func provenance(
        envelope: ProvenanceEnvelope,
        exclusions: [ExclusionEntry]
    ) throws -> Data {
        let object: [String: Any] = [
            "authorizedCaller": envelope.authorizedCaller,
            "distributionArtifactApprovals": envelope.distributionArtifactApprovals.map {
                [
                    "authority": $0.authority,
                    "environmentIdentity": $0.environmentIdentity,
                    "evidenceReference": $0.evidenceReference,
                    "path": $0.path,
                ]
            },
            "environmentIdentity": envelope.environmentIdentity,
            "evidenceClassification": envelope.evidenceClassification,
            "exclusions": exclusions.map { ["path": $0.path, "reason": $0.reason] },
            "implementationCommit": envelope.implementationCommit,
            "manifestDigest": envelope.manifestDigest,
            "profile": envelope.profile.rawValue,
            "sourceClassification": envelope.sourceClassification,
            "toolVersion": envelope.toolVersion,
        ]
        return try artifactData(object)
    }

    public static func failure(_ failure: DigestFailure) throws -> Data {
        var object: [String: Any] = ["code": failure.code.rawValue]
        if let path = failure.path, isSafeRelativePath(path) {
            object["path"] = path
        }
        return try artifactData(object)
    }

    private static func artifactData(_ object: [String: Any]) throws -> Data {
        var data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        data.append(0x0a)
        return data
    }

    private static func isSafeRelativePath(_ path: String) -> Bool {
        !path.isEmpty && !path.hasPrefix("/") && !path.contains("\\")
            && !path.contains("\0") && !path.contains("\t")
            && !path.contains("\r") && !path.contains("\n")
    }
}
