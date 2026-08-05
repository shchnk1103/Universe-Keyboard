import Foundation

/// The two internal diagnostic arms covered by P2-PERF-02.
public enum T9ResponsiveEvidenceArm: String, Equatable, Sendable {
    case sync
    case threadAffine = "thread-affine"
}

/// Immutable expectations supplied by the external Run Header.
public struct T9ResponsiveEvidenceExpectation: Equatable, Sendable {
    public let runToken: String
    public let arm: T9ResponsiveEvidenceArm
    public let fixtureID: String
    public let actionCount: Int
    public let requirePathMarker: Bool
    public let requireReadyMarker: Bool
    public let requireRunBoundMarkers: Bool
    /// Sync evidence has no responsive ACCEPT/PUBLISH chain. Thread-affine
    /// evidence must prove that chain for every accepted revision.
    public let requireResponsiveFeltMarkers: Bool
    public let markerSchemaVersion: String

    public init(
        runToken: String,
        arm: T9ResponsiveEvidenceArm,
        actionCount: Int = 39,
        requirePathMarker: Bool? = nil,
        requireReadyMarker: Bool? = nil,
        fixtureID: String = "T9RESP-R5P",
        requireRunBoundMarkers: Bool? = nil,
        requireResponsiveFeltMarkers: Bool? = nil,
        markerSchemaVersion: String = ResponsiveRimePreflight.markerSchemaVersion
    ) {
        self.runToken = runToken
        self.arm = arm
        self.fixtureID = fixtureID
        self.actionCount = actionCount
        self.requirePathMarker = requirePathMarker ?? (arm == .threadAffine)
        self.requireReadyMarker = requireReadyMarker ?? (arm == .threadAffine)
        self.requireRunBoundMarkers = requireRunBoundMarkers ?? (arm == .threadAffine)
        self.requireResponsiveFeltMarkers =
            requireResponsiveFeltMarkers ?? (arm == .threadAffine)
        self.markerSchemaVersion = markerSchemaVersion
    }
}

public enum T9ResponsiveEvidenceStatus: String, Equatable, Sendable {
    case complete
    case partial
    case blocked
    case notRun
}

/// Content-free validator output. It is safe to put in a handoff summary.
public struct T9ResponsiveEvidenceValidation: Equatable, Sendable {
    public let status: T9ResponsiveEvidenceStatus
    public let reasons: [String]
    public let segmentActions: [Int]
    public let segmentEvents: [Int]
    public let hasDeviceMarker: Bool
    public let hasPathMarker: Bool
    public let hasReadyMarker: Bool
    public let hasPreparedGeometry: Bool
    public let hasExecutionGeometry: Bool
    public let geometryDigestMatches: Bool
    public let sessionIsValid: Bool
    public let sessionStayedStable: Bool
    public let sawCommit: Bool
    public let sawPrivacyViolation: Bool

    public init(
        status: T9ResponsiveEvidenceStatus,
        reasons: [String],
        segmentActions: [Int],
        segmentEvents: [Int],
        hasDeviceMarker: Bool,
        hasPathMarker: Bool,
        hasReadyMarker: Bool,
        hasPreparedGeometry: Bool,
        hasExecutionGeometry: Bool,
        geometryDigestMatches: Bool,
        sessionIsValid: Bool,
        sessionStayedStable: Bool,
        sawCommit: Bool,
        sawPrivacyViolation: Bool
    ) {
        self.status = status
        self.reasons = reasons
        self.segmentActions = segmentActions
        self.segmentEvents = segmentEvents
        self.hasDeviceMarker = hasDeviceMarker
        self.hasPathMarker = hasPathMarker
        self.hasReadyMarker = hasReadyMarker
        self.hasPreparedGeometry = hasPreparedGeometry
        self.hasExecutionGeometry = hasExecutionGeometry
        self.geometryDigestMatches = geometryDigestMatches
        self.sessionIsValid = sessionIsValid
        self.sessionStayedStable = sessionStayedStable
        self.sawCommit = sawCommit
        self.sawPrivacyViolation = sawPrivacyViolation
    }
}

