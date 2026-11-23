import CoreFoundation
import XCTest

@testable import KeyboardCore

final class MixedScriptSpacingTests: XCTestCase {
    private func space(_ before: String?, _ committing: String) -> String {
        MixedScriptSpacing.leadingSpace(before: before, committing: committing)
    }

    func testDirectedPairsAndCaseAndSameScript() {
        for latin in ["A", "a", "Z", "z"] {
            XCTAssertEqual(space("中", latin), " ")
            XCTAssertEqual(space(latin, "中"), " ")
        }
        for digit in ["0", "9"] {
            XCTAssertEqual(space("中", digit), " ")
            XCTAssertEqual(space(digit, "中"), " ")
        }
        XCTAssertEqual(space("中", "文"), "")
        XCTAssertEqual(space("A", "b"), "")
        XCTAssertEqual(space("1", "2"), "")
        XCTAssertEqual(space("A", "1"), "")
        XCTAssertEqual(space("1", "A"), "")
    }

    func testHanEndpointsAndOutsideNeighbors() {
        for han in ["\u{3400}", "\u{4DBF}", "\u{4E00}", "\u{9FFF}"] {
            XCTAssertEqual(space(han, "A"), " ")
            XCTAssertEqual(space("A", han), " ")
        }
        for other in ["\u{33FF}", "\u{4DC0}", "\u{A000}"] {
            XCTAssertEqual(space(other, "A"), "")
            XCTAssertEqual(space("中", other), "")
        }
    }

    func testEmptyWhitespaceAndSecondCall() {
        XCTAssertEqual(space(nil, "你"), "")
        XCTAssertEqual(space("", "你"), "")
        XCTAssertEqual(space("A", ""), "")
        for gap in ["\t", "\r", "\n", "\u{00A0}", " "] {
            XCTAssertEqual(space(gap, "你"), "")
            XCTAssertEqual(space("A", gap), "")
        }
        XCTAssertEqual(space("A ", "你"), "")
        XCTAssertEqual(space("A", " 你"), "")
    }

    func testOnlyTheBoundaryScalarsAndNoInternalRewrite() {
        // English <-> digit never inserts, even against a Han run before it.
        XCTAssertEqual(space("苹果X", "9"), "")
        XCTAssertEqual(space("A", "苹果iPhone"), " ")
        let committed =
            MixedScriptSpacing.leadingSpace(before: "A", committing: "苹果iPhone")
            + "苹果iPhone"
        XCTAssertFalse(committed.contains("苹果 i"))
    }

    func testFullwidthKanaHangulAndKeycapDirections() {
        XCTAssertEqual(space("中", "１"), "")
        XCTAssertEqual(space("中", "あ"), "")
        XCTAssertEqual(space("中", "한"), "")
        XCTAssertEqual(space("中", "\u{F900}"), "")
        XCTAssertEqual(space("中", "é"), "")
        XCTAssertEqual(space("中", "1️⃣"), " ")
        XCTAssertEqual(space("1️⃣", "中"), "")
        XCTAssertEqual(space("中", "😀"), "")
        XCTAssertEqual(space("中", "☺️"), "")
    }

    func testSettingMatrixDoesNotTreatIntegersAsBooleans() {
        let suite = UserDefaults(suiteName: "mixed-script-spacing-tests")!
        suite.removePersistentDomain(forName: "mixed-script-spacing-tests")
        XCTAssertTrue(MixedScriptSpacing.isEnabled(stored: suite.object(forKey: "missing"), hasFullAccess: true))
        suite.set(1, forKey: "n")
        XCTAssertTrue(MixedScriptSpacing.isEnabled(stored: suite.object(forKey: "n"), hasFullAccess: true))
        suite.set(true, forKey: "b")
        XCTAssertTrue(MixedScriptSpacing.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: true))
        suite.set(false, forKey: "b")
        XCTAssertFalse(MixedScriptSpacing.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: true))
        XCTAssertTrue(MixedScriptSpacing.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: false))
        XCTAssertEqual(suite.object(forKey: "b") as? Bool, false)
        XCTAssertTrue(MixedScriptSpacing.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: false))
        XCTAssertFalse(MixedScriptSpacing.isEnabled(stored: suite.object(forKey: "b"), hasFullAccess: true))
    }
}

