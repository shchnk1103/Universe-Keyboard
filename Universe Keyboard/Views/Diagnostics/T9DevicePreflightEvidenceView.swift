#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
import KeyboardCore
import SwiftUI

enum T9DevicePreflightRunCoordinator {
    private static let prepareEnvironmentKey = "T9_S6A_PREPARE_RUN_TOKEN"
    private static let cleanupEnvironmentKey = "T9_S6A_CLEANUP_RUN_TOKEN"
    private static let finalizeMatrixEnvironmentKey = "T9_S6A_FINALIZE_MATRIX"
    #if T9_RESPONSIVE_CANARY_INTERNAL
    private static let canaryPrepareRunIDEnvironmentKey =
        "T9_CANARY_PREPARE_RUN_ID"
    private static let canaryExpiryEnvironmentKey =
        "T9_CANARY_EXPIRY_UNIX_SECONDS"
    private static let canaryKillRunIDEnvironmentKey =
        "T9_CANARY_ASSERT_KILL_RUN_ID"
    #endif

    static func handleLaunchEnvironment() {
        let environment = ProcessInfo.processInfo.environment
        if let token = environment[prepareEnvironmentKey] {
            prepare(token: token)
        } else if let token = environment[cleanupEnvironmentKey] {
            cleanup(token: token)
        } else if environment[finalizeMatrixEnvironmentKey] == "1" {
            finalizeMatrix()
        }
        #if T9_RESPONSIVE_CANARY_INTERNAL
        handleCanaryLaunchEnvironment(environment)
        #endif
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    /// Internal-only control entry for DEVICE-001. Ordinary Release compiles
    /// neither these environment keys nor the App Group writer.
    private static func handleCanaryLaunchEnvironment(
        _ environment: [String: String]
    ) {
        let now = Date().timeIntervalSince1970
        let receipt: ResponsiveRimePreflight.CanaryConfigReceipt?
        if let runID = environment[canaryPrepareRunIDEnvironmentKey],
           let expiryText = environment[canaryExpiryEnvironmentKey]
        {
            receipt = ResponsiveRimePreflight.prepareCanaryConfiguration(
                defaults: UserDefaults(suiteName: universeAppGroupID),
                runID: runID,
                expiryUnixSeconds: TimeInterval(expiryText) ?? 0,
                nowUnixSeconds: now
            )
        } else if let runID = environment[canaryKillRunIDEnvironmentKey] {
            receipt = ResponsiveRimePreflight.assertCanaryKill(
                defaults: UserDefaults(suiteName: universeAppGroupID),
                runID: runID,
                nowUnixSeconds: now
            )
        } else {
            receipt = nil
        }
        guard let receipt else { return }
        Logger.shared.devicePreflightPerformance(receipt.markerLine)
        Logger.shared.requestFlush()
    }
    #endif

    private static func prepare(token: String) {
        guard let defaults = UserDefaults(suiteName: universeAppGroupID)
        else {
            return
        }

        // A retained log occurrence makes the token stale even if the envelope
        // was removed after a prior arm.
        let retainedLog = defaults.string(forKey: "rime_diag_log") ?? ""
        let existingEnvelope: String?
        if let envelopeObject = defaults.object(
            forKey: T9DevicePreflightRun.envelopeKey
        ) {
            guard let serializedEnvelope = envelopeObject as? String else {
                return
            }
            existingEnvelope = serializedEnvelope
        } else {
            existingEnvelope = nil
        }
        let registry: T9DevicePreflightRun.MatrixRegistry
        if let registryObject = defaults.object(
            forKey: T9DevicePreflightRun.matrixRegistryKey
        ) {
            guard let serializedRegistry = registryObject as? String else {
                return
            }
            guard let parsed = T9DevicePreflightRun.MatrixRegistry(
                serialized: serializedRegistry
            ) else {
                return
            }
            registry = parsed
        } else {
            registry = .init()
        }
        guard let envelope = T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: existingEnvelope,
            retainedEvidence: retainedLog,
            currentMatrixTokens: Set(registry.tokens)
        ), let updatedRegistry = registry.appending(token) else {
            return
        }

        // Persist registry identity first. A crash between these writes can
        // reject an unused token, but can never allow that token to resume.
        defaults.set(
            updatedRegistry.serialized,
            forKey: T9DevicePreflightRun.matrixRegistryKey
        )
        defaults.synchronize()
        defaults.set(
            envelope.serialized,
            forKey: T9DevicePreflightRun.envelopeKey
        )
        // This is a pre-arm lifecycle boundary, never the input hot path.
        defaults.synchronize()
    }