/// Pure, content-free P2 evidence validator.
///
/// It deliberately accepts log lines rather than a logger type so the same
/// rules can be used by unit tests, an App diagnostics export and an external
/// handoff parser. It never reconstructs or stores composition text.
public enum T9ResponsiveEvidenceValidator {
    public static func validate(
        lines: [String],
        expectation: T9ResponsiveEvidenceExpectation
    ) -> T9ResponsiveEvidenceValidation {
        var reasons: [String] = []
        var segmentActions: [Int] = []
        var segmentEvents: [Int] = []
        var sessionPairs: [(before: UInt64, beforeValid: Bool, after: UInt64, afterValid: Bool)] = []
        var runTokens: Set<String> = []
        var preparedDigests: Set<String> = []
        var executionDigests: Set<String> = []
        var sawDeviceMarker = false
        var sawPathMarker = false
        var sawReadyMarker = false
        var sawCommit = false
        var sawPrivacyViolation = false
        var sawRecognizedMarker = false
        var hasPublish = false
        var hasEpochBoundPublish = false
        var orderViolation = false
        var sawInvalidRunBinding = false
        var sawInvalidMarkerSchema = false
        var sawOwnerNotReady = false
        var sawExecutionUnavailable = false
        var sawInvalidGeometryDigest = false
        var sawMultipleGeometryDigests = false
        var sawMalformedSegment = false
        var sawSegmentPairMismatch = false
        var sawVisibleRevisionRegression = false
        var sawVisibleDuplicateSource = false
        var sawDuplicateOwnerPublish = false
        var sawEnginePresentationBeforePublish = false
        var sawEpochRegression = false
        var acceptedRevisions: Set<UInt64> = []
        var acceptedEpochByRevision: [UInt64: UInt64] = [:]
        var epochPublishRevisions: Set<UInt64> = []
        var lastAcceptedRevision: UInt64?
        var lastAcceptedEpoch: UInt64?
        var lastPublishedRevision: UInt64?
        var lastPublishedEpoch: UInt64?
        var lastVisibleRevision: UInt64?
        var visibleSourcesByRevision: [UInt64: Set<String>] = [:]

        guard !lines.isEmpty else {
            return result(
                status: .notRun,
                reasons: ["no-runtime-records"],
                segmentActions: [],
                segmentEvents: [],
                hasDeviceMarker: false,
                hasPathMarker: false,
                hasReadyMarker: false,
                hasPreparedGeometry: false,
                hasExecutionGeometry: false,
                geometryDigestMatches: false,
                sessionPairs: [],
                sawCommit: false,
                sawPrivacyViolation: false
            )
        }

        for line in lines {
            if containsPrivacySensitiveContent(line) {
                sawPrivacyViolation = true
            }

            guard let marker = markerLine(from: line) else { continue }
            sawRecognizedMarker = true
            let fields = keyValueFields(from: marker)
            let isSlowSegmentWarning = marker.hasPrefix("SLOW T9SEG ")

            // Run identity is part of the evidence boundary for every
            // run-scoped marker. A missing binding is not equivalent to a
            // line from the expected run; fail closed instead of letting the
            // remaining rows make the sample look complete.
            if !isSlowSegmentWarning,
               requiresRunBinding(marker),
               fields["run"] != expectation.runToken {
                sawInvalidRunBinding = true
            }

            if let token = fields["run"], !token.isEmpty {
                runTokens.insert(token)
            }

            if marker.contains("T9DEVICE ") {
                sawDeviceMarker = true
                if fields["schema"] != ResponsiveRimePreflight.markerSchemaVersion
                    || fields["marker"] != "T9DEVICE_DISABLED"
                    || fields["gate"] != "off"
                    || fields["measurement"] != "on" {
                    reasons.append("unexpected-device-gate-marker")
                }
            } else if marker.contains("T9GEOM ") {
                let phase = fields["phase"]
                let digest = fields["digest"]
                if fields["schema"] != ResponsiveRimePreflight.markerSchemaVersion {
                    sawInvalidMarkerSchema = true
                }
                let isExecutionUnavailable = phase == "execution"
                    && fields["status"] == "unavailable"
                if phase == "prepared" || (phase == "execution" && !isExecutionUnavailable) {
                    if !hasRequiredGeometryFields(fields) {
                        sawInvalidMarkerSchema = true
                    }
                }
                if phase == "prepared" {
                    guard let digest else {
                        sawInvalidGeometryDigest = true
                        continue
                    }
                    if !isValidGeometryDigest(digest) {
                        sawInvalidGeometryDigest = true
                    } else {
                        if !preparedDigests.isEmpty && !preparedDigests.contains(digest) {
                            sawMultipleGeometryDigests = true
                        }
                        preparedDigests.insert(digest)
                    }
                }
                if phase == "execution", fields["status"] == nil {
                    guard let digest else {
                        sawInvalidGeometryDigest = true
                        continue
                    }
                    if !isValidGeometryDigest(digest) {
                        sawInvalidGeometryDigest = true
                    } else {
                        if !executionDigests.isEmpty && !executionDigests.contains(digest) {
                            sawMultipleGeometryDigests = true
                        }
                        executionDigests.insert(digest)
                    }
                }
                if isExecutionUnavailable {
                    sawExecutionUnavailable = true
                    if digest != nil {
                        sawInvalidGeometryDigest = true
                    }
                }
                if phase != "prepared", phase != "execution" {
                    sawInvalidMarkerSchema = true
                }
            } else if marker.contains("T9SEG ") {
                // `SLOW T9SEG` is a warning copy of a sample and must not be
                // counted as a second physical action.
                guard !isSlowSegmentWarning else { continue }
                if !hasRequiredSegmentFields(fields) {
                    sawMalformedSegment = true
                }
                if let action = Int(fields["action"] ?? "") {
                    segmentActions.append(action)
                } else {
                    reasons.append("segment-action-unparseable")
                }
                if let event = Int(fields["event"] ?? "") {
                    segmentEvents.append(event)
                } else {
                    reasons.append("segment-event-unparseable")
                }
                if fields["action"] != fields["event"] {
                    sawSegmentPairMismatch = true
                }
                if fields["committed"] == "true" {
                    sawCommit = true
                } else if fields["committed"] != "false" {
                    sawMalformedSegment = true
                }
                let before = UInt64(fields["sessionBefore"] ?? "0") ?? 0
                let after = UInt64(fields["sessionAfter"] ?? "0") ?? 0
                let beforeValid = fields["validBefore"] == "true"
                let afterValid = fields["validAfter"] == "true"
                sessionPairs.append((before, beforeValid, after, afterValid))
            } else if marker.contains("T9RESP ") {
                let markerName = fields["marker"]
                if markerName == "PATH" {
                    let gateStateValid: Bool
                    if expectation.arm == .threadAffine {
                        gateStateValid = fields["dualGateRequested"] == "1"
                            && fields["dualGateActive"] == "1"
                    } else {
                        // Sync is a legitimate gate-off arm. If the marker
                        // carries gate fields, they must explicitly be off;
                        // sync must never be forced to look like B.
                        gateStateValid =
                            (fields["dualGateRequested"] == nil
                                && fields["dualGateActive"] == nil)
                            || (fields["dualGateRequested"] == "0"
                                && fields["dualGateActive"] == "0")
                    }
                    let schemaValid = fields["path"] == expectation.arm.rawValue
                        && fields["schema"] == expectation.markerSchemaVersion
                        && fields["fixture"] == expectation.fixtureID
                        && (!expectation.requireRunBoundMarkers
                            || fields["run"] == expectation.runToken)
                        && gateStateValid
                    if schemaValid {
                        sawPathMarker = true
                    } else {
                        sawInvalidMarkerSchema = true
                    }
                } else if markerName == "READY" {
                    let schemaValid = fields["fixture"] == expectation.fixtureID
                        && fields["schema"] == expectation.markerSchemaVersion
                        && fields["bootstrap"] == "config-only"
                        && fields["session"] == "owner-thread"
                        && (!expectation.requireRunBoundMarkers
                            || fields["run"] == expectation.runToken)
                    if schemaValid {
                        sawReadyMarker = true
                    } else {
                        sawInvalidMarkerSchema = true
                    }
                } else if markerName == "NOT_READY" {
                    sawOwnerNotReady = true
                    sawInvalidMarkerSchema = true
                } else if markerName == "ACCEPT", let revision = revision(from: fields) {
                    let schemaValid = fields["action"] == "k"
                        && fields["schema"] == expectation.markerSchemaVersion
                        && fields["fixture"] == expectation.fixtureID
                        && isPositive(revision)
                        && isPositive(epoch(from: fields))
                        && nonNegativeInt(fields["pending"])
                    guard schemaValid, let acceptEpoch = epoch(from: fields) else {
                        sawInvalidMarkerSchema = true
                        continue
                    }
                    acceptedRevisions.insert(revision)
                    if acceptedEpochByRevision[revision] != nil {
                        sawInvalidMarkerSchema = true
                    }
                    acceptedEpochByRevision[revision] = acceptEpoch
                    if let lastAcceptedEpoch, acceptEpoch < lastAcceptedEpoch {
                        sawEpochRegression = true
                    }
                    lastAcceptedEpoch = max(lastAcceptedEpoch ?? acceptEpoch, acceptEpoch)
                    if let lastAcceptedRevision, revision < lastAcceptedRevision {
                        orderViolation = true
                    }
                    lastAcceptedRevision = max(lastAcceptedRevision ?? revision, revision)
                } else if markerName == "ACCEPT" {
                    sawInvalidMarkerSchema = true
                } else if markerName == "VISIBLE", let revision = revision(from: fields) {
                    let source = fields["source"]
                    let schemaValid = fields["fixture"] == expectation.fixtureID
                        && fields["schema"] == expectation.markerSchemaVersion
                        && isPositive(revision)
                        && nonNegativeUInt(fields["lagMs"])
                        && (source == "provisional" || source == "engine")
                    guard schemaValid, let source else {
                        sawInvalidMarkerSchema = true
                        continue
                    }
                    guard acceptedRevisions.contains(revision) else {
                        orderViolation = true
                        continue
                    }
                    if source == "engine", !epochPublishRevisions.contains(revision) {
                        sawEnginePresentationBeforePublish = true
                    }
                    if let lastVisibleRevision, revision < lastVisibleRevision {
                        sawVisibleRevisionRegression = true
                    }
                    if visibleSourcesByRevision[revision, default: []].contains(source) {
                        sawVisibleDuplicateSource = true
                    }
                    visibleSourcesByRevision[revision, default: []].insert(source)
                    lastVisibleRevision = max(lastVisibleRevision ?? revision, revision)
                } else if markerName == "VISIBLE" {
                    sawInvalidMarkerSchema = true
                } else if markerName == "PUBLISH", let revision = revision(from: fields) {
                    // P2-D1: PUBLISH is owner completion, not UI paint. The
                    // latter is represented by PAINT and may be coalesced.
                    let hasPresentationFields = fields["lagMs"] != nil
                        || fields["pendingAfter"] != nil
                        || fields["coalesced"] != nil
                    let schemaValid = fields["fixture"] == expectation.fixtureID
                        && fields["schema"] == expectation.markerSchemaVersion
                        && isPositive(revision)
                        && isPositive(epoch(from: fields))
                        && !hasPresentationFields
                    guard schemaValid else {
                        sawInvalidMarkerSchema = true
                        continue
                    }
                    hasPublish = true
                    if !acceptedRevisions.contains(revision) {
                        orderViolation = true
                    }
                    if let epoch = epoch(from: fields) {
                        hasEpochBoundPublish = true
                        if let lastPublishedEpoch, epoch < lastPublishedEpoch {
                            sawEpochRegression = true
                        }
                        lastPublishedEpoch = max(lastPublishedEpoch ?? epoch, epoch)
                        if epochPublishRevisions.contains(revision) {
                            sawDuplicateOwnerPublish = true
                        }
                        epochPublishRevisions.insert(revision)
                        if acceptedEpochByRevision[revision] != epoch {
                            orderViolation = true
                        }
                    }
                    if let lastPublishedRevision, revision < lastPublishedRevision {
                        orderViolation = true
                    }
                    lastPublishedRevision = max(lastPublishedRevision ?? revision, revision)
                } else if markerName == "PAINT", let revision = revision(from: fields) {
                    let schemaValid = fields["fixture"] == expectation.fixtureID
                        && fields["schema"] == expectation.markerSchemaVersion
                        && isPositive(revision)
                        && nonNegativeUInt(fields["lagMs"])
                        && nonNegativeInt(fields["pendingAfter"])
                        && (fields["coalesced"] == "0" || fields["coalesced"] == "1")
                    guard schemaValid else {
                        sawInvalidMarkerSchema = true
                        continue
                    }
                    guard acceptedRevisions.contains(revision) else {
                        orderViolation = true
                        continue
                    }
                    if !epochPublishRevisions.contains(revision) {
                        sawEnginePresentationBeforePublish = true
                    }
                } else if markerName == "PUBLISH" {
                    sawInvalidMarkerSchema = true
                } else if markerName == "PAINT" {
                    sawInvalidMarkerSchema = true
                }
            }
        }

        guard sawRecognizedMarker else {
            let markerlessStatus: T9ResponsiveEvidenceStatus =
                sawPrivacyViolation ? .blocked : .notRun
            return result(
                status: markerlessStatus,
                reasons: sawPrivacyViolation
                    ? ["privacy-sensitive-content"]
                    : ["no-recognized-runtime-markers"],
                segmentActions: [],
                segmentEvents: [],
                hasDeviceMarker: false,
                hasPathMarker: false,
                hasReadyMarker: false,
                hasPreparedGeometry: false,
                hasExecutionGeometry: false,
                geometryDigestMatches: false,
                sessionPairs: [],
                sawCommit: false,
                sawPrivacyViolation: sawPrivacyViolation
            )
        }

        if sawPrivacyViolation {
            reasons.append("privacy-sensitive-content")
        }
        if !isCanonicalRunToken(expectation.runToken) {
            reasons.append("expected-run-token-invalid")
        }
        if runTokens.contains(where: { !isCanonicalRunToken($0) }) {
            reasons.append("observed-run-token-invalid")
        }
        if sawInvalidRunBinding {
            reasons.append("marker-run-token-missing-or-wrong")
        }
        if sawInvalidMarkerSchema {
            reasons.append("marker-schema-invalid")
        }
        if sawOwnerNotReady {
            reasons.append("owner-not-ready")
        }
        if !runTokens.isEmpty, runTokens != Set([expectation.runToken]) {
            reasons.append("mixed-run-tokens")
        }
        if !sawDeviceMarker {
            reasons.append("device-marker-missing")
        }

        let expectedActions = expectation.actionCount > 0
            ? Array(1...expectation.actionCount)
            : []
        if segmentActions != expectedActions {
            reasons.append("segment-actions-not-contiguous")
        }
        if segmentEvents != expectedActions {
            reasons.append("segment-events-not-contiguous")
        }
        if segmentActions.count != Set(segmentActions).count {
            reasons.append("duplicate-segment-actions")
        }
        if segmentEvents.count != Set(segmentEvents).count {
            reasons.append("duplicate-segment-events")
        }
        if sawSegmentPairMismatch {
            reasons.append("segment-action-event-mismatch")
        }
        if sawMalformedSegment {
            reasons.append("segment-schema-invalid")
        }
        if sawVisibleRevisionRegression {
            reasons.append("visible-revision-regression")
        }
        if sawVisibleDuplicateSource {
            reasons.append("visible-source-duplicate")
        }
        if sawDuplicateOwnerPublish {
            reasons.append("duplicate-owner-publish")
        }
        if sawEnginePresentationBeforePublish {
            reasons.append("engine-presentation-before-publish")
        }
        if sawEpochRegression {
            reasons.append("epoch-regression")
        }
        if sawCommit {
            reasons.append("unexpected-commit")
        }
        if expectation.requirePathMarker, !sawPathMarker {
            reasons.append("path-marker-missing-or-wrong")
        }
        if expectation.requireReadyMarker, !sawReadyMarker {
            reasons.append("ready-marker-missing")
        }
        if expectation.requireResponsiveFeltMarkers {
            if !hasPublish {
                reasons.append("publish-marker-missing")
            }
            let expectedRevisions = expectation.actionCount > 0
                ? Set((1...expectation.actionCount).map(UInt64.init))
                : []
            if acceptedRevisions != expectedRevisions {
                reasons.append("accept-revisions-not-complete")
            }
            if !hasEpochBoundPublish {
                reasons.append("epoch-bound-publish-missing")
            }
            if epochPublishRevisions != acceptedRevisions {
                reasons.append("epoch-bound-publish-incomplete")
            }
        }
        if orderViolation {
            reasons.append("accept-publish-order-invalid")
        }

        let hasPreparedGeometry = !preparedDigests.isEmpty
        let hasExecutionGeometry = !executionDigests.isEmpty
        let geometryDigestMatches =
            hasPreparedGeometry
            && hasExecutionGeometry
            && preparedDigests == executionDigests
            && !sawInvalidGeometryDigest
            && !sawMultipleGeometryDigests
        if !hasPreparedGeometry {
            reasons.append("prepared-geometry-missing")
        }
        if !hasExecutionGeometry {
            if sawExecutionUnavailable {
                reasons.append("execution-geometry-unavailable")
            } else {
                reasons.append("execution-geometry-missing")
            }
        }
        if hasPreparedGeometry && hasExecutionGeometry && !geometryDigestMatches {
            reasons.append("geometry-digest-mismatch")
        }
        if sawInvalidGeometryDigest {
            reasons.append("geometry-digest-invalid")
        }
        if sawMultipleGeometryDigests {
            reasons.append("geometry-digest-multiple")
        }

        let sessionIsValid = !sessionPairs.isEmpty
            && sessionPairs.allSatisfy {
                $0.before != 0
                    && $0.after != 0
                    && $0.beforeValid
                    && $0.afterValid
            }
        let sessionIDs = Set(
            sessionPairs.flatMap { [$0.before, $0.after] }
        )
        let sessionStayedStable = sessionIsValid && sessionIDs.count == 1
        if !sessionIsValid {
            reasons.append("native-session-invalid-or-missing")
        } else if !sessionStayedStable {
            reasons.append("native-session-identity-changed")
        }

        let isBlocked = sawPrivacyViolation
            || reasons.contains("expected-run-token-invalid")
            || reasons.contains("observed-run-token-invalid")
            || reasons.contains("mixed-run-tokens")
            || sawInvalidRunBinding
        let status: T9ResponsiveEvidenceStatus
        if isBlocked {
            status = .blocked
        } else if reasons.isEmpty {
            status = .complete
        } else {
            status = .partial
        }

        return result(
            status: status,
            reasons: reasons,
            segmentActions: segmentActions,
            segmentEvents: segmentEvents,
            hasDeviceMarker: sawDeviceMarker,
            hasPathMarker: sawPathMarker,
            hasReadyMarker: sawReadyMarker,
            hasPreparedGeometry: hasPreparedGeometry,
            hasExecutionGeometry: hasExecutionGeometry,
            geometryDigestMatches: geometryDigestMatches,
            sessionPairs: sessionPairs,
            sawCommit: sawCommit,
            sawPrivacyViolation: sawPrivacyViolation
        )
    }

