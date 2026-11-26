import UIKit
import XCTest

@testable import KeyboardCore

/// PB-017 PR-2：26 键键帽双拼副标的显隐与无障碍拼接。
nonisolated final class ShuangpinSublegendChromeTests: XCTestCase {
    // MARK: - Helpers

    @MainActor
    private func installedKeyboard() throws -> KeyboardViewController {
        let sut = KeyboardViewController()
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        sut.keyboardRowHeightSource = { 45 }
        sut.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        sut.prepareKeyboardHeightForAppearance()
        sut.installPreferredKeyboardHeight()
        sut.installKeyboardUIIfNeeded()
        _ = try XCTUnwrap(sut.rootStack)
        return sut
    }

    @MainActor
    private func letterButton(_ sut: KeyboardViewController, key: String) throws -> UIButton {
        let button = try XCTUnwrap(
            sut.letterButtons.first { $0.accessibilityIdentifier == key },
            "26 键字母行应包含键 \(key)")
        return button
    }

    @MainActor
    private func sublabel(of button: UIButton) -> UILabel? {
        button.viewWithTag(KeyboardViewController.shuangpinSublegendTag) as? UILabel
    }

    // MARK: - 显隐

    @MainActor
    func testShuangpinSchemaShowsSublegendOnLetterKeys() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = .flypy
        sut.cachedShuangpinSublegendEnabled = true
        sut.reloadKeyboard()

        let q = try letterButton(sut, key: "q")
        let label = try XCTUnwrap(sublabel(of: q))
        XCTAssertEqual(label.text, "iu")
        XCTAssertEqual(label.font.pointSize, 9, accuracy: 0.01)
        XCTAssertEqual(label.textColor, .secondaryLabel)
        // A/E 两键无映射韵母，整键隐藏。
        XCTAssertNil(sublabel(of: try letterButton(sut, key: "a")))
        XCTAssertNil(sublabel(of: try letterButton(sut, key: "e")))
    }

    @MainActor
    func testNaturalCodeSchemaUsesItsOwnMapping() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = .zrm
        sut.cachedShuangpinSublegendEnabled = true
        sut.reloadKeyboard()

        // W 键：小鹤 ei / 自然码 ia，分方案显示所选方案映射。
        let w = try letterButton(sut, key: "w")
        XCTAssertEqual(try XCTUnwrap(sublabel(of: w)).text, "ia")
        // P 键：小鹤 ie / 自然码 un。
        let p = try letterButton(sut, key: "p")
        XCTAssertEqual(try XCTUnwrap(sublabel(of: p)).text, "un")
    }

    @MainActor
    func testNonShuangpinSchemaHidesSublegendLayer() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = nil
        sut.cachedShuangpinSublegendEnabled = true
        sut.reloadKeyboard()

        for key in ["q", "w", "m"] {
            XCTAssertNil(
                sublabel(of: try letterButton(sut, key: key)),
                "非双拼方案键 \(key) 不应有副标")
        }
    }

    @MainActor
    func testNineKeyLayoutHidesSublegendLayer() throws {
        // 九宫格从零构建：T9 语义先于 UI 安装，键帽走 makeT9KeyButton 管线。
        let sut = KeyboardViewController()
        sut.cachedShuangpinLegendTable = .flypy
        sut.cachedShuangpinSublegendEnabled = true
        sut.cachedLayoutStyle = .nineKey
        sut.loadViewIfNeeded()
        sut.controller.usesT9InputSemantics = true
        sut.controller.state.currentPage = .letters
        sut.view.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        sut.keyboardRowHeightSource = { 45 }
        sut.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        sut.prepareKeyboardHeightForAppearance()
        sut.installPreferredKeyboardHeight()
        sut.installKeyboardUIIfNeeded()
        _ = try XCTUnwrap(sut.rootStack)

        // 九宫格字母组键走 makeT9KeyButton 管线（副标只挂 26 键 makeLetterRow），
        // 全视图树不应存在任何副标子 label。
        func containsSublegend(_ view: UIView) -> Bool {
            if let label = view as? UILabel, label.tag == KeyboardViewController.shuangpinSublegendTag {
                return true
            }
            return view.subviews.contains(where: containsSublegend)
        }
        XCTAssertFalse(containsSublegend(sut.view), "九宫格布局不应存在任何副标子 label")
    }

    @MainActor
    func testToggleOffRestoresPlainKeycaps() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = .flypy
        sut.cachedShuangpinSublegendEnabled = false
        sut.reloadKeyboard()

        for key in ["q", "w", "m"] {
            XCTAssertNil(
                sublabel(of: try letterButton(sut, key: key)),
                "开关关闭后键 \(key) 不应有副标")
        }
    }

    // MARK: - 无障碍

    @MainActor
    func testAccessibilityLabelIncludesShuangpinMappingWhenVisible() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = .flypy
        sut.cachedShuangpinSublegendEnabled = true
        sut.reloadKeyboard()

        let q = try letterButton(sut, key: "q")
        XCTAssertEqual(q.accessibilityLabel, "Q，双拼 iu")
        let v = try letterButton(sut, key: "v")
        XCTAssertEqual(v.accessibilityLabel, "V，双拼 zh")
    }

    @MainActor
    func testAccessibilityLabelRestoresWhenHidden() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = nil
        sut.cachedShuangpinSublegendEnabled = true
        sut.reloadKeyboard()

        let q = try letterButton(sut, key: "q")
        XCTAssertEqual(q.accessibilityLabel, sut.displayTitle(for: "q"))
        XCTAssertFalse(
            q.accessibilityLabel?.contains("双拼") ?? true,
            "副标隐藏时 a11y label 不应包含映射词")
    }

    @MainActor
    func testAccessibilityLabelRestoresWhenToggleOff() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = .flypy
        sut.cachedShuangpinSublegendEnabled = false
        sut.reloadKeyboard()

        let q = try letterButton(sut, key: "q")
        XCTAssertEqual(q.accessibilityLabel, sut.displayTitle(for: "q"))
    }

    // MARK: - 几何约束

    @MainActor
    func testSublabelStaysRightBottomWithinFrozenKeyHeight() throws {
        let sut = try installedKeyboard()
        sut.cachedShuangpinLegendTable = .flypy
        sut.cachedShuangpinSublegendEnabled = true
        sut.reloadKeyboard()

        let q = try letterButton(sut, key: "q")
        let label = try XCTUnwrap(sublabel(of: q))
        sut.view.layoutIfNeeded()
        XCTAssertLessThanOrEqual(
            label.frame.maxY, q.bounds.height - 1.9,
            "副标不得溢出 45pt 冻结键高")
        XCTAssertGreaterThanOrEqual(
            label.frame.minY, q.bounds.midY + 1.9,
            "副标与主标题（居中 17pt）最小间距 2pt")
        XCTAssertLessThanOrEqual(
            label.frame.maxX, q.bounds.width - 2.9,
            "副标右缘不贴键缘")
        XCTAssertFalse(label.isAccessibilityElement, "副标本身不参与朗读")
    }
}
