import XCTest

final class CandidateBarIdleDismissContractTests: XCTestCase {
    func testTrailingButtonWiresDismissAndKeepsExpand() throws {
        let bar = try sourceFile("Keyboard/Controllers/KeyboardViewController+CandidateBar.swift")
        let panel = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift"
        )
        let view = try sourceFile("Keyboard/Views/CandidateBar/CandidateBarView.swift")

        XCTAssertTrue(bar.contains("handleCandidateBarTrailingButton"))
        XCTAssertTrue(bar.contains("dismissKeyboard()"))
        XCTAssertTrue(bar.contains("expandsCandidateBarPanel"))
        XCTAssertTrue(bar.contains("allowsSwipeToExpand = canExpand"))
        XCTAssertTrue(bar.contains("candidateExpandButtonWidthConstraint?.constant != 56"))
        XCTAssertTrue(panel.contains("关闭键盘"))
        XCTAssertTrue(panel.contains("button.configuration = nil"))
        XCTAssertTrue(view.contains("var allowsSwipeToExpand"))
        XCTAssertTrue(view.contains("guard allowsSwipeToExpand else { return false }"))
        XCTAssertTrue(view.contains("chevron.down.circle"))
        XCTAssertTrue(view.contains("alwaysTemplate"))
        XCTAssertTrue(view.contains("CandidateBarExpandButton(type: .custom)"))
        XCTAssertFalse(view.contains("UIButton.Configuration"))
        XCTAssertFalse(view.contains("keyboard.chevron.compact.down"))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let repositoryRoot = testsDirectory.deletingLastPathComponent()
        return try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
