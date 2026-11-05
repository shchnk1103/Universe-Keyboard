import KeyboardCore
import UIKit
import XCTest

@testable import KeyboardCore

/// Candidate-bar pinyin uses the validated projection, not the engine composition string.
nonisolated final class CandidateBarVisiblePreeditTests: XCTestCase {
    @MainActor
    func testCompositionItemUsesVisiblePreedit() {
        let owner = makeOwner()
        owner.controller.state.lastRimeOutput = RimeOutput(
            composition: RimeComposition(preeditText: "", cursorPosition: 0))
        let snapshot = T9CompositionPresentationSnapshot(
            candidates: [],
            visiblePreedit: "ni",
            compositionPreedit: "64")
        owner.resetCandidateSnapshot(from: snapshot)
        let titles = owner.presentedCandidates.filter { $0.kind == .composition }.map(\.title)
        XCTAssertEqual(titles, ["ni"])
        XCTAssertFalse(titles.contains("64"))
    }

    @MainActor
    func testEmptyVisiblePreeditDoesNotShowCompositionPreedit() {
        let owner = makeOwner()
        owner.controller.state.currentComposition = ""
        owner.controller.state.lastRimeOutput = RimeOutput(
            composition: RimeComposition(preeditText: "", cursorPosition: 0))
        XCTAssertEqual(owner.controller.state.lastRimeOutput?.composition?.preeditText, "")
        let snapshot = T9CompositionPresentationSnapshot(
            candidates: [],
            visiblePreedit: "",
            compositionPreedit: "64")
        owner.resetCandidateSnapshot(from: snapshot)
        let titles = owner.presentedCandidates.map(\.title)
        XCTAssertFalse(titles.contains("64"))
        XCTAssertFalse(owner.presentedCandidates.contains { $0.kind == .composition && $0.title == "64" })
    }

    @MainActor
    func testNineKeyEmptyProjectionDoesNotShowRawDigits() {
        let owner = makeOwner(nineKey: true, raw: "44444")
        let snapshot = T9CompositionPresentationSnapshot(
            candidates: [],
            visiblePreedit: "",
            compositionPreedit: "44444")
        owner.resetCandidateSnapshot(from: snapshot)
        let titles = owner.presentedCandidates.map(\.title)
        XCTAssertFalse(titles.contains("44444"))
        XCTAssertFalse(titles.contains { $0.unicodeScalars.allSatisfy { (48...57).contains($0.value) } && !$0.isEmpty })
    }

    @MainActor
    func testTwentySixKeyStillShowsRawCompositionDigits() {
        let owner = makeOwner(nineKey: false, raw: "44444")
        let snapshot = T9CompositionPresentationSnapshot(
            candidates: [],
            visiblePreedit: "",
            compositionPreedit: "44444")
        owner.resetCandidateSnapshot(from: snapshot)
        XCTAssertTrue(owner.presentedCandidates.map(\.title).contains("44444"))
    }

    @MainActor
    private func makeOwner(nineKey: Bool = false, raw: String = "") -> CandidatePreeditOwner {
        let owner = CandidatePreeditOwner()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.cachedLayoutStyle = nineKey ? .nineKey : .twentySixKey
        owner.controller.usesT9InputSemantics = nineKey
        owner.controller.state.inputMode = .chinese
        owner.controller.state.currentPage = .letters
        if !raw.isEmpty {
            owner.controller.state.lastRimeOutput = RimeOutput(
                rawInput: raw,
                composition: RimeComposition(preeditText: raw, cursorPosition: raw.count),
                candidates: [RimeCandidate(text: raw, comment: nil)]
            )
        }
        return owner
    }
}

@MainActor
private final class CandidatePreeditOwner: KeyboardViewController {
    override func viewDidLoad() {}
}
