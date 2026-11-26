import UIKit
import XCTest

@testable import KeyboardCore

/// Real chrome: layout table, space long-press, shortcut strip. No UIKit frames.
nonisolated final class T9NumberPadChromeTests: XCTestCase {
    @MainActor
    func testNumbersChromeMatchesLayoutTableAndKeepsSpaceLongPress() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let host = try XCTUnwrap(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.first)
        XCTAssertEqual(host.touchColumns.count, 3)
        XCTAssertEqual(host.touchColumns.map { $0.rows.count }, [4, 4, 3])
        XCTAssertEqual(host.touchColumns[1].rows.map(\.count), [3, 3, 3, 3])

        let leftTitles = host.touchColumns[0].rows.map { $0.map { $0.currentTitle ?? "" } }
        XCTAssertEqual(leftTitles, [["@"], ["+"], ["-"], ["#+="]])
        let middleTitles = host.touchColumns[1].rows.map { $0.map { $0.currentTitle ?? "" } }
        XCTAssertEqual(middleTitles, [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["返回", "0", "."]])

        let delete = host.touchColumns[2].rows[0][0]
        XCTAssertEqual(delete.accessibilityIdentifier, "delete")
        let space = host.touchColumns[2].rows[1][0]
        XCTAssertEqual(space.accessibilityIdentifier, " ")
        let spaceActions = space.actions(forTarget: sut, forControlEvent: .touchUpInside) ?? []
        XCTAssertTrue(spaceActions.contains("insertT9NumberPadLiteral:"))
        XCTAssertFalse(spaceActions.contains("insertSpace:"))
        let longPresses =
            space.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer } ?? []
        XCTAssertEqual(longPresses.count, 1)
        XCTAssertTrue(
            String(describing: longPresses[0]).contains("handleSpaceCursorLongPress:"),
            String(describing: longPresses[0]))
        XCTAssertTrue(sut.returnButton === host.touchColumns[2].rows[2][0])
        let returnElsewhere = host.touchColumns.enumerated().flatMap { column, touch in
            touch.rows.enumerated().flatMap { row, keys in
                keys.compactMap { key in
                    key === sut.returnButton && (column != 2 || row != 2) ? key : nil
                }
            }
        }
        XCTAssertTrue(returnElsewhere.isEmpty)
        let titles = host.touchColumns.flatMap(\.rows).flatMap { $0 }.map { $0.currentTitle ?? "" }
        for banned in ["😊", "选拼音", "ABC", "DEF"] {
            XCTAssertFalse(titles.contains(banned), banned)
        }
    }

    // MARK: - PB-009-SHORTCUT-BAR-REUSE-001（快捷栏复用原候选栏 collectionView）

    /// 数字页快捷栏不再有独立 UIScrollView 叠层，直接喂进原候选栏管线。
    @MainActor
    func testShortcutStripFeedsNativeCandidatesOnNumbersPage() throws {
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        let textClient = FakeTextInputClient()
        sut.controller.textClient = textClient
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.layoutIfNeeded()

        // 无旧叠层；原 collectionView 可见、可交互，条目即快捷符号
        XCTAssertNil(bar.subviews.first { $0.accessibilityIdentifier == "numberPadShortcuts" })
        XCTAssertFalse(bar.collectionView.isHidden)
        XCTAssertTrue(bar.collectionView.isUserInteractionEnabled)
        XCTAssertTrue(sut.isT9NumberPadShortcutStripActive)
        XCTAssertEqual(
            bar.collectionView.numberOfItems(inSection: 0), T9NumberPadLayout.shortcutSymbols.count)
        // T9-NUMPAD-SHORTCUTS-EXPAND-001 r4：18 项超出候选栏单屏宽度，
        // 逐项滚动进视口再断言（cellForItem 只对已 materialize 的 cell 非 nil）。
        for (index, symbol) in T9NumberPadLayout.shortcutSymbols.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            bar.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            bar.layoutIfNeeded()
            let cell = try XCTUnwrap(
                bar.collectionView.cellForItem(at: indexPath),
                "missing visible cell for \(symbol)")
            XCTAssertEqual(firstLabelText(in: cell), symbol)
        }

        // 点击候选栏第 0 项 → 数字页字面量上屏，而非 insertCandidate 引擎选择
        var seen: [KeyboardAction] = []
        sut.controller.onActionObserved = { seen.append($0) }
        sut.collectionView(bar.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(seen, [.insertT9NumberPadText("/")])
        XCTAssertEqual(textClient.text, "/")
        XCTAssertFalse(
            seen.contains { action in
                if case .insertCandidate = action { return true }
                return false
            })

        // 有组合时恢复普通候选显示
        sut.controller.state.currentComposition = "ni"
        sut.refreshCandidateBar()
        XCTAssertFalse(sut.isT9NumberPadShortcutStripActive)
        XCTAssertFalse(bar.collectionView.isHidden)
        XCTAssertTrue(bar.collectionView.isUserInteractionEnabled)

        // 回到空组合无缝恢复快捷栏
        sut.controller.state.currentComposition = ""
        sut.refreshCandidateBar()
        XCTAssertTrue(sut.isT9NumberPadShortcutStripActive)
        XCTAssertEqual(
            bar.collectionView.numberOfItems(inSection: 0), T9NumberPadLayout.shortcutSymbols.count)
    }

    /// PB-021-NUMPAD-SWIPE-EXPAND-001 问题①：pageChanged 等整建路径重建候选栏后，
    /// 数字快捷栏激活态的新 bar 必须携带 `allowsSwipeToExpand`（否则下滑展开完全失效）。
    @MainActor
    func testRebuiltCandidateBarKeepsSwipeToExpandWhileShortcutStripActive() throws {
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        // 首次整建即走 makeCandidateBar → refreshPasteToolbar(on:) 路径，快捷栏激活。
        XCTAssertTrue(sut.isT9NumberPadShortcutStripActive)
        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        XCTAssertTrue(bar.allowsSwipeToExpand, "快捷栏激活时重建的候选栏必须允许下滑展开")

        // 切回中文页：快捷栏去激活、无候选 → 旗标必须为 false（口径下限）。
        sut.controller.state.currentPage = .letters
        sut.reloadKeyboard()
        XCTAssertFalse(sut.isT9NumberPadShortcutStripActive)
        let lettersBar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        XCTAssertFalse(lettersBar.allowsSwipeToExpand)

        // 再切数字页：pageChanged 重建，快捷栏重新激活，新 bar 旗标必须恢复 true。
        sut.controller.state.currentPage = .numbers
        sut.reloadKeyboard()
        XCTAssertTrue(sut.isT9NumberPadShortcutStripActive)
        let rebuilt = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        XCTAssertFalse(rebuilt === lettersBar, "pageChanged 应整建候选栏")
        XCTAssertTrue(rebuilt.allowsSwipeToExpand, "重建后的新 bar 旗标漏置即复现下滑展开失效")
    }

    /// 复用后走原生 UICollectionView 滚动（不再依赖叠层 UIScrollView）。
    /// bar 宽度由约束主导，因此用窄窗口验证内容超宽时的原生滚动。
    @MainActor
    func testShortcutStripScrollsNatively() throws {
        let (sut, window) = try makeWindowedKeyboard(width: 300)
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.layoutIfNeeded()
        let collection = bar.collectionView
        XCTAssertGreaterThan(collection.contentSize.width, collection.bounds.width)
        collection.setContentOffset(CGPoint(x: 30, y: 0), animated: false)
        XCTAssertEqual(collection.contentOffset.x, 30, accuracy: 0.1)
    }

    /// 命中测试路由到原生候选 cell（点击高亮与手势桥全继承）。
    @MainActor
    func testShortcutStripHitRoutesToCollectionViewCell() throws {
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.frame = CGRect(x: 0, y: 0, width: 390, height: 46)
        bar.layoutIfNeeded()
        let cell = try XCTUnwrap(bar.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
        let point = cell.convert(CGPoint(x: cell.bounds.midX, y: cell.bounds.midY), to: bar)
        let hit = bar.hitTest(point, with: nil)
        XCTAssertTrue(
            hit === cell || (hit?.isDescendant(of: cell) ?? false),
            "hit=\(String(describing: hit)) point=\(point) cell=\(cell.frame) bar=\(bar.bounds)")
    }

    /// 复用后快捷条目由 CandidateCollectionCell 原生管线渲染（清晰度一致性）。
    @MainActor
    func testShortcutStripRendersThroughCandidateCollectionCell() throws {
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.layoutIfNeeded()
        let cell = try XCTUnwrap(bar.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
        XCTAssertTrue(cell is CandidateCollectionCell)
        XCTAssertEqual(firstLabelText(in: cell), "/")
    }

    /// 展开态同样复用候选管线：面板集合显示符号，点击上屏并收起面板。
    @MainActor
    func testShortcutStripExpandedPanelShowsSymbolsAndTapCollapses() throws {
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(true) }

        sut.handleCandidateBarTrailingButton()
        XCTAssertTrue(sut.isCandidateExpanded)
        let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
        XCTAssertNil(
            panel.revealViewport.subviews.first {
                $0.accessibilityIdentifier == "t9NumberPadExpandedShortcuts"
            }, "旧叠层行不应再安装")
        let collection = try XCTUnwrap(sut.expandedCandidateCollectionView)
        XCTAssertEqual(
            collection.numberOfItems(inSection: 0), T9NumberPadLayout.shortcutSymbols.count)

        var seen: [KeyboardAction] = []
        sut.controller.onActionObserved = { seen.append($0) }
        sut.collectionView(collection, didSelectItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(seen, [.insertT9NumberPadText("/")])
        XCTAssertFalse(sut.isCandidateExpanded)
    }

    @MainActor
    func testNumberPadPreferencePersistsAcrossKeyboardInstances() throws {
        let suite = "T9NumberPadChromeTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: "twenty_six_key_number_pad_enabled")
        let sut = try installedKeyboard()
        sut.sharedDefaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        sut.refreshCachedSettings()
        sut.controller.state.inputMode = .chinese
        sut.cachedLayoutStyle = .twentySixKey
        sut.controller.state.currentPage = .numbers
        sut.reloadKeyboard()
        XCTAssertFalse(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

    @MainActor
    func testTwentySixKeyNumberPadDefaultsOff() throws {
        let sut = try installedKeyboard()
        let suite = "T9NumberPadChromeTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        sut.sharedDefaults = defaults
        sut.refreshCachedSettings()
        sut.cachedLayoutStyle = .twentySixKey
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.reloadKeyboard()
        XCTAssertTrue(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

    @MainActor
    func testTwentySixKeyNumberPadSettingRoutesAndReturns() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.cachedLayoutStyle = .twentySixKey
        sut.cachedT9ReadinessMatched = false
        let suite = "T9NumberPadChromeTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: "twenty_six_key_number_pad_enabled")
        sut.sharedDefaults = defaults
        sut.refreshCachedSettings()
        sut.cachedLayoutStyle = .twentySixKey
        sut.controller.state.currentPage = .numbers
        sut.reloadKeyboard()
        XCTAssertFalse(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
        sut.controller.state.currentPage = .letters
        sut.reloadKeyboard()
        XCTAssertTrue(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

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

    /// 带窗口挂载的键盘（候选 cell 可见性测试需要真实布局）。
    /// 调用方负责 `defer { window.isHidden = true }`。
    @MainActor
    private func makeWindowedKeyboard(width: CGFloat = 390) throws -> (
        sut: KeyboardViewController, window: UIWindow
    ) {
        let sut = KeyboardViewController()
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(x: 0, y: 0, width: width, height: 300)
        sut.keyboardRowHeightSource = { 45 }
        sut.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        sut.prepareKeyboardHeightForAppearance()
        sut.installPreferredKeyboardHeight()
        sut.installKeyboardUIIfNeeded()
        _ = try XCTUnwrap(sut.rootStack)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 300))
        window.rootViewController = sut
        window.makeKeyAndVisible()
        sut.view.layoutIfNeeded()
        return (sut, window)
    }

    /// 递归读取 `UILabel.text` 与 `UIView.subviews`——两者均为主 actor 隔离属性，
    /// 调用方（各 `@MainActor` 测试方法）均在主线程，故本辅助函数同样限定 `@MainActor`
    /// 以通过 Swift 6 严格并发检查（CI Xcode 26.6 编译期报错点）。
    @MainActor
    private func firstLabelText(in view: UIView?) -> String? {
        guard let view else { return nil }
        if let label = view as? UILabel, !(label.text ?? "").isEmpty { return label.text }
        for subview in view.subviews {
            if let text = firstLabelText(in: subview) { return text }
        }
        return nil
    }
}
