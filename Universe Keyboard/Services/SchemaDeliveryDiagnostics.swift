import Foundation
import KeyboardCore

nonisolated protocol SchemaDeliveryDiagnosing: Sendable {
    func record(_ payload: DiagnosticEvent.SchemeDeliveryPayload)
}

/// Main-App adapter for ADR 0027. It accepts only the reviewed composite value;
/// journal availability and backpressure can never affect delivery behavior.
nonisolated final class SchemaDeliveryDiagnostics: SchemaDeliveryDiagnosing, Sendable {
    static let live = SchemaDeliveryDiagnostics()

    private let runtime: DiagnosticsJournalRuntime

    init(runtime: DiagnosticsJournalRuntime? = nil) {
        self.runtime =
            runtime
            ?? DiagnosticsJournalRuntime(
                origin: .mainApp,
                isMainAppWriter: true,
                rootURL: {
                    FileManager.default
                        .containerURL(
                            forSecurityApplicationGroupIdentifier: SchemaManager.appGroupID
                        )?
                        .appendingPathComponent("Diagnostics/v1", isDirectory: true)
                },
                isCategoryEnabled: Logger.isLiveCategoryEnabled
            )
    }

    func record(_ payload: DiagnosticEvent.SchemeDeliveryPayload) {
        runtime.recordSchemeDelivery(payload)
    }
}

nonisolated enum SchemeDeliveryDiagnosticMapper {
    static func context(
        operationID: UUID,
        identity: RimeSchemeStagedIdentity
    ) -> DiagnosticEvent.SchemeDeliveryContext? {
        guard let artifact = artifact(identity.artifactIdentityID),
            let stagedIdentity = stagedIdentity(identity.id)
        else { return nil }
        return DiagnosticEvent.SchemeDeliveryContext(
            operationID: operationID,
            artifact: artifact,
            stagedIdentity: stagedIdentity
        )
    }

    static func source(_ id: String) -> DiagnosticEvent.SchemeSource? {
        DiagnosticEvent.SchemeSource(rawValue: id)
    }

    static func host(_ value: String) -> DiagnosticEvent.SchemeHost? {
        DiagnosticEvent.SchemeHost(rawValue: value.lowercased())
    }

    static func artifact(_ id: String) -> DiagnosticEvent.SchemeArtifactIdentity? {
        switch id {
        case "rime-ice-nightly-f60aa4f3": .rimeIceNightlyF60AA4F3
        case "wanxiang-17.5.9-cnb9bfc-github73f8": .wanxiang1759CNB9BFCGitHub73F8
        default: nil
        }
    }

    static func stagedIdentity(_ id: String) -> DiagnosticEvent.SchemeStagedIdentity? {
        switch id {
        case "rime-ice-nightly-plan1-post1": .rimeIceNightlyPlan1Post1
        case "wanxiang-17.5.9-plan1-post1": .wanxiang1759Plan1Post1
        default: nil
        }
    }

    static func observation(_ failure: DownloadIntegrityFailure)
        -> DiagnosticEvent.SchemeIntegrityObservation?
    {
        switch failure {
        case .archiveSize(let expected, let actual):
            return .archiveSize(expected: expected, actual: actual)
        case .archiveDigest(let expected, let actual):
            guard
                let expected = DiagnosticEvent.DigestPrefix16(fullDigest: expected),
                let actual = DiagnosticEvent.DigestPrefix16(fullDigest: actual)
            else { return nil }
            return .archiveDigest(expected: expected, actual: actual)
        case .stagedContent(let expected, let actual):
            guard
                let expected = DiagnosticEvent.DigestPrefix16(fullDigest: expected),
                let actual = DiagnosticEvent.DigestPrefix16(fullDigest: actual)
            else { return nil }
            return .stagedContent(expected: expected, actual: actual)
        }
    }
}
