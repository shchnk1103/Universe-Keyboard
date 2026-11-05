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
        XCTAssertEqual(text, Self.skeleton(processor: "", abbrev: true, abbrevOption: false))
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
        let expected = """
            engine:
               processors:  # keep
                  - ascii_composer # stay
                  - speller
            speller:
              algebra:
                - abbrev/^([A-Z]).+$/$1/
                - abbrev/^([ZCS]H).+$/$1/
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              rules:
                - option: emoji

            """
        XCTAssertEqual(text, expected)
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
            throw XCTSkip("WANXIANG_T9I_SOURCE unset")
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let inputDigest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(inputDigest, "394e5e091623938c78bbe63146f869546da13db1fa8f945c86c6e3becadc9d0f")
        guard inputDigest == "394e5e091623938c78bbe63146f869546da13db1fa8f945c86c6e3becadc9d0f" else { return }
        let original = String(decoding: data, as: UTF8.self)
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(original) else {
            return XCTFail("expected rewrite of fixed source")
        }
        let digest = SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(digest, rewrittenSourceSHA)
        var expectedLines = original.components(separatedBy: "\n")
        let processor = try XCTUnwrap(expectedLines.firstIndex { $0.contains("- t9_processor") })
        expectedLines.remove(at: processor)
        let option = try XCTUnwrap(
            expectedLines.firstIndex { $0.trimmingCharacters(in: .whitespaces) == "- option: abbrev" })
        let end =
            (option + 1..<expectedLines.count).first { index in
                let line = expectedLines[index]
                return !line.isEmpty && !line.hasPrefix(" ") && !line.hasPrefix("#")
                    || line.hasPrefix("    - ")
            } ?? expectedLines.count
        expectedLines.removeSubrange(option..<end)
        if original.hasSuffix("\n"), expectedLines.last != "" { expectedLines.append("") }
        let xlit = try XCTUnwrap(
            expectedLines.firstIndex {
                $0.trimmingCharacters(in: .whitespaces) == WanxiangT9SchemaCompatibility.xlitLineBody
            })
        expectedLines.insert(
            contentsOf: [
                "    " + WanxiangT9SchemaCompatibility.initialAbbrevLineBody,
                "    " + WanxiangT9SchemaCompatibility.compoundAbbrevLineBody,
            ], at: xlit)
        XCTAssertEqual(text.components(separatedBy: "\n"), expectedLines)
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(text), .alreadyCompatible)
        XCTAssertFalse(text.contains("t9_processor"))
        XCTAssertFalse(text.contains("- option: abbrev"))
    }

    func testEachSingleMissingEdit() {
        let ready = Self.skeleton(processor: "", abbrev: true, abbrevOption: false)
        let inputs = [
            Self.skeleton(processor: "    - t9_processor\n", abbrev: true, abbrevOption: false),
            Self.skeleton(processor: "", abbrev: false, abbrevOption: false),
            Self.skeleton(processor: "", abbrev: true, abbrevOption: true),
        ]
        for input in inputs { XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(input), .rewritten(ready)) }
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(ready), .alreadyCompatible)
    }

    func testOptionBoundaryAndTrivia() {
        let base = Self.skeleton(processor: "", abbrev: true, abbrevOption: false)
        let item = "    - option: abbrev\n      mode: abbrev\n      # internal\n      tags: [abc]\n    # next\n"
        let input = base.replacingOccurrences(of: "    - option: emoji", with: item + "    - option: emoji")
        let expected = base.replacingOccurrences(of: "    - option: emoji", with: "    # next\n    - option: emoji")
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(input), .rewritten(expected))
        let other = base.replacingOccurrences(of: "option: emoji", with: "option: abbreviation")
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(other), .alreadyCompatible)
        let commented = base.replacingOccurrences(
            of: "    - option: emoji", with: "    - option: abbrev # comment\n    - option: emoji")
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(commented), .rewritten(base))
        let mixed = base.replacingOccurrences(
            of: "    - option: emoji", with: "    - option: abbrev\n    # keep\n      # delete\n    - option: emoji")
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(mixed), .failed(.unlocatableSuperReplacerRules))
    }

    func testLineEndingsAndWhitespace() {
        let base = Self.skeleton(processor: "", abbrev: true, abbrevOption: false)
        let trailing = base.replacingOccurrences(of: "- abbrev/^([A-Z]).+$/$1/", with: "- abbrev/^([A-Z]).+$/$1/  ")
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(trailing), .alreadyCompatible)
        XCTAssertEqual(
            WanxiangT9SchemaCompatibility.rewrite(base.replacingOccurrences(of: "\n", with: "\r\n")),
            .failed(.unsupportedLineEndings))
    }

    func testNestedKeysAndInvalidAlgebra() {
        let base = Self.skeleton(processor: "", abbrev: true, abbrevOption: false)
        let nested = base.replacingOccurrences(
            of: "  rules:", with: "  wrapper:\n    rules:\n      - option: nested\n  rules:")
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(nested), .alreadyCompatible)
        let xlit = "    " + WanxiangT9SchemaCompatibility.xlitLineBody
        XCTAssertEqual(
            WanxiangT9SchemaCompatibility.rewrite(base.replacingOccurrences(of: xlit, with: xlit + "\n" + xlit)),
            .failed(.xlitLineNotUnique))
        let reversed = base.replacingOccurrences(
            of: "    " + WanxiangT9SchemaCompatibility.initialAbbrevLineBody + "\n    "
                + WanxiangT9SchemaCompatibility.compoundAbbrevLineBody,
            with: "    " + WanxiangT9SchemaCompatibility.compoundAbbrevLineBody + "\n    "
                + WanxiangT9SchemaCompatibility.initialAbbrevLineBody)
        XCTAssertEqual(WanxiangT9SchemaCompatibility.rewrite(reversed), .failed(.abbrevLinesNotReady))
        XCTAssertEqual(
            WanxiangT9SchemaCompatibility.rewrite(base.replacingOccurrences(of: "  rules:", with: "  missing:")),
            .failed(.unlocatableSuperReplacerRules))
        XCTAssertEqual(
            WanxiangT9SchemaCompatibility.rewrite(
                base.replacingOccurrences(of: "  rules:", with: "  rules:\n    - option: emoji\n  rules:")),
            .failed(.unlocatableSuperReplacerRules))
    }

    func testNestedRulesBaitLeavesRealAbbrevOptionAsTheOnlyEdit() {
        let input = """
            engine:
              processors:
                - ascii_composer
                - speller
            speller:
              algebra:
                - abbrev/^([A-Z]).+$/$1/
                - abbrev/^([ZCS]H).+$/$1/
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              wrapper:
                rules:
                  - option: abbrev
              rules:
                - option: abbrev
                  comment: drop
                - option: emoji

            """
        let expected = """
            engine:
              processors:
                - ascii_composer
                - speller
            speller:
              algebra:
                - abbrev/^([A-Z]).+$/$1/
                - abbrev/^([ZCS]H).+$/$1/
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              wrapper:
                rules:
                  - option: abbrev
              rules:
                - option: emoji

            """
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(input) else {
            return XCTFail("expected rewrite")
        }
        XCTAssertEqual(text, expected)
    }

    func testMissingAbbrevKeepsXlitTrailingSpacesWhileRemovingProcessor() {
        let twoSpaces = "  "
        let input = """
            engine:
              processors:
                - ascii_composer
                - t9_processor
                - speller
            speller:
              algebra:
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/\(twoSpaces)
            super_replacer:
              rules:
                - option: emoji

            """
        let expected = """
            engine:
              processors:
                - ascii_composer
                - speller
            speller:
              algebra:
                - abbrev/^([A-Z]).+$/$1/
                - abbrev/^([ZCS]H).+$/$1/
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/\(twoSpaces)
            super_replacer:
              rules:
                - option: emoji

            """
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(input) else {
            return XCTFail("expected rewrite")
        }
        XCTAssertEqual(text, expected)
    }

    func testAbbrevTrailingSpacesStayWhileRealOptionItemIsRemoved() {
        let twoSpaces = "  "
        let input = """
            engine:
              processors:
                - ascii_composer
                - speller
            speller:
              algebra:
                - abbrev/^([A-Z]).+$/$1/\(twoSpaces)
                - abbrev/^([ZCS]H).+$/$1/\(twoSpaces)
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              rules:
                - option: abbrev
                  comment: drop
                - option: emoji

            """
        let expected = """
            engine:
              processors:
                - ascii_composer
                - speller
            speller:
              algebra:
                - abbrev/^([A-Z]).+$/$1/\(twoSpaces)
                - abbrev/^([ZCS]H).+$/$1/\(twoSpaces)
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              rules:
                - option: emoji

            """
        guard case .rewritten(let text) = WanxiangT9SchemaCompatibility.rewrite(input) else {
            return XCTFail("expected rewrite")
        }
        XCTAssertEqual(text, expected)
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
