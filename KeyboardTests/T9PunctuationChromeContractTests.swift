import KeyboardCore
import XCTest

final class T9PunctuationChromeContractTests: XCTestCase {
    func testNineKeyPunctuationChromeTitleIsFrozen() {
        XCTAssertEqual(T9CommonPunctuationChrome.keyTitle, "，。？！")
        XCTAssertEqual(T9CommonPunctuationChrome.accessibilityLabel, "常用标点")
    }

    func testNineKeyPunctuationSourceWiresTitleAndCoreAction() throws {
        let rows = try sourceFile("Keyboard/Controllers/KeyboardViewController+Rows.swift")
        let actions = try sourceFile("Keyboard/Controllers/KeyboardViewController+ModeActions.swift")

        XCTAssertTrue(
            rows.contains("T9CommonPunctuationChrome.keyTitle"),
            "九键标点键面必须引用 Core chrome 合同，不能再写死 ASCII ,?!"
        )
        XCTAssertTrue(rows.contains("insertT9CommonPunctuation"))
        XCTAssertTrue(actions.contains(".pressT9CommonPunctuation"))
        XCTAssertFalse(actions.contains("insertDirectText(\"，\")"))
        XCTAssertFalse(actions.contains("title: \",?!\""))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let root = testsDir.deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
