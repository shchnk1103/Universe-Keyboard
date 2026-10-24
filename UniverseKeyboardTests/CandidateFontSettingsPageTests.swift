import KeyboardCore
import SwiftUI
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
    func testProductionSliderBindsTenIntegerTiersAndDefaultTick() async throws {
        let store = CandidateFontDefaultsSpy()
        let model = CandidateFontSettingsPageModel(defaults: store)
        XCTAssertEqual(CandidateFontSettingsPageModel.sliderRange, 13...22)
        XCTAssertEqual(CandidateFontSettingsPageModel.sliderStep, 1)
        let page = CandidateFontSettingsView(model: model)
        // 检查实际 body 中 ForEach 的数据，不在测试里另造刻度视图。
        func tickData(_ value: Any, depth: Int = 0) -> [[Int]] {
            guard depth < 25 else { return [] }
            let mirror = Mirror(reflecting: value)
            var result: [[Int]] = []
            if String(describing: mirror.subjectType).hasPrefix("ForEach<"),
                let data = mirror.children.first(where: { $0.label == "data" })?.value as? [Int]
            {
                result.append(data)
            }
            for child in mirror.children { result += tickData(child.value, depth: depth + 1) }
            return result
        }
        let marks = try XCTUnwrap(tickData(page.body).first)
        XCTAssertEqual(marks, Array(13...22))
        XCTAssertEqual(marks.count, 10)
        XCTAssertEqual(marks.firstIndex(of: 17), 4)
        XCTAssertEqual(marks.first, Int(CandidateFontSettingsPageModel.sliderRange.lowerBound))
        XCTAssertEqual(marks.last, Int(CandidateFontSettingsPageModel.sliderRange.upperBound))
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        let host = UIHostingController(rootView: page)
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true; previous?.makeKey() }
        await Task.yield()
        host.view.layoutIfNeeded()
        func sliders(_ view: UIView) -> [UISlider] {
            (view as? UISlider).map { [$0] } ?? view.subviews.flatMap { sliders($0) }
        }
        let slider = try XCTUnwrap(sliders(host.view).first)
        // SwiftUI 的原生控件可能归一化为0...1；验证生产 Binding 的所有离散位置。
        for (index, tier) in marks.enumerated() {
            let fraction = Float(index) / Float(marks.count - 1)
            slider.setValue(
                slider.minimumValue + fraction * (slider.maximumValue - slider.minimumValue), animated: false)
            slider.sendActions(for: .valueChanged)
            await Task.yield()
            XCTAssertEqual(model.tier, tier)
            if tier == 17 { XCTAssertNil(store.value) } else { XCTAssertEqual(store.value as? Int, tier) }
        }
        model.select(17)
        await Task.yield()
        host.view.layoutIfNeeded()
        let defaultFraction = (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)
        XCTAssertEqual(defaultFraction, Float(4) / 9)
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
    func testPreviewUsesCompactGeometryAndReversedPreferredColors() throws {
        let preview = CandidateFontPreviewBar()
        preview.frame = CGRect(x: 0, y: 0, width: 350, height: preview.intrinsicContentSize.height)
        preview.layoutIfNeeded()
        let expectedHeight =
            ceil(preview.sampleLabels[0].font.lineHeight)
            + max(22, preview.sampleLabels.dropFirst().map { ceil($0.font.lineHeight) }.max()!) + 8 + 4 + 16
        XCTAssertEqual(preview.intrinsicContentSize.height, expectedHeight)
        XCTAssertFalse(preview.isUserInteractionEnabled)
        let viewport = try XCTUnwrap(preview.subviews.compactMap { $0 as? UIScrollView }.first)
        XCTAssertEqual(viewport.frame.width, 350 - 56)
        XCTAssertFalse(viewport.isScrollEnabled)
        XCTAssertFalse(viewport.showsHorizontalScrollIndicator)
        let preferred = preview.sampleLabels[1]
        let plate = try XCTUnwrap(preferred.superview)
        XCTAssertEqual(plate.layer.cornerRadius, 8)
        XCTAssertEqual(preferred.frame.minX, 8)
        XCTAssertEqual(plate.bounds.width - preferred.frame.maxX, 8)
        XCTAssertEqual(preferred.frame.minY, 4)
        let ordinary = preview.sampleLabels[2]
        let ordinaryPlate = try XCTUnwrap(ordinary.superview)
        let leading = try XCTUnwrap(
            ordinaryPlate.constraints.first {
                $0.firstItem === ordinary && $0.firstAttribute == .leading
            })
        XCTAssertEqual(leading.constant, 12)
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            XCTAssertEqual(
                plate.backgroundColor?.resolvedColor(with: traits), UIColor.label.resolvedColor(with: traits))
            XCTAssertEqual(
                preferred.textColor.resolvedColor(with: traits), UIColor.systemBackground.resolvedColor(with: traits))
            XCTAssertNotEqual(
                preferred.textColor.resolvedColor(with: traits), plate.backgroundColor?.resolvedColor(with: traits))
        }
        preview.update(tier: 22)
        preview.frame.size.height = preview.intrinsicContentSize.height
        preview.layoutIfNeeded()
        let largestHeight =
            ceil(preview.sampleLabels[0].font.lineHeight)
            + max(22, preview.sampleLabels.dropFirst().map { ceil($0.font.lineHeight) }.max()!) + 8 + 4 + 16
        XCTAssertEqual(preview.bounds.height, largestHeight)
        XCTAssertEqual(preferred.font.pointSize, 22)
        let composition = preview.sampleLabels[0]
        XCTAssertEqual(composition.frame.minY, 8)
        XCTAssertEqual(viewport.frame.minY, composition.frame.maxY + 4)
        XCTAssertEqual(viewport.frame.maxY, preview.bounds.maxY - 8)
        XCTAssertEqual(viewport.frame.minX, 0)
        let preferredRect = preferred.convert(preferred.bounds, to: preview)
        let compositionLeading = try XCTUnwrap(
            preview.constraints.first { $0.firstItem === composition && $0.firstAttribute == .leading })
        XCTAssertEqual(compositionLeading.constant, 12 + 2 + 8)
        XCTAssertGreaterThanOrEqual(preferred.bounds.height, preferred.font.lineHeight)
        XCTAssertLessThanOrEqual(preferredRect.maxY, preview.bounds.maxY - 8)
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            XCTAssertEqual(
                preview.backgroundColor?.resolvedColor(with: traits),
                CandidateFontPreviewBar.surfaceColor.resolvedColor(with: traits))
        }
    }

    @MainActor
    func testTwoRowsFitEveryTierAndLargestDynamicTypeWithoutClipping() throws {
        let preview = CandidateFontPreviewBar()
        for tier in 13...22 {
            for category in [UIContentSizeCategory.large, .accessibilityExtraExtraExtraLarge] {
                let snapshot = CandidateFontSnapshot(
                    settings: CandidateFontSettings(savedValue: tier),
                    traits: UITraitCollection(preferredContentSizeCategory: category))
                preview.apply(snapshot)
                preview.frame = CGRect(x: 0, y: 0, width: 350, height: preview.intrinsicContentSize.height)
                preview.layoutIfNeeded()
                let composition = preview.sampleLabels[0]
                let viewport = try XCTUnwrap(preview.subviews.compactMap { $0 as? UIScrollView }.first)
                XCTAssertEqual(composition.font, snapshot.titleFont(kind: .composition, preferred: false))
                XCTAssertEqual(composition.frame.minY, 8)
                XCTAssertEqual(composition.frame.height, ceil(composition.font.lineHeight))
                XCTAssertEqual(viewport.frame.minY, composition.frame.maxY + 4)
                XCTAssertEqual(viewport.frame.maxY, preview.bounds.maxY - 8)
                XCTAssertEqual(viewport.frame.minX, 0)
                XCTAssertEqual(viewport.frame.maxX, preview.bounds.maxX - 56)
                for (index, label) in preview.sampleLabels.enumerated().dropFirst() {
                    XCTAssertEqual(label.font, snapshot.titleFont(kind: .candidate, preferred: index == 1))
                    XCTAssertGreaterThanOrEqual(label.bounds.height, label.font.lineHeight)
                    let rect = label.convert(label.bounds, to: preview)
                    XCTAssertGreaterThanOrEqual(rect.minY, composition.frame.maxY + 4)
                    XCTAssertLessThanOrEqual(rect.maxY, preview.bounds.maxY - 8)
                    if index == 1 {
                        let leading = try XCTUnwrap(
                            preview.constraints.first { $0.firstItem === composition && $0.firstAttribute == .leading })
                        XCTAssertEqual(leading.constant, 12 + 2 + 8)
                    }
                }
                for style in [UIUserInterfaceStyle.light, .dark] {
                    let traits = UITraitCollection(userInterfaceStyle: style)
                    XCTAssertEqual(
                        preview.backgroundColor?.resolvedColor(with: traits),
                        CandidateFontPreviewBar.surfaceColor.resolvedColor(with: traits))
                }
                XCTAssertEqual(preview.layer.cornerRadius, 0)
            }
        }
    }

    /// 自动化导航不可用时，承载同一生产设置页；不造替代预览或改产品入口。
    /// 附件来自模拟器窗口内的真实SwiftUI/UIKit渲染，非真机或导航交互证据。
    @MainActor
    func testPreviewPageCapturesLightDarkDefaultAndLargestTier() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousWindow = scene.windows.first(where: \.isKeyWindow)
        let defaults = try XCTUnwrap(UserDefaults(suiteName: universeAppGroupID))
        let saved = defaults.object(forKey: CandidateFontSettings.storageKey)
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.windowLevel = .alert + 1
        defer {
            window.isHidden = true
            previousWindow?.makeKey()
            if let saved {
                defaults.set(saved, forKey: CandidateFontSettings.storageKey)
            } else {
                defaults.removeObject(forKey: CandidateFontSettings.storageKey)
            }
        }
        for (name, style) in [("light", UIUserInterfaceStyle.light), ("dark", .dark)] {
            for tier in [17, 22] {
                if tier == 17 {
                    defaults.removeObject(forKey: CandidateFontSettings.storageKey)
                } else {
                    defaults.set(tier, forKey: CandidateFontSettings.storageKey)
                }
                let page = NavigationStack { CandidateFontSettingsView() }
                    .environment(\.colorScheme, style == .dark ? .dark : .light)
                let host = UIHostingController(rootView: page)
                window.overrideUserInterfaceStyle = style
                window.rootViewController = host
                window.makeKeyAndVisible()
                host.view.setNeedsLayout()
                host.view.layoutIfNeeded()
                // 等待SwiftUI完成一次渲染事务；不修改任何测试超时。
                await Task.yield()
                host.view.layoutIfNeeded()
                let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                    window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                }
                XCTAssertGreaterThan(image.size.width, 0)
                let attachment = XCTAttachment(image: image)
                attachment.name = "ui3-p6r1-preview-\(name)-tier\(tier)"
                attachment.lifetime = .keepAlways
                add(attachment)
            }
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
