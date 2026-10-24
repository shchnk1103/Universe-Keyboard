import KeyboardCore
import UIKit
import XCTest

/// 只隔离引擎 bootstrap；通过生产 appearance 回调验证字号更新发生在 didAppear 之前。
nonisolated final class CandidateFontIntegrationTests: XCTestCase {
    @MainActor
    func testDefaultFontsMatchLegacyExpressionsAcrossTraitsAndKinds() {
        for category in [
            UIContentSizeCategory.small, .large, .extraExtraExtraLarge,
            .accessibilityExtraExtraExtraLarge,
        ] {
            let traits = UITraitCollection(preferredContentSizeCategory: category)
            let snapshot = CandidateFontSnapshot(settings: CandidateFontSettings(), traits: traits)
            for kind in [CandidateKind.candidate, .composition] {
                for preferred in [false, true] {
                    let base = UIFont.systemFont(
                        ofSize: kind == .composition ? 15 : 17,
                        weight: preferred ? .semibold : .regular)
                    let expected = UIFontMetrics(forTextStyle: .body).scaledFont(
                        for: base, maximumPointSize: 28, compatibleWith: traits)
                    let actual = snapshot.titleFont(kind: kind, preferred: preferred)
                    XCTAssertEqual(actual, expected)
                }
            }
            let hint = UIFontMetrics(forTextStyle: .caption1).scaledFont(
                for: .systemFont(ofSize: 13, weight: .semibold), maximumPointSize: 18,
                compatibleWith: traits)
            XCTAssertEqual(snapshot.correctionHintFont, hint)
        }
    }

    @MainActor
    func testAllTiersRenderAndMeasureSameFontsAndFixedTiersDoNotScale() throws {
        for tier in 13...22 {
            for category in [UIContentSizeCategory.large, .accessibilityExtraExtraExtraLarge] {
                let traits = UITraitCollection(preferredContentSizeCategory: category)
                let snapshot = CandidateFontSnapshot(settings: CandidateFontSettings(savedValue: tier), traits: traits)
                for kind in [CandidateKind.candidate, .composition] {
                    for preferred in [false, true] {
                        let owner = makeOwner()
                        owner.candidateFontSnapshot = snapshot
                        let item = CandidateItem(title: "候选宽度验证长词", kind: kind)
                        owner.accumulatedCandidates = [item]
                        let collection = try XCTUnwrap(owner.candidateCollectionView)
                        // 首选语义由生产数据源决定；分别用组字/候选及索引来核对真实测量。
                        let actualPreferred = kind == .candidate
                        let cell = CandidateCollectionCell(frame: CGRect(x: 0, y: 0, width: 260, height: 46))
                        cell.configure(with: item, preferred: preferred, expanded: false, fontSnapshot: snapshot)
                        let label = try XCTUnwrap(labels(in: cell).first { $0.text == item.title })
                        if tier != 17 {
                            XCTAssertEqual(label.font.pointSize, CGFloat(tier - (kind == .composition ? 2 : 0)))
                        }
                        XCTAssertEqual(label.font, snapshot.titleFont(kind: kind, preferred: preferred))
                        let expectedFont = snapshot.titleFont(kind: kind, preferred: actualPreferred)
                        let insets: CGFloat = actualPreferred ? 16 : 24
                        let expectedWidth =
                            max(
                                44,
                                ceil(
                                    (item.title as NSString).size(
                                        withAttributes: [.font: expectedFont]).width + insets)) + 4
                        let size = owner.collectionView(
                            collection, layout: collection.collectionViewLayout,
                            sizeForItemAt: IndexPath(item: 0, section: 0))
                        XCTAssertEqual(size.width, expectedWidth)
                        XCTAssertEqual(size.height, 46)
                        collection.reloadData()
                        collection.layoutIfNeeded()
                        let rendered = try XCTUnwrap(
                            collection.cellForItem(
                                at: IndexPath(item: 0, section: 0)) as? CandidateCollectionCell)
                        XCTAssertEqual(
                            try XCTUnwrap(labels(in: rendered).first { $0.text == item.title }).font,
                            expectedFont)
                        let expanded = CandidateCollectionCell(frame: CGRect(x: 0, y: 0, width: 260, height: 42))
                        expanded.configure(with: item, preferred: preferred, expanded: true, fontSnapshot: snapshot)
                        XCTAssertEqual(
                            try XCTUnwrap(labels(in: expanded).first { $0.text == item.title }).font,
                            label.font)
                        XCTAssertEqual(expanded.bounds.height, 42)
                    }
                }
            }
        }
    }

    @MainActor
    func testAppearanceAdoptsNewTierBeforeDisplayAndInvalidatesBothCaches() throws {
        let owner = makeOwner()
        var saved: Any? = 13
        var reads = 0
        owner.candidateFontValueSource = {
            reads += 1; return saved
        }
        owner.beginAppearanceTransition(true, animated: false)
        XCTAssertEqual(owner.candidateFontSnapshot.settings.tier, 13)
        XCTAssertEqual(reads, 1)
        owner.endAppearanceTransition()
        let collection = try XCTUnwrap(owner.candidateCollectionView)
        let expanded = owner.makeExpandedCandidatePanel()
        expanded.frame = CGRect(x: 0, y: 46, width: 390, height: 208)
        owner.view.addSubview(expanded)
        expanded.layoutIfNeeded()
        let expandedCollection = try XCTUnwrap(owner.expandedCandidateCollectionView)
        owner.accumulatedCandidates = [CandidateItem(title: "字号切换前后的同一候选", kind: .candidate)]
        collection.reloadData()
        expandedCollection.reloadData()
        layout(owner)
        _ = owner.collectionView(
            collection, layout: collection.collectionViewLayout,
            sizeForItemAt: IndexPath(item: 0, section: 0))
        let stale = CGSize(width: 9999, height: 46)
        for key in owner.candidateCellSizeCache.keys { owner.candidateCellSizeCache[key] = stale }
        let barIdentity = owner.candidateBar
        let rows = owner.rootStack.arrangedSubviews.map(ObjectIdentifier.init)
        let request = owner.keyboardHeightConstraint
        let rowHeight = owner.keyHeight
        owner.beginAppearanceTransition(false, animated: false)
        owner.endAppearanceTransition()
        saved = 22
        // 在下次出现前重新设置候选；消失清理不被当成字号缓存失效的证据。
        owner.accumulatedCandidates = [CandidateItem(title: "字号切换前后的同一候选", kind: .candidate)]
        let cacheKey = CandidateCellSizeCacheKey(
            isExpanded: false, isPreferred: true,
            collectionWidth: 390, kindRawValue: CandidateKind.candidate.rawValue,
            title: "字号切换前后的同一候选", correctionHint: nil,
            fontTier: 13, contentSizeCategory: UIContentSizeCategory.large.rawValue)
        for view in [collection, expandedCollection] {
            view.reloadData()
            view.layoutIfNeeded()
        }
        let oldLabels = try [collection, expandedCollection].map { view -> UILabel in
            let cell = try XCTUnwrap(view.cellForItem(at: IndexPath(item: 0, section: 0)))
            return try XCTUnwrap(labels(in: cell).first { $0.text == "字号切换前后的同一候选" })
        }
        XCTAssertEqual(oldLabels.map { $0.font.pointSize }, [13, 13])
        owner.candidateCellSizeCache[cacheKey] = stale
        owner.beginAppearanceTransition(true, animated: false)
        XCTAssertEqual(oldLabels.map { $0.font.pointSize }, [22, 22])
        // 不等 didAppear：此时已采用22，且没有重建整盘或改变UI-4约束。
        XCTAssertEqual(owner.candidateFontSnapshot.settings.tier, 22)
        XCTAssertEqual(reads, 2)
        XCTAssertFalse(owner.candidateCellSizeCache.values.contains(stale))
        XCTAssertTrue(owner.candidateBar === barIdentity)
        XCTAssertEqual(owner.rootStack.arrangedSubviews.map(ObjectIdentifier.init), rows)
        XCTAssertTrue(owner.keyboardHeightConstraint === request)
        XCTAssertEqual(owner.keyHeight, rowHeight)
        XCTAssertEqual(owner.view.alpha, 1)
        for view in [collection, expandedCollection] {
            view.layoutIfNeeded()
            let cell = try XCTUnwrap(
                view.cellForItem(
                    at: IndexPath(item: 0, section: 0)) as? CandidateCollectionCell)
            XCTAssertEqual(try XCTUnwrap(labels(in: cell).first { $0.text == "字号切换前后的同一候选" }).font.pointSize, 22)
        }
        owner.endAppearanceTransition()
        owner.beginAppearanceTransition(false, animated: false)
        owner.endAppearanceTransition()
    }

    @MainActor
    func testProductionBootstrapThenWillAppearReadsOnlyOnceBeforeCoreExists() throws {
        let owner = KeyboardViewController()
        let suite = "UI3-Cold-Bootstrap-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        owner.sharedDefaults = defaults
        owner.keyboardRowHeightSource = { nil }
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        var reads = 0
        owner.candidateFontValueSource = { [weak owner] in
            reads += 1
            XCTAssertNil(owner?.controller)
            return 22
        }
        owner.loadViewIfNeeded()
        XCTAssertEqual(reads, 1)
        XCTAssertEqual(owner.candidateFontSnapshot.settings.tier, 22)
        owner.beginAppearanceTransition(true, animated: false)
        XCTAssertEqual(reads, 1)
        XCTAssertTrue(owner.isKeyboardUIInstalled)
        owner.endAppearanceTransition()
        owner.beginAppearanceTransition(false, animated: false)
        owner.endAppearanceTransition()
    }

    @MainActor
    func testInjectedPreferenceStorageDeletionAndInvalidObjectsFallBackOnNextAppearance() throws {
        let suite = "UI3-Preference-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let owner = makeOwner()
        owner.sharedDefaults = defaults
        for raw: Any? in [22, nil, true, 18.0, "22", 12, 23, 13] {
            if let raw {
                defaults.set(raw, forKey: CandidateFontSettings.storageKey)
            } else {
                defaults.removeObject(forKey: CandidateFontSettings.storageKey)
            }
            owner.beginAppearanceTransition(true, animated: false)
            let expected = CandidateFontSettings(savedValue: raw)
            XCTAssertEqual(owner.candidateFontSnapshot.settings, expected)
            // 输入周期内再次保存不生效，只有下一次出现才读取。
            defaults.set(19, forKey: CandidateFontSettings.storageKey)
            owner.viewWillAppear(false)
            XCTAssertEqual(owner.candidateFontSnapshot.settings, expected)
            owner.endAppearanceTransition()
            owner.beginAppearanceTransition(false, animated: false)
            owner.endAppearanceTransition()
        }
    }

    @MainActor
    func testWillAppearUpdatesTraitsFromPrecreatedSnapshotWithoutRereadingTier() {
        let owner = makeOwner()
        var reads = 0
        owner.candidateFontValueSource = {
            reads += 1; return 17
        }
        owner.traitOverrides.preferredContentSizeCategory = .large
        owner.beginAppearanceTransition(true, animated: false)
        let original = owner.candidateFontSnapshot.titleFont(kind: .candidate, preferred: true)
        owner.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        owner.viewWillAppear(false)
        XCTAssertEqual(reads, 1)
        XCTAssertEqual(
            owner.candidateFontSnapshot.traits.preferredContentSizeCategory,
            .accessibilityExtraExtraExtraLarge)
        XCTAssertGreaterThan(
            owner.candidateFontSnapshot.titleFont(kind: .candidate, preferred: true).pointSize,
            original.pointSize)
        owner.endAppearanceTransition()
        owner.beginAppearanceTransition(false, animated: false)
        owner.endAppearanceTransition()
    }

    @MainActor
    func testReentrantWillAppearReadsOnceAndBadStorageFallsBack() {
        for raw: Any? in [nil, true, 18.0, "22", 12, 23, NSNull()] {
            let owner = makeOwner()
            var reads = 0
            owner.candidateFontValueSource = {
                reads += 1; return raw
            }
            owner.beginAppearanceTransition(true, animated: false)
            owner.viewWillAppear(false)
            XCTAssertEqual(reads, 1)
            XCTAssertEqual(owner.candidateFontSnapshot.settings, CandidateFontSettings())
            owner.endAppearanceTransition()
            owner.beginAppearanceTransition(false, animated: false)
            owner.endAppearanceTransition()
        }
    }

    @MainActor
    private func makeOwner() -> FontLifecycleController {
        let owner = FontLifecycleController()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 254)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.isKeyboardUIInstalled = true
        layout(owner)
        return owner
    }

    @MainActor
    private func layout(_ owner: KeyboardViewController) {
        owner.view.setNeedsLayout()
        owner.view.layoutIfNeeded()
        owner.rootStack.layoutIfNeeded()
    }

    @MainActor
    private func labels(in view: UIView) -> [UILabel] {
        (view as? UILabel).map { [$0] } ?? view.subviews.flatMap { labels(in: $0) }
    }
}

@MainActor
private final class FontLifecycleController: KeyboardViewController {
    override func viewDidLoad() { /* 隔离RIME与共享环境；保留生产loadView和appearance回调。 */  }
}
