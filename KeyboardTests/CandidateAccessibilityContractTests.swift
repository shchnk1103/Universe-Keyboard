import XCTest

final class CandidateAccessibilityContractTests: XCTestCase {
    /// Keyboard.appex 不能作为普通 XCTest 的可链接宿主，因此这里沿用现有的
    /// Extension 源码合同测试，防止候选按钮语义在后续 UI 重构中被移除。
    func testCandidateCellDeclaresActionableVoiceOverSemantics() throws {
        let source = try sourceFile("Keyboard/Views/CandidateBar/CandidateCell.swift")

        XCTAssertTrue(source.contains("isAccessibilityElement = true"))
        XCTAssertTrue(source.contains("accessibilityTraits.insert(.button)"))
        XCTAssertTrue(source.contains("双击选择候选词"))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let repositoryRoot = testsDirectory.deletingLastPathComponent()
        return try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
