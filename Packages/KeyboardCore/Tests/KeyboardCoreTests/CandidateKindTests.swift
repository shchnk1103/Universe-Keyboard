import XCTest

@testable import KeyboardCore

/// 测试 CandidateKind 枚举和 CandidateItem 结构体。
/// 这两个类型是候选栏数据模型的基础，被 KeyboardController、CandidateBarDataSource、
/// CandidateButtonFactory 使用。
@MainActor
final class CandidateKindTests: XCTestCase {

    // MARK: - CandidateKind raw values

    func testCandidateKindRawValueCandidate() {
        // .candidate = 0 → 用于 UIButton.tag，标记正常可选候选词
        XCTAssertEqual(CandidateKind.candidate.rawValue, 0)
    }

    func testCandidateKindRawValueComposition() {
        // .composition = 1 → 标记拼音原始字符串（可提交上屏）
        XCTAssertEqual(CandidateKind.composition.rawValue, 1)
    }

    func testCandidateKindRawValuePlaceholder() {
        // .placeholder = 2 → 标记占位符（无操作）
        XCTAssertEqual(CandidateKind.placeholder.rawValue, 2)
    }

    func testCandidateKindInitFromRawValue() {
        XCTAssertEqual(CandidateKind(rawValue: 0), .candidate)
        XCTAssertEqual(CandidateKind(rawValue: 1), .composition)
        XCTAssertEqual(CandidateKind(rawValue: 2), .placeholder)
        XCTAssertEqual(CandidateKind(rawValue: 3), .correctionCandidate)
        // 非法 rawValue 返回 nil
        XCTAssertNil(CandidateKind(rawValue: 99))
        XCTAssertNil(CandidateKind(rawValue: -1))
    }

    // MARK: - CandidateItem construction

    func testCandidateItemForCandidate() {
        let item = CandidateItem(title: "你好", kind: .candidate)
        XCTAssertEqual(item.title, "你好")
        XCTAssertEqual(item.kind, .candidate)
        XCTAssertNil(item.selectionReference)
    }

    func testCandidateItemForRimeCandidateCarriesSelectionReference() {
        let item = CandidateItem.rimeCandidate(
            RimeCandidate(text: "你好"),
            page: 2,
            indexOnPage: 4
        )

        XCTAssertEqual(item.title, "你好")
        XCTAssertEqual(item.kind, .candidate)
        XCTAssertEqual(
            item.selectionReference,
            CandidateSelectionReference(page: 2, indexOnPage: 4)
        )
    }

    func testCandidateItemForComposition() {
        let item = CandidateItem(title: "ni", kind: .composition)
        XCTAssertEqual(item.title, "ni")
        XCTAssertEqual(item.kind, .composition)
    }

    func testCandidateItemForPlaceholder() {
        let item = CandidateItem(title: "...", kind: .placeholder)
        XCTAssertEqual(item.title, "...")
        XCTAssertEqual(item.kind, .placeholder)
    }

    func testCandidateItemForCorrectionCandidate() {
        let commit = TypoCorrectionCommit(
            committedText: "你好",
            originalInput: "nihap",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")]
        )

        let item = CandidateItem(title: "你好", kind: .correctionCandidate, correction: commit)

        XCTAssertEqual(item.title, "你好")
        XCTAssertEqual(item.kind, .correctionCandidate)
        XCTAssertEqual(item.correction, commit)
        XCTAssertNil(item.selectionReference)
    }

    func testCandidateItemEquality() {
        // CandidateItem 是 struct，通过成员比较
        let a = CandidateItem(title: "你好", kind: .candidate)
        let b = CandidateItem(title: "你好", kind: .candidate)
        let c = CandidateItem(title: "你好", kind: .composition)
        XCTAssertEqual(a.title, b.title)
        XCTAssertEqual(a.kind, b.kind)
        XCTAssertNotEqual(a.kind, c.kind)
    }

    // MARK: - KeyboardEffect OptionSet

    func testKeyboardEffectEmpty() {
        let effects: KeyboardEffect = []
        XCTAssertTrue(effects.isEmpty)
    }

    func testKeyboardEffectSingleBit() {
        let effect: KeyboardEffect = .compositionChanged
        XCTAssertFalse(effect.isEmpty)
        XCTAssertTrue(effect.contains(.compositionChanged))
        XCTAssertFalse(effect.contains(.pageChanged))
    }

    func testKeyboardEffectMultipleBits() {
        var effects: KeyboardEffect = [.pageChanged, .inputModeChanged]
        XCTAssertTrue(effects.contains(.pageChanged))
        XCTAssertTrue(effects.contains(.inputModeChanged))
        XCTAssertFalse(effects.contains(.shiftStateChanged))

        effects.insert(.shiftStateChanged)
        XCTAssertTrue(effects.contains(.shiftStateChanged))
        let intersection = effects.intersection([.pageChanged, .inputModeChanged])
        XCTAssertTrue(intersection.contains(.pageChanged))
        XCTAssertTrue(intersection.contains(.inputModeChanged))
    }

    func testKeyboardEffectFormUnion() {
        var effects: KeyboardEffect = [.compositionChanged]
        effects.formUnion([.shiftStateChanged, .pageChanged])
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertTrue(effects.contains(.shiftStateChanged))
        XCTAssertTrue(effects.contains(.pageChanged))
    }
}
