import CryptoKit
import XCTest

@testable import KeyboardCore

final class WanxiangT9SchemaCompatibilityTests: XCTestCase {
    private let rewrittenSourceSHA =
        "ee11ab22c9736247a22881031df8100edeef0c0a8f2672c77c57c32700e16d02"

    func testOneProcessorRemovesThatElementAndKeepsOtherBytes() {
        let yaml = Self.skeleton(processor: "    - t9_processor\n", abbrev: false, abbrevOption: false)
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(yaml) else {
            return XCTFail("expected rewrite")
        }
        XCTAssertFalse(text.contains("t9_processor"))
        XCTAssertEqual(count(of: WanxiangT9SchemaCompatibility.initialAbbrevLineBody, in: text), 1)
        XCTAssertEqual(count(of: WanxiangT9SchemaCompatibility.compoundAbbrevLineBody, in: text), 1)
        XCTAssertFalse(text.contains("- option: abbrev"))
        XCTAssertTrue(text.contains("- ascii_composer"))
        XCTAssertTrue(text.contains("- speller"))
    }

    func testZeroProcessorsDoesNotRequestAWrite() {
        let yaml = Self.skeleton(processor: "", abbrev: true, abbrevOption: false)
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
        let yaml = """
            engine:
               processors:  # keep
                  - ascii_composer # stay
                  - t9_processor # 元书
                  - speller
            speller:
              algebra:
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              rules:
                - option: emoji

            """
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(yaml) else {
            return XCTFail("expected rewrite")
        }
        XCTAssertFalse(text.contains("t9_processor"))
        XCTAssertTrue(text.contains("- ascii_composer # stay"))
        XCTAssertTrue(text.contains("processors:  # keep"))
    }

    func testOnlyOneAbbrevLineFails() {
        let yaml = Self.skeleton(processor: "", abbrev: false, abbrevOption: false)
            .replacingOccurrences(
                of: "    - xlit/",
                with: "    - abbrev/^([A-Z]).+$/$1/\n    - xlit/"
            )
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(yaml), .failed(.abbrevLinesNotReady))
    }

    func testDuplicateAbbrevLineFails() {
        let yaml = Self.skeleton(processor: "", abbrev: true, abbrevOption: false)
            .replacingOccurrences(
                of: "    - xlit/",
                with: "    - abbrev/^([A-Z]).+$/$1/\n    - xlit/"
            )
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(yaml), .failed(.abbrevLinesNotReady))
    }

    func testMissingXlitFails() {
        let yaml = """
            engine:
              processors:
                - speller
            speller:
              algebra:
                - erase/./
            super_replacer:
              rules:
                - option: emoji

            """
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(yaml), .failed(.xlitLineNotUnique))
    }

    func testTwoAbbrevOptionsFail() {
        let yaml =
            Self.skeleton(processor: "", abbrev: true, abbrevOption: true)
                + """
                    - option: abbrev
                      comment: second

                """
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(yaml), .failed(.multipleAbbrevOptions))
    }

    func testFixedSourceMatchesFrozenHash() throws {
        guard let path = ProcessInfo.processInfo.environment["WANXIANG_T9I_SOURCE"] else {
            return XCTFail("WANXIANG_T9I_SOURCE unset")
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let original = String(decoding: data, as: UTF8.self)
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(original) else {
            return XCTFail("expected rewrite of fixed source")
        }
        let digest = SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(digest, rewrittenSourceSHA)
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(text), .alreadyCompatible)
        XCTAssertFalse(text.contains("t9_processor"))
        XCTAssertFalse(text.contains("- option: abbrev"))
    }

    private func count(of needle: String, in text: String) -> Int {
        text.components(separatedBy: "\n").filter { $0.trimmingCharacters(in: .whitespaces) == needle }.count
    }

    private static func skeleton(processor: String, abbrev: Bool, abbrevOption: Bool) -> String {
        let abbrevLines =
            abbrev
            ? """
                - abbrev/^([A-Z]).+$/$1/
                - abbrev/^([ZCS]H).+$/$1/

            """
            : ""
        let option =
            abbrevOption
            ? """
                - option: abbrev
                  comment: drop

            """
            : ""
        return """
            engine:
              processors:
                - ascii_composer
            \(processor)    - speller
            speller:
              algebra:
            \(abbrevLines)    - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              rules:
            \(option)    - option: emoji

            """
    }
}
