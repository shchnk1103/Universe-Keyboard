import XCTest

@testable import KeyboardCore

final class EnglishAutospaceTests: XCTestCase {
    private func trailing(_ after: String?, _ committing: String, leading: Bool = false) -> Bool {
        EnglishAutospace.trailingSpace(after: after, committing: committing, leadingSpaceAdded: leading)
    }

    // MARK: - Positive cases

    func testAddsSpaceBeforeWordLikeRightNeighbor() {
        for after in ["here", "World", "你", "苹果", "3d"] {
            XCTAssertTrue(trailing(after, "world"), after)
        }
    }

    func testAddsSpaceAtKnownWordBoundaryOnlyOnce() {
        // The decision appends exactly one space; callers own the single
        // insertion transaction. Repeated decisions on the same input are
        // stable (no re-counting of the inserted space).
        XCTAssertTrue(trailing("here", "world"))
        XCTAssertTrue(trailing("here", "world"))
    }

    // MARK: - Negative cases

    func testDoesNotAddSpaceWhenRightNeighborUnknown() {
        XCTAssertFalse(trailing(nil, "world"))
    }

    func testDoesNotAddSpaceAtDocumentEnd() {
        XCTAssertFalse(trailing("", "world"))
    }

    func testDoesNotAddSpaceBeforeWhitespaceOrPunctuationOrConnectors() {
        for after in [" ", "  ", "\t", "\n", ".", ",", "。", "!", "?", "@", ":", "#", "/", "-"] {
            XCTAssertFalse(trailing(after, "world"), after)
        }
        XCTAssertFalse(trailing(" world", "world"))
        XCTAssertFalse(trailing("/Users/doubleshy0n", "world"))
    }

    func testDoesNotAddSpaceAfterCommittingEndsWithWhitespace() {
        XCTAssertFalse(trailing("here", "world "))
        XCTAssertFalse(trailing("here", " "))
        XCTAssertFalse(trailing("here", ""))
    }

    func testLeadingMixedScriptSpaceSuppressesTrailingAutospace() {
        // MixedScriptSpacing owns the left boundary; when it added the leading
        // space the trailing autospace must skip to keep one spacing decision.
        XCTAssertFalse(trailing("here", "world", leading: true))
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
