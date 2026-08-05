import Foundation

/// Content-free validation result for the target-level P3-D1 lifecycle seam.
public struct P3D1LifecycleEvidenceValidation: Equatable, Sendable {
    public enum Status: String, Equatable, Sendable {
        case complete
        case partial
        case blocked
        case notRun
    }

    public let status: Status
    public let reasons: [String]
    public let runID: String?
    public let markers: [String]
    public let ownerCycleIsOrdered: Bool
    public let sawAcceptedRevision: Bool
    public let sawAppliedRevision: Bool
    public let sawClear: Bool
    public let sawReturnClean: Bool
    public let sawPrivacyViolation: Bool

    public init(
        status: Status,
        reasons: [String],
        runID: String?,
        markers: [String],
        ownerCycleIsOrdered: Bool,
        sawAcceptedRevision: Bool,
        sawAppliedRevision: Bool,
        sawClear: Bool,
        sawReturnClean: Bool,
        sawPrivacyViolation: Bool
    ) {
        self.status = status
        self.reasons = reasons
        self.runID = runID
        self.markers = markers
        self.ownerCycleIsOrdered = ownerCycleIsOrdered
        self.sawAcceptedRevision = sawAcceptedRevision
        self.sawAppliedRevision = sawAppliedRevision
        self.sawClear = sawClear
        self.sawReturnClean = sawReturnClean
        self.sawPrivacyViolation = sawPrivacyViolation
    }
}

/// Validates P3-D1 `P3LIFE` lines without retaining user text.
///
/// The validator is intentionally independent of Logger and XCTest so an App
/// diagnostics export or a future external handoff parser can reuse exactly
/// the same fail-closed rules. It validates marker identity, field shape,
/// owner order and lifecycle cleanup; it never infers target execution from a
/// missing line or from a UI surface label.
public enum P3D1LifecycleEvidenceValidator {
    public static let schemaVersion = "v1"

    private static let requiredFields = [
        "schema", "marker", "run", "gate", "epoch", "rev", "pending",
        "accepted", "applied", "stale", "discard", "terminal", "ownerReady",
        "cleared", "returnClean", "reason",
    ]