    private static func cleanup(token: String) {
        guard let defaults = UserDefaults(suiteName: universeAppGroupID),
              T9DevicePreflightRun.canRemoveConsumedEnvelope(
                  serialized: defaults.string(
                      forKey: T9DevicePreflightRun.envelopeKey
                  ),
                  token: token
              )
        else {
            return
        }
        defaults.removeObject(forKey: T9DevicePreflightRun.envelopeKey)
        defaults.synchronize()
    }

    private static func finalizeMatrix() {
        guard let defaults = UserDefaults(suiteName: universeAppGroupID) else {
            return
        }
        let envelopeObject = defaults.object(
            forKey: T9DevicePreflightRun.envelopeKey
        )
        let registryObject = defaults.object(
            forKey: T9DevicePreflightRun.matrixRegistryKey
        )
        let envelopeStorage = T9DevicePreflightRun.inspectEnvelopeStorage(
            objectExists: envelopeObject != nil,
            serialized: envelopeObject as? String
        )
        let registryStorage =
            T9DevicePreflightRun.inspectMatrixRegistryStorage(
                objectExists: registryObject != nil,
                serialized: registryObject as? String
            )
        guard T9DevicePreflightRun.canFinalizeMatrix(
            envelopeStorage: envelopeStorage,
            registryStorage: registryStorage
        ) else {
            return
        }
        defaults.removeObject(forKey: T9DevicePreflightRun.matrixRegistryKey)
        defaults.synchronize()
    }
}

/// Internal-only, content-free evidence surface for the S6-A UI runner.
///
/// Ordinary Release does not compile this view. Keeping extraction inside the
/// main App lets XCTest replace Reminders before it reports any failure.
struct T9DevicePreflightEvidenceView: View {
    private let evidence: String

    init() {
        let defaults = UserDefaults(suiteName: universeAppGroupID)
        let raw = defaults?.string(forKey: "rime_diag_log") ?? ""
        let logEvidence = raw
            .components(separatedBy: "\n")
            .filter(T9DevicePreflightEvidenceLineFilter.retains)
            .joined(separator: "\n")
        let envelopeObject = defaults?.object(
            forKey: T9DevicePreflightRun.envelopeKey
        )
        let envelopeEvidence: String
        switch T9DevicePreflightRun.inspectEnvelopeStorage(
            objectExists: envelopeObject != nil,
            serialized: envelopeObject as? String
        ) {
        case .valid(let envelope):
            envelopeEvidence =
                "T9TOKEN state=\(envelope.state.rawValue) run=\(envelope.token)"
        case .absent:
            envelopeEvidence = "T9TOKEN state=absent"
        case .invalid:
            envelopeEvidence = "T9TOKEN state=invalid"
        }
        let registryObject = defaults?.object(
            forKey: T9DevicePreflightRun.matrixRegistryKey
        )
        let matrixEvidence: String
        switch T9DevicePreflightRun.inspectMatrixRegistryStorage(
            objectExists: registryObject != nil,
            serialized: registryObject as? String
        ) {
        case .valid(let registry):
            matrixEvidence =
                "T9MATRIX state=active count=\(registry.tokens.count)"
        case .absent:
            matrixEvidence = "T9MATRIX state=absent"
        case .invalid:
            matrixEvidence = "T9MATRIX state=invalid"
        }
        evidence = [envelopeEvidence, matrixEvidence, logEvidence]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            Text(evidence)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .accessibilityIdentifier("T9S6AEvidence")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}
#endif
