import KeyboardCore
import XCTest

final class TypoCorrectionRecallRuntimeTests: XCTestCase {
    func testRuntimeBudgetPinsAreTheAuthorizedProductionValues() {
        XCTAssertEqual(TypoCorrectionRecallRuntimeBudget.selectedGroups, 8)
        XCTAssertEqual(TypoCorrectionRecallRuntimeBudget.maxQueryAttempts, 8)
        XCTAssertEqual(TypoCorrectionRecallRuntimeBudget.candidateLimit, 3)
        XCTAssertEqual(TypoCorrectionRecallRuntimeBudget.acceptedDisplayResults, 4)
    }
}