@MainActor
final class MixedScriptSpacingHostTests: XCTestCase {
    private final class CountingClient: TextInputClient {
        let inner = FakeTextInputClient()
        var inserts: [String] = []
        var marks: [String] = []
        var unmarks = 0
        var hasTextBeforeInput: Bool { inner.hasTextBeforeInput }
        var text: String { inner.text }
        var marked: String { inner.markedText }
        var history: [String] { inner.markedTextHistory }
        var cursor: Int { inner.cursorOffset }
        func insertText(_ text: String) { inserts.append(text); inner.insertText(text) }
        func deleteBackward() { inner.deleteBackward() }
        func adjustTextPosition(byCharacterOffset offset: Int) {
            inner.adjustTextPosition(byCharacterOffset: offset)
        }
        func setMarkedText(_ text: String, selectedRange: Range<Int>) {
            marks.append(text)
            inner.setMarkedText(text, selectedRange: selectedRange)
        }
        func unmarkText() { unmarks += 1; inner.unmarkText() }
        func seed(_ text: String) { inner.text = text }
    }

    private func make(before: String) -> (KeyboardController, CountingClient, () -> Int) {
        let client = CountingClient()
        client.seed(before)
        let controller = KeyboardController()
        controller.textClient = client
        var reads = 0
        controller.documentContextBeforeInput = {
            reads += 1
            return before
        }
        return (controller, client, { reads })
    }

    func testSevenHostCommitContracts() {
        struct Example {
            let before: String
            let preedits: [String]
            let commit: String
            let offset: Int?
            let result: String
            let write: String
            let viaInsert: Bool
            let cursor: Int
        }
        let examples: [Example] = [
            .init(
                before: "A", preedits: ["ni"], commit: "你", offset: nil, result: "A 你", write: " 你", viaInsert: false,
                cursor: 3),
            .init(
                before: "中", preedits: ["ni"], commit: "你", offset: nil, result: "中你", write: "你", viaInsert: false,
                cursor: 2),
            .init(
                before: "A", preedits: ["你"], commit: "你", offset: nil, result: "A 你", write: " 你", viaInsert: false,
                cursor: 3),
            .init(
                before: "A", preedits: ["ni"], commit: "ni", offset: nil, result: "Ani", write: "ni", viaInsert: true,
                cursor: 3),
            .init(
                before: "中", preedits: ["ni"], commit: "ni", offset: nil, result: "中 ni", write: " ni",
                viaInsert: false,
                cursor: 4),
            .init(
                before: "A", preedits: [], commit: "你", offset: nil, result: "A 你", write: " 你", viaInsert: true,
                cursor: 3),
            .init(
                before: "A", preedits: ["ni", "苹果"], commit: "苹果", offset: nil, result: "A 苹果", write: " 苹果",
                viaInsert: false, cursor: 4),
            .init(
                before: "A", preedits: ["苹果"], commit: "苹果", offset: 1, result: "A 苹果", write: " 苹果", viaInsert: false,
                cursor: 3),
        ]
        for (index, example) in examples.enumerated() {
            let (controller, client, reads) = make(before: example.before)
            for preedit in example.preedits {
                controller.updateInlinePreedit(preedit, source: .compositionProjection)
            }
            let markCount = client.marks.count
            var events: [String] = []
            controller.onCommittedText = { events.append($0.text) }
            controller.commitInlinePreedit(as: example.commit, selectedOffset: example.offset)
            let label = "case \(index + 1)"
            XCTAssertEqual(client.text, example.result, label)
            XCTAssertEqual(client.cursor, example.cursor, label)
            XCTAssertEqual(reads(), 1, label)
            XCTAssertEqual(client.marked, "", label)
            XCTAssertEqual(events, [example.write], label)
            XCTAssertEqual(client.inserts, example.viaInsert ? [example.write] : [], label)
            XCTAssertEqual(Array(client.marks.dropFirst(markCount)), example.viaInsert ? [] : [example.write], label)
            XCTAssertEqual(client.unmarks, example.viaInsert ? 0 : 1, label)
        }
    }

