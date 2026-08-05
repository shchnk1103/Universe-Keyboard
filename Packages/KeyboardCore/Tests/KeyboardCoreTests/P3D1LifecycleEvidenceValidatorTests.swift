import XCTest
@testable import KeyboardCore

final class P3D1LifecycleEvidenceValidatorTests: XCTestCase {
    private let runID = "P3D1-T02-T03-SIM-TEST"

    func testCompleteOwnerAndReturnSequenceIsContentFree() {
        let result = P3D1LifecycleEvidenceValidator.validate(
            lines: [
                marker("OWNER_READY", rev: 0, accepted: 0, applied: 0),
                marker("OWNER_BEGIN", rev: 0, accepted: 0, applied: 0),
                marker("OWNER_END", rev: 1, accepted: 1, applied: 0),
                marker("PUBLISH", rev: 1, accepted: 1, applied: 1),
                marker("CLEAR", rev: 1, accepted: 1, applied: 1, cleared: 1),
                marker("RETURN_CLEAN", rev: 1, accepted: 1, applied: 1, cleared: 1),
            ],
            runID: runID,
            requiredMarkers: ["OWNER_READY", "OWNER_BEGIN", "OWNER_END", "PUBLISH", "RETURN_CLEAN"]
        )

        XCTAssertEqual(result.status, .complete)
        XCTAssertTrue(result.ownerCycleIsOrdered)
        XCTAssertTrue(result.sawAcceptedRevision)
        XCTAssertTrue(result.sawAppliedRevision)
        XCTAssertTrue(result.sawClear)
        XCTAssertTrue(result.sawReturnClean)
        XCTAssertFalse(result.sawPrivacyViolation)
    }

    func testMissingRunBindingBlocksInsteadOfInferringIdentity() {
        let result = P3D1LifecycleEvidenceValidator.validate(
            lines: [marker("OWNER_READY", run: "OTHER")],
            runID: runID,
            requiredMarkers: ["OWNER_READY"]
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.reasons.contains("run-token-missing-or-wrong"))
    }

    func testPrivacySensitiveFieldBlocksEvidence() {
        let result = P3D1LifecycleEvidenceValidator.validate(
            lines: [marker("OWNER_READY") + " rawInput=nihao"],
            runID: runID,
            requiredMarkers: ["OWNER_READY"]
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertTrue(result.sawPrivacyViolation)
        XCTAssertTrue(result.reasons.contains("privacy-sensitive-content"))
    }

    func testOwnerOrderAndRequiredPublishArePartial() {
        let result = P3D1LifecycleEvidenceValidator.validate(
            lines: [
                marker("OWNER_END", rev: 2, accepted: 0, applied: 0),
                marker("OWNER_BEGIN", rev: 1, accepted: 0, applied: 0),
            ],
            runID: runID,
            requiredMarkers: ["OWNER_READY", "OWNER_BEGIN", "OWNER_END", "PUBLISH"]
        )

        XCTAssertEqual(result.status, .partial)
        XCTAssertTrue(result.reasons.contains("required-marker-missing"))
        XCTAssertTrue(result.reasons.contains("owner-cycle-order-invalid"))
        XCTAssertTrue(result.reasons.contains("accepted-revision-missing"))
        XCTAssertTrue(result.reasons.contains("applied-revision-missing"))
    }

    func testRevisionMayResetWhenLifecycleEpochAdvances() {
        let result = P3D1LifecycleEvidenceValidator.validate(
            lines: [
                marker("PUBLISH", epoch: 1, rev: 3),
                marker("PUBLISH", epoch: 2, rev: 1),
            ],
            runID: runID,
            requiredMarkers: ["PUBLISH"]
        )

        XCTAssertEqual(result.status, .complete)
        XCTAssertFalse(result.reasons.contains("revision-regression"))
    }

    func testEmptyExportIsNotRun() {
        let result = P3D1LifecycleEvidenceValidator.validate(lines: [], runID: runID)

        XCTAssertEqual(result.status, .notRun)
        XCTAssertEqual(result.reasons, ["p3life-markers-missing"])
    }

    private func marker(
        _ name: String,
        run: String? = nil,
        epoch: Int = 1,
        rev: Int = 1,
        accepted: Int = 1,
        applied: Int = 1,
        cleared: Int = 0
    ) -> String {
        "P3LIFE schema=v1 marker=\(name) run=\(run ?? runID) gate=1 epoch=\(epoch) "
            + "rev=\(rev) pending=0 accepted=\(accepted) applied=\(applied) "
            + "stale=0 discard=0 terminal=0 ownerReady=1 cleared=\(cleared) "
            + "returnClean=\(cleared) reason=test"
    }
}
