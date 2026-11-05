import KeyboardCore
import XCTest

@testable import RimeBridge

final class NineKeySmokeProbeTests: XCTestCase {
    func testCommentWindowAcceptsLaterCandidateWhenFirstCommentIsEmpty() {
        let passed = RimeT9SmokeProbe.evaluationPasses(
            raw: "64",
            expectedRaw: "64",
            candidates: [
                RimeCandidate(text: "你", comment: nil),
                RimeCandidate(text: "泥", comment: "ni"),
            ],
            rawAfterDelete: "6",
            expectedAfterDelete: "6"
        )
        XCTAssertTrue(passed)
    }

    func testInvalidFirstCommentStillPassesWhenAnotherCommentValidates() {
        let passed = RimeT9SmokeProbe.evaluationPasses(
            raw: "6446",
            expectedRaw: "6446",
            candidates: [
                RimeCandidate(text: "好", comment: "〔表情：👋〕"),
                RimeCandidate(text: "号", comment: "hao"),
            ],
            rawAfterDelete: "644",
            expectedAfterDelete: "644"
        )
        XCTAssertTrue(passed)
    }

    func testEmptyCommentsFailWithoutRequiringOnlyTheFirst() {
        let passed = RimeT9SmokeProbe.evaluationPasses(
            raw: "64",
            expectedRaw: "64",
            candidates: [RimeCandidate(text: "你", comment: "")],
            rawAfterDelete: "6",
            expectedAfterDelete: "6"
        )
        XCTAssertFalse(passed)
    }

    func testRegisteredInputsStayOnTheSchemeRecord() {
        XCTAssertEqual(NineKeySchemeRegistry.smokeInput(for: "t9"), "64")
        let wanID = NineKeySchemeRegistry.schemes(forFamily: "wanxiang")[0].schemaID
        XCTAssertEqual(NineKeySchemeRegistry.smokeInput(for: wanID), "6446")
    }
}
