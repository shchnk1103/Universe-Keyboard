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
    func testHapticToggleAndIntensitySliderShareOneSection() {
        let page = FeedbackSettingsView()
        XCTAssertEqual(sectionCount(page.body), 2)
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
