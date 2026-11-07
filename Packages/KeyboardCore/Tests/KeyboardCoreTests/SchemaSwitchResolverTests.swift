import CryptoKit
import XCTest

@testable import KeyboardCore

final class SchemaSwitchResolverTests: XCTestCase {
    func testAdversarialExamplesHaveTheFixedFailures() {
        XCTAssertEqual(failure(""), .missingSwitches)
        XCTAssertEqual(failure("schema:\n  schema_id: demo\n"), .missingSwitches)
        XCTAssertEqual(failure("switches:\n  - name: a\nswitches:\n  - name: b\n"), .duplicateTopKey)
        XCTAssertEqual(failure("switches:\n  - name: a\n    name: b\n"), .duplicateField)
        XCTAssertEqual(failure("switches:\n  - ascii_mode\n"), .nonMappingItem)
        XCTAssertEqual(failure("switches:\n  - { name: emoji }\n"), .unsupportedSyntax)
        XCTAssertEqual(failure("switches:\n  - name: \"unterminated\n"), .ambiguousScalar)
        XCTAssertEqual(failure("switches:\n  - name: \"\\x41\"\n"), .ambiguousScalar)
        XCTAssertEqual(failure("switches:\n  - options: [a, b\n"), .unsupportedSyntax)
        XCTAssertEqual(failure("switches:\n  - name: a\n    states:\n    - wrong\n"), .unsupportedSyntax)

        let commented = try? SchemaSwitchResolver.recognize("switches:\n  - name: emoji\n    reset: 1 # ok\n").get()
        XCTAssertEqual(commented?.first?.reset, 1)

        let quoted = try? SchemaSwitchResolver.recognize("switches:\n  - name: emoji\n    reset: \"1\"\n").get()
        XCTAssertEqual(quoted?.first?.reset, 1)
        XCTAssertEqual(failure("switches:\n  - name: emoji\n    reset: one\n"), .unsupportedSyntax)

        let both = """
            switches:
              - name: traditionalization
                states: [简, 繁]
              - options: [zh_hant, zh_hans]
                states: [繁, 简]
            """
        let parsed = try? SchemaSwitchResolver.recognize(both).get()
        XCTAssertEqual(SchemaSwitchResolver.simplification(in: parsed ?? []).failure, .notUniqueCandidate)
        let unproven = try? SchemaSwitchResolver.recognize(
            "switches:\n  - name: traditionalization\n    states: [漢字, 汉字]\n"
        ).get()
        XCTAssertEqual(SchemaSwitchResolver.simplification(in: unproven ?? []).failure, .directionUnproven)
        XCTAssertEqual(failure("switches:\n  - name: a\n__include: other.yaml:/switches\n"), .switchesPatched)

        let duplicateEmoji = try? SchemaSwitchResolver.recognize(
            "switches:\n  - name: emoji\n    states: [表情关, 表情开]\n  - name: emoji\n    states: [表情关, 表情开]\n"
        ).get()
        XCTAssertEqual(
            SchemaSwitchResolver.emojiReset(in: duplicateEmoji ?? [], wanxiangFamily: true).failure,
            .emojiDirectionUnproven
        )
        XCTAssertEqual(
            SchemaSwitchResolver.simplification(in: duplicateEmoji ?? []).failure,
            .notUniqueCandidate
        )
        let inexact = try? SchemaSwitchResolver.recognize(
            "switches:\n  - name: emoji\n    states: [关, 开]\n"
        ).get()
        XCTAssertEqual(
            SchemaSwitchResolver.emojiReset(in: inexact ?? [], wanxiangFamily: true).failure,
            .emojiDirectionUnproven
        )
    }

