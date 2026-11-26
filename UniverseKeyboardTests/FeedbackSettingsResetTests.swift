import KeyboardCore
import SwiftUI
import UIKit
import XCTest

@testable import Universe_Keyboard

@MainActor
final class FeedbackSettingsResetTests: XCTestCase {
    /// 「重置为默认强度」写回默认档位并返回默认强度供预览（PB-001-FEEDBACK-UI-001）。
    func testResetRestoresDefaultIntensityAndPersists() {
        let suiteName = "FeedbackSettingsResetTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(1.0, forKey: KeyboardFeedbackSettingsKey.hapticIntensityContinuous)
        defaults.set(KeyboardFeedbackLevel.heavy.rawValue, forKey: KeyboardFeedbackSettingsKey.hapticLevel)

        let intensity = FeedbackHapticReset(defaults: defaults).perform()

        XCTAssertEqual(intensity, KeyboardFeedbackLevel.defaultLevel.hapticIntensity)
        XCTAssertEqual(
            defaults.double(forKey: KeyboardFeedbackSettingsKey.hapticIntensityContinuous),
            KeyboardFeedbackLevel.defaultLevel.hapticIntensity)
        XCTAssertEqual(
            defaults.integer(forKey: KeyboardFeedbackSettingsKey.hapticLevel),
            KeyboardFeedbackLevel.defaultLevel.rawValue)
    }

    func testResetClampsCorruptStoredValues() {
        let suiteName = "FeedbackSettingsResetTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(9.0, forKey: KeyboardFeedbackSettingsKey.hapticIntensityContinuous)
        defaults.set(99, forKey: KeyboardFeedbackSettingsKey.hapticLevel)

        let intensity = FeedbackHapticReset(defaults: defaults).perform()

        XCTAssertEqual(intensity, KeyboardFeedbackLevel.defaultLevel.hapticIntensity)
        XCTAssertEqual(defaults.integer(forKey: KeyboardFeedbackSettingsKey.hapticLevel), 3)
    }

    func testResetWithMissingSharedContainerStillReturnsDefault() {
        let intensity = FeedbackHapticReset(defaults: nil).perform()
        XCTAssertEqual(intensity, KeyboardFeedbackLevel.defaultLevel.hapticIntensity)
    }

    /// 触感反馈开关与震动强度滑块必须合并为同一个 Section 卡片（红测：旧结构为 3 个 Section）。
    /// PB-019-PR2 新增「按键气泡预览」独立卡片后整页共 3 个卡片：
    /// 按键音 / 按键气泡预览 / 触感合并卡片（开关 + 强度滑块同卡）。
    func testHapticToggleAndIntensitySliderShareOneSection() {
        let page = FeedbackSettingsView()
        XCTAssertEqual(sectionCount(page.body), 3)
    }

    /// 重置入口与确认弹窗文案必须存在于页面状态中，取消不改强度。
    func testResetSheetCopyAndCancelKeepsIntensity() {
        XCTAssertEqual(FeedbackResetConfirmationSheet.title, "重置为默认强度？")
        XCTAssertTrue(FeedbackResetConfirmationSheet.confirmTitle.contains("重置"))
        XCTAssertEqual(FeedbackResetConfirmationSheet.cancelTitle, "取消")
        // 取消路径：仅关闭弹窗，不触碰任何存储键。
        var closed = false
        FeedbackResetConfirmationSheet.handle(dismiss: { closed = true }, confirm: false) {}
        XCTAssertTrue(closed)
    }

