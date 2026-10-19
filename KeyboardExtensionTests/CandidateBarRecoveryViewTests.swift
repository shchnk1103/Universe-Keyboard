import KeyboardCore
import UIKit
import XCTest

/// Compiles and instantiates the production bar and its real cells.
/// It does not activate a Keyboard Extension or manufacture a Core recovery.
nonisolated final class CandidateBarRecoveryViewTests: XCTestCase {
    @MainActor
    func testRecoveryNoticeKeepsRowAndCollectionGeometry() throws {
        for width in [320.0, 390.0, 430.0] {
            let fixture = Fixture(width: width)
            let originalHeight = fixture.bar.bounds.height
            let originalCollectionFrame = fixture.bar.collectionView.frame
            let originalExpandWidth = fixture.bar.expandButtonWidthConstraint.constant
            for message in [
                "输入恢复中，可继续输入或按删除重试",
                "输入恢复失败，按删除取消本段后重试",
                "当前拼音已取消，请重新输入",
            ] {
                fixture.bar.setInputRecoveryNotice(message)
                fixture.container.layoutIfNeeded()
                let label = try fixture.noticeLabel()
                XCTAssertEqual(fixture.bar.bounds.height, originalHeight)
                XCTAssertEqual(fixture.bar.collectionView.frame, originalCollectionFrame)
                XCTAssertEqual(fixture.bar.expandButtonWidthConstraint.constant, originalExpandWidth)
                XCTAssertEqual(label.text, message)
                XCTAssertEqual(label.accessibilityLabel, message)
                XCTAssertTrue(label.isAccessibilityElement)
                XCTAssertFalse(label.isHidden)
                XCTAssertTrue(fixture.bar.bounds.contains(label.frame))
            }
            fixture.bar.setInputRecoveryNotice(nil)
            fixture.container.layoutIfNeeded()
            XCTAssertEqual(fixture.bar.bounds.height, originalHeight)
            XCTAssertEqual(fixture.bar.collectionView.frame, originalCollectionFrame)
            XCTAssertTrue(try fixture.noticeLabel().isHidden)
            XCTAssertNil(try fixture.noticeLabel().accessibilityLabel)
        }
    }

    @MainActor
    func testRecoveryRoutesRealCandidateAndExpandHitsToBarThenRestores() throws {
        let fixture = Fixture(width: 390)
        let cell = try XCTUnwrap(fixture.bar.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)))
        let candidatePoint = fixture.bar.convert(
            CGPoint(x: cell.bounds.midX, y: cell.bounds.midY), from: cell)
        let expandPoint = fixture.bar.expandButton.center
        let originalHit = try XCTUnwrap(fixture.bar.hitTest(candidatePoint, with: nil))
        XCTAssertTrue(originalHit.isDescendant(of: fixture.bar.collectionView))
        XCTAssertTrue(fixture.bar.hitTest(expandPoint, with: nil) === fixture.bar.expandButton)

        fixture.bar.setInputRecoveryNotice("输入恢复失败，按删除取消本段后重试")
        XCTAssertTrue(fixture.bar.hitTest(candidatePoint, with: nil) === fixture.bar)
        XCTAssertTrue(fixture.bar.hitTest(expandPoint, with: nil) === fixture.bar)
        // A hidden chevron must not retain its out-of-row touch extension.
        let outsidePoint = CGPoint(x: expandPoint.x, y: fixture.bar.bounds.maxY + 4)
        XCTAssertFalse(fixture.bar.point(inside: outsidePoint, with: nil))
        XCTAssertNil(fixture.bar.hitTest(outsidePoint, with: nil))

        fixture.bar.setInputRecoveryNotice(nil)
        let restoredHit = try XCTUnwrap(fixture.bar.hitTest(candidatePoint, with: nil))
        XCTAssertTrue(restoredHit.isDescendant(of: fixture.bar.collectionView))
        XCTAssertTrue(fixture.bar.hitTest(expandPoint, with: nil) === fixture.bar.expandButton)
    }

    @MainActor
    func testRecoveryDisablesGesturesAndCollectionUntilNoticeRemoved() {
        let fixture = Fixture(width: 390)
        fixture.bar.allowsSwipeToExpand = true
        fixture.bar.setInputRecoveryNotice("输入恢复中，可继续输入或按删除重试")
        XCTAssertTrue(fixture.bar.collectionView.isHidden)
        XCTAssertFalse(fixture.bar.collectionView.isUserInteractionEnabled)
        XCTAssertTrue(fixture.bar.expandButton.isHidden)
        XCTAssertFalse(fixture.bar.expandButton.isEnabled)
        XCTAssertFalse(fixture.bar.gestureRecognizers?.isEmpty ?? true)
        XCTAssertTrue(fixture.bar.gestureRecognizers?.allSatisfy { !$0.isEnabled } == true)

        fixture.bar.setInputRecoveryNotice(nil)
        XCTAssertFalse(fixture.bar.collectionView.isHidden)
        XCTAssertTrue(fixture.bar.collectionView.isUserInteractionEnabled)
        XCTAssertFalse(fixture.bar.expandButton.isHidden)
        XCTAssertTrue(fixture.bar.expandButton.isEnabled)
        XCTAssertTrue(fixture.bar.gestureRecognizers?.allSatisfy { $0.isEnabled } == true)
    }

    @MainActor
    func testNoticeUsesSemanticTextColorInBothAppearances() throws {
        let fixture = Fixture(width: 390)
        fixture.bar.setInputRecoveryNotice("当前拼音已取消，请重新输入")
        let label = try fixture.noticeLabel()
        let textColor = try XCTUnwrap(label.textColor)
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            XCTAssertEqual(textColor.resolvedColor(with: traits), UIColor.secondaryLabel.resolvedColor(with: traits))
            XCTAssertNotEqual(
                textColor.resolvedColor(with: traits), UIColor.systemBackground.resolvedColor(with: traits))
        }
    }

    @MainActor
    private final class Fixture: NSObject, UICollectionViewDataSource {
        let container: UIView
        let bar: CandidateBarView

        init(width: CGFloat) {
            container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 60))
            bar = CandidateBarView(
                height: 40, bottomHitExtension: 4, backgroundColor: .clear,
                interactionTarget: nil, expandAction: #selector(expand))
            super.init()
            bar.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(bar)
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                bar.topAnchor.constraint(equalTo: container.topAnchor),
            ])
            bar.collectionView.dataSource = self
            (bar.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize =
                CGSize(width: 100, height: 40)
            container.layoutIfNeeded()
            bar.collectionView.reloadData()
            bar.collectionView.layoutIfNeeded()
        }

        func noticeLabel() throws -> UILabel {
            try XCTUnwrap(
                bar.subviews.compactMap { $0 as? UILabel }.first {
                    $0.accessibilityIdentifier == "t9.input-recovery.notice"
                })
        }

        @objc private func expand() {}

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

        func collectionView(
            _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CandidateCollectionCell.barReuseIdentifier, for: indexPath)
            (cell as? CandidateCollectionCell)?.configure(
                with: CandidateItem(title: "因此", kind: .candidate), preferred: true, expanded: false)
            return cell
        }
    }
}
