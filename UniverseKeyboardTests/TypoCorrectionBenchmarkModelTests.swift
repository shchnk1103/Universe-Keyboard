import XCTest

@testable import Universe_Keyboard

@MainActor
final class TypoCorrectionBenchmarkModelTests: XCTestCase {
    func testModelSummarizesLocalBenchmarkResults() {
        let model = TypoCorrectionBenchmarkModel()

        XCTAssertEqual(model.statusText, "质量闸门通过")
        XCTAssertEqual(model.passRateText, "\(model.summary.totalCount)/\(model.summary.totalCount)")
        XCTAssertEqual(model.summary.falsePositiveCount, 0)
        XCTAssertEqual(model.summary.dangerousCorrectionCount, 0)
    }

    func testModelGroupsBenchmarkResultsForDisplay() {
        let model = TypoCorrectionBenchmarkModel()

        XCTAssertEqual(
            model.groupedResults.map(\.title),
            ["当前覆盖", "正常输入", "已知边界", "危险样例"]
        )
        XCTAssertTrue(model.groupedResults.allSatisfy { !$0.results.isEmpty })
    }

    func testResultDisplayTextUsesExpectedAndActualValues() {
        let model = TypoCorrectionBenchmarkModel()
        let zhonghuo = model.summary.results.first { $0.testCase.input == "zhonghuo" }

        XCTAssertEqual(zhonghuo?.displayActual, "zhongguo -> 中国")
        XCTAssertEqual(zhonghuo?.displayExpected, "zhongguo -> 中国")
        XCTAssertEqual(zhonghuo?.displayConfidence, "高")
        XCTAssertEqual(zhonghuo?.displayPromotion, "不提升")
        XCTAssertEqual(zhonghuo?.displayReason, "中间安全邻键替换")
    }
}
