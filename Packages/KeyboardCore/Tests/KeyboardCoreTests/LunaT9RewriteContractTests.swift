import CryptoKit
import Foundation
import XCTest

@testable import KeyboardCore

final class LunaT9RewriteContractTests: XCTestCase {
    // Resolve the checked-out repository, never an SPM resource or .build copy.
    private var repository: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source() throws -> Data {
        try Data(
            contentsOf: repository.appendingPathComponent(
                "Universe Keyboard/RimeBuiltin/luna_pinyin.schema.yaml"))
    }

    func testFrozenVariantMatchesEveryByte() throws {
        let expected = try Data(
            contentsOf: repository.appendingPathComponent(
                "Packages/RimeBridge/Tests/RimeBridgeTests/Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(try LunaT9SchemaCompatibility.rewrite(source()), expected)
    }

    func testTranslatorKeepsOriginalFieldsAndAddsOneHint() throws {
        let originalData = try source()
        let sourceHash = SHA256.hash(data: originalData).map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(sourceHash, LunaT9SchemaCompatibility.sourceSHA256)
        let original = String(decoding: originalData, as: UTF8.self)
        let rewritten = String(decoding: try LunaT9SchemaCompatibility.rewrite(originalData), as: UTF8.self)
        func translator(_ text: String) throws -> String {
            let start = try XCTUnwrap(text.range(of: "\ntranslator:\n"))
            let tail = text[start.upperBound...]
            let end = try XCTUnwrap(tail.range(of: "\n[a-zA-Z_][a-zA-Z0-9_]*:", options: .regularExpression))
            return String(tail[..<end.lowerBound])
        }
        let section = try translator(rewritten)
        for line in [
            "  dictionary: luna_pinyin\n", "  prism: luna_pinyin_t9\n", "  spelling_hints: 8\n", "  preedit_format:\n",
        ] {
            XCTAssertEqual(section.components(separatedBy: line).count - 1, 1, line)
        }
        let originalSection = try translator(original)
        let restored = section.replacingOccurrences(of: "  prism: luna_pinyin_t9\n", with: "")
            .replacingOccurrences(of: "  spelling_hints: 8\n", with: "")
        XCTAssertEqual(restored, originalSection)
        XCTAssertEqual(
            rewritten.components(separatedBy: "  preedit_format:\n").count,
            original.components(separatedBy: "  preedit_format:\n").count)
    }

    func testMissingAndDuplicateAnchorsFailClosed() throws {
        let original = String(decoding: try source(), as: UTF8.self)
        let anchors = [
            "  schema_id: luna_pinyin\n",
            "  alphabet: zyxwvutsrqponmlkjihgfedcba\n",
            "  algebra:\n    __patch:\n      - pinyin:/abbreviation\n      - pinyin:/spelling_correction\n      - pinyin:/key_correction\n",
            "translator:\n  dictionary: luna_pinyin\n",
        ]
        for anchor in anchors {
            XCTAssertEqual(original.components(separatedBy: anchor).count, 2)
            for replacement in ["", anchor + anchor] {
                let malformed = original.replacingOccurrences(of: anchor, with: replacement)
                XCTAssertThrowsError(try LunaT9SchemaCompatibility.rewrite(Data(malformed.utf8)))
            }
        }
    }

    func testIdentityDriftAndInvalidUTF8FailClosed() throws {
        var changed = try source()
        changed.append(contentsOf: "# unreviewed change\n".utf8)
        XCTAssertThrowsError(try LunaT9SchemaCompatibility.rewrite(changed))
        XCTAssertThrowsError(try LunaT9SchemaCompatibility.rewrite(Data([0xFF])))
    }

    func testDerivedSchemaCannotBeUsedAsSource() throws {
        let derived = try LunaT9SchemaCompatibility.rewrite(source())
        XCTAssertThrowsError(try LunaT9SchemaCompatibility.rewrite(derived))
    }
}
