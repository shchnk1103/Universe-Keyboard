import KeyboardCore
import RimeBridgeObjC
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

    func testObjCFacadeSeparatesValidationAndSidecarReadinessWithoutEngineSetup() {
        let manager = RimeSessionManager()

        let empty = manager.correctionCandidates(forInput: "", limit: 0)
        XCTAssertEqual(empty[RimeKeyCorrectionQueryReadiness] as? String, "unknown")
        XCTAssertEqual(empty[RimeKeyCorrectionQueryResultState] as? String, "empty_input")
        XCTAssertEqual((empty[RimeKeyCandidates] as? [Any])?.count, 0)

        let zeroLimit = manager.correctionCandidates(forInput: "nihao", limit: 0)
        XCTAssertEqual(zeroLimit[RimeKeyCorrectionQueryReadiness] as? String, "unknown")
        XCTAssertEqual(zeroLimit[RimeKeyCorrectionQueryResultState] as? String, "zero_limit")

        let unavailable = manager.correctionCandidates(forInput: "nihao", limit: 3)
        XCTAssertEqual(unavailable[RimeKeyCorrectionQueryReadiness] as? String, "unavailable")
        XCTAssertEqual(
            unavailable[RimeKeyCorrectionQueryResultState] as? String,
            "sidecar_unavailable"
        )
    }

    func testSwiftFacadeParserPreservesSameCallReadinessAndResultStates() throws {
        let cases: [(String, String, TypoCorrectionQueryReadiness, TypoCorrectionQueryResultState)] = [
            ("ready", "candidates_returned", .ready, .candidatesReturned),
            ("ready", "context_unavailable", .ready, .contextUnavailable),
            ("unavailable", "sidecar_unavailable", .unavailable, .sidecarUnavailable),
            ("unknown", "empty_input", .unknown, .emptyInput),
            ("unknown", "zero_limit", .unknown, .zeroLimit),
        ]

        for (readiness, state, expectedReadiness, expectedState) in cases {
            let candidateData: [[String: String]] =
                expectedState == .candidatesReturned
                ? [["text": "你好"]]
                : []
            let result = try XCTUnwrap(
                RimeEngineImpl.parseCorrectionQueryResult([
                    RimeKeyCandidates: candidateData,
                    RimeKeyCorrectionQueryReadiness: readiness,
                    RimeKeyCorrectionQueryResultState: state,
                ])
            )
            XCTAssertEqual(result.readiness, expectedReadiness)
            XCTAssertEqual(result.state, expectedState)
            XCTAssertEqual(
                result.candidates.map(\.text),
                expectedState == .candidatesReturned ? ["你好"] : []
            )
        }

        XCTAssertNil(
            RimeEngineImpl.parseCorrectionQueryResult([
                RimeKeyCandidates: [],
                RimeKeyCorrectionQueryReadiness: "new_value",
                RimeKeyCorrectionQueryResultState: "candidates_returned",
            ])
        )
        XCTAssertNil(
            RimeEngineImpl.parseCorrectionQueryResult([
                RimeKeyCandidates: [],
                RimeKeyCorrectionQueryReadiness: "unavailable",
                RimeKeyCorrectionQueryResultState: "candidates_returned",
            ])
        )
    }

    func testCandidateParserDropsEmptyTextBeforeBucketClassification() {
        let parsed = RimeEngineImpl.parseCandidateWindowDictionary([
            RimeKeyCandidates: [
                [RimeKeyCandidateText: ""],
                [RimeKeyCandidateText: "你好"],
                [RimeKeyCandidateText: "世界"],
            ]
        ])

        XCTAssertEqual(parsed.candidates.map(\.text), ["你好", "世界"])
        XCTAssertEqual(
            DiagnosticEvent.TypoRecallCandidateBucket.classify(
                candidates: parsed.candidates,
                resultState: .candidatesReturned
            ),
            .oneToThree
        )
    }
}

private final class QueryStub: TypoCorrectionCandidateQuerying {
    private(set) var inputs: [String] = []

    func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        inputs.append(input)
        return [RimeCandidate(text: "你好")].prefix(max(0, limit)).map { $0 }
    }
}