    func testTableReplacesMarkedUsingTheAnchorOnce() {
        let (controller, client, reads) = make(before: "A")
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        XCTAssertEqual(reads(), 1)
        var events: [String] = []
        controller.onCommittedText = { events.append($0.text) }
        controller.commitInlinePreedit(as: "你")
        XCTAssertEqual(client.text, "A 你")
        XCTAssertEqual(reads(), 1)
        XCTAssertEqual(client.marks.filter { $0.hasPrefix(" ") }, [" 你"])
        XCTAssertEqual(client.unmarks, 1)
        XCTAssertTrue(client.inserts.isEmpty)
        XCTAssertEqual(events, [" 你"])
        XCTAssertEqual(client.marked, "")
        XCTAssertFalse(client.history.dropLast().contains { $0.hasPrefix(" ") })
    }

    func testMarkedEndingInLatinDoesNotAddInsideChinese() {
        let (controller, client, reads) = make(before: "中")
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        controller.commitInlinePreedit(as: "你")
        XCTAssertEqual(client.text, "中你")
        XCTAssertEqual(reads(), 1)
    }

    func testSameMarkedStillReroutesWhenAnchorNeedsASpace() {
        let (controller, client, reads) = make(before: "A")
        controller.updateInlinePreedit("你", source: .compositionProjection)
        controller.commitInlinePreedit(as: "你")
        XCTAssertEqual(client.text, "A 你")
        XCTAssertTrue(client.inserts.isEmpty)
        XCTAssertEqual(client.unmarks, 1)
        XCTAssertEqual(reads(), 1)
    }

    func testSameMarkedWithoutSpaceStillUsesInsertText() {
        let (controller, client, reads) = make(before: "A")
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        controller.commitInlinePreedit(as: "ni")
        XCTAssertEqual(client.text, "Ani")
        XCTAssertEqual(client.inserts, ["ni"])
        XCTAssertEqual(client.unmarks, 0)
        XCTAssertEqual(reads(), 1)
    }

    func testDirectInsertReadsOnceInsideInsertText() {
        let (controller, client, reads) = make(before: "A")
        var events: [String] = []
        controller.onCommittedText = { events.append($0.text) }
        controller.commitInlinePreedit(as: "你")
        XCTAssertEqual(client.text, "A 你")
        XCTAssertEqual(reads(), 1)
        XCTAssertEqual(client.inserts, [" 你"])
        XCTAssertEqual(events, [" 你"])
    }

    func testPartialCommitKeepsTheOriginalAnchor() {
        let (controller, client, reads) = make(before: "A")
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        controller.updateInlinePreedit("苹果", source: .compositionProjection)
        XCTAssertEqual(reads(), 1)
        XCTAssertEqual(client.history, ["ni", "苹果"])
        controller.commitInlinePreedit(as: "苹果")
        XCTAssertEqual(client.text, "A 苹果")
        XCTAssertEqual(reads(), 1)
    }

    func testOffsetMovesByOneForChangedMarkedText() {
        let (controller, client, _) = make(before: "A")
        controller.updateInlinePreedit("pingguo", source: .compositionProjection)
        controller.commitInlinePreedit(as: "苹果", selectedOffset: 1)
        XCTAssertEqual(client.text, "A 苹果")
        XCTAssertEqual(client.cursor, 3)
        XCTAssertEqual(client.marks, ["pingguo", " 苹果"])
        XCTAssertEqual(client.unmarks, 1)
        XCTAssertTrue(client.inserts.isEmpty)
    }

    func testOffsetMovesByOneCharacterWhenASpaceIsAdded() {
        let (controller, client, _) = make(before: "A")
        controller.updateInlinePreedit("苹果", source: .compositionProjection)
        controller.commitInlinePreedit(as: "苹果", selectedOffset: 1)
        XCTAssertEqual(client.text, "A 苹果")
        XCTAssertEqual(client.cursor, 3)
    }

    func testOffsetsCoverNilZeroMiddleAndPastTheEnd() {
        func cursor(offset: Int?) -> Int {
            let (controller, client, _) = make(before: "A")
            controller.updateInlinePreedit("苹果", source: .compositionProjection)
            controller.commitInlinePreedit(as: "苹果", selectedOffset: offset)
            XCTAssertEqual(client.text, "A 苹果")
            return client.cursor
        }
        XCTAssertEqual(cursor(offset: nil), 4)
        XCTAssertEqual(cursor(offset: 0), 2)
        XCTAssertEqual(cursor(offset: 1), 3)
        XCTAssertEqual(cursor(offset: 9), 4)
    }

