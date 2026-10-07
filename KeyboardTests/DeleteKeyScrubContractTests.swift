import XCTest

final class DeleteKeyScrubContractTests: XCTestCase {
    func testDeleteButtonKeepsDragExitInsideTheHold() throws {
        let factory = try sourceFile("Keyboard/Controllers/KeyboardViewController+KeyFactory.swift")
        let actions = try sourceFile("Keyboard/Controllers/KeyboardViewController+DeleteActions.swift")

        XCTAssertTrue(factory.contains("deleteKeyTouchDown(_:forEvent:)"))
        XCTAssertTrue(factory.contains("deleteKeyTouchDrag(_:forEvent:)"))
        XCTAssertTrue(factory.contains(".touchDragInside, .touchDragOutside, .touchDragExit"))
        XCTAssertFalse(
            factory.contains("for: [.touchUpOutside, .touchDragExit]"),
            "Leaving the key face must not end the hold."
        )
        XCTAssertTrue(actions.contains(".lockedWithoutDelete"))
        XCTAssertTrue(actions.contains("resumeRepeating"))
        XCTAssertTrue(actions.contains("dropRemainingPreeditKeepingConfirmedPrefix()"))
        XCTAssertTrue(actions.contains("insertDirectText"))
        XCTAssertFalse(actions.contains("abandonCompositionForVisibilityChange()"))
        XCTAssertFalse(actions.contains("textDocumentProxy.insertText"))
        XCTAssertFalse(actions.contains("isComposing()"))
        XCTAssertFalse(actions.contains("selectAll"))
        XCTAssertTrue(actions.contains("deleteOneGraphemeBeforeCursor()"))
        XCTAssertTrue(actions.contains("oneGraphemeBeforeCursor: true"))
        XCTAssertTrue(actions.contains("keyFrame.contains(location)"))
        XCTAssertTrue(actions.contains("performDeleteBackward()"))

        let repeatController = try sourceFile("Keyboard/Controllers/DeleteRepeatController.swift")
        XCTAssertTrue(repeatController.contains("repeatGeneration"))
        XCTAssertTrue(repeatController.contains("self.repeatGeneration == generation"))

        let bubble = try sourceFile("Keyboard/Views/DeleteTrashBubbleView.swift")
        XCTAssertTrue(bubble.contains("minimumHeight"))
        XCTAssertTrue(bubble.contains("gapAboveKey"))
        XCTAssertTrue(bubble.contains("preferredHeight"))
    }

    func testTrashBubbleStaysATemplateSymbol() throws {
        let bubble = try sourceFile("Keyboard/Views/DeleteTrashBubbleView.swift")
        XCTAssertTrue(bubble.contains("systemName: \"trash\""))
        XCTAssertTrue(bubble.contains(".alwaysTemplate"))
        XCTAssertTrue(bubble.contains("accessibilityLabel = \"删除光标前文字\""))
        XCTAssertFalse(bubble.contains("UIButton.Configuration"))
        XCTAssertFalse(bubble.contains("documentContext"))
    }

    func testPlayheadDoesNotStoreHostText() throws {
        let playhead = try sourceFile(
            "Packages/KeyboardCore/Sources/KeyboardCore/DeleteScrubPlayhead.swift"
        )
        XCTAssertTrue(playhead.contains("ledgerCap = 64"))
        XCTAssertTrue(playhead.contains("clearAllCap = 256"))
        XCTAssertFalse(playhead.contains("insertText"))
        XCTAssertFalse(playhead.contains("documentContext"))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let repositoryRoot = testsDirectory.deletingLastPathComponent()
        return try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