    private static func result(
        status: T9ResponsiveEvidenceStatus,
        reasons: [String],
        segmentActions: [Int],
        segmentEvents: [Int],
        hasDeviceMarker: Bool,
        hasPathMarker: Bool,
        hasReadyMarker: Bool,
        hasPreparedGeometry: Bool,
        hasExecutionGeometry: Bool,
        geometryDigestMatches: Bool,
        sessionPairs: [(before: UInt64, beforeValid: Bool, after: UInt64, afterValid: Bool)],
        sawCommit: Bool,
        sawPrivacyViolation: Bool
    ) -> T9ResponsiveEvidenceValidation {
        let sessionIsValid = !sessionPairs.isEmpty
            && sessionPairs.allSatisfy {
                $0.before != 0
                    && $0.after != 0
                    && $0.beforeValid
                    && $0.afterValid
            }
        let sessionIDs = Set(sessionPairs.flatMap { [$0.before, $0.after] })
        return T9ResponsiveEvidenceValidation(
            status: status,
            reasons: reasons,
            segmentActions: segmentActions,
            segmentEvents: segmentEvents,
            hasDeviceMarker: hasDeviceMarker,
            hasPathMarker: hasPathMarker,
            hasReadyMarker: hasReadyMarker,
            hasPreparedGeometry: hasPreparedGeometry,
            hasExecutionGeometry: hasExecutionGeometry,
            geometryDigestMatches: geometryDigestMatches,
            sessionIsValid: sessionIsValid,
            sessionStayedStable: sessionIsValid && sessionIDs.count == 1,
            sawCommit: sawCommit,
            sawPrivacyViolation: sawPrivacyViolation
        )
    }

