import XCTest

/// URL-MODE-ENGLISH-IMPL-001: 方案 A 底行替换与 `@` 符号页可达性的源码契约。
/// Keyboard.appex 不能承载普通 XCTest，按 KeyAccessibilityContractTests 先例以源码契约钉住。
final class URLModeBottomRowContractTests: XCTestCase {
    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let repositoryRoot = testsDirectory.deletingLastPathComponent()
        return try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func testEmailLeadingSlotIsModeToggleNotAt() throws {
        let bottom = try sourceFile("Keyboard/Controllers/KeyboardViewController+BottomRow.swift")
        XCTAssertFalse(
            bottom.contains("let atButton = makeKeyButton"),
            "方案 A：email 前槽不得再直接构建 `@` 键。"
        )
        XCTAssertFalse(
            bottom.contains("let slashButton = makeKeyButton"),
            "方案 A：URL 前槽不得再直接构建 `/` 键。"
        )
        // 前槽统一走中/英切换键。
        XCTAssertTrue(bottom.contains("addressLikeModeToggle"), "前槽须提供中/英切换键。")
    }

    func testTrailingShortcutsArePreserved() throws {
        let bottom = try sourceFile("Keyboard/Controllers/KeyboardViewController+BottomRow.swift")
        XCTAssertTrue(bottom.contains("makeKeyButton(title: \".com\""), "方案 A 保留右侧 .com。")
        XCTAssertTrue(bottom.contains("makeKeyButton(title: \".\""), "方案 A 保留 email 右侧 .。")
    }

    func testModeToggleKeyHasAccessibilityLabel() throws {
        let bottom = try sourceFile("Keyboard/Controllers/KeyboardViewController+BottomRow.swift")
        XCTAssertTrue(
            bottom.contains("accessibilityLabel = \"中/英切换\""),
            "中/英切换键须有本地化 accessibilityLabel。"
        )
        XCTAssertTrue(
            bottom.contains("makeKeyButton(\n                title: inputModeButtonTitle")
                || bottom.contains("inputModeButtonTitle"),
            "切换键须复用 inputModeButtonTitle 显示当前模式。"
        )
    }

    func testAtRemainsReachableOnSymbolsPage() throws {
        let presentation = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+Presentation.swift")
        // email 符号页（英文 symbols 页）须显式包含 `@` 可达入口。
        XCTAssertTrue(
            presentation.contains("@"),
            "英文符号页须保留 `@` 直接可达入口。"
        )
    }

    func testSlashRemainsReachableOnNumbersPage() throws {
        let presentation = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+Presentation.swift")
        XCTAssertTrue(
            presentation.contains("\"-\", \"/\""),
            "数字页须保留 `/` 直接可达入口。"
        )
    }
}
