import XCTest

@testable import KeyboardCore

final class WanxiangT9SchemaCompatibilityTests: XCTestCase {
    func testOneProcessorRemovesThatElementAndKeepsOtherBytes() {
        let yaml = """
            engine:
              processors:
                - ascii_composer
                - t9_processor
                - speller

            """
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(yaml) else {
            return XCTFail("expected rewrite")
        }
        XCTAssertEqual(
            text,
            """
            engine:
              processors:
                - ascii_composer
                - speller

            """
        )
        XCTAssertFalse(text.contains("t9_processor"))
    }

    func testZeroProcessorsDoesNotRequestAWrite() {
        let yaml = "engine:\n  processors:\n    - speller\n"
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(yaml), .alreadyCompatible)
    }

    func testTwoProcessorsFailWithoutADocument() {
        let yaml = "engine:\n  processors:\n    - t9_processor\n    - t9_processor\n"
        XCTAssertEqual(
            WanxiangT9SchemaCompatibility.rewrite(yaml),
            .failed(.multipleT9Processors)
        )
    }

    func testMissingEngineProcessorsFails() {
        XCTAssertEqual(
            WanxiangT9SchemaCompatibility.rewrite("engine:\n  segmentors:\n    - abc\n"),
            .failed(.missingEngineProcessors)
        )
    }

    func testInlineCommentAndIndentChangeStillRemoveOnlyTheElement() {
        let yaml =
            "engine:\n   processors:  # keep\n      - ascii_composer # stay\n      - t9_processor # 元书\n      - speller\n"
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(yaml) else {
            return XCTFail("expected rewrite")
        }
        XCTAssertEqual(
            text,
            "engine:\n   processors:  # keep\n      - ascii_composer # stay\n      - speller\n"
        )
    }

    func testFixedSourceDropsOnlyLine53() throws {
        guard let path = ProcessInfo.processInfo.environment["WANXIANG_T9I_SOURCE"] else {
            throw XCTSkip("WANXIANG_T9I_SOURCE unset")
        }
        let original = try String(contentsOfFile: path, encoding: .utf8)
        let originalLines = original.components(separatedBy: "\n")
        XCTAssertGreaterThanOrEqual(originalLines.count, 53)
        let removed = originalLines[52]
        XCTAssertTrue(removed.contains("t9_processor"))
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(original) else {
            return XCTFail("expected rewrite of fixed source")
        }
        var expected = originalLines
        expected.remove(at: 52)
        XCTAssertEqual(text.components(separatedBy: "\n"), expected)
        let started = Date()
        _ = WanxiangT9SchemaCompatibility.rewrite(original)
        let elapsedMS = Date().timeIntervalSince(started) * 1000
        print("WANXIANG_T9_REWRITE_ELAPSED_MS=\(elapsedMS)")
    }
}