    private static func markerLine(from line: String) -> String? {
        let markerNames = [
            "T9DEVICE ",
            "T9GEOM ",
            "T9SEG ",
            "T9RESP ",
            "T9ARM ",
            "SLOW T9SEG ",
            "SLOW RIME "
        ]
        guard let match = markerNames.compactMap({ name in
            line.range(of: name).map { (name, $0) }
        }).min(by: { $0.1.lowerBound < $1.1.lowerBound }) else {
            return nil
        }
        return String(line[match.1.lowerBound...])
    }

    private static func keyValueFields(from marker: String) -> [String: String] {
        var fields: [String: String] = [:]
        for token in marker.split(whereSeparator: { $0.isWhitespace }) {
            guard let separator = token.firstIndex(of: "=") else { continue }
            let key = String(token[..<separator])
            let valueStart = token.index(after: separator)
            fields[key] = String(token[valueStart...])
        }
        return fields
    }

    private static func revision(from fields: [String: String]) -> UInt64? {
        UInt64(fields["rev"] ?? "")
    }

    private static func epoch(from fields: [String: String]) -> UInt64? {
        UInt64(fields["epoch"] ?? "")
    }

    private static func isPositive(_ value: UInt64?) -> Bool {
        guard let value else { return false }
        return value > 0
    }

