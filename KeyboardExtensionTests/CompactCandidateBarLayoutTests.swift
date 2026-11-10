import KeyboardCore
import UIKit
import XCTest

/// Real UIKit geometry and hit routing, independent of engine/session fixtures.
nonisolated final class CompactCandidateBarLayoutTests: XCTestCase {
    @MainActor
    func testViewportAndActionZoneHaveDisjointFullHeightTouchAreas() throws {
        for width in [320.0, 390.0, 430.0] {
            let f = Fixture(width: width)
            XCTAssertEqual(f.bar.bounds.height, 46)
            XCTAssertEqual(f.bar.collectionView.bounds.height, f.bar.bounds.height)
            XCTAssertEqual(f.bar.expandButton.frame, CGRect(x: width - 56, y: 0, width: 56, height: 46))
            XCTAssertEqual(f.bar.collectionView.frame.maxX, f.bar.expandButton.frame.minX)
            let separator = try Self.actionSeparator(in: f.bar)
            XCTAssertLessThanOrEqual(f.bar.collectionView.frame.maxX, separator.frame.minX + 0.01)
            XCTAssertEqual(
                separator.frame.width, 1.0 / max(f.bar.traitCollection.displayScale, 1), accuracy: 0.01)
            Self.assertSeparatorHeight(separator, in: f.bar)
            XCTAssertTrue(f.bar.collectionView.clipsToBounds)
            XCTAssertEqual(f.bar.collectionView.contentInset, .zero)
            XCTAssertGreaterThanOrEqual(f.bar.expandButton.bounds.height, 44)
            for y in [1.0, 23.0, 45.0] {
                let candidatePoint = CGPoint(x: f.bar.collectionView.frame.maxX - 1, y: y)
                let hit = try XCTUnwrap(f.bar.hitTest(candidatePoint, with: nil))
                XCTAssertTrue(hit === f.bar.collectionView || hit.isDescendant(of: f.bar.collectionView))
                XCTAssertTrue(f.bar.hitTest(CGPoint(x: width - 1, y: y), with: nil) === f.bar.expandButton)
            }
            XCTAssertNil(f.bar.hitTest(CGPoint(x: width - 20, y: 47), with: nil))
        }
    }

    @MainActor
    func testLastCandidateCanScrollEntirelyIntoViewportWithoutDuplicateReservation() throws {
        let f = Fixture(width: 320)
        let collection = f.bar.collectionView
        collection.setContentOffset(
            CGPoint(x: max(0, collection.contentSize.width - collection.bounds.width), y: 0), animated: false)
        collection.layoutIfNeeded()
        let last = try XCTUnwrap(collection.layoutAttributesForItem(at: IndexPath(item: 9, section: 0)))
        XCTAssertTrue(collection.bounds.contains(last.frame))
        XCTAssertEqual(collection.bounds.maxX - last.frame.maxX, 8, accuracy: 0.01)
        XCTAssertEqual(last.frame.height, 46)
        XCTAssertTrue(collection.isScrollEnabled)
    }

    @MainActor
    func testCandidateLabelsFitAtLargestSupportedSizeAndExpandedHeightStaysIndependent() throws {
        let f = Fixture(width: 390)
        for category in [UIContentSizeCategory.large, .accessibilityExtraExtraExtraLarge] {
            f.host.traitOverrides.preferredContentSizeCategory = category
            f.bar.collectionView.reloadData()
            f.host.view.layoutIfNeeded()
            f.bar.collectionView.layoutIfNeeded()
            let cell = try XCTUnwrap(f.bar.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
            for label in descendants(of: cell).compactMap({ $0 as? UILabel }) where !label.isHidden {
                XCTAssertGreaterThanOrEqual(label.bounds.height + 0.5, label.font.lineHeight)
                XCTAssertLessThanOrEqual(label.font.pointSize, 28)
            }
        }
        let expanded = CandidateCollectionCell(frame: CGRect(x: 0, y: 0, width: 120, height: 42))
        expanded.configure(with: CandidateItem(title: "展开候选", kind: .candidate), preferred: true, expanded: true)
        expanded.layoutIfNeeded()
        XCTAssertEqual(expanded.bounds.height, 42)
    }

    @MainActor
    func testRecoveryHidesSeparatorWithTheActionButton() throws {
        let f = Fixture(width: 390)
        let separator = try Self.actionSeparator(in: f.bar)
        f.bar.setCanExpandCandidates(true)
        XCTAssertFalse(f.bar.expandButton.isHidden)
        XCTAssertFalse(separator.isHidden)
        XCTAssertFalse(separator.isUserInteractionEnabled)
        XCTAssertFalse(separator.isAccessibilityElement)
        f.bar.setInputRecoveryNotice("输入恢复失败，按删除取消本段后重试")
        XCTAssertTrue(separator.isHidden)
        XCTAssertTrue(f.bar.expandButton.isHidden)
        XCTAssertFalse(f.bar.expandButton.isEnabled)
        XCTAssertTrue(f.bar.hitTest(CGPoint(x: 380, y: 23), with: nil) === f.bar)
        f.bar.setInputRecoveryNotice(nil)
        f.bar.setCanExpandCandidates(false)
        XCTAssertFalse(separator.isHidden)
        XCTAssertFalse(f.bar.expandButton.isHidden)
        XCTAssertTrue(f.bar.expandButton.isEnabled)
    }

    @MainActor
    func testCompactActionUsesChevronAndSeparatorWithoutMaterialOrGradient() throws {
        let f = Fixture(width: 390)
        let configuration = UIImage.SymbolConfiguration(
            pointSize: KeyboardDesignTokens.CandidateBar.actionSymbolSize, weight: .medium)
        let expected = UIImage(systemName: "chevron.down", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)
        for expanding in [false, true] {
            let image = CandidateBarView.trailingChromeImage(expanding: expanding)
            XCTAssertEqual(image?.pngData(), expected?.pngData())
        }
        for style in [UIUserInterfaceStyle.light, .dark] {
            f.host.traitOverrides.userInterfaceStyle = style
            f.bar.layoutIfNeeded()
            for canExpand in [false, true] {
                f.bar.setCanExpandCandidates(canExpand)
                f.host.view.layoutIfNeeded()
                XCTAssertNil(f.bar.subviews.first { $0.accessibilityIdentifier == "candidateActionTint" })
                XCTAssertNil(f.bar.subviews.first { $0.accessibilityIdentifier == "candidateActionMaterial" })
                XCTAssertTrue(f.bar.subviews.compactMap { $0 as? UIVisualEffectView }.isEmpty)
                XCTAssertTrue(
                    f.bar.layer.sublayers?.compactMap { $0 as? CAGradientLayer }.isEmpty ?? true)
                let separator = try Self.actionSeparator(in: f.bar)
                XCTAssertFalse(separator.isHidden)
                XCTAssertFalse(f.bar.expandButton.isHidden)
                XCTAssertTrue(f.bar.expandButton.isEnabled)
                XCTAssertEqual(f.bar.expandButton.frame.size, CGSize(width: 56, height: 46))
                XCTAssertTrue(f.bar.hitTest(CGPoint(x: 389, y: 23), with: nil) === f.bar.expandButton)
                XCTAssertLessThanOrEqual(f.bar.collectionView.frame.maxX, separator.frame.minX + 0.01)
                XCTAssertEqual(
                    separator.frame.width, 1.0 / max(f.bar.traitCollection.displayScale, 1), accuracy: 0.01)
                Self.assertSeparatorHeight(separator, in: f.bar)
                XCTAssertEqual(
                    separator.backgroundColor?.resolvedColor(with: f.bar.traitCollection).cgColor,
                    UIColor.separator.resolvedColor(with: f.bar.traitCollection).cgColor)
            }
        }
    }

    @MainActor
    private static func actionSeparator(in bar: CandidateBarView) throws -> UIView {
        try XCTUnwrap(bar.subviews.first { $0.accessibilityIdentifier == "candidateActionSeparator" })
    }

    @MainActor
    private static func assertSeparatorHeight(_ separator: UIView, in bar: CandidateBarView) {
        let scale = max(bar.traitCollection.displayScale, 1)
        let expected =
            KeyboardDesignTokens.CandidateBar.totalHeight
            * KeyboardDesignTokens.CandidateBar.actionSeparatorHeightRatio
        // Auto Layout pixel-aligns the multiplier constraint; allow one physical pixel.
        XCTAssertEqual(separator.frame.height, expected, accuracy: 1.0 / scale + 0.01)
        XCTAssertEqual(
            abs(separator.center.y - bar.bounds.midY), 0, accuracy: 1.0 / scale + 0.01)
    }

    @MainActor
    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }

    @MainActor
    private final class Fixture: NSObject, UICollectionViewDataSource {
        let host: UIViewController
        let window: UIWindow
        let bar: CandidateBarView

        init(width: CGFloat) {
            host = UIViewController()
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 46))
            window.rootViewController = host
            window.makeKeyAndVisible()
            host.view.frame = CGRect(x: 0, y: 0, width: width, height: 46)
            host.view.backgroundColor = KeyboardDesignTokens.CandidateActionAppearance.backgroundColor
            bar = CandidateBarView(
                backgroundColor: .clear, interactionTarget: nil, expandAction: NSSelectorFromString("unused"))
            super.init()
            bar.translatesAutoresizingMaskIntoConstraints = false
            host.view.addSubview(bar)
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: host.view.trailingAnchor),
                bar.topAnchor.constraint(equalTo: host.view.topAnchor),
            ])
            bar.collectionView.dataSource = self
            (bar.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize =
                CGSize(width: 100, height: KeyboardDesignTokens.CandidateBar.normalCellHeight)
            host.view.layoutIfNeeded()
            bar.collectionView.reloadData()
            bar.collectionView.layoutIfNeeded()
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 10 }

        func collectionView(
            _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CandidateCollectionCell.barReuseIdentifier, for: indexPath)
            (cell as? CandidateCollectionCell)?.configure(
                with: CandidateItem(title: indexPath.item == 0 ? "你好" : "候选\(indexPath.item)", kind: .candidate),
                preferred: indexPath.item == 0, expanded: false)
            return cell
        }
    }
}
