import KeyboardCore
import UIKit
import XCTest

@testable import Universe_Keyboard

nonisolated final class CandidateFontSettingsPageTests: XCTestCase {
    @MainActor
    func testSearchFindsUniqueCandidateFontEntry() throws {
        let entries = SettingsSearchCatalog.all.filter { $0.id == "candidateFont" }
        XCTAssertEqual(entries.count, 1)
        let item = try XCTUnwrap(entries.first)
        XCTAssertEqual(item.title, "候选字大小")
        XCTAssertEqual(item.subtitle, "调整键盘候选词的字号")
        for query in ["候选", "候选字", "字号", "字体大小", "大小"] {
            XCTAssertTrue(SettingsSearchCatalog.matches(query: query).contains(item))
        }
    }
    @MainActor
    func testTenTiersPersistIntegersAndDefaultDeletesKey() {
        let store = CandidateFontDefaultsSpy()
        let model = CandidateFontSettingsPageModel(defaults: store)
        XCTAssertEqual(Array(CandidateFontSettingsPageModel.tiers), Array(13...22))
        for tier in CandidateFontSettingsPageModel.tiers {
            model.select(tier)
            XCTAssertEqual(model.tier, tier)
            XCTAssertEqual(model.accessibilityValue, tier == 17 ? "默认" : "\(tier) 点")
            if tier == 17 {
                XCTAssertNil(store.value)
                XCTAssertEqual(store.removedKeys.last, CandidateFontSettings.storageKey)
            } else {
                XCTAssertEqual(store.value as? Int, tier)
                XCTAssertTrue(store.value is Int)
            }
        }
        model.select(12)
        XCTAssertEqual(model.tier, 22)
        XCTAssertEqual(store.readKeys, [CandidateFontSettings.storageKey])
        XCTAssertEqual(Set(store.writtenKeys), [CandidateFontSettings.storageKey])
    }

    @MainActor
    func testInitialValueUsesCoreValidationAndOnlyInjectedSharedStore() {
        for raw: Any? in [nil, true, false, 3.5, 17.0, "22", 12, 23, NSNull()] {
            let store = CandidateFontDefaultsSpy()
            store.value = raw
            let model = CandidateFontSettingsPageModel(defaults: store)
            XCTAssertEqual(model.tier, 17)
            XCTAssertEqual(store.readKeys, [CandidateFontSettings.storageKey])
            XCTAssertTrue(store.writtenKeys.isEmpty)
            XCTAssertTrue(store.removedKeys.isEmpty)
        }
        let shared = CandidateFontDefaultsSpy()
        shared.value = 22
        XCTAssertEqual(CandidateFontSettingsPageModel(defaults: shared).tier, 22)
        XCTAssertEqual(CandidateFontSettingsPageModel(defaults: nil).tier, 17)
    }

    @MainActor
    func testPageCopyIsStaticAndDoesNotClaimPermissionBehavior() {
        XCTAssertEqual(CandidateFontSettingsCopy.title, "候选字大小")
        XCTAssertEqual(CandidateFontSettingsCopy.subtitle, "调整键盘候选词的字号")
        XCTAssertEqual(
            CandidateFontSettingsCopy.footer,
            "更改在键盘下次出现时生效。选择“默认”时跟随系统“更大字体”设置。")
        for text in [
            CandidateFontSettingsCopy.title, CandidateFontSettingsCopy.subtitle,
            CandidateFontSettingsCopy.footer, CandidateFontSettingsCopy.preview,
        ] {
            XCTAssertFalse(text.contains("完全访问"))
        }
    }

    @MainActor
    func testPreviewLabelsUseSharedSnapshotForEveryTierAndTrait() {
        let preview = CandidateFontPreviewBar()
        XCTAssertEqual(preview.sampleLabels.map(\.text), ["ni hao", "你好", "您好", "你们"])
        XCTAssertEqual(preview.sampleLabels[0].textColor, .secondaryLabel)
        for tier in 13...22 {
            preview.update(tier: tier)
            let current = CandidateFontSnapshot(
                settings: CandidateFontSettings(savedValue: tier), traits: preview.traitCollection)
            XCTAssertEqual(preview.sampleLabels[1].font, current.titleFont(kind: .candidate, preferred: true))
            for category in [UIContentSizeCategory.small, .large, .accessibilityExtraExtraExtraLarge] {
                let snapshot = CandidateFontSnapshot(
                    settings: CandidateFontSettings(savedValue: tier),
                    traits: UITraitCollection(preferredContentSizeCategory: category))
                preview.apply(snapshot)
                for (index, label) in preview.sampleLabels.enumerated() {
                    XCTAssertEqual(
                        label.font,
                        snapshot.titleFont(
                            kind: index == 0 ? .composition : .candidate, preferred: index == 1))
                    XCTAssertFalse(label.adjustsFontForContentSizeCategory)
                }
            }
        }
    }
}

/// 不访问任何真实偏好域，记录模型触及的全部键和写入类型。
private final class CandidateFontDefaultsSpy: UserDefaults {
    var value: Any?
    var readKeys: [String] = []
    var writtenKeys: [String] = []
    var removedKeys: [String] = []

    override func object(forKey defaultName: String) -> Any? {
        readKeys.append(defaultName)
        return value
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        writtenKeys.append(defaultName)
        self.value = value
    }

    override func removeObject(forKey defaultName: String) {
        removedKeys.append(defaultName)
        value = nil
    }
}
