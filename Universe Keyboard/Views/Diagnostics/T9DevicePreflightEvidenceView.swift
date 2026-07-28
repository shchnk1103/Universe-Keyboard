#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
import SwiftUI

/// Internal-only, content-free evidence surface for the S6-A UI runner.
///
/// Ordinary Release does not compile this view. Keeping extraction inside the
/// app avoids reading or mutating the user's clipboard.
struct T9DevicePreflightEvidenceView: View {
    private let evidence: String

    init() {
        let raw = UserDefaults(
            suiteName: universeAppGroupID
        )?.string(forKey: "rime_diag_log") ?? ""
        evidence = raw
            .components(separatedBy: "\n")
            .filter { line in
                line.contains("T9DEVICE ")
                    || line.contains("T9SEG ")
                    || line.contains("T9AUTO ")
                    || line.contains("T9ARM ")
            }
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
