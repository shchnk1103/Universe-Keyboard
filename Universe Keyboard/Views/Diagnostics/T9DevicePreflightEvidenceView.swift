#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
import KeyboardCore
import SwiftUI

enum T9DevicePreflightRunCoordinator {
    private static let prepareEnvironmentKey = "T9_S6A_PREPARE_RUN_TOKEN"
    private static let cleanupEnvironmentKey = "T9_S6A_CLEANUP_RUN_TOKEN"

    static func handleLaunchEnvironment() {
        let environment = ProcessInfo.processInfo.environment
        if let token = environment[prepareEnvironmentKey] {
            prepare(token: token)
        } else if let token = environment[cleanupEnvironmentKey] {
            cleanup(token: token)
        }
    }

    private static func prepare(token: String) {
        guard let defaults = UserDefaults(suiteName: universeAppGroupID)
        else {
            return
        }

        // A retained log occurrence makes the token stale even if the envelope
        // was removed after a prior arm.
        let retainedLog = defaults.string(forKey: "rime_diag_log") ?? ""
        guard let envelope = T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: defaults.string(
                forKey: T9DevicePreflightRun.envelopeKey
            ),
            retainedEvidence: retainedLog
        ) else {
            return
        }
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
}

/// Internal-only, content-free evidence surface for the S6-A UI runner.
///
/// Ordinary Release does not compile this view. Keeping extraction inside the
/// app avoids reading or mutating the user's clipboard.
struct T9DevicePreflightEvidenceView: View {
    private let evidence: String

    init() {
        let defaults = UserDefaults(suiteName: universeAppGroupID)
        let raw = defaults?.string(forKey: "rime_diag_log") ?? ""
        let logEvidence = raw
            .components(separatedBy: "\n")
            .filter { line in
                line.contains("T9DEVICE ")
                    || line.contains("T9GEOM ")
                    || line.contains("T9SEG ")
                    || line.contains("T9AUTO ")
                    || line.contains("T9ARM ")
            }
            .joined(separator: "\n")
        let envelopeEvidence: String
        if let rawEnvelope = defaults?.string(
            forKey: T9DevicePreflightRun.envelopeKey
        ), let envelope = T9DevicePreflightRun.Envelope(
            serialized: rawEnvelope
        ) {
            envelopeEvidence =
                "T9TOKEN state=\(envelope.state.rawValue) run=\(envelope.token)"
        } else {
            envelopeEvidence = "T9TOKEN state=absent"
        }
        evidence = [envelopeEvidence, logEvidence]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    var body: some View {
        Text(evidence.isEmpty ? "T9_S6A_EVIDENCE_EMPTY" : evidence)
            .font(.caption2.monospaced())
            .accessibilityIdentifier("T9S6AEvidence")
            .padding()
    }
}
#endif
