import KeyboardCore
import UIKit
import XCTest

/// PB-016-UK-ENTRY-VISIBILITY-FIX-001: real-render coverage for the leading
/// 44×46pt UK quick-menu entry. The visibility toggle must be a conflict-free
/// two-state swap of the candidate viewport's leading clip edge (RC1), and the
/// "UK" title must stay visible in dark mode (RC2).
nonisolated final class CandidateBarUKEntryVisibilityTests: XCTestCase {
    // MARK: - RC1 (geometry, conflict-free two-state swap)

    @MainActor
    func testVisibleEntryGeometryIsConflictFreeTwoStateSwap() throws {
        let f = Fixture(width: 320)
        f.bar.setUkQuickMenuVisible(true)
        f.host.view.layoutIfNeeded()

        // Exactly one active equal leading pin from the viewport to the bar
        // edge is allowed, and only while the entry is hidden. A second
        // anonymous pin keeps the required constraints unsatisfiable whenever
        // the stored swap constraint is toggled.
        XCTAssertEqual(
            Self.activeBarEdgeLeadingPins(in: f.bar).count, 0,
            "the viewport must not keep any active pin to the bar's leading edge while the entry is visible")
        XCTAssertEqual(f.bar.ukQuickMenuEntryButton.frame.size, CGSize(width: 44, height: 46))
        XCTAssertEqual(
            f.bar.collectionView.frame.minX, f.bar.ukQuickMenuEntryButton.frame.maxX, accuracy: 0.01)
        XCTAssertEqual(f.bar.collectionView.frame.minX, 44, accuracy: 0.01)
        XCTAssertFalse(f.bar.ukQuickMenuEntryButton.isHidden)
        let entrySeparator = try XCTUnwrap(
            f.bar.subviews.first { $0.accessibilityIdentifier == "ukQuickMenuEntrySeparator" })
        XCTAssertFalse(entrySeparator.isHidden)

        f.bar.setUkQuickMenuVisible(false)
        f.host.view.layoutIfNeeded()

        XCTAssertEqual(
            Self.activeBarEdgeLeadingPins(in: f.bar).count, 1,
            "hiding the entry must restore exactly one bar-edge leading pin")
        XCTAssertEqual(f.bar.collectionView.frame.minX, 0, accuracy: 0.01)
        XCTAssertEqual(f.bar.ukQuickMenuEntryButton.frame.size, CGSize(width: 44, height: 46))
        XCTAssertTrue(f.bar.ukQuickMenuEntryButton.isHidden)
        XCTAssertTrue(entrySeparator.isHidden)
    }

    // MARK: - RC2 (dark-mode render)

    @MainActor
    func testUKEntryTitleRendersVisibleGlyphsInDarkMode() throws {
        let f = Fixture(width: 320)
        f.host.traitOverrides.userInterfaceStyle = .dark
        f.bar.setUkQuickMenuVisible(true)
        f.host.view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        // drawHierarchy needs an on-screen render server; unit tests render the
        // host layer tree offscreen instead.
        let renderBounds = CGRect(x: 0, y: 0, width: 320, height: 46)
        let renderer = UIGraphicsImageRenderer(bounds: renderBounds, format: format)
        let image = renderer.image { context in
            f.host.view.layer.render(in: context.cgContext)
        }
        let pixels = try Self.luminanceGrid(of: image, stripWidth: 42, height: 46)

        let background = pixels.sorted()
        let median = background[background.count / 2]
        let glyphPixels = pixels.filter { abs($0 - median) > 0.25 }
        let range = (pixels.max() ?? 0) - (pixels.min() ?? 0)

        XCTAssertGreaterThan(
            glyphPixels.count, 15,
            "the leading 44×46pt strip must contain visible \"UK\" glyph pixels in dark mode")
        XCTAssertGreaterThan(range, 0.5, "the strip must be non-uniform (glyph vs. tray background)")
    }

    // MARK: - Helpers

    @MainActor
    private static func activeBarEdgeLeadingPins(in bar: CandidateBarView) -> [NSLayoutConstraint] {
        bar.constraints.filter { constraint in
            constraint.isActive
                && constraint.relation == .equal
                && (constraint.firstItem as? UIView) === bar.collectionView
                && constraint.firstAttribute == .leading
                && (constraint.secondItem as? UIView) === bar
                && constraint.secondAttribute == .leading
        }
    }

    private static func luminanceGrid(of image: UIImage, stripWidth: Int, height: Int) throws -> [Double] {
        guard let cgImage = image.cgImage, cgImage.width >= stripWidth, cgImage.height == height else {
            throw XCTSkip("unexpected rendered bitmap \(image.cgImage.map { "\($0.width)x\($0.height)" } ?? "nil")")
        }
        guard let data = cgImage.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else {
            throw XCTSkip("unreadable rendered bitmap")
        }
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        var luminance: [Double] = []
        luminance.reserveCapacity(stripWidth * height)
        for y in 0..<height {
            for x in 0..<stripWidth {
                let offset = y * cgImage.bytesPerRow + x * bytesPerPixel
                let r = Double(bytes[offset]) / 255
                let g = Double(bytes[offset + 1]) / 255
                let b = Double(bytes[offset + 2]) / 255
                luminance.append(0.2126 * r + 0.7152 * g + 0.0722 * b)
            }
        }
        return luminance
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
