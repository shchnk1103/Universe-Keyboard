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
