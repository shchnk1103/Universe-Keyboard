import XCTest

final class KeyAccessibilityContractTests: XCTestCase {
    /// Keyboard.appex cannot host ordinary XCTest, so these contracts pin the
    /// AX publication rules that XCUITest `app.keys` depends on.
    func testKeyButtonsRemainIndependentAccessibilityElements() throws {
        let accessibility = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+KeyAccessibility.swift"
        )
        let factory = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+KeyFactory.swift"
        )
        let rows = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+Rows.swift"
        )
        let bottom = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+BottomRow.swift"
        )

        XCTAssertTrue(accessibility.contains("button.isAccessibilityElement = true"))
        XCTAssertTrue(accessibility.contains("button.accessibilityTraits = .keyboardKey"))
        XCTAssertTrue(accessibility.contains("accessibilityIdentifier = \"delete\""))
        XCTAssertTrue(accessibility.contains("accessibilityIdentifier = \"space\""))
        XCTAssertTrue(accessibility.contains("accessibilityIdentifier = \"return\""))
        XCTAssertTrue(accessibility.contains("accessibilityIdentifier = \"nextKeyboard\""))
        XCTAssertTrue(accessibility.contains("accessibilityLabel = \"删除\""))
        XCTAssertTrue(accessibility.contains("accessibilityLabel = \"空格\""))
        XCTAssertTrue(accessibility.contains("accessibilityLabel = \"切换键盘\""))
        XCTAssertTrue(factory.contains("configureKeyAccessibility(button, title: title, action: action)"))
        XCTAssertTrue(rows.contains("button.accessibilityIdentifier = key"))
        XCTAssertTrue(bottom.contains("handleInputModeList(from:with:)"))
        XCTAssertTrue(bottom.contains("insertSpace"))
        XCTAssertTrue(bottom.contains("insertReturn"))
    }

    func testTouchRoutingOverlayDoesNotOccupyAccessibilitySpace() throws {
        let source = try sourceFile(
            "Keyboard/Controllers/KeyboardInputHitAreaStackView.swift"
        )

        XCTAssertTrue(source.contains("isAccessibilityElement = false"))
        XCTAssertTrue(source.contains("accessibilityElementsHidden = false"))
        XCTAssertTrue(source.contains("get { .null }"))
        XCTAssertFalse(
            source.contains("accessibilityElementsHidden = true"),
            "A covering overlay that hides contained AX elements also conceals sibling keys from the AX tree."
        )
        XCTAssertFalse(
            source.contains("insertText("),
            "Key accessibility must not inject host text."
        )
        XCTAssertFalse(source.contains("UIPasteboard"))
        XCTAssertFalse(source.contains("setMarkedText"))
        XCTAssertFalse(source.contains("documentContext"))
    }

    func testKeyActionPathStaysOnUIKitTargets() throws {
        let factory = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+KeyFactory.swift"
        )
        let actions = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+InputActions.swift"
        )

        XCTAssertTrue(factory.contains("button.addTarget(self, action: action, for: .touchUpInside)"))
        XCTAssertTrue(actions.contains("controller.handle(.insertKey(key))"))
        XCTAssertFalse(actions.contains("UIPasteboard"))
        XCTAssertFalse(actions.contains("insertText("))
    }

    func testProductionPasteReadAndInsertionBoundaries() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let keyboard = root.appendingPathComponent("Keyboard")
        let files = try XCTUnwrap(FileManager.default.enumerator(at: keyboard, includingPropertiesForKeys: nil))
        for case let file as URL in files where ["swift", "m"].contains(file.pathExtension) {
            let source = try String(contentsOf: file, encoding: .utf8)
            XCTAssertFalse(source.contains("UIPasteboard"), file.path)
            if file.lastPathComponent != "PasteToolbarControl.swift" {
                XCTAssertFalse(source.contains("UIPasteControl"), file.path)
            }
            if file.lastPathComponent != "UITextDocumentProxyAdapter.swift" {
                XCTAssertFalse(source.contains("proxy.insertText("), file.path)
                XCTAssertFalse(source.contains("textDocumentProxy.insertText("), file.path)
                XCTAssertFalse(source.contains("textClient.insertText("), file.path)
            }
        }
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let repositoryRoot = testsDirectory.deletingLastPathComponent()
        return try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
