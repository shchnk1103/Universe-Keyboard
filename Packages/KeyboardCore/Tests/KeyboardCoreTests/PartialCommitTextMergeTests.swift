import XCTest

@testable import KeyboardCore

final class PartialCommitTextMergeTests: XCTestCase {
    func testPartialOverlapIsDroppedBeforeConcatenation() {
        XCTAssertEqual(
            PartialCommitTextMerge.mergedText(confirmed: "记进任务", committed: "任务目录"),
            "记进任务目录")
        XCTAssertEqual(
            PartialCommitTextMerge.mergedText(confirmed: "记进任务", committed: "任务目录里"),
            "记进任务目录里")
    }

    func testFullPrefixCommitStillWins() {
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "记进", committed: "记进任务"), "记进任务")
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "你好", committed: "你好安排"), "你好安排")
    }

    func testNoOverlapConcatenatesFully() {
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "记", committed: "进"), "记进")
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "你好", committed: "安排"), "你好安排")
    }

    func testCommittedPrefixOfConfirmedCollapsesToConfirmed() {
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "记进任务", committed: "记进"), "记进任务")
    }

    func testEmptyStringBoundaries() {
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "", committed: "abc"), "abc")
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "abc", committed: ""), "abc")
        XCTAssertEqual(PartialCommitTextMerge.mergedText(confirmed: "", committed: ""), "")
    }
}
