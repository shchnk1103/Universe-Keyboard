import KeyboardCore
import UIKit
import XCTest

/// Real production Controller and root hierarchy, with lifecycle/engine bootstrap deliberately not run.
/// This is in-process UIKit integration, not a system-activated Keyboard Extension.
nonisolated final class CompactHeaderControllerLayoutTests: XCTestCase {
    @MainActor
    func testRealRootAlignsHeaderAndKeepsKeyGeometryAcrossReloads() throws {
        for width in [320.0, 390.0, 430.0] {
            for nineKey in [false, true] {
                let sut = makeController(width: width, nineKey: nineKey)
                let surface = try XCTUnwrap(sut.keyboardSurfaceView)
                let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
                let frame = bar.convert(bar.bounds, to: surface)
                print("HEADER_ROOT width=\(width) nineKey=\(nineKey) frame=\(frame)")
                XCTAssertEqual(frame.minX, 0, accuracy: 0.01)
                XCTAssertEqual(frame.maxX, width, accuracy: 0.01)
                XCTAssertEqual(frame.height, 46, accuracy: 0.01)
                assertRequiredEqualities(in: sut.view)
                let point = CGPoint(x: width - 1, y: frame.midY)
                XCTAssertTrue(surface.hitTest(point, with: nil) === bar.expandButton)
                assertFirstRowTouchCells(sut, nineKey: nineKey)
                let keys = keyFrames(sut)
                sut.reloadKeyboard()
                layout(sut)
                XCTAssertEqual(keyFrames(sut), keys)
                assertRequiredEqualities(in: sut.view)
                sut.reloadKeyboardContent()
                layout(sut)
                XCTAssertEqual(keyFrames(sut), keys)
                assertRequiredEqualities(in: sut.view)
                let recoveryBar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
                recoveryBar.setInputRecoveryNotice("输入恢复失败，按删除取消本段后重试")
                layout(sut)
                XCTAssertTrue(surface.hitTest(point, with: nil) === recoveryBar)
                XCTAssertEqual(keyFrames(sut), keys)
                XCTAssertFalse(recoveryBar.isHidden)
            }
        }
    }

    @MainActor
    func testExpandedActionMatchesCompactActionWithoutChangingCellHeight() async throws {
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsEnabled) }
        for width in [320.0, 390.0, 430.0] {
            for (nineKey, hasPath) in [(false, false), (true, false), (true, true)] {
                let sut = makeController(width: width, nineKey: nineKey)
                sut.overrideUserInterfaceStyle = width == 390 ? .dark : .light
                if hasPath {
                    // Presentation fixture only: not live RIME path issuance or selection evidence.
                    let path = T9PinyinPath(displayText: "ni", replacementRawInput: "ni")
                    sut.t9PinyinPathBarView?.setPaths([path], selected: path, compositionRevision: 0)
                    layout(sut)
                }
                let originalKeys = keyFrames(sut)
                let originalAccessibility = sut.rootStack.arrangedSubviews.map { $0.accessibilityElementsHidden }
                let surface = try XCTUnwrap(sut.keyboardSurfaceView)
                let compact = try XCTUnwrap((sut.candidateBar as? CandidateBarView)?.expandButton)
                let expected = compact.convert(compact.bounds, to: surface)
                sut.accumulatedCandidates = (0..<80).map {
                    CandidateItem(title: "候选\($0)", kind: .continuationCandidate)
                }
                sut.updateExpandButtonAppearance()
                layout(sut)
                let compactGlyphSize = try XCTUnwrap(compact.imageView).bounds.size
                sut.toggleCandidateExpand()
                layout(sut)
                let panel = try XCTUnwrap(sut.candidateExpandedPanel)
                XCTAssertEqual(panel.convert(panel.bounds, to: surface).minY, expected.minY, accuracy: 0.01)
                XCTAssertEqual(panel.bounds.width, width)
                XCTAssertEqual(panel.backgroundColor?.cgColor.alpha, 1)
                let button = try XCTUnwrap(panel.subviews.compactMap { $0 as? UIButton }.first)
                XCTAssertEqual(button.convert(button.bounds, to: surface), expected)
                XCTAssertEqual(button.accessibilityLabel, "收起候选面板")
                XCTAssertTrue(
                    sut.view.hitTest(surface.convert(CGPoint(x: width - 1, y: expected.midY), to: sut.view), with: nil)
                        === button)
                XCTAssertFalse(button.point(inside: CGPoint(x: -1, y: 23), with: nil))
                assertRequiredEqualities(in: sut.view)
                let collection = try XCTUnwrap(sut.expandedCandidateCollectionView)
                collection.layoutIfNeeded()
                XCTAssertEqual(collection.frame.minY, 0, accuracy: 0.01)
                XCTAssertEqual(collection.frame.height, panel.bounds.height)
                let first = try XCTUnwrap(collection.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)))
                XCTAssertEqual(first.frame.minY, 3, accuracy: 0.01)
                XCTAssertEqual(collection.convert(first.frame, to: surface).minY, expected.minY + 3, accuracy: 0.01)
                XCTAssertTrue(panel.clipsToBounds)
                XCTAssertEqual(panel.layer.cornerRadius, sut.keyboardSurfaceMaskCornerRadius)
                XCTAssertEqual(panel.layer.maskedCorners, [.layerMinXMinYCorner, .layerMaxXMinYCorner])
                XCTAssertNil(compact.configuration)
                XCTAssertNil(button.configuration)
                let collapseGlyphSize = try XCTUnwrap(button.imageView).bounds.size
                // A pi rotation introduces floating-point tails; compare well below one pixel.
                XCTAssertEqual(collapseGlyphSize.width, compactGlyphSize.width, accuracy: 0.001)
                XCTAssertEqual(collapseGlyphSize.height, compactGlyphSize.height, accuracy: 0.001)
                XCTAssertEqual(compact.image(for: .normal)?.size, button.image(for: .normal)?.size)
                XCTAssertEqual(compact.image(for: .normal)?.pngData(), button.image(for: .normal)?.pngData())
                XCTAssertEqual(compact.contentHorizontalAlignment, button.contentHorizontalAlignment)
                XCTAssertFalse(sut.rootStack.isHidden)
                for row in sut.rootStack.arrangedSubviews where row !== sut.t9PinyinPathBarView {
                    XCTAssertTrue(row.accessibilityElementsHidden)
                }
                if let pathBar = sut.t9PinyinPathBarView {
                    XCTAssertFalse(pathBar.isHidden)
                    let point = pathBar.convert(CGPoint(x: 30, y: 17), to: sut.view)
                    let hit = try XCTUnwrap(sut.view.hitTest(point, with: nil))
                    XCTAssertTrue(hit === pathBar || hit.isDescendant(of: pathBar))
                }
                // The unchanged underlying keys cannot receive a touch through the opaque overlay.
                if let key = originalKeys.first {
                    let hit = try XCTUnwrap(sut.view.hitTest(CGPoint(x: key.midX, y: key.midY), with: nil))
                    XCTAssertTrue(hit === panel || hit.isDescendant(of: panel))
                }
                if nineKey { XCTAssertEqual(expected.minY, 36, accuracy: 0.01) }
                let buttonFrame = button.convert(button.bounds, to: collection)
                for index in 0..<80 {
                    let attributes = try XCTUnwrap(
                        collection.layoutAttributesForItem(at: IndexPath(item: index, section: 0)))
                    XCTAssertEqual(attributes.frame.height, 42)
                    XCTAssertFalse(attributes.frame.intersects(buttonFrame))
                }
                collection.scrollToItem(at: IndexPath(item: 79, section: 0), at: .bottom, animated: false)
                collection.layoutIfNeeded()
                let last = try XCTUnwrap(collection.layoutAttributesForItem(at: IndexPath(item: 79, section: 0)))
                XCTAssertTrue(collection.bounds.contains(last.frame))
                XCTAssertTrue(
                    button.actions(forTarget: sut, forControlEvent: .touchUpInside)?.contains("toggleCandidateExpand")
                        == true)
                // Hostless XCTest has no UIApplication event dispatcher; invoke the verified target directly.
                sut.toggleCandidateExpand()
                XCTAssertFalse(sut.isCandidateExpanded)
                // UIKit schedules transition completion even with animations disabled. Allow its
                // documented 0.16s dismissal to restore root interaction before testing the route.
                try await Task.sleep(for: .milliseconds(250))
                XCTAssertNil(sut.candidateExpandedPanel)
                XCTAssertTrue(sut.rootStack.isUserInteractionEnabled)
                layout(sut)
                XCTAssertTrue(surface.hitTest(CGPoint(x: width - 1, y: expected.midY), with: nil) === compact)
                XCTAssertEqual(compact.convert(compact.bounds, to: surface), expected)
                XCTAssertEqual(keyFrames(sut), originalKeys)
                XCTAssertEqual(
                    sut.rootStack.arrangedSubviews.map { $0.accessibilityElementsHidden }, originalAccessibility)
                let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
                bar.setInputRecoveryNotice("输入恢复失败，按删除取消本段后重试")
                layout(sut)
                XCTAssertTrue(surface.hitTest(CGPoint(x: width - 1, y: expected.midY), with: nil) === bar)
            }
        }
    }

    @MainActor
    func testIdleHeaderMeasurementsKeepOnlyFixedCandidateReservation() throws {
        for width in [320.0, 390.0, 430.0] {
            let sut = makeController(width: width, nineKey: false)
            let surface = try XCTUnwrap(sut.keyboardSurfaceView)
            let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
            let row = try XCTUnwrap(bar.superview)
            let collection = bar.collectionView
            let keys = keyFrames(sut)
            let firstKeyTop = try XCTUnwrap(keys.map(\.minY).min())
            print(
                "VISUAL_HEADER W=\(width) surface=\(surface.frame) root=\(sut.rootStack.frame) row=\(row.convert(row.bounds, to: sut.view)) viewport=\(collection.convert(collection.bounds, to: sut.view)) firstKeyY=\(firstKeyTop) targetHeight=\(sut.preferredKeyboardHeight)"
            )
            XCTAssertEqual(surface.frame.minY, 0)
            XCTAssertEqual(sut.rootStack.frame.minY, 2)
            XCTAssertEqual(row.convert(row.bounds, to: sut.view).minY, 2)
            XCTAssertEqual(collection.convert(collection.bounds, to: sut.view).minY, 2)
            XCTAssertEqual(collection.bounds.height, 46)
            XCTAssertEqual(firstKeyTop, 48)
            XCTAssertEqual(sut.preferredKeyboardHeight, 254)
            XCTAssertFalse(sut.shouldReserveT9PinyinPathBar)
        }
    }

    @MainActor
    private func makeController(width: CGFloat, nineKey: Bool) -> KeyboardViewController {
        let sut = KeyboardViewController()
        let core = KeyboardController(state: KeyboardState())
        sut.controller = core
        // Install the actual input view directly, without Main-App resources or a live RIME session.
        sut.loadView()
        XCTAssertTrue(sut.controller === core)
        sut.cachedLayoutStyle = nineKey ? .nineKey : .twentySixKey
        sut.cachedT9ReadinessMatched = nineKey
        sut.setupRootStack()
        sut.reloadKeyboard()
        sut.view.frame = CGRect(x: 0, y: 0, width: width, height: sut.preferredKeyboardHeight)
        layout(sut)
        return sut
    }

    @MainActor
    private func keyFrames(_ sut: KeyboardViewController) -> [CGRect] {
        descendants(sut.rootStack).compactMap { view in
            guard let key = view as? KeyboardKeyButton, !key.isHidden else { return nil }
            return key.convert(key.bounds, to: sut.view)
        }
    }

    @MainActor
    private func assertFirstRowTouchCells(_ sut: KeyboardViewController, nineKey: Bool) {
        guard let root = sut.rootStack as? KeyboardInputHitAreaStackView else { return XCTFail("Missing real root") }
        root.refreshKeyTouchGeometry()
        let first = descendants(root).compactMap { $0 as? KeyboardKeyButton }.first {
            nineKey ? $0.accessibilityIdentifier == "2" : $0.accessibilityLabel == "q"
        }
        guard let first else { return XCTFail("Missing first row key") }
        XCTAssertEqual(first.bounds.height, 45, accuracy: 0.01)
        for x in [first.bounds.minX + 0.5, first.bounds.maxX - 0.5] {
            let point = first.convert(CGPoint(x: x, y: first.bounds.midY), to: sut.view)
            let hit = sut.view.hitTest(point, with: nil)
            XCTAssertTrue(hit === first || hit?.isDescendant(of: first) == true)
        }
        XCTAssertNotNil(first.localTouchBounds)
        XCTAssertTrue(first.localTouchBounds?.contains(first.bounds) == true)
    }

    @MainActor
    private func descendants(_ view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }

    @MainActor
    private func layout(_ sut: KeyboardViewController) {
        // No host run loop installs the keyboard here. Explicitly flush pending arranged-view layout.
        sut.view.setNeedsLayout()
        sut.view.layoutIfNeeded()
        for view in [sut.rootStack!] + descendants(sut.rootStack) { view.layoutIfNeeded() }
    }

    /// Check required equations between rendered views, including stack canvas connections.
    /// Private solver spacers and layout guides cannot be verified from rendered UIView frames.
    /// NSContentSizeLayoutConstraint represents intrinsic hugging/resistance (250/750), even when its
    /// wrapper reports priority 1000; it is not a required size equality and is not tested as one.
    @MainActor
    private func assertRequiredEqualities(in root: UIView, file: StaticString = #filePath, line: UInt = #line) {
        for owner in [root] + descendants(root) {
            for constraint in owner.constraints where constraint.isActive && constraint.priority == .required {
                guard !String(describing: type(of: constraint)).contains("NSContentSizeLayoutConstraint"),
                    let left = value(of: constraint.firstItem, attribute: constraint.firstAttribute, in: root),
                    let right = constraint.secondItem == nil
                        ? 0
                        : value(
                            of: constraint.secondItem, attribute: constraint.secondAttribute, in: root)
                else { continue }
                let expected = right * constraint.multiplier + constraint.constant
                switch constraint.relation {
                case .equal:
                    XCTAssertEqual(left, expected, accuracy: 0.75, constraint.description, file: file, line: line)
                case .lessThanOrEqual:
                    XCTAssertLessThanOrEqual(left, expected + 0.75, constraint.description, file: file, line: line)
                case .greaterThanOrEqual:
                    XCTAssertGreaterThanOrEqual(left, expected - 0.75, constraint.description, file: file, line: line)
                @unknown default: XCTFail("Unknown layout relation", file: file, line: line)
                }
            }
        }
    }

    @MainActor
    private func value(of item: AnyObject?, attribute: NSLayoutConstraint.Attribute, in root: UIView) -> CGFloat? {
        let frame: CGRect
        if let view = item as? UIView {
            // Private layout spacers are solver proxies, not rendered views with observable frames.
            guard !String(describing: type(of: view)).hasPrefix("_") else { return nil }
            frame = view.convert(view.bounds, to: root)
        } else {
            return nil
        }
        switch attribute {
        case .left, .leading: return frame.minX
        case .right, .trailing: return frame.maxX
        case .top: return frame.minY
        case .bottom: return frame.maxY
        case .width: return frame.width
        case .height: return frame.height
        case .centerX: return frame.midX
        case .centerY: return frame.midY
        default: return nil
        }
    }
}