    func testDisabledAndMissingClientDoNotReadOrCallTheRule() {
        let client = CountingClient()
        client.seed("A")
        let controller = KeyboardController()
        controller.textClient = client
        controller.mixedScriptSpacingEnabled = false
        var reads = 0
        controller.documentContextBeforeInput = {
            reads += 1; return "A"
        }
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        controller.commitInlinePreedit(as: "你")
        XCTAssertEqual(reads, 0)
        XCTAssertEqual(client.text, "A你")

        let bare = KeyboardController()
        bare.mixedScriptSpacingEnabled = true
        var bareReads = 0
        bare.documentContextBeforeInput = {
            bareReads += 1; return "A"
        }
        bare.insertText("你")
        XCTAssertEqual(bareReads, 0)
    }

    func testEmptyCommitDoesNotReadAgain() {
        let (controller, client, reads) = make(before: "A")
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        controller.commitInlinePreedit(as: "")
        XCTAssertEqual(reads(), 1)
        XCTAssertEqual(client.text, "A")
        XCTAssertEqual(client.marked, "")
    }

    func testExternalChangeDropsTheAnchor() {
        let (controller, client, reads) = make(before: "A")
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        _ = controller.noteExternalDocumentChange()
        controller.commitInlinePreedit(as: "你")
        // Anchor is unknown after the external change: no space, marked is
        // still replaced, and the closure is never re-read in place.
        XCTAssertEqual(client.text, "A你")
        XCTAssertFalse(client.text.contains(" "))
        XCTAssertEqual(reads(), 1)
    }

    func testPendingPunctuationAndPasteDoNotGainASpace() {
        let (controller, client, _) = make(before: "中")
        controller.insertText("。")
        XCTAssertEqual(client.text, "中。")
        let pasted = KeyboardController()
        let pasteClient = CountingClient()
        pasteClient.seed("中")
        pasted.textClient = pasteClient
        pasted.documentContextBeforeInput = { "中" }
        XCTAssertEqual(pasted.commitPastedPlainText("iPhone"), .inserted)
        XCTAssertEqual(pasteClient.text, "中iPhone")
    }

    func testBackspaceRemovesTheLetterThenTheSpace() {
        let (controller, client, _) = make(before: "中")
        controller.insertText("A")
        XCTAssertEqual(client.text, "中 A")
        client.deleteBackward()
        XCTAssertEqual(client.text, "中 ")
        client.deleteBackward()
        XCTAssertEqual(client.text, "中")
        controller.insertText("😀")
        XCTAssertEqual(client.text, "中😀")
        client.deleteBackward()
        XCTAssertEqual(client.text, "中")
    }

    func testBackspaceDeletesComposedCharactersAsWholeClusters() {
        // A-03: multi-scalar composed Characters — a decomposed e-acute and a
        // keycap sequence — are deleted one whole grapheme cluster at a time.
        // The first backspace after mixed-script insertion removes the entire
        // cluster (not just its final scalar), leaving the inserted space but
        // never an orphaned combining scalar.
        let orphanScalars: Set<Unicode.Scalar> = ["\u{0301}", "\u{FE0F}", "\u{20E3}"]
        func assertNoOrphanScalars(in text: String, _ label: String) {
            XCTAssertFalse(
                text.unicodeScalars.contains(where: orphanScalars.contains),
                "\(label): orphaned combining scalar left behind in \(text)")
        }

        let (controller, client, _) = make(before: "中")
        controller.insertText("e\u{0301}")
        XCTAssertEqual(client.text, "中 e\u{0301}")
        client.deleteBackward()
        XCTAssertEqual(client.text, "中 ")
        XCTAssertEqual(client.text.count, 2)
        assertNoOrphanScalars(in: client.text, "e-acute")
        client.deleteBackward()
        XCTAssertEqual(client.text, "中")
        assertNoOrphanScalars(in: client.text, "e-acute")

        let (keycapController, keycapClient, _) = make(before: "中")
        keycapController.insertText("1️⃣")
        XCTAssertEqual(keycapClient.text, "中 1️⃣")
        keycapClient.deleteBackward()
        XCTAssertEqual(keycapClient.text, "中 ")
        XCTAssertEqual(keycapClient.text.count, 2)
        assertNoOrphanScalars(in: keycapClient.text, "keycap")
        keycapClient.deleteBackward()
        XCTAssertEqual(keycapClient.text, "中")
        assertNoOrphanScalars(in: keycapClient.text, "keycap")
    }
}
