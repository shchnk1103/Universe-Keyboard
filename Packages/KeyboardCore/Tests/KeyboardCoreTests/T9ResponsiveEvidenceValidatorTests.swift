import XCTest
@testable import KeyboardCore

final class T9ResponsiveEvidenceValidatorTests: XCTestCase {
    private let runToken = "S6A-0123456789ABCDEF0123456789ABCDEF"
    private let digest = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    private let geometryPayload = "space=portrait-screen-points orientation=portrait "
        + "screen=0,0,390,844 scale=3 keyboard=0,500,390,344 "
        + "s0=0,500,48,48 s1=48,500,48,48 s2=96,500,48,48 s3=144,500,48,48 "
        + "s4=192,500,48,48 s5=240,500,48,48 s6=288,500,48,48 s7=336,500,48,48"

    func testDeviceEvidenceFilterRetainsResponsiveAndSlowRimeMarkers() {
        XCTAssertTrue(
            T9DevicePreflightEvidenceLineFilter.retains(
                "[INFO] [ENGINE] T9RESP marker=READY fixture=T9RESP-R5P"
            )
        )
        XCTAssertTrue(
            T9DevicePreflightEvidenceLineFilter.retains(
                "[WARN] [PERF] SLOW RIME keyLength=1 bridge=150.0ms"
            )
        )
        XCTAssertTrue(
            T9DevicePreflightEvidenceLineFilter.retains(
                "[INFO] [PERF] T9SEG run=\(runToken) action=1 event=1"
            )
        )
        XCTAssertTrue(
            T9DevicePreflightEvidenceLineFilter.retains(
                "[INFO] [PERF] T9RESP marker=PAINT schema=v1 run=\(runToken) rev=1"
            )
        )
        XCTAssertFalse(
            T9DevicePreflightEvidenceLineFilter.retains(
                "[INFO] [GEN] ordinary host text must not enter the evidence subset"
            )
        )
    }

    func testDeclaredBArmWithThirtyNineRowsIsComplete() {
        let result = T9ResponsiveEvidenceValidator.validate(
            lines: completeLines(),
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .complete)
        XCTAssertEqual(result.segmentActions, Array(1...39))
        XCTAssertEqual(result.segmentEvents, Array(1...39))
        XCTAssertTrue(result.hasPathMarker)
        XCTAssertTrue(result.hasReadyMarker)
        XCTAssertTrue(result.sessionIsValid)
        XCTAssertTrue(result.sessionStayedStable)
        XCTAssertTrue(result.geometryDigestMatches)
        XCTAssertFalse(result.reasons.contains("segment-actions-not-contiguous"))
    }

    func testSyncArmDoesNotRequireResponsiveFeltMarkers() {
        let result = T9ResponsiveEvidenceValidator.validate(
            lines: syncLines(),
            expectation: T9ResponsiveEvidenceExpectation(
                runToken: runToken,
                arm: .sync,
                requirePathMarker: true,
                requireRunBoundMarkers: true,
                requireResponsiveFeltMarkers: false
            )
        )

        XCTAssertEqual(result.status, .complete)
        XCTAssertTrue(result.hasPathMarker)
        XCTAssertFalse(result.hasReadyMarker)
        XCTAssertFalse(result.reasons.contains("publish-marker-missing"))
        XCTAssertFalse(result.reasons.contains("accept-revisions-not-complete"))
    }

    func testLegacyThirtyEightActionArmCheckpointDoesNotReplaceP2Count() {
        let result = T9ResponsiveEvidenceValidator.validate(
            lines: completeLines() + [
                "[INFO] [PERF] T9ARM run=\(runToken) actions=38 committed=0 session=42 sessionStable=true sessionValid=true"
            ],
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .complete)
        XCTAssertEqual(result.segmentActions.count, 39)
        XCTAssertFalse(result.reasons.contains("segment-actions-not-contiguous"))
    }

