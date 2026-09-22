import KeyboardCore
import XCTest

@testable import RimeBridge

@MainActor
final class TypoCorrectionSidecarOwnerAdapterTests: XCTestCase {
    func testRouteAdaptersWrapOnlyTheirInstalledFacadeWithNoNativeEpoch() {
        for route in TypoCorrectionSidecarRoute.allCases {
            let stub = QueryStub()
            let owner = TypoCorrectionSidecarOwnerAdapters.wrapping(stub, route: route)

            XCTAssertEqual(owner.route, route)
            XCTAssertNil(owner.routeLocalOwnerEpoch)
            XCTAssertEqual(
                owner.correctionCandidates(for: "nihao", limit: 3).map(\.text),
                ["你好"]
            )
            XCTAssertEqual(stub.inputs, ["nihao"])
        }
    }
}

private final class QueryStub: TypoCorrectionCandidateQuerying {
    private(set) var inputs: [String] = []

    func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        inputs.append(input)
        return [RimeCandidate(text: "你好")].prefix(max(0, limit)).map { $0 }
    }
}
