import XCTest

@testable import KeyboardCore

@MainActor
final class TypoCorrectionTests: XCTestCase {
    func testEngineSuggestsNearbyReplacementForTrailingMistouch() {
        let suggestions = TypoCorrectionEngine().suggestions(for: "nihap")

        XCTAssertTrue(suggestions.contains { suggestion in
            suggestion.correctedInput == "nihao"
                && suggestion.edits == [
                    TypoCorrectionEdit(index: 4, original: "p", replacement: "o")
                ]
        })
    }

    func testEngineSkipsSingleCharacterInput() {
        XCTAssertTrue(TypoCorrectionEngine().suggestions(for: "n").isEmpty)
    }

    func testControllerBuildsCorrectionStateWhenRimeHasNoCandidates() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nihap" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(controller.state.currentComposition, "nihap")
        XCTAssertEqual(client.text, "nihap")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates, [])

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "nihap")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "nihao")
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "你好")
    }

    func testControllerDoesNotBuildCorrectionWhenNormalCandidatesExist() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nihao" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(controller.state.currentComposition, "nihao")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.first?.text, "你好")
        XCTAssertNil(controller.state.typoCorrection)
    }

    func testInsertCorrectionCandidateCommitsTextAndClearsComposition() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nihap" {
            _ = controller.handle(.insertKey(String(character)))
        }

        guard let suggestion = controller.state.typoCorrection?.suggestions.first,
            let candidate = suggestion.candidates.first
        else {
            XCTFail("Expected typo correction candidate")
            return
        }

        let commit = TypoCorrectionCommit(
            committedText: candidate.text,
            originalInput: suggestion.originalInput,
            correctedInput: suggestion.correctedInput,
            edits: suggestion.edits
        )

        _ = controller.handle(.insertCorrectionCandidate(commit))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertNil(controller.state.typoCorrection)
        XCTAssertFalse(engine.isComposing())
    }

    func testRankerPromotesNihaoBeforeLongExpansionForTrailingMistouch() {
        let normalItems = [
            CandidateItem(title: "你好安排", kind: .candidate),
            CandidateItem(title: "你好啊", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "你好",
                originalInput: "nihap",
                correctedInput: "nihao",
                edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["你好", "你好安排", "你好啊"])
        XCTAssertEqual(merged.first?.kind, .correctionCandidate)
    }

    func testRankerLeavesNormalNihaoInputUnchangedWithoutCorrectionItems() {
        let normalItems = [
            CandidateItem(title: "你好", kind: .candidate),
            CandidateItem(title: "拟好", kind: .candidate),
            CandidateItem(title: "你号", kind: .candidate),
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: []
        )

        XCTAssertEqual(merged, normalItems)
    }

    func testRankerDoesNotPromoteLowConfidenceMultiEditCorrection() {
        let normalItems = [
            CandidateItem(title: "你好安排", kind: .candidate),
            CandidateItem(title: "你好啊", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "你好",
                originalInput: "nixap",
                correctedInput: "nihao",
                edits: [
                    TypoCorrectionEdit(index: 2, original: "x", replacement: "h"),
                    TypoCorrectionEdit(index: 4, original: "p", replacement: "o"),
                ]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["你好安排", "你好啊", "你好"])
        XCTAssertEqual(merged.first?.kind, .candidate)
    }

    func testBenchmarkDocumentsCurrentCorrectionCoverage() {
        let cases = [
            benchmarkCase(
                input: "nihao",
                category: .validInput,
                expectedOutcome: .notCorrected,
                note: "有效输入已有普通候选，当前应保持 RIME/Provider 原始行为"
            ),
            benchmarkCase(
                input: "nihap",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: true,
                note: "末尾 p 邻键误触 o，当前核心成功样例"
            ),
            benchmarkCase(
                input: "nihal",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: true,
                note: "末尾 l 邻键误触 o"
            ),
            benchmarkCase(
                input: "nihak",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: true,
                note: "末尾 k 邻键误触 o"
            ),
            benchmarkCase(
                input: "nihau",
                category: .finalCharacterMistake,
                expectedOutcome: .notCorrected,
                note: "当前邻键表不包含 u -> o，记录为已知覆盖缺口"
            ),
            benchmarkCase(
                input: "nihaoo",
                category: .repeatedCharacter,
                expectedOutcome: .notCorrected,
                note: "当前不处理重复字符删除"
            ),
            benchmarkCase(
                input: "nihoa",
                category: .transposedCharacter,
                expectedOutcome: .notCorrected,
                note: "当前不处理相邻字符转置"
            ),
            benchmarkCase(
                input: "nihso",
                category: .middleCharacterMistake,
                expectedOutcome: .notCorrected,
                note: "当前只替换最后一个字符，不修正中间 s -> a"
            ),
            benchmarkCase(
                input: "zhongguo",
                category: .validInput,
                expectedOutcome: .notCorrected,
                note: "有效长拼音不应触发纠错"
            ),
            benchmarkCase(
                input: "zhonggup",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "zhongguo",
                expectedCandidate: "中国",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: true,
                note: "末尾 p 邻键误触 o，验证长拼音样例"
            ),
            benchmarkCase(
                input: "woaini",
                category: .validInput,
                expectedOutcome: .notCorrected,
                note: "有效短语拼音不应触发纠错"
            ),
            benchmarkCase(
                input: "woainj",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "woaini",
                expectedCandidate: "我爱你",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: true,
                note: "末尾 j 邻键误触 i"
            ),
            benchmarkCase(
                input: "niho",
                category: .omittedCharacter,
                expectedOutcome: .notCorrected,
                note: "当前不处理漏字补全"
            ),
            benchmarkCase(
                input: "haop",
                category: .ambiguousDangerous,
                expectedOutcome: .notCorrected,
                note: "模糊输入不能解析为已知候选时，不应产生危险纠错"
            ),
            benchmarkCase(
                input: "xianp",
                category: .ambiguousDangerous,
                expectedOutcome: .notCorrected,
                note: "模糊输入不能解析为已知候选时，不应产生危险纠错"
            ),
        ]

        for benchmark in cases {
            let actual = resolvedBenchmarkOutcome(for: benchmark.input)

            XCTAssertEqual(
                actual.correctedInput,
                benchmark.expectedCorrectedInput,
                benchmark.failureMessage("correctedInput")
            )
            XCTAssertEqual(
                actual.candidate,
                benchmark.expectedCandidate,
                benchmark.failureMessage("candidate")
            )
            XCTAssertEqual(
                actual.outcome,
                benchmark.expectedOutcome,
                benchmark.failureMessage("outcome")
            )
        }
    }

    func testBenchmarkDocumentsCurrentPromotionCoverage() {
        let cases = [
            benchmarkCase(
                input: "nihap",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: true,
                note: "短纠错候选应排在更长前缀扩展前"
            ),
            benchmarkCase(
                input: "nihaoo",
                category: .repeatedCharacter,
                expectedOutcome: .notCorrected,
                shouldPromote: false,
                note: "重复字符当前没有纠错候选，因此不能提升"
            ),
            benchmarkCase(
                input: "nihoa",
                category: .transposedCharacter,
                expectedOutcome: .notCorrected,
                shouldPromote: false,
                note: "转置字符当前没有纠错候选，因此不能提升"
            ),
            benchmarkCase(
                input: "nihso",
                category: .middleCharacterMistake,
                expectedOutcome: .notCorrected,
                shouldPromote: false,
                note: "中间字符错误当前没有纠错候选，因此不能提升"
            ),
            benchmarkCase(
                input: "haop",
                category: .ambiguousDangerous,
                expectedOutcome: .notCorrected,
                shouldPromote: false,
                note: "危险/模糊输入不能被提升"
            ),
        ]

        for benchmark in cases {
            let correctionItems = correctionItems(for: benchmark)
            let merged = TypoCorrectionCandidateRanker.mergedCandidates(
                normalItems: [
                    CandidateItem(title: "\(benchmark.expectedCandidate ?? "候选")扩展", kind: .candidate),
                    CandidateItem(title: "\(benchmark.expectedCandidate ?? "候选")备选", kind: .candidate),
                ],
                correctionItems: correctionItems
            )

            let didPromote = merged.first?.kind == .correctionCandidate
            XCTAssertEqual(didPromote, benchmark.shouldPromote, benchmark.failureMessage("shouldPromote"))
        }
    }

    private func correctionItem(
        title: String,
        originalInput: String,
        correctedInput: String,
        edits: [TypoCorrectionEdit]
    ) -> CandidateItem {
        CandidateItem(
            title: title,
            kind: .correctionCandidate,
            correction: TypoCorrectionCommit(
                committedText: title,
                originalInput: originalInput,
                correctedInput: correctedInput,
                edits: edits
            )
        )
    }

    private func benchmarkCase(
        input: String,
        category: TypoCorrectionBenchmarkCategory,
        expectedCorrectedInput: String? = nil,
        expectedCandidate: String? = nil,
        expectedOutcome: TypoCorrectionBenchmarkOutcome,
        shouldPromote: Bool = false,
        note: String
    ) -> TypoCorrectionBenchmarkCase {
        TypoCorrectionBenchmarkCase(
            input: input,
            category: category,
            expectedCorrectedInput: expectedCorrectedInput,
            expectedCandidate: expectedCandidate,
            expectedOutcome: expectedOutcome,
            shouldPromote: shouldPromote,
            note: note
        )
    }

    private func resolvedBenchmarkOutcome(for input: String) -> TypoCorrectionBenchmarkActual {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client

        for character in input {
            _ = controller.handle(.insertKey(String(character)))
        }

        guard let suggestion = controller.state.typoCorrection?.suggestions.first,
            let candidate = suggestion.candidates.first?.text
        else {
            return TypoCorrectionBenchmarkActual(
                correctedInput: nil,
                candidate: nil,
                outcome: .notCorrected
            )
        }

        return TypoCorrectionBenchmarkActual(
            correctedInput: suggestion.correctedInput,
            candidate: candidate,
            outcome: .correctedSuccessfully
        )
    }

    private func correctionItems(for benchmark: TypoCorrectionBenchmarkCase) -> [CandidateItem] {
        guard let correctedInput = benchmark.expectedCorrectedInput,
            let candidate = benchmark.expectedCandidate
        else { return [] }

        guard let edit = singleTrailingEdit(from: benchmark.input, to: correctedInput) else {
            return [
                correctionItem(
                    title: candidate,
                    originalInput: benchmark.input,
                    correctedInput: correctedInput,
                    edits: []
                )
            ]
        }

        return [
            correctionItem(
                title: candidate,
                originalInput: benchmark.input,
                correctedInput: correctedInput,
                edits: [edit]
            )
        ]
    }

    private func singleTrailingEdit(from originalInput: String, to correctedInput: String) -> TypoCorrectionEdit? {
        let originalLetters = Array(originalInput)
        let correctedLetters = Array(correctedInput)
        guard originalLetters.count == correctedLetters.count else { return nil }

        let mismatches = zip(originalLetters.indices, zip(originalLetters, correctedLetters))
            .filter { _, pair in pair.0 != pair.1 }

        guard mismatches.count == 1,
            let mismatch = mismatches.first,
            mismatch.0 == originalLetters.count - 1
        else { return nil }

        return TypoCorrectionEdit(
            index: mismatch.0,
            original: mismatch.1.0,
            replacement: mismatch.1.1
        )
    }
}

private enum TypoCorrectionBenchmarkCategory {
    case validInput
    case adjacentKeySubstitution
    case repeatedCharacter
    case omittedCharacter
    case transposedCharacter
    case middleCharacterMistake
    case finalCharacterMistake
    case ambiguousDangerous
}

private enum TypoCorrectionBenchmarkOutcome: Equatable {
    case correctedSuccessfully
    case notCorrected
    case falsePositive
    case dangerousCorrection
}

private struct TypoCorrectionBenchmarkCase {
    let input: String
    let category: TypoCorrectionBenchmarkCategory
    let expectedCorrectedInput: String?
    let expectedCandidate: String?
    let expectedOutcome: TypoCorrectionBenchmarkOutcome
    let shouldPromote: Bool
    let note: String

    func failureMessage(_ field: String) -> String {
        "\(input) [\(category)] \(field): \(note)"
    }
}

private struct TypoCorrectionBenchmarkActual {
    let correctedInput: String?
    let candidate: String?
    let outcome: TypoCorrectionBenchmarkOutcome
}
