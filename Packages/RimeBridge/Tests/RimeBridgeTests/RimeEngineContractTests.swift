import XCTest
import KeyboardCore

@testable import RimeBridge

final class RimeEngineContractTests: XCTestCase {
    func testPrintableKeycodesUseASCIIValues() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "a"), 0x0061)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Z"), 0x005A)
        XCTAssertEqual(RimeEngineImpl.keycode(for: " "), 0x0020)
    }

    func testControlKeycodesMatchRimeKeysyms() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "BackSpace"), 0xFF08)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Delete"), 0xFF08)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Return"), 0xFF0D)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Enter"), 0xFF0D)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Tab"), 0xFF09)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Escape"), 0xFF1B)
    }

    func testSpaceActionAliasMatchesLiteralSpace() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "space"), RimeEngineImpl.keycode(for: " "))
    }

    func testEmptyAndMultiscalarInputDoNotEmitAKeycode() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: ""), 0)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "ni"), 0)
    }

    func testOutputParserSeparatesRawInputFromDisplayPreedit() {
        let output = RimeEngineImpl.parseOutputDictionary([
            "rawInput": "nihap",
            "preedit": "ni h a p",
            "cursorPos": 8,
            "candidates": [["text": "你好安排", "comment": ""]],
            "pageNo": 2,
            "isLastPage": false,
            "highlightedIndex": 0,
        ])

        XCTAssertEqual(output.rawInput, "nihap")
        XCTAssertEqual(output.composition?.preeditText, "ni h a p")
        XCTAssertEqual(output.candidatePageNumber, 2)
        XCTAssertEqual(output.candidates.map(\.text), ["你好安排"])
        XCTAssertTrue(output.hasMorePages)
    }

    func testOutputParserAcceptsObjectiveCCollections() {
        let candidate = NSMutableDictionary()
        candidate["text"] = "你" as NSString
        candidate["comment"] = "" as NSString
        candidate["globalIndex"] = NSNumber(value: 0)

        let output = RimeEngineImpl.parseOutputDictionary([
            "rawInput": "ni",
            "preedit": "ni",
            "cursorPos": 2,
            "candidates": NSMutableArray(object: candidate),
            "isLastPage": true,
        ])

        XCTAssertEqual(output.candidates.map(\.text), ["你"])
        XCTAssertEqual(output.candidates.map(\.globalIndex), [0])
    }

    func testOutputParserUsesPhaseOneDefaultsWhenMetadataIsMissing() {
        let output = RimeEngineImpl.parseOutputDictionary([:])

        XCTAssertNil(output.rawInput)
        XCTAssertEqual(output.candidatePageNumber, 0)
    }

    func testCandidateWindowParserPreservesGlobalIndexes() {
        let window = RimeEngineImpl.parseCandidateWindowDictionary([
            "startIndex": 9,
            "nextIndex": 12,
            "hasMoreCandidates": true,
            "candidates": [
                ["text": "今", "comment": "", "globalIndex": 9],
                ["text": "金", "comment": "", "globalIndex": 10],
                ["text": "仅", "comment": "", "globalIndex": 11],
            ],
        ])

        XCTAssertEqual(window.startIndex, 9)
        XCTAssertEqual(window.nextIndex, 12)
        XCTAssertTrue(window.hasMoreCandidates)
        XCTAssertEqual(window.candidates.map(\.text), ["今", "金", "仅"])
        XCTAssertEqual(window.candidates.map(\.globalIndex), [9, 10, 11])
    }

    func testDeploymentRequestCarriesFullCheckBoundary() {
        let request = RimeDeploymentRequest(
            mode: .fullCheck,
            sharedDataURL: URL(fileURLWithPath: "/shared"),
            userDataURL: URL(fileURLWithPath: "/user")
        )

        guard case .fullCheck = request.mode else {
            return XCTFail("Main app deployments must use full-check mode.")
        }
        XCTAssertEqual(request.sharedDataURL.path, "/shared")
        XCTAssertEqual(request.userDataURL.path, "/user")
    }

    func testRuntimeRecoveryRequestPreservesSessionOwnedBoundary() {
        let request = RimeDeploymentRequest(
            mode: .runtimeRecovery,
            sharedDataURL: URL(fileURLWithPath: "/shared"),
            userDataURL: URL(fileURLWithPath: "/user")
        )

        guard case .runtimeRecovery = request.mode else {
            return XCTFail("Keyboard recovery must remain a session-owned operation.")
        }
    }

    func testDeploymentServiceRejectsRuntimeRecoveryWithoutDeploymentDirectories() async throws {
        let request = RimeDeploymentRequest(
            mode: .runtimeRecovery,
            sharedDataURL: URL(fileURLWithPath: "/does-not-exist/shared"),
            userDataURL: URL(fileURLWithPath: "/does-not-exist/user")
        )

        let result = try await RimeDeploymentService().deploy(request)

        XCTAssertFalse(result.succeeded)
        XCTAssertTrue(result.diagnosticMessage.contains("keyboard session engine"))
    }
}
