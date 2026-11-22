import XCTest

@testable import KeyboardCore

/// ZH9-RETURN-FIX-001 (PB-005): unify return-key semantics across the 9-key
/// and 26-key layouts — space commits the selected candidate, return commits
/// the currently visible pinyin (never the unresolved digits).
@MainActor
final class T9ReturnCommitTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    override func setUp() {
        super.setUp()
        client.text = ""
    }

    private func seed(_ raw: String?, candidates: [RimeCandidate], highlighted: Int = -1) {
        if let raw {
            controller.state.lastRimeOutput = RimeOutput(
                rawInput: raw,
                composition: RimeComposition(preeditText: raw, cursorPosition: raw.count),
                candidates: candidates,
                highlightedIndex: highlighted
            )
            controller.state.currentComposition = raw
        } else {
            controller.state.lastRimeOutput = nil
            controller.state.currentComposition = ""
        }
    }

    // MARK: - 1. 26 键不回归：回车上屏原始拼音

    func testTwentySixKeyReturnStillCommitsRawPinyin() {
        controller.usesT9InputSemantics = false
        seed("nihao", candidates: [RimeCandidate(text: "你好", comment: "nihao", globalIndex: 0)])

        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "nihao", "26 键回车上屏原始拼音，不回归")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    // MARK: - 2. 九宫格纯数字 + 有候选：回车上屏可见拼音（不再选首选）

    func testT9PureDigitsWithCandidatesCommitVisiblePinyin() {
        controller.usesT9InputSemantics = true
        seed(
            "64",
            candidates: [
                RimeCandidate(text: "你", comment: "ni", globalIndex: 0),
                RimeCandidate(text: "密", comment: "mi", globalIndex: 1),
            ],
            highlighted: 0
        )

        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "ni", "回车上屏可见拼音而非首选候选词")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)
    }

    // MARK: - 3. 九宫格已选部分音节：回车上屏字母投影

    func testT9PartiallyRefinedPathCommitsLetterProjection() {
        controller.usesT9InputSemantics = true
        // mixed raw: refined syllable letters + leftover digits; no comment
        seed("qiu'53", candidates: [], highlighted: -1)

        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "qiu", "上屏显式字母投影，剩余数字不进宿主")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    // MARK: - 4. 九宫格无候选兜底：不吐数字，保持组词

    func testT9UnresolvableDigitsKeepCompositionWithoutDigitDump() {
        controller.usesT9InputSemantics = true
        seed("64426", candidates: [], highlighted: -1)

        _ = controller.handle(.insertReturn)

        XCTAssertTrue(client.text.isEmpty, "纯数字且无字母投影时严禁把数字串吐入宿主")
        XCTAssertEqual(controller.state.currentComposition, "64426", "keepComposition")
    }

    // MARK: - 5. 空输入回车仍换行

    func testEmptyInputReturnInsertsNewline() {
        controller.usesT9InputSemantics = true
        seed(nil, candidates: [])

        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "\n")
    }

    // MARK: - 6. partialCommit 优先 displayText

    func testPartialCommitDisplayTextWinsOverVisiblePinyin() {
        controller.usesT9InputSemantics = true
        seed(
            "64",
            candidates: [RimeCandidate(text: "你", comment: "ni", globalIndex: 0)],
            highlighted: 0
        )
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "你好",
            remainingRawInput: "64",
            remainingPreeditText: "ni",
            displayText: "你好ni"
        )

        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "你好ni", "partialCommit.displayText 优先于字母投影")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
    }
}
