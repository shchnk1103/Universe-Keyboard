import KeyboardCore
import XCTest

final class T9KaomojiChromeContractTests: XCTestCase {
    func testKaomojiChromeTitleIsFrozen() {
        XCTAssertEqual(KaomojiChrome.keyTitle, "^_^")
        XCTAssertEqual(KaomojiChrome.accessibilityLabel, "颜表情")
        XCTAssertEqual(PendingKaomojiState.defaultPending, "^_^")
        XCTAssertEqual(PendingKaomojiState.compactCatalog.first, "^_^")
        XCTAssertEqual(PendingKaomojiState.catalogTokens.first, "^_^")
    }

    func testNineKeyAndSymbolsKaomojiShareCoreAction() throws {
        let rows = try sourceFile("Keyboard/Controllers/KeyboardViewController+Rows.swift")
        let actions = try sourceFile("Keyboard/Controllers/KeyboardViewController+ModeActions.swift")

        XCTAssertTrue(rows.contains("KaomojiChrome.keyTitle"))
        XCTAssertTrue(rows.contains("insertKaomoji"))
        XCTAssertTrue(actions.contains(".pressKaomoji"))
        XCTAssertFalse(actions.contains("打开颜表情入口（占位）"))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let root = testsDir.deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
