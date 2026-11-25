import XCTest

@testable import KeyboardCore

final class EnglishAutospaceTests: XCTestCase {
    private func trailing(_ after: String?, _ committing: String) -> Bool {
        EnglishAutospace.trailingSpace(after: after, committing: committing)
    }

    // MARK: - Positive cases (EN-AUTOSPACE-IMMEDIATE-001)

    func testAddsSpaceBeforeNonWhitespaceNonAttachedRightNeighbor() {
        for after in ["here", "World", "你", "苹果", "3d", "/", "@", "#", "。", "-"] {
            XCTAssertTrue(trailing(after, "world"), after)
        }
    }

    func testAddsSpaceWhenRightNeighborUnknown() {
        // Unknown right context is the undecided boundary toward the next
        // word: the space is written immediately (r3 §2.1, replaces the old
        // conservative no-space rule).
        XCTAssertTrue(trailing(nil, "world"))
    }

    func testAddsSpaceAtDocumentEnd() {
        XCTAssertTrue(trailing("", "world"))
    }

    func testAddsSpaceAtKnownWordBoundaryOnlyOnce() {
        // The decision appends exactly one space; callers own the single
        // insertion transaction. Repeated decisions on the same input are
        // stable (no re-counting of the inserted space).
        XCTAssertTrue(trailing("here", "world"))
        XCTAssertTrue(trailing("here", "world"))
    }

    // MARK: - Negative cases

    /// 冻结附着标点集合：右邻命中时不补空格（不含 /、@、#、引号及中文轮换
    /// 标点，取代旧版排除 connector 的右侧规则）。
    func testDoesNotAddSpaceBeforeAttachedPunctuation() {
        for after in [".", ",", "?", "!", ";", ":", ")", "]", "}"] {
            XCTAssertFalse(trailing(after, "world"), after)
        }
    }

    func testDoesNotAddSpaceBeforeWhitespace() {
        for after in [" ", "  ", "\t", "\n"] {
            XCTAssertFalse(trailing(after, "world"), after)
        }
        XCTAssertFalse(trailing(" world", "world"))
    }

    func testDoesNotAddSpaceAfterCommittingEndsWithWhitespace() {
        XCTAssertFalse(trailing("here", "world "))
        XCTAssertFalse(trailing("here", " "))
        XCTAssertFalse(trailing("here", ""))
    }

    /// 前导/尾随两侧决策独立：旧 `leadingSpaceAdded` 抑制语义废除。
    func testTrailingDecisionIsIndependentFromLeadingDecision() {
        // 决策函数不再接受 leadingSpaceAdded 参数；同一输入重复给出同一
        // 尾随判定，与左边界是否已补格无关。
        XCTAssertTrue(trailing("here", "world"))
        XCTAssertTrue(trailing("", "world"))
    }

    func testFrozenAttachedPunctuationSetMatchesContract() {
        XCTAssertEqual(
            EnglishAutospace.attachedPunctuation,
            [".", ",", "?", "!", ";", ":", ")", "]", "}"]
        )
    }

    // MARK: - Leading space after sentence terminator (EN-mode fix r1)

    func testAddsLeadingSpaceAfterSentenceTerminator() {
        for terminator in [".", "!", "?", "。", "！", "？"] {
            XCTAssertTrue(
                EnglishAutospace.leadingSpaceAfterSentenceTerminator(
                    before: "Word\(terminator)", committing: "Hello"
                ),
                terminator
            )
        }
    }

    func testLeadingSpaceAfterTerminatorStaysConservative() {
        // Unknown read, document start, already-typed space, whitespace or
        // non-letter commit heads, and non-terminator punctuation all stay
        // without a leading space.
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: nil, committing: "Hello"))
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: "", committing: "Hello"))
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: "Word. ", committing: "Hello"))
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: "Word.", committing: " "))
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: "Word.", committing: "3d"))
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: "Word,", committing: "Hello"))
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: "Word:", committing: "Hello"))
        XCTAssertFalse(EnglishAutospace.leadingSpaceAfterSentenceTerminator(before: "Word/", committing: "Hello"))
    }

    // MARK: - Disabled host types

    func testDisabledForURLAndEmailAndWebSearchHosts() {
        XCTAssertTrue(EnglishAutospace.isDisabled(for: .URL))
        XCTAssertTrue(EnglishAutospace.isDisabled(for: .emailAddress))
        XCTAssertTrue(EnglishAutospace.isDisabled(for: .webSearch))
    }

    func testEnabledForOtherHostTypesByDefault() {
        XCTAssertFalse(EnglishAutospace.isDisabled(for: .default))
        XCTAssertFalse(EnglishAutospace.isDisabled(for: .other))
    }

    // MARK: - Settings matrix

    func testSettingMatrixDoesNotTreatIntegersAsBooleans() {
        let suite = UserDefaults(suiteName: "english-autospace-tests")!
        suite.removePersistentDomain(forName: "english-autospace-tests")
        XCTAssertTrue(EnglishAutospace.isEnabled(stored: suite.object(forKey: "missing"), hasFullAccess: true))
        suite.set(1, forKey: "n")
        XCTAssertTrue(EnglishAutospace.isEnabled(stored: suite.object(forKey: "n"), hasFullAccess: true))
        suite.set(true, forKey: "b")
        XCTAssertTrue(EnglishAutospace.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: true))
        suite.set(false, forKey: "b")
        XCTAssertFalse(EnglishAutospace.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: true))
    }

    func testWithoutFullAccessTheSwitchIsForcedOn() {
        let suite = UserDefaults(suiteName: "english-autospace-tests-full")!
        suite.removePersistentDomain(forName: "english-autospace-tests-full")
        suite.set(false, forKey: "b")
        XCTAssertTrue(EnglishAutospace.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: false))
    }
}