    private static func nonNegativeInt(_ rawValue: String?) -> Bool {
        guard let rawValue, let value = Int(rawValue) else { return false }
        return value >= 0
    }

    private static func nonNegativeUInt(_ rawValue: String?) -> Bool {
        guard let rawValue else { return false }
        return UInt64(rawValue) != nil
    }

    private static func requiresRunBinding(_ marker: String) -> Bool {
        marker.contains("T9DEVICE ")
            || marker.contains("T9GEOM ")
            || marker.contains("T9SEG ")
            || marker.contains("T9ARM ")
            || marker.contains("T9RESP marker=PATH")
            || marker.contains("T9RESP marker=READY")
            || marker.contains("T9RESP marker=NOT_READY")
            || marker.contains("T9RESP marker=FALLBACK")
            || marker.contains("T9RESP marker=ACCEPT")
            || marker.contains("T9RESP marker=VISIBLE")
            || marker.contains("T9RESP marker=PUBLISH")
            || marker.contains("T9RESP marker=PAINT")
            || marker.contains("T9RESP marker=BURST")
    }

    private static func hasRequiredSegmentFields(_ fields: [String: String]) -> Bool {
        let requiredKeys = [
            "action", "event", "keyLen", "compBefore", "rawLen", "paths", "cands",
            "committed", "sessionBefore", "validBefore", "sessionAfter", "validAfter",
            "total", "engine", "ui", "rime", "pathLocal", "preedit", "pathUI",
            "candUI", "unaccounted"
        ]
        guard requiredKeys.allSatisfy({ fields[$0] != nil }) else {
            return false
        }
        let nonNegativeIntegerKeys = [
            "action", "event", "keyLen", "compBefore", "rawLen", "paths", "cands",
        ]
        guard nonNegativeIntegerKeys.allSatisfy({
            guard let value = fields[$0], let integer = Int64(value) else { return false }
            return integer >= 0
        }) else {
            return false
        }
        // Native session identities are UInt64 values; do not narrow them to
        // Int64 merely because the surrounding counters are signed integers.
        guard ["sessionBefore", "sessionAfter"].allSatisfy({
            guard let value = fields[$0] else { return false }
            return UInt64(value) != nil
        }) else {
            return false
        }
        let booleanKeys = ["committed", "validBefore", "validAfter"]
        guard booleanKeys.allSatisfy({ fields[$0] == "true" || fields[$0] == "false" }) else {
            return false
        }
        let timingKeys = [
            "total", "engine", "ui", "rime", "pathLocal", "preedit", "pathUI",
            "candUI", "unaccounted"
        ]
        return timingKeys.allSatisfy { value in
            guard let raw = fields[value], let number = Double(raw) else { return false }
            return number.isFinite && number >= 0
        }
    }

