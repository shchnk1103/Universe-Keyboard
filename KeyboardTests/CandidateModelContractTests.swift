import KeyboardCore
import XCTest

final class CandidateModelContractTests: XCTestCase {
    func testCandidateKindsRemainCompatibleWithButtonTagMapping() {
        XCTAssertEqual(CandidateKind.candidate.rawValue, 0)
        XCTAssertEqual(CandidateKind.composition.rawValue, 1)
        XCTAssertEqual(CandidateKind.placeholder.rawValue, 2)
        XCTAssertEqual(CandidateKind.correctionCandidate.rawValue, 3)
        XCTAssertEqual(CandidateKind.continuationCandidate.rawValue, 4)
    }

    func testCandidateItemPreservesDisplayTextAndBehaviorKind() {
        let item = CandidateItem(title: "你好", kind: .candidate)

        XCTAssertEqual(item, CandidateItem(title: "你好", kind: .candidate))
        XCTAssertEqual(item.title, "你好")
        XCTAssertEqual(item.kind, .candidate)
    }
}