    func testMissingPathSessionAndExecutionGeometryRemainPartial() {
        let lines = completeLines().filter { line in
            !line.contains("T9RESP marker=PATH")
                && !line.contains("T9RESP marker=READY")
                && !line.contains("phase=execution")
        }.map { line in
            line.replacingOccurrences(
                of: "sessionBefore=42 validBefore=true sessionAfter=42 validAfter=true",
                with: "sessionBefore=0 validBefore=false sessionAfter=0 validAfter=false"
            )
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("path-marker-missing-or-wrong"))
        XCTAssertTrue(result.reasons.contains("ready-marker-missing"))
        XCTAssertTrue(result.reasons.contains("execution-geometry-missing"))
        XCTAssertTrue(result.reasons.contains("native-session-invalid-or-missing"))
    }

    func testMixedRunTokensAreBlocked() {
        var lines = completeLines()
        lines.append(
            "[INFO] [PERF] T9SEG run=S6A-FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF action=40 event=40 "
                + "keyLen=1 compBefore=39 rawLen=40 paths=0 cands=0 committed=false "
                + "sessionBefore=42 validBefore=true sessionAfter=42 validAfter=true total=1.0 engine=1.0 ui=0.0 "
                + "rime=1.0 pathLocal=0.0 preedit=0.0 pathUI=0.0 candUI=0.0 unaccounted=0.0"
        )

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.reasons.contains("mixed-run-tokens"))
    }

    func testMissingRunBindingIsBlockedInsteadOfInferred() {
        let lines = completeLines().map { line in
            guard line.contains("T9SEG run=\(runToken) action=1") else {
                return line
            }
            return line.replacingOccurrences(of: "T9SEG run=\(runToken)", with: "T9SEG")
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.reasons.contains("marker-run-token-missing-or-wrong"))
    }

    func testPrivacySensitiveRuntimeLineIsBlocked() {
        let lines = completeLines() + [
            "[INFO] [PERF] T9SEG run=\(runToken) action=40 event=40 rawInput=nihao"
        ]

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.sawPrivacyViolation)
        XCTAssertTrue(result.reasons.contains("privacy-sensitive-content"))
    }

    func testGapAndDuplicateArePartialInsteadOfSilentlyFilled() {
        let lines = completeLines().filter { !$0.contains("action=10 event=10") }
            + [
                completeSegmentLine(action: 9)
            ]

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("segment-actions-not-contiguous"))
        XCTAssertTrue(result.reasons.contains("duplicate-segment-actions"))
    }

    func testPublishRevisionRegressionIsPartial() {
        var lines = completeLines()
        lines.append(
            "[INFO] [PERF] T9RESP marker=PUBLISH schema=v1 run=\(runToken) epoch=1 rev=1 fixture=T9RESP-R5P"
        )

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("accept-publish-order-invalid"))
    }

    func testEpochRegressionIsPartial() {
        let lines = completeLines().map { line in
            guard line.contains("rev=2") else { return line }
            return line.replacingOccurrences(of: "epoch=1", with: "epoch=2")
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("epoch-regression"))
    }

    func testDuplicateOwnerPublishIsPartial() {
        var lines = completeLines()
        lines.append(
            "[INFO] [PERF] T9RESP marker=PUBLISH schema=v1 run=\(runToken) epoch=1 rev=39 fixture=T9RESP-R5P"
        )

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("duplicate-owner-publish"))
    }

    func testAcceptSchemaRequiresFixtureAndNonNegativePending() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(
                of: "action=k rev=1 pending=1 epoch=1 fixture=T9RESP-R5P",
                with: "action=k rev=1 pending=-1 epoch=1 fixture=wrong-fixture"
            )
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("marker-schema-invalid"))
        XCTAssertTrue(result.reasons.contains("accept-revisions-not-complete"))
    }

    func testVisibleSchemaIsValidatedInsteadOfIgnored() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(
                of: "T9RESP marker=VISIBLE schema=v1 run=\(runToken) lagMs=1 rev=1 source=provisional fixture=T9RESP-R5P",
                with: "T9RESP marker=VISIBLE schema=bad run=\(runToken) lagMs=bad rev=1 source=unknown fixture=wrong-fixture"
            )
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("marker-schema-invalid"))
    }

    func testEpochBoundPublishMustCoverEveryAcceptedRevision() {
        let lines = completeLines().filter { line in
            !line.contains("T9RESP marker=PUBLISH schema=v1 run=\(runToken) epoch=1 rev=39")
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("epoch-bound-publish-incomplete"))
    }

    func testPaintCannotSubstituteForOwnerCompletion() {
        let lines = completeLines().filter { line in
            !line.contains("T9RESP marker=PUBLISH schema=v1")
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("publish-marker-missing"))
        XCTAssertTrue(result.reasons.contains("epoch-bound-publish-missing"))
        XCTAssertTrue(result.reasons.contains("epoch-bound-publish-incomplete"))
    }

    func testEngineVisibleAndPaintMustFollowOwnerCompletion() {
        let publish = "T9RESP marker=PUBLISH schema=v1 run=\(runToken) epoch=1 rev=1 fixture=T9RESP-R5P"
        var lines = completeLines()
        guard let publishIndex = lines.firstIndex(where: { $0.contains(publish) }) else {
            XCTFail("fixture must contain the revision-one owner completion")
            return
        }
        let engineVisible = "[INFO] [PERF] T9RESP marker=VISIBLE schema=v1 run=\(runToken) lagMs=1 rev=1 source=engine fixture=T9RESP-R5P"
        let paint = "[INFO] [PERF] T9RESP marker=PAINT schema=v1 run=\(runToken) lagMs=2 rev=1 pendingAfter=0 coalesced=0 fixture=T9RESP-R5P"
        lines.insert(engineVisible, at: publishIndex)
        lines.insert(paint, at: publishIndex)

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("engine-presentation-before-publish"))
    }

    func testPublishRejectsUiPresentationFields() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(
                of: "T9RESP marker=PAINT schema=v1 run=\(runToken) lagMs=2 rev=1 pendingAfter=0 coalesced=0 fixture=T9RESP-R5P",
                with: "T9RESP marker=PUBLISH schema=bad run=\(runToken) lagMs=bad rev=1 pendingAfter=-1 coalesced=2 fixture=wrong-fixture"
            )
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("marker-schema-invalid"))
    }

    func testMalformedGeometryDigestIsPartial() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(of: digest, with: "not-a-digest")
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("geometry-digest-invalid"))
        XCTAssertFalse(result.geometryDigestMatches)
    }

    func testGeometryPayloadSchemaIsRequired() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(
                of: "orientation=portrait",
                with: "orientation=landscape",
                options: [],
                range: line.contains("phase=prepared") ? line.startIndex..<line.endIndex : nil
            )
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("marker-schema-invalid"))
    }

    func testUnavailableGeometryThenValidRetryUsesFinalExecutionState() {
        var lines = completeLines()
        lines.insert(
            "[WARN] [PERF] T9GEOM schema=v1 phase=execution run=\(runToken) status=unavailable",
            at: 4
        )

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .complete)
        XCTAssertFalse(result.reasons.contains("execution-geometry-unavailable"))
        XCTAssertTrue(result.geometryDigestMatches)
    }

    func testOwnerNotReadyCannotSatisfyReadyMarker() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(
                of: "T9RESP marker=READY schema=v1 run=\(runToken)",
                with: "T9RESP marker=NOT_READY schema=v1 run=\(runToken) reason=owner-timeout"
            )
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("owner-not-ready"))
        XCTAssertTrue(result.reasons.contains("ready-marker-missing"))
    }

    func testActionEventPairMismatchIsPartial() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(
                of: "action=1 event=1",
                with: "action=1 event=2"
            )
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("segment-action-event-mismatch"))
    }

    func testMarkerlessPrivacyViolationIsBlocked() {
        let result = T9ResponsiveEvidenceValidator.validate(
            lines: ["[INFO] [GEN] markedText=你好"],
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.sawPrivacyViolation)
    }

    func testContentFreeCandidateCountIsAllowed() {
        let result = T9ResponsiveEvidenceValidator.validate(
            lines: completeLines() + [
                "[WARN] [PERF] SLOW RIME keyLength=1 candidates=12, bridge=150.0ms"
            ],
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .complete)
        XCTAssertFalse(result.sawPrivacyViolation)
    }

    func testCandidateTextStillBlocksPrivacyValidation() {
        let result = T9ResponsiveEvidenceValidator.validate(
            lines: completeLines() + [
                "[WARN] [PERF] SLOW RIME keyLength=1 candidates=今天天气 bridge=150.0ms"
            ],
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.sawPrivacyViolation)
    }

    func testMalformedCandidateCountStillBlocksPrivacyValidation() {
        let result = T9ResponsiveEvidenceValidator.validate(
            lines: completeLines() + [
                "[WARN] [PERF] SLOW RIME keyLength=1 candidates=12ms bridge=150.0ms"
            ],
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.sawPrivacyViolation)
    }

    func testMalformedAcceptMarkerIsPartial() {
        let lines = completeLines().map { line in
            line.replacingOccurrences(of: "rev=1", with: "rev=not-a-revision")
        }

        let result = T9ResponsiveEvidenceValidator.validate(
            lines: lines,
            expectation: expectation()
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("marker-schema-invalid"))
    }

    private func expectation() -> T9ResponsiveEvidenceExpectation {
        T9ResponsiveEvidenceExpectation(
            runToken: runToken,
            arm: .threadAffine
        )
    }

    private func completeLines() -> [String] {
        var lines = [
            "[INFO] [PERF] T9DEVICE schema=v1 marker=T9DEVICE_DISABLED run=\(runToken) gate=off measurement=on",
            "[INFO] [ENGINE] T9RESP marker=PATH schema=v1 run=\(runToken) path=thread-affine fixture=T9RESP-R5P dualGateRequested=1 dualGateActive=1",
            "[INFO] [ENGINE] T9RESP marker=READY schema=v1 run=\(runToken) fixture=T9RESP-R5P bootstrap=config-only session=owner-thread",
            "[INFO] [PERF] T9GEOM schema=v1 phase=prepared run=\(runToken) digest=\(digest) \(geometryPayload)",
            "[INFO] [PERF] T9GEOM schema=v1 phase=execution run=\(runToken) digest=\(digest) \(geometryPayload)"
        ]
        for action in 1...39 {
            lines.append(
                "[INFO] [PERF] T9RESP marker=ACCEPT schema=v1 run=\(runToken) action=k rev=\(action) pending=1 epoch=1 fixture=T9RESP-R5P"
            )
            lines.append(
                "[INFO] [PERF] T9RESP marker=VISIBLE schema=v1 run=\(runToken) lagMs=1 rev=\(action) source=provisional fixture=T9RESP-R5P"
            )
            lines.append(
                "[INFO] [PERF] T9RESP marker=PUBLISH schema=v1 run=\(runToken) epoch=1 rev=\(action) fixture=T9RESP-R5P"
            )
            lines.append(
                "[INFO] [PERF] T9RESP marker=VISIBLE schema=v1 run=\(runToken) lagMs=3 rev=\(action) source=engine fixture=T9RESP-R5P"
            )
            lines.append(
                "[INFO] [PERF] T9RESP marker=PAINT schema=v1 run=\(runToken) lagMs=2 rev=\(action) pendingAfter=0 coalesced=0 fixture=T9RESP-R5P"
            )
            lines.append(completeSegmentLine(action: action))
        }
        return lines
    }

    private func syncLines() -> [String] {
        var lines = [
            "[INFO] [PERF] T9DEVICE schema=v1 marker=T9DEVICE_DISABLED run=\(runToken) gate=off measurement=on",
            "[INFO] [ENGINE] T9RESP marker=PATH schema=v1 run=\(runToken) path=sync fixture=T9RESP-R5P dualGateRequested=0 dualGateActive=0",
            "[INFO] [PERF] T9GEOM schema=v1 phase=prepared run=\(runToken) digest=\(digest) \(geometryPayload)",
            "[INFO] [PERF] T9GEOM schema=v1 phase=execution run=\(runToken) digest=\(digest) \(geometryPayload)"
        ]
        for action in 1...39 {
            lines.append(completeSegmentLine(action: action))
        }
        return lines
    }

    private func completeSegmentLine(action: Int) -> String {
        "[INFO] [PERF] T9SEG run=\(runToken) action=\(action) event=\(action) "
            + "keyLen=1 compBefore=\(action - 1) rawLen=\(action) paths=0 cands=0 committed=false "
            + "sessionBefore=42 validBefore=true sessionAfter=42 validAfter=true total=2.0 engine=1.0 ui=1.0 "
            + "rime=1.0 pathLocal=0.0 preedit=0.0 pathUI=0.0 candUI=0.0 unaccounted=1.0"
    }
}