    func testFixedSourcesMatchTheSpecTable() throws {
        let ice = try fixedSource("SWITCH_RESOLVER_RIME_ICE", expectedSHA256: iceSHA)
        let iceItems = try SchemaSwitchResolver.recognize(ice).get()
        XCTAssertEqual(
            iceItems.map(\.name),
            [
                "ascii_mode", "ascii_punct", "traditionalization", "emoji", "full_shape", "search_single_char",
            ])
        let iceSimplification = try SchemaSwitchResolver.simplification(in: iceItems).get()
        XCTAssertEqual(iceSimplification.index, 2)
        XCTAssertEqual(iceSimplification.simplifiedReset, 0)
        XCTAssertEqual(iceSimplification.traditionalReset, 1)
        XCTAssertNil(try SchemaSwitchResolver.emojiReset(in: iceItems, wanxiangFamily: false).get())

        let wanxiang = try fixedSource("SWITCH_RESOLVER_WANXIANG", expectedSHA256: wanxiangSHA)
        let wanxiangItems = try SchemaSwitchResolver.recognize(wanxiang).get()
        let wanxiangSimplification = try SchemaSwitchResolver.simplification(in: wanxiangItems).get()
        XCTAssertEqual(wanxiangSimplification.index, 7)
        XCTAssertEqual(wanxiangSimplification.simplifiedReset, 0)
        XCTAssertEqual(wanxiangSimplification.traditionalReset, 1)
        XCTAssertNil(try SchemaSwitchResolver.emojiReset(in: wanxiangItems, wanxiangFamily: false).get())
        let emoji = try SchemaSwitchResolver.emojiReset(in: wanxiangItems, wanxiangFamily: true).get()
        XCTAssertEqual(emoji?.index, 3)
        XCTAssertEqual(emoji?.reset, 1)

        let t9 = try fixedSource("SWITCH_RESOLVER_T9", expectedSHA256: t9SHA)
        XCTAssertEqual(SchemaSwitchResolver.recognize(t9).failure, .switchesPatched)

        let luna = try fixedSource("SWITCH_RESOLVER_LUNA", expectedSHA256: lunaSHA)
        XCTAssertEqual(SchemaSwitchResolver.recognize(luna).failure, .switchesPatched)
        let exempted = try SchemaSwitchResolver.recognizeLuna(
            source: luna,
            sourceSHA256: lunaSHA,
            grammarYamlPresent: false
        ).get()
        let lunaSimplification = try SchemaSwitchResolver.simplification(in: exempted).get()
        XCTAssertEqual(lunaSimplification.index, 2)
        XCTAssertEqual(lunaSimplification.simplifiedReset, 1)
        XCTAssertEqual(lunaSimplification.traditionalReset, 0)
    }

    func testLunaExemptionRejectsHashPatchAndGrammarChanges() throws {
        let luna = try fixedSource("SWITCH_RESOLVER_LUNA", expectedSHA256: lunaSHA)
        XCTAssertEqual(
            SchemaSwitchResolver.recognizeLuna(source: luna, sourceSHA256: "not-the-file", grammarYamlPresent: false)
                .failure,
            .switchesPatched
        )
        XCTAssertEqual(
            SchemaSwitchResolver.recognizeLuna(source: luna, sourceSHA256: lunaSHA, grammarYamlPresent: true).failure,
            .switchesPatched
        )
        let extra = luna.replacingOccurrences(
            of: "- luna_pinyin.custom:/patch?",
            with: "- luna_pinyin.custom:/patch?\n  - extra:/patch?"
        )
        XCTAssertEqual(
            SchemaSwitchResolver.recognizeLuna(source: extra, sourceSHA256: lunaSHA, grammarYamlPresent: false).failure,
            .switchesPatched
        )
    }

    private func fixedSource(_ name: String, expectedSHA256: String) throws -> String {
        guard let path = ProcessInfo.processInfo.environment[name] else {
            throw XCTSkip("\(name) is unset")
        }
        let text = try String(contentsOfFile: path, encoding: .utf8)
        XCTAssertEqual(sha256(text), expectedSHA256)
        return text
    }

    private func sha256(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private func failure(_ source: String) -> SchemaSwitchResolver.Failure? {
        SchemaSwitchResolver.recognize(source).failure
    }

    private let iceSHA = "ec4b0dd02ac287f53fe401f315cde648913eb60bb8cf8d9a8a613d1eb4f9698b"
    private let wanxiangSHA = "e52cc55fb71157c72098c44e5cd79deb58f5538dcd76c7f1b27648ae91a204b7"
    private let t9SHA = "56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6"
    private let lunaSHA = SchemaSwitchResolver.builtinLunaSHA256

    func testPinnedPatchParsesWithoutTheLunaHashExemption() {
        let source = """
            switches:
              - options: [zh_hant, zh_hans]
                states: [繁, 简]
            __patch:
              - grammar:/hant?
              - luna_pinyin.custom:/patch?
              - luna_pinyin_t9.custom:/patch?

            """
        let twoItem = source.replacingOccurrences(
            of: "\n  - luna_pinyin_t9.custom:/patch?",
            with: ""
        )
        XCTAssertEqual(SchemaSwitchResolver.recognize(source).failure, .switchesPatched)
        XCTAssertEqual(SchemaSwitchResolver.recognizePinnedPatch(twoItem).failure, .switchesPatched)
        let items = try? SchemaSwitchResolver.recognizePinnedPatch(source).get()
        XCTAssertEqual(items?.count, 1)
        guard case .success(let selection)? = items.map({ SchemaSwitchResolver.simplification(in: $0) }) else {
            return XCTFail("pinned patch should resolve simplification")
        }
        XCTAssertEqual(selection.key, "switches/@0/reset")
    }
}

extension Result where Failure == SchemaSwitchResolver.Failure {
    fileprivate var failure: SchemaSwitchResolver.Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let failure):
            return failure
        }
    }
}
