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

    func testEngineSuggestsNearbyReplacementForInitialMistouch() {
        let suggestions = TypoCorrectionEngine().suggestions(for: "bihao")

        XCTAssertTrue(suggestions.contains { suggestion in
            suggestion.correctedInput == "nihao"
                && suggestion.edits == [
                    TypoCorrectionEdit(index: 0, original: "b", replacement: "n")
                ]
        })
    }

    func testEngineSuggestsNearbyReplacementForMiddleMistouch() {
        let suggestions = TypoCorrectionEngine().suggestions(for: "nigao")

        XCTAssertTrue(suggestions.contains { suggestion in
            suggestion.correctedInput == "nihao"
                && suggestion.edits == [
                    TypoCorrectionEdit(index: 2, original: "g", replacement: "h")
                ]
        })
    }

    func testEnginePrioritizesLongMiddleMistouchWithinLookupWindow() {
        let suggestions = TypoCorrectionEngine().suggestions(for: "zhonghuo")

        XCTAssertLessThanOrEqual(suggestions.count, 16)
        XCTAssertTrue(suggestions.contains { suggestion in
            suggestion.correctedInput == "zhongguo"
                && suggestion.edits == [
                    TypoCorrectionEdit(index: 5, original: "h", replacement: "g")
                ]
        })
    }

    func testEngineSkipsUnsafeMiddleVowelConsonantReplacement() {
        let suggestions = TypoCorrectionEngine().suggestions(for: "nihso")

        XCTAssertFalse(
            suggestions.contains { $0.correctedInput == "nihao" },
            "非末尾位置暂不做辅音/元音跨类替换，避免扩大中间字符误纠错噪声"
        )
    }

    func testEngineLimitsGeneratedSuggestionCount() {
        let suggestions = TypoCorrectionEngine().suggestions(for: "zhongguopinyin")

        XCTAssertLessThanOrEqual(suggestions.count, 16)
    }

    func testAssessmentMarksTrailingSubstitutionAsPromotionEligibleHighConfidence() {
        let assessment = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "nihap",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")],
            firstNormalCandidate: "你好安排"
        )

        XCTAssertEqual(assessment.confidence, .high)
        XCTAssertEqual(assessment.score, 90)
        XCTAssertTrue(assessment.isDisplayEligible)
        XCTAssertTrue(assessment.isPromotionEligible)
        XCTAssertNil(assessment.rejectReason)
    }

    func testAssessmentMarksInitialSubstitutionAsDisplayOnlyHighConfidence() {
        let assessment = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "bihao",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 0, original: "b", replacement: "n")],
            firstNormalCandidate: "笔画"
        )

        XCTAssertEqual(assessment.confidence, .high)
        XCTAssertEqual(assessment.score, 75)
        XCTAssertTrue(assessment.isDisplayEligible)
        XCTAssertFalse(assessment.isPromotionEligible)
        XCTAssertNil(assessment.rejectReason)
    }

    func testAssessmentMarksRepeatedFinalDeletionAsMediumDisplayOnly() {
        let assessment = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "nihaoo",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 5, original: "o", replacement: "o", kind: .deletion)],
            firstNormalCandidate: "你好哦"
        )

        XCTAssertEqual(assessment.confidence, .medium)
        XCTAssertEqual(assessment.score, 55)
        XCTAssertTrue(assessment.isDisplayEligible)
        XCTAssertFalse(assessment.isPromotionEligible)
        XCTAssertNil(assessment.rejectReason)
    }

    func testAssessmentRejectsUnsafeMiddleReplacement() {
        let assessment = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "nihso",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 3, original: "s", replacement: "a")],
            firstNormalCandidate: nil
        )

        XCTAssertEqual(assessment.confidence, .rejected)
        XCTAssertFalse(assessment.isDisplayEligible)
        XCTAssertEqual(assessment.rejectReason, .unsafeReplacement)
    }

    func testAssessmentRejectsShortInputLongCandidateAndNormalCandidateConflict() {
        let shortInput = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "haop",
            correctedInput: "haoo",
            edits: [TypoCorrectionEdit(index: 3, original: "p", replacement: "o")],
            firstNormalCandidate: nil
        )
        XCTAssertEqual(shortInput.rejectReason, .inputTooShort)

        let longCandidate = TypoCorrectionAssessment.evaluate(
            title: "你好啊朋友",
            originalInput: "nihap",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")],
            firstNormalCandidate: nil
        )
        XCTAssertEqual(longCandidate.rejectReason, .candidateTextTooLong)

        let normalCandidateConflict = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "womem",
            correctedInput: "women",
            edits: [TypoCorrectionEdit(index: 4, original: "m", replacement: "n")],
            firstNormalCandidate: "你好"
        )
        XCTAssertEqual(normalCandidateConflict.rejectReason, .normalCandidateAlreadyMatches)
    }

    func testAssessmentCanRepresentMissingCorrectedCandidates() {
        let assessment = TypoCorrectionAssessment.rejected(.noCorrectedCandidates)

        XCTAssertEqual(assessment.confidence, .rejected)
        XCTAssertFalse(assessment.isDisplayEligible)
        XCTAssertFalse(assessment.isPromotionEligible)
        XCTAssertEqual(assessment.rejectReason, .noCorrectedCandidates)
    }

    func testEngineSuggestsRepeatedFinalCharacterDeletion() {
        let suggestions = TypoCorrectionEngine().suggestions(for: "nihaoo")

        XCTAssertTrue(suggestions.contains { suggestion in
            suggestion.correctedInput == "nihao"
                && suggestion.edits == [
                    TypoCorrectionEdit(index: 5, original: "o", replacement: "o", kind: .deletion)
                ]
        })
    }

    func testExperimentalSettingsDefaultToStableEdits() {
        let settings = TypoCorrectionExperimentalSettings()

        XCTAssertFalse(settings.insertionEnabled)
        XCTAssertFalse(settings.transpositionEnabled)
        XCTAssertTrue(settings.experimentalEdits.isEmpty)
    }

    func testExperimentalSettingsMapEnabledFlagsToEdits() {
        let settings = TypoCorrectionExperimentalSettings(
            insertionEnabled: true,
            transpositionEnabled: true
        )

        XCTAssertTrue(settings.experimentalEdits.contains(.insertion))
        XCTAssertTrue(settings.experimentalEdits.contains(.transposition))
    }

    func testEngineSkipsSingleCharacterInput() {
        XCTAssertTrue(TypoCorrectionEngine().suggestions(for: "n").isEmpty)
    }

    func testControllerBuildsCorrectionStateForRepeatedFinalCharacter() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client

        for character in "nihaoo" {
            _ = controller.handle(.insertKey(String(character)))
        }

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "nihaoo")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "nihao")
        XCTAssertEqual(correction?.suggestions.first?.edits.first?.kind, .deletion)
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "你好")
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

    func testControllerBuildsHighConfidenceCorrectionWhenRimeHasLongExpansionCandidates() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: ["nihap": ["你好安排", "你好"]])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nihap" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(controller.state.currentComposition, "nihap")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你好安排", "你好"])

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "nihap")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "nihao")
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "你好")
        XCTAssertEqual(correction?.suggestions.first?.edits, [
            TypoCorrectionEdit(index: 4, original: "p", replacement: "o")
        ])
    }

    func testControllerBuildsHighConfidenceCorrectionFromSegmentedRimePreedit() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(
            dictionary: ["nihap": ["你好安排", "你好"]],
            preeditFormatter: { input in
                input == "nihap" ? "ni h a p" : input
            }
        )
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nihap" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(controller.state.currentComposition, "ni h a p")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你好安排", "你好"])

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "nihap")
        XCTAssertEqual(correction?.suggestions.first?.originalInput, "nihap")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "nihao")
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "你好")
        XCTAssertEqual(correction?.suggestions.first?.edits, [
            TypoCorrectionEdit(index: 4, original: "p", replacement: "o")
        ])
    }

    func testControllerBuildsCorrectionStateForInitialMistouch() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "bihao" {
            _ = controller.handle(.insertKey(String(character)))
        }

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "bihao")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "nihao")
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "你好")
        XCTAssertEqual(correction?.suggestions.first?.edits, [
            TypoCorrectionEdit(index: 0, original: "b", replacement: "n")
        ])
    }

    func testControllerBuildsCorrectionStateForMiddleMistouch() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nigao" {
            _ = controller.handle(.insertKey(String(character)))
        }

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "nigao")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "nihao")
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "你好")
        XCTAssertEqual(correction?.suggestions.first?.edits, [
            TypoCorrectionEdit(index: 2, original: "g", replacement: "h")
        ])
    }

    func testControllerBuildsCorrectionStateForLongMiddleMistouch() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "zhonghuo" {
            _ = controller.handle(.insertKey(String(character)))
        }

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "zhonghuo")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "zhongguo")
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "中国")
        XCTAssertEqual(correction?.suggestions.first?.edits, [
            TypoCorrectionEdit(index: 5, original: "h", replacement: "g")
        ])
    }

    func testControllerDoesNotBuildCorrectionForValidNihaoInput() {
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

    func testControllerKeepsExperimentalInsertionDisabledByDefault() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: [
            "niho": ["你或"],
            "nihao": ["你好"],
        ])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "niho" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertNil(controller.state.typoCorrection)
    }

    func testControllerCanEnableExperimentalInsertionForLocalValidation() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: [
            "niho": ["你或"],
            "nihao": ["你好"],
        ])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.typoCorrectionExperimentalEdits = [.insertion]

        for character in "niho" {
            _ = controller.handle(.insertKey(String(character)))
        }

        let correction = controller.state.typoCorrection
        XCTAssertEqual(correction?.originalInput, "niho")
        XCTAssertEqual(correction?.suggestions.first?.correctedInput, "nihao")
        XCTAssertEqual(correction?.suggestions.first?.candidates.first?.text, "你好")
        XCTAssertEqual(correction?.suggestions.first?.edits.first?.kind, .insertion)
    }

    func testNormalUnrelatedPinyinKeepsRimeCandidates() {
        let cases: [(input: String, candidates: [String])] = [
            ("women", ["我们", "我门", "沃门"]),
            ("jintian", ["今天", "金天", "尽天"]),
            ("xiexie", ["谢谢", "写写", "歇歇"]),
            ("shijian", ["时间", "事件", "实践"]),
            ("zhongwen", ["中文", "中文输入", "中闻"]),
            ("ceshi", ["测试", "侧室", "测时"]),
        ]

        for testCase in cases {
            let client = FakeTextInputClient()
            let engine = FakeRimeEngine(dictionary: [testCase.input: testCase.candidates])
            let controller = KeyboardController()
            controller.textClient = client
            controller.rimeEngine = engine

            for character in testCase.input {
                _ = controller.handle(.insertKey(String(character)))
            }

            XCTAssertEqual(controller.state.currentComposition, testCase.input)
            XCTAssertEqual(
                controller.state.lastRimeOutput?.candidates.map(\.text),
                testCase.candidates,
                "\(testCase.input) should preserve normal RIME candidates"
            )
        }
    }

    func testCorrectionLogicDoesNotSuppressNormalCandidatesWithoutHighConfidenceCorrection() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: [
            "women": ["我们", "我门"],
            "jintian": ["今天", "金天"],
        ])
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "women" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["我们", "我门"])
        XCTAssertNil(controller.state.typoCorrection)

        _ = controller.handle(.insertCandidate("我们", kind: .candidate))

        XCTAssertEqual(client.text, "我们")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.lastRimeOutput?.committedText, "我们")
        XCTAssertNil(controller.state.typoCorrection)

        for character in "jintian" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["今天", "金天"])
        XCTAssertNil(controller.state.typoCorrection)
    }

    func testCorrectionStateIsNotKeptWhenNormalRimeCandidateAlreadyMatchesCorrection() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: ["womem": ["我们", "我们吗"]])
        let provider = DictionaryCandidateProvider(dictionary: ["women": ["我们"]])
        let controller = KeyboardController(candidateProvider: provider)
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "womem" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["我们", "我们吗"])
        XCTAssertNil(
            controller.state.typoCorrection,
            "正常 RIME 已经给出同名首候选时，不应保留纠错状态替换普通候选行为"
        )
    }

    func testRankerPreservesNormalCandidateOrderForUnrelatedInput() {
        let normalItems = [
            CandidateItem(title: "我们", kind: .candidate),
            CandidateItem(title: "我门", kind: .candidate),
            CandidateItem(title: "沃门", kind: .candidate),
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: []
        )

        XCTAssertEqual(merged, normalItems)
    }

    func testValidNormalInputIsNotReplacedByCorrectionSuggestion() {
        let normalItems = [
            CandidateItem(title: "今天", kind: .candidate),
            CandidateItem(title: "金天", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "金田",
                originalInput: "jintian",
                correctedInput: "jintiao",
                edits: [TypoCorrectionEdit(index: 6, original: "n", replacement: "o")]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["今天", "金天", "金田"])
        XCTAssertEqual(merged.first?.kind, .candidate)
    }

    func testNormalNihaoCandidateSelectionBehaviorRemainsUnchanged() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nihao" {
            _ = controller.handle(.insertKey(String(character)))
        }

        _ = controller.handle(.insertCandidate("你好", kind: .candidate))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.lastRimeOutput?.committedText, "你好")
        XCTAssertNil(controller.state.typoCorrection)
        XCTAssertFalse(engine.isComposing())
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

    func testInsertCorrectionCandidateFromLongExpansionRimeStateCommitsTextAndClearsComposition() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: ["nihap": ["你好安排", "你好"]])
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
        XCTAssertEqual(engine.sessionResetCount, 1)
    }

    func testInsertCorrectionCandidateFromSegmentedRimePreeditCommitsAndClearsComposition() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(
            dictionary: ["nihap": ["你好安排", "你好"]],
            preeditFormatter: { input in
                input == "nihap" ? "ni hap" : input
            }
        )
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine

        for character in "nihap" {
            _ = controller.handle(.insertKey(String(character)))
        }

        guard let suggestion = controller.state.typoCorrection?.suggestions.first,
            let candidate = suggestion.candidates.first
        else {
            XCTFail("Expected typo correction candidate for segmented RIME preedit")
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
        XCTAssertEqual(engine.sessionResetCount, 1)
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

    func testRankerPromotesCorrectionBeforeLongExpansionAndDropsDuplicateNormalCandidate() {
        let normalItems = [
            CandidateItem(title: "你好安排", kind: .candidate),
            CandidateItem(title: "你好啊", kind: .candidate),
            CandidateItem(title: "你好", kind: .candidate),
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

    func testRankerPlacesInitialMistouchCorrectionNearFrontWithoutReplacingTopCandidate() {
        let normalItems = [
            CandidateItem(title: "笔画", kind: .candidate),
            CandidateItem(title: "比好", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "你好",
                originalInput: "bihao",
                correctedInput: "nihao",
                edits: [TypoCorrectionEdit(index: 0, original: "b", replacement: "n")]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["笔画", "你好", "比好"])
        XCTAssertEqual(merged[0].kind, .candidate)
        XCTAssertEqual(merged[1].kind, .correctionCandidate)
    }

    func testRankerPlacesMiddleMistouchCorrectionNearFrontAndDropsDuplicateNormalCandidate() {
        let normalItems = [
            CandidateItem(title: "你高", kind: .candidate),
            CandidateItem(title: "你好", kind: .candidate),
            CandidateItem(title: "拟稿", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "你好",
                originalInput: "nigao",
                correctedInput: "nihao",
                edits: [TypoCorrectionEdit(index: 2, original: "g", replacement: "h")]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["你高", "你好", "拟稿"])
        XCTAssertEqual(merged[0].kind, .candidate)
        XCTAssertEqual(merged[1].kind, .correctionCandidate)
    }

    func testRankerPlacesLongMiddleMistouchNearFrontWithoutReplacingTopCandidate() {
        let normalItems = [
            CandidateItem(title: "中火", kind: .candidate),
            CandidateItem(title: "中华", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "中国",
                originalInput: "zhonghuo",
                correctedInput: "zhongguo",
                edits: [TypoCorrectionEdit(index: 5, original: "h", replacement: "g")]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["中火", "中国", "中华"])
        XCTAssertEqual(merged[0].kind, .candidate)
        XCTAssertEqual(merged[1].kind, .correctionCandidate)
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

    func testRankerDoesNotPromoteRepeatedFinalDeletionCorrection() {
        let normalItems = [
            CandidateItem(title: "你好哦", kind: .candidate),
            CandidateItem(title: "你好", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "你好",
                originalInput: "nihaoo",
                correctedInput: "nihao",
                edits: [TypoCorrectionEdit(index: 5, original: "o", replacement: "o", kind: .deletion)]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["你好哦", "你好"])
        XCTAssertEqual(merged.first?.kind, .candidate)
    }

    func testRankerPlacesConservativeInsertionNearFrontWithoutReplacingTopCandidate() {
        let normalItems = [
            CandidateItem(title: "你或", kind: .candidate),
            CandidateItem(title: "拟或", kind: .candidate),
            CandidateItem(title: "你好", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "你好",
                originalInput: "niho",
                correctedInput: "nihao",
                edits: [
                    TypoCorrectionEdit(
                        index: 3,
                        original: "a",
                        replacement: "a",
                        kind: .insertion,
                        inserted: "a"
                    )
                ]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["你或", "你好", "拟或"])
        XCTAssertEqual(merged[0].kind, .candidate)
        XCTAssertEqual(merged[1].kind, .correctionCandidate)
    }

    func testRankerDoesNotMoveTranspositionCorrectionNearFront() {
        let normalItems = [
            CandidateItem(title: "你好", kind: .candidate),
            CandidateItem(title: "你号", kind: .candidate),
        ]
        let correctionItems = [
            correctionItem(
                title: "你号",
                originalInput: "nihoa",
                correctedInput: "nihao",
                edits: [
                    TypoCorrectionEdit(
                        index: 3,
                        original: "o",
                        replacement: "a",
                        kind: .transposition,
                        secondIndex: 4
                    )
                ]
            )
        ]

        let merged = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems
        )

        XCTAssertEqual(merged.map(\.title), ["你好", "你号"])
        XCTAssertEqual(merged[0].kind, .candidate)
        XCTAssertEqual(merged[1].kind, .candidate)
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
                input: "bihao",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "首字符 b 邻键误触 n，可生成纠错候选但不盲目压过普通首候选"
            ),
            benchmarkCase(
                input: "nigao",
                category: .middleCharacterMistake,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "中间 g 邻键误触 h，可生成纠错候选但不盲目压过普通首候选"
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
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "V0.2.6 支持保守的末尾重复字符删除，但不盲目提升"
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
                note: "非末尾辅音/元音跨类替换仍不支持，避免扩大中间字符误纠错噪声"
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
                input: "zhonghuo",
                category: .middleCharacterMistake,
                expectedCorrectedInput: "zhongguo",
                expectedCandidate: "中国",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "长拼音中后段 h 邻键误触 g，可生成纠错候选但不盲目压过普通首候选"
            ),
            benchmarkCase(
                input: "zhongguoo",
                category: .repeatedCharacter,
                expectedCorrectedInput: "zhongguo",
                expectedCandidate: "中国",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "V0.2.6 支持长拼音末尾重复字符删除"
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
                input: "woainii",
                category: .repeatedCharacter,
                expectedCorrectedInput: "woaini",
                expectedCandidate: "我爱你",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "V0.2.6 支持短语拼音末尾重复字符删除"
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
                note: "过短重复输入不能通过删除规则产生危险纠错"
            ),
            benchmarkCase(
                input: "nii",
                category: .ambiguousDangerous,
                expectedOutcome: .notCorrected,
                note: "非常短的重复输入不能触发末尾重复字符删除"
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
                input: "bihao",
                category: .adjacentKeySubstitution,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "首字符纠错进入前排，但不提升到普通首候选之前"
            ),
            benchmarkCase(
                input: "nigao",
                category: .middleCharacterMistake,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "中间同类邻键纠错进入前排，但不提升到普通首候选之前"
            ),
            benchmarkCase(
                input: "zhonghuo",
                category: .middleCharacterMistake,
                expectedCorrectedInput: "zhongguo",
                expectedCandidate: "中国",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "长拼音中后段同类邻键纠错进入前排，但不提升到普通首候选之前"
            ),
            benchmarkCase(
                input: "nihaoo",
                category: .repeatedCharacter,
                expectedCorrectedInput: "nihao",
                expectedCandidate: "你好",
                expectedOutcome: .correctedSuccessfully,
                shouldPromote: false,
                note: "重复字符可生成纠错候选，但当前不作为 ranker 高置信提升项"
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

        guard let edit = singleConservativeEdit(from: benchmark.input, to: correctedInput) else {
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

    private func singleConservativeEdit(from originalInput: String, to correctedInput: String) -> TypoCorrectionEdit? {
        let originalLetters = Array(originalInput)
        let correctedLetters = Array(correctedInput)

        if originalLetters.count == correctedLetters.count + 1,
            Array(originalLetters.dropLast()) == correctedLetters,
            originalLetters.count >= 2,
            originalLetters[originalLetters.count - 1] == originalLetters[originalLetters.count - 2]
        {
            let editIndex = originalLetters.count - 1
            return TypoCorrectionEdit(
                index: editIndex,
                original: originalLetters[editIndex],
                replacement: originalLetters[editIndex],
                kind: .deletion
            )
        }

        guard originalLetters.count == correctedLetters.count else { return nil }

        let mismatches = zip(originalLetters.indices, zip(originalLetters, correctedLetters))
            .filter { _, pair in pair.0 != pair.1 }

        guard mismatches.count == 1,
            let mismatch = mismatches.first
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

private final class DictionaryCandidateProvider: CandidateProvider {
    private let dictionary: [String: [String]]

    init(dictionary: [String: [String]]) {
        self.dictionary = dictionary
    }

    func candidates(for composition: String) -> [String] {
        dictionary[composition] ?? []
    }
}