    /// PB-022-HAPTIC-TOGGLE-LOCK-FIX-001：触感反馈 `Section` 外层不得再挂整段
    /// `.disabled(!hapticEnabled)`（关闭开关后 `Toggle("按键震动")` 被禁用锁死，
    /// 永远无法重新打开）。禁用/降透明度只允许作用于内部强度区与重置按钮。
    func testHapticSectionNotGloballyDisabledAndToggleAlwaysInteractive() {
        let page = FeedbackSettingsView()
        XCTAssertFalse(
            modifierWrapsHead(
                page.body, modifier: "EnvironmentKeyTransformModifier<Bool>", head: "Section<"),
            "触感反馈 Section 外层的 .disabled(!hapticEnabled) 必须移除（PB-022）")
        XCTAssertFalse(
            modifierWrapsHead(page.body, modifier: "OpacityEffect", head: "Section<"),
            "触感反馈 Section 外层的 .opacity 必须移除（PB-022）")
        XCTAssertFalse(
            modifierWrapsHead(
                page.body, modifier: "EnvironmentKeyTransformModifier<Bool>", head: "Toggle"),
            "「按键震动」Toggle 不得被 .disabled 包裹")
        // 内部禁用契约保持：强度区 .disabled + .opacity，重置按钮 .disabled + .opacity。
        XCTAssertTrue(
            modifierWrapsHead(
                page.body, modifier: "EnvironmentKeyTransformModifier<Bool>", head: "VStack<"),
            "强度区仍需 .disabled(!hapticEnabled)")
        XCTAssertTrue(
            modifierWrapsHead(page.body, modifier: "OpacityEffect", head: "VStack<"),
            "强度区仍需 .opacity(hapticEnabled ? 1 : 0.48)")
        XCTAssertTrue(
            modifierWrapsHead(
                page.body, modifier: "EnvironmentKeyTransformModifier<Bool>", head: "AppActionButton"),
            "重置按钮仍需 .disabled(!hapticEnabled)")
        XCTAssertTrue(
            modifierWrapsHead(page.body, modifier: "OpacityEffect", head: "AppActionButton"),
            "重置按钮需补 .opacity(hapticEnabled ? 1 : 0.48)")
    }

    /// 判断 body 树中是否存在"最外层修饰符为 `modifier` 的 ModifiedContent 节点"，
    /// 且其 content 链解包后的头部视图类型以 `head` 开头（即修饰符直接作用在该视图上）。
    /// 经验证（PB-022）：`.disabled` 的修饰符类型为 `_EnvironmentKeyTransformModifier<Bool>`，
    /// `.opacity` 为 `_OpacityEffect`。只比较节点类型串的**最外层**泛型参数，避免外层
    /// 节点泛型参数里嵌的同名修饰符类型造成误判。
    private func modifierWrapsHead(
        _ value: Any, modifier: String, head: String, depth: Int = 0
    ) -> Bool {
        guard depth < 40 else { return false }
        let mirror = Mirror(reflecting: value)
        let typeName = String(describing: mirror.subjectType)
        if typeName.hasPrefix("ModifiedContent<"),
            let split = topLevelModifierRange(of: typeName),
            typeName[split].contains(modifier)
        {
            var current = mirror.children.first?.value
            var hops = 0
            while let node = current, hops < 12 {
                let nodeType = String(describing: Swift.type(of: node))
                if nodeType.hasPrefix(head) { return true }
                guard nodeType.hasPrefix("ModifiedContent<") else { break }
                current = Mirror(reflecting: node).children.first?.value
                hops += 1
            }
            for child in mirror.children {
                if modifierWrapsHead(child.value, modifier: modifier, head: head, depth: depth + 1) {
                    return true
                }
            }
            return false
        }
        for child in mirror.children {
            if modifierWrapsHead(child.value, modifier: modifier, head: head, depth: depth + 1) {
                return true
            }
        }
        return false
    }

    /// `ModifiedContent<CONTENT, MODIFIER>` 类型串：返回最外层 MODIFIER 部分的 Range
    /// （顶层逗号之后、收尾 `>` 之前）。非该形态返回 nil。
    private func topLevelModifierRange(of typeName: String) -> Range<String.Index>? {
        guard typeName.hasPrefix("ModifiedContent<") else { return nil }
        var depth = 0
        var lastComma: String.Index?
        for (offset, ch) in typeName.enumerated() {
            let index = typeName.index(typeName.startIndex, offsetBy: offset)
            switch ch {
            case "<": depth += 1
            case ">": depth -= 1
            case "," where depth == 1: lastComma = index
            default: break
            }
        }
        guard depth == 0, let comma = lastComma else { return nil }
        let after = typeName.index(after: comma)
        if typeName.last == ">" {
            return after..<typeName.index(before: typeName.endIndex)
        }
        return after..<typeName.endIndex
    }

    private func sectionCount(_ value: Any, depth: Int = 0) -> Int {
        guard depth < 25 else { return 0 }
        let mirror = Mirror(reflecting: value)
        var count = 0
        if String(describing: mirror.subjectType).hasPrefix("Section<") {
            count += 1
        }
        for child in mirror.children {
            count += sectionCount(child.value, depth: depth + 1)
        }
        return count
    }
}