    public static func validate(
        lines: [String],
        runID: String,
        requiredMarkers: Set<String> = []
    ) -> P3D1LifecycleEvidenceValidation {
        let markers = lines.compactMap(parseMarker)
        guard !markers.isEmpty else {
            return result(
                status: .notRun,
                reasons: ["p3life-markers-missing"],
                runID: nil,
                markers: [],
                ownerCycleIsOrdered: false,
                sawAcceptedRevision: false,
                sawAppliedRevision: false,
                sawClear: false,
                sawReturnClean: false,
                sawPrivacyViolation: false
            )
        }

        var reasons: [String] = []
        var sawPrivacyViolation = false
        var sawBlockedShape = false
        var sawPartialOrder = false
        var observedRunID: String?
        var markerNames: [String] = []
        var ownerReadyIndex: Int?
        var ownerBeginIndex: Int?
        var ownerEndIndex: Int?
        var lastEpoch: UInt64?
        var lastRevision: UInt64?
        var sawAcceptedRevision = false
        var sawAppliedRevision = false
        var sawClear = false
        var sawReturnClean = false

        for marker in markers {
            if marker.privacyViolation {
                sawPrivacyViolation = true
            }

            guard marker.fields["schema"] == schemaVersion,
                  let markerName = marker.fields["marker"],
                  let token = marker.fields["run"],
                  token == runID,
                  Set(marker.fields.keys).isSuperset(of: requiredFields)
            else {
                sawBlockedShape = true
                continue
            }

            if observedRunID == nil {
                observedRunID = token
            }
            markerNames.append(markerName)

            if markerName == "OWNER_READY" {
                ownerReadyIndex = markerNames.count - 1
                if marker.fields["ownerReady"] != "1" {
                    sawPartialOrder = true
                }
            } else if markerName == "OWNER_BEGIN" {
                ownerBeginIndex = markerNames.count - 1
            } else if markerName == "OWNER_END" {
                ownerEndIndex = markerNames.count - 1
            }

            if let accepted = UInt64(marker.fields["accepted"] ?? ""), accepted > 0 {
                sawAcceptedRevision = true
            }
            if let applied = UInt64(marker.fields["applied"] ?? ""), applied > 0 {
                sawAppliedRevision = true
            }
            if marker.fields["cleared"] == "1" {
                sawClear = true
            }
            if markerName == "RETURN_CLEAN" {
                sawReturnClean = marker.fields["cleared"] == "1"
            }

            guard let revision = UInt64(marker.fields["rev"] ?? ""),
                  let epoch = UInt64(marker.fields["epoch"] ?? ""),
                  Int(marker.fields["pending"] ?? "") != nil,
                  Int(marker.fields["stale"] ?? "") != nil,
                  Int(marker.fields["discard"] ?? "") != nil,
                  (marker.fields["gate"] == "0" || marker.fields["gate"] == "1"),
                  (marker.fields["terminal"] == "0" || marker.fields["terminal"] == "1"),
                  (marker.fields["ownerReady"] == "0" || marker.fields["ownerReady"] == "1"),
                  (marker.fields["cleared"] == "0" || marker.fields["cleared"] == "1")
            else {
                sawBlockedShape = true
                continue
            }
            if let lastEpoch, epoch < lastEpoch {
                reasons.append("epoch-regression")
                sawPartialOrder = true
            } else if let lastEpoch, epoch == lastEpoch,
                      let lastRevision, revision < lastRevision
            {
                reasons.append("revision-regression")
                sawPartialOrder = true
            }
            switch lastEpoch {
            case nil:
                lastEpoch = epoch
                lastRevision = revision
            case let previousEpoch? where epoch > previousEpoch:
                lastEpoch = epoch
                lastRevision = revision
            case let previousEpoch? where epoch == previousEpoch:
                lastRevision = revision
            default:
                // Keep the highest observed epoch watermark after reporting
                // a regression; later lines remain fail-closed as well.
                break
            }
        }

        if sawPrivacyViolation {
            reasons.append("privacy-sensitive-content")
        }
        if observedRunID == nil {
            reasons.append("run-token-missing-or-wrong")
        }
        if sawBlockedShape {
            reasons.append("marker-shape-invalid")
        }
        if !requiredMarkers.isSubset(of: Set(markerNames)) {
            reasons.append("required-marker-missing")
            sawPartialOrder = true
        }

        let ownerCycleIsOrdered = if let ownerReadyIndex, let ownerBeginIndex, let ownerEndIndex {
            ownerReadyIndex <= ownerBeginIndex && ownerBeginIndex <= ownerEndIndex
        } else {
            false
        }
        if !ownerCycleIsOrdered, requiredMarkers.contains("OWNER_END") {
            reasons.append("owner-cycle-order-invalid")
            sawPartialOrder = true
        }
        if !sawAcceptedRevision, requiredMarkers.contains("PUBLISH") {
            reasons.append("accepted-revision-missing")
            sawPartialOrder = true
        }
        if !sawAppliedRevision, requiredMarkers.contains("PUBLISH") {
            reasons.append("applied-revision-missing")
            sawPartialOrder = true
        }

        let status: P3D1LifecycleEvidenceValidation.Status
        if sawPrivacyViolation || sawBlockedShape || observedRunID == nil {
            status = .blocked
        } else if sawPartialOrder || !reasons.isEmpty {
            status = .partial
        } else {
            status = .complete
        }
        return result(
            status: status,
            reasons: reasons,
            runID: observedRunID,
            markers: markerNames,
            ownerCycleIsOrdered: ownerCycleIsOrdered,
            sawAcceptedRevision: sawAcceptedRevision,
            sawAppliedRevision: sawAppliedRevision,
            sawClear: sawClear,
            sawReturnClean: sawReturnClean,
            sawPrivacyViolation: sawPrivacyViolation
        )
    }

    private struct ParsedMarker {
        let fields: [String: String]
        let privacyViolation: Bool
    }

    private static func parseMarker(_ line: String) -> ParsedMarker? {
        guard let markerRange = line.range(of: "P3LIFE ") else { return nil }
        let payload = line[markerRange.upperBound...]
        var fields: [String: String] = [:]
        var privacyViolation = false
        for field in payload.split(separator: " ") {
            let parts = field.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            fields[parts[0]] = parts[1]
            if ["rawInput", "candidate", "candidateText", "committedText", "markedText", "preeditText", "hostText"].contains(parts[0]) {
                privacyViolation = true
            }
        }
        return ParsedMarker(fields: fields, privacyViolation: privacyViolation)
    }

    private static func result(
        status: P3D1LifecycleEvidenceValidation.Status,
        reasons: [String],
        runID: String?,
        markers: [String],
        ownerCycleIsOrdered: Bool,
        sawAcceptedRevision: Bool,
        sawAppliedRevision: Bool,
        sawClear: Bool,
        sawReturnClean: Bool,
        sawPrivacyViolation: Bool
    ) -> P3D1LifecycleEvidenceValidation {
        P3D1LifecycleEvidenceValidation(
            status: status,
            reasons: reasons,
            runID: runID,
            markers: markers,
            ownerCycleIsOrdered: ownerCycleIsOrdered,
            sawAcceptedRevision: sawAcceptedRevision,
            sawAppliedRevision: sawAppliedRevision,
            sawClear: sawClear,
            sawReturnClean: sawReturnClean,
            sawPrivacyViolation: sawPrivacyViolation
        )
    }
}