    private static func isValidGeometryDigest(_ digest: String) -> Bool {
        guard digest.count == 64 else { return false }
        let hex = Set("0123456789abcdef")
        return digest.allSatisfy(hex.contains)
    }

    private static func hasRequiredGeometryFields(_ fields: [String: String]) -> Bool {
        guard fields["space"] == "portrait-screen-points",
              fields["orientation"] == "portrait",
              isFinitePositive(fields["scale"]),
              isValidRect(fields["screen"]),
              isValidRect(fields["keyboard"])
        else {
            return false
        }
        return (0..<8).allSatisfy { isValidRect(fields["s\($0)"]) }
    }

    private static func isFinitePositive(_ rawValue: String?) -> Bool {
        guard let rawValue, let value = Double(rawValue) else { return false }
        return value.isFinite && value > 0
    }

    private static func isValidRect(_ rawValue: String?) -> Bool {
        guard let rawValue else { return false }
        let values = rawValue.split(separator: ",").compactMap { Double($0) }
        guard values.count == 4, values.allSatisfy(\.isFinite) else { return false }
        return values[2] > 0 && values[3] > 0
    }

    private static func isCanonicalRunToken(_ token: String) -> Bool {
        guard token.count == 36, token.hasPrefix("S6A-") else { return false }
        let hex = Set("0123456789ABCDEF")
        return token.dropFirst(4).allSatisfy(hex.contains)
    }

    private static func containsPrivacySensitiveContent(_ line: String) -> Bool {
        let forbiddenFields = [
            "rawInput=",
            "composition=",
            "candidate=",
            "candidates=",
            "markedText=",
            "hostText=",
            "pinyin=",
            "userDictionary="
        ]
        if forbiddenFields.contains(where: { field in
            field != "candidates=" && line.contains(field)
        }) {
            return true
        }
        if line.contains("candidates=") && !containsContentFreeCandidateCount(line) {
            return true
        }
        return line.unicodeScalars.contains { $0.value > 0x7F }
    }

    /// `SLOW RIME candidates=12,` is a count-only diagnostic field. Candidate
    /// text, malformed values and any trailing non-punctuation remain blocked.
    private static func containsContentFreeCandidateCount(_ line: String) -> Bool {
        guard let range = line.range(of: "candidates=") else { return false }
        let token = line[range.upperBound...]
            .split(whereSeparator: { $0.isWhitespace })
            .first
            .map(String.init) ?? ""
        let count = token.trimmingCharacters(in: CharacterSet(charactersIn: ",;"))
        return !count.isEmpty && count.allSatisfy(\.isNumber)
    }
}
