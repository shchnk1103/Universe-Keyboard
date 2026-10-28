import UIKit
import XCTest

@testable import KeyboardCore

/// Real production Controller and root hierarchy, with lifecycle/engine bootstrap deliberately not run.
/// This is in-process UIKit integration, not a system-activated Keyboard Extension.
nonisolated final class CompactHeaderControllerLayoutTests: XCTestCase {
    @MainActor
    func testTraceClientBootstrapAndSameDocumentRebindWhileDisabled() {
        let sut = KeyboardViewController()
        var reads = 0
        var events = 0
        let recorder = CommitTraceRecorder(
            context: {
                reads += 1; return nil
            }, emit: { _, _ in events += 1 })
        sut.commitTrace = recorder
        sut.commitTraceTestDocumentIdentifier = UUID()
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.controller.textClient is TracingTextInputClient)
        sut.textDidChange(nil)
        let first = sut.controller.textClient
        XCTAssertTrue(first is TracingTextInputClient)
        sut.textDidChange(nil)
        XCTAssertTrue(sut.controller.textClient is TracingTextInputClient)
        XCTAssertFalse(sut.controller.textClient === first)
        sut.controller.rimeEngine = nil
        let host = FakeTextInputClient()
        sut.controller.textClient = TracingTextInputClient(host, recorder: recorder)
        sut.accumulatedCandidates = [CandidateItem(title: "trace", kind: .candidate)]
        sut.commitCompactCandidate(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(host.text, "trace")
        sut.textDidChange(nil)
        XCTAssertEqual(events, 0)
        XCTAssertEqual(reads, 0)
    }

    @MainActor
    func testCandidateCommitTraceEntryWiring() {
        let sut = makeController(width: 390, nineKey: false, hasPath: false, stickyEmpty: false)
        var entries: [Int] = []
        let recorder = CommitTraceRecorder(
            context: { nil },
            emit: { _, fields in
                for field in fields {
                    if case let .count(.traceEntry, entry) = field { entries.append(entry) }
                }
            })
        recorder.enabled = true
        sut.commitTrace = recorder
        sut.controller.onActionObserved = { recorder.observeAction($0) }
        let item = CandidateItem(title: "test", kind: .placeholder)
        sut.accumulatedCandidates = [item]
        sut.commitCompactCandidate(at: IndexPath(item: 0, section: 0))
        recorder.close(.nextInput)
        sut.commitExpandedCandidate(item)
        recorder.close(.nextInput)
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "test"
        button.configuration = config
        button.tag = CandidateKind.placeholder.rawValue
        sut.insertCandidate(button)
        recorder.close(.nextInput)
        XCTAssertEqual(entries, [0, 1, 2])
        let base = FakeTextInputClient()
        XCTAssertTrue(sut.traceClient(base) is TracingTextInputClient)
        recorder.enabled = false
        XCTAssertTrue(sut.traceClient(base) is TracingTextInputClient)
    }

    @MainActor
    func testRealRootAlignsHeaderAndKeepsKeyGeometryAcrossReloads() throws {
        for width in [320.0, 390.0, 430.0] {
            for (nineKey, hasPath, stickyEmpty) in [
                (false, false, false), (true, false, false), (true, true, false), (true, true, true),
            ] {
                let sut = makeController(width: width, nineKey: nineKey, hasPath: hasPath, stickyEmpty: stickyEmpty)
                let surface = try XCTUnwrap(sut.keyboardSurfaceView)
                let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
                let frame = bar.convert(bar.bounds, to: surface)
                print("HEADER_ROOT width=\(width) nineKey=\(nineKey) frame=\(frame)")
                XCTAssertEqual(frame.minX, 0, accuracy: 0.01)
                XCTAssertEqual(frame.maxX, width, accuracy: 0.01)
                XCTAssertEqual(frame.height, KeyboardDesignTokens.CandidateBar.totalHeight, accuracy: 0.01)
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
            for (nineKey, hasPath, stickyEmpty) in [
                (false, false, false), (true, false, false), (true, true, false), (true, true, true),
            ] {
                let sut = makeController(width: width, nineKey: nineKey, hasPath: hasPath, stickyEmpty: stickyEmpty)
                sut.overrideUserInterfaceStyle = width == 390 ? .dark : .light
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
                XCTAssertEqual(panel.backgroundColor?.cgColor.alpha, 0)
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
                XCTAssertEqual(first.frame.minY, 2, accuracy: 0.01)
                XCTAssertEqual(collection.convert(first.frame, to: surface).minY, expected.minY + 2, accuracy: 0.01)
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
                if let pathBar = sut.t9PinyinPathBarView, hasPath {
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
                if nineKey {
                    XCTAssertEqual(
                        expected.minY, sut.keyboardContentTopInset + (hasPath ? sut.t9PinyinPathBarHeight : 0),
                        accuracy: 0.01)
                    XCTAssertEqual(sut.t9PinyinPathBarView?.frame.height, hasPath ? sut.t9PinyinPathBarHeight : 0)
                }
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
            XCTAssertEqual(collection.bounds.height, KeyboardDesignTokens.CandidateBar.totalHeight)
            XCTAssertEqual(firstKeyTop, 48)
            XCTAssertEqual(sut.preferredKeyboardHeight, KeyboardViewController.defaultKeyboardHeightWithoutPath)
            XCTAssertFalse(sut.shouldReserveT9PinyinPathBar)
        }
    }

    @MainActor
    func testFirstRowTextAlignmentAcrossPresentations() throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        for width in [320.0, 390.0, 430.0] {
            for nineKey in [false, true] {
                let sut = makeController(width: width, nineKey: nineKey)
                seedReadingCandidates(sut)
                let surface = try XCTUnwrap(sut.keyboardSurfaceView)
                func textGeometry(_ collection: UICollectionView) throws -> (rect: CGRect, baseline: CGFloat) {
                    let cell = try XCTUnwrap(collection.cellForItem(at: IndexPath(item: 0, section: 0)))
                    let label = try XCTUnwrap(descendants(cell).compactMap { $0 as? UILabel }.first { $0.text == "词0" })
                    let rect = label.textRect(forBounds: label.bounds, limitedToNumberOfLines: 1)
                    let text = label.convert(rect, to: surface)
                    let flow = try XCTUnwrap(collection.collectionViewLayout as? UICollectionViewFlowLayout)
                    print(
                        "TEXT_GEOMETRY width=\(width) t9=\(nineKey) viewport=\(collection.convert(collection.bounds, to: surface)) inset=\(collection.contentInset) section=\(flow.sectionInset) offset=\(collection.contentOffset) cell=\(cell.frame) label=\(label.frame) text=\(text) font=\(label.font.pointSize) baseline=\(text.minY + label.font.ascender) measured=\((label.text! as NSString).size(withAttributes: [.font: label.font!]))"
                    )
                    return (text, text.minY + label.font.ascender)
                }
                let compact = try textGeometry(XCTUnwrap(sut.candidateCollectionView))
                sut.toggleCandidateExpand()
                layout(sut)
                let expanded = try textGeometry(XCTUnwrap(sut.expandedCandidateCollectionView))
                print(
                    "TEXT_DELTA x=\(expanded.rect.minX - compact.rect.minX) y=\(expanded.rect.minY - compact.rect.minY)"
                )
                XCTAssertEqual(expanded.rect.minX, compact.rect.minX, accuracy: 0.01)
                XCTAssertEqual(expanded.rect.minY, compact.rect.minY, accuracy: 0.01)
                XCTAssertEqual(expanded.rect.height, compact.rect.height, accuracy: 0.01)
                XCTAssertEqual(expanded.baseline, compact.baseline, accuracy: 0.01)
                let compactButton = try XCTUnwrap((sut.candidateBar as? CandidateBarView)?.expandButton)
                let expandedButton = try XCTUnwrap(
                    sut.candidateExpandedPanel?.subviews.compactMap { $0 as? UIButton }.first)
                XCTAssertEqual(compactButton.tintColor, expandedButton.tintColor)
                XCTAssertEqual(expandedButton.tintColor, KeyboardDesignTokens.CandidateActionAppearance.symbolColor)
                assertRequiredEqualities(in: sut.view)
            }
        }
    }

    @MainActor
    private func seedReadingCandidates(_ sut: KeyboardViewController, count: Int = 120) {
        sut.candidateSnapshotGeneration = 10
        sut.accumulatedCandidates = (0..<count).map {
            CandidateItem(title: "词\($0)", kind: .continuationCandidate)
        }
        sut.hasMoreCandidates = false
        sut.fillCandidateBar()
        layout(sut)
        sut.candidateCollectionView?.layoutIfNeeded()
    }

    @MainActor
    func testPartialAndSliverAnchorsExpandWithoutDroppingEarlierCandidates() throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        for width in [320.0, 390.0, 430.0] {
            for nineKey in [false, true] {
                for sliver in [false, true] {
                    let sut = makeController(width: width, nineKey: nineKey)
                    seedReadingCandidates(sut)
                    let compact = try XCTUnwrap(sut.candidateCollectionView)
                    let cell = try XCTUnwrap(compact.layoutAttributesForItem(at: IndexPath(item: 15, section: 0)))
                    let x = cell.frame.minX + (sliver ? cell.frame.width - 1 : cell.frame.width * 0.5)
                    compact.setContentOffset(CGPoint(x: x, y: 0), animated: false)
                    let original = compact.contentOffset.x
                    sut.toggleCandidateExpand()
                    layout(sut)
                    let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
                    let anchor = try XCTUnwrap(panel.readingPosition?.entryAnchor)
                    XCTAssertEqual(anchor.index, sliver ? 16 : 15)
                    if !sliver {  // UIKit quantizes scroll offsets to the display pixel grid.
                        let pixelFraction = 1 / max(1, sut.traitCollection.displayScale) / cell.frame.width
                        XCTAssertEqual(anchor.visibleFraction, 0.5, accuracy: pixelFraction)
                    }
                    let expanded = try XCTUnwrap(sut.expandedCandidateCollectionView)
                    expanded.layoutIfNeeded()
                    let attribute = try XCTUnwrap(
                        expanded.layoutAttributesForItem(at: IndexPath(item: anchor.index, section: 0)))
                    XCTAssertTrue(expanded.bounds.contains(attribute.frame))
                    XCTAssertFalse(attribute.frame.intersects(panel.actionFrame(in: expanded)))
                    XCTAssertGreaterThan(expanded.contentOffset.y, 0)
                    XCTAssertEqual(expanded.numberOfItems(inSection: 0), 120)
                    expanded.setContentOffset(.zero, animated: false)
                    XCTAssertNotNil(expanded.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)))
                    // Programmatic positioning is not a user's vertical pan.
                    XCTAssertFalse(panel.readingPosition?.userScrolled == true)
                    sut.toggleCandidateExpand()
                    XCTAssertEqual(compact.contentOffset.x, original, accuracy: 0.001)
                    XCTAssertNil(sut.rootStack.layer.mask)
                }
            }
        }
    }

    @MainActor
    func testUserScrolledAnchorReturnsToCompactAndSnapshotChangesFallBack() throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        for invalidate in [false, true] {
            let sut = makeController(width: 390, nineKey: true)
            seedReadingCandidates(sut)
            let compact = try XCTUnwrap(sut.candidateCollectionView)
            compact.setContentOffset(CGPoint(x: 300.375, y: 0), animated: false)
            sut.toggleCandidateExpand()
            layout(sut)
            let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
            let expanded = try XCTUnwrap(sut.expandedCandidateCollectionView)
            expanded.scrollToItem(at: IndexPath(item: 40, section: 0), at: .top, animated: false)
            expanded.layoutIfNeeded()
            panel.recordUserScroll()  // The same UI-only event the collection's pan observer records.
            let anchor = try XCTUnwrap(
                CandidateReadingAnchor.capture(
                    in: expanded, items: sut.presentedCandidates, horizontal: false,
                    occluded: panel.actionFrame(in: expanded)))
            XCTAssertGreaterThan(anchor.index, 15)
            if invalidate {
                sut.candidateSnapshotGeneration += 1
                sut.refreshExpandedPanel()
                expanded.layoutIfNeeded()
                XCTAssertEqual(expanded.contentOffset, .zero)
            }
            sut.toggleCandidateExpand()
            if invalidate {
                XCTAssertEqual(compact.contentOffset, .zero)
            } else {
                let frame = try XCTUnwrap(
                    compact.layoutAttributesForItem(at: IndexPath(item: anchor.index, section: 0))
                ).frame
                XCTAssertTrue(compact.bounds.contains(frame))
                XCTAssertEqual(compact.contentOffset.x, frame.minX, accuracy: 0.001)
            }
        }
    }

    @MainActor
    func testPagingAppendKeepsAnchorAndFlowStableAcrossScrolling() async throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        let sut = makeController(width: 320, nineKey: false)
        seedReadingCandidates(sut, count: 60)
        let compact = try XCTUnwrap(sut.candidateCollectionView)
        compact.setContentOffset(CGPoint(x: 350.25, y: 0), animated: false)
        let offset = compact.contentOffset
        let original = sut.presentedCandidates
        sut.toggleCandidateExpand()
        layout(sut)
        let expanded = try XCTUnwrap(sut.expandedCandidateCollectionView)
        let frames = (0..<60).compactMap {
            expanded.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.frame
        }
        sut.accumulatedCandidates += (60..<72).map { CandidateItem(title: "词\($0)", kind: .continuationCandidate) }
        sut.appendToExpandedCandidatePanel(insertedCount: 12)
        try await Task.sleep(for: .milliseconds(50))
        expanded.layoutIfNeeded()
        XCTAssertEqual(Array(sut.presentedCandidates.prefix(60)), original)
        XCTAssertEqual(expanded.numberOfItems(inSection: 0), 72)
        expanded.setContentOffset(CGPoint(x: 0, y: 200), animated: false)
        expanded.layoutIfNeeded()
        XCTAssertEqual(
            (0..<60).compactMap { expanded.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.frame }, frames
        )
        sut.toggleCandidateExpand()
        XCTAssertEqual(compact.numberOfItems(inSection: 0), 72)
        XCTAssertEqual(compact.contentOffset, offset)
    }

    @MainActor
    func testNaturalFlowFixedActionMaterialAndTouchOcclusion() throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        for width in [320.0, 390.0, 430.0] {
            let sut = makeController(width: width, nineKey: true, hasPath: true)
            seedReadingCandidates(sut)
            let mixed = ["你", "一个自然换行的较长候选词", String(repeating: "长词", count: 25), "abc", "中英混合"]
            sut.accumulatedCandidates = (0..<120).map {
                CandidateItem(title: mixed[$0 % mixed.count], kind: .continuationCandidate)
            }
            sut.fillCandidateBar()
            sut.toggleCandidateExpand()
            layout(sut)
            let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
            let expanded = try XCTUnwrap(sut.expandedCandidateCollectionView)
            let button = try XCTUnwrap(panel.subviews.compactMap { $0 as? UIButton }.first)
            let material = try XCTUnwrap(panel.subviews.compactMap { $0 as? UIVisualEffectView }.first)
            XCTAssertEqual(
                material.frame,
                button.frame.inset(by: KeyboardDesignTokens.CandidateActionAppearance.controlBackgroundInsets))
            XCTAssertTrue(material.clipsToBounds)
            XCTAssertEqual(
                material.layer.cornerRadius, KeyboardDesignTokens.CandidateActionAppearance.controlCornerRadius)
            XCTAssertEqual(panel.backgroundColor?.cgColor.alpha, 0)
            let frames = (0..<120).compactMap {
                expanded.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.frame
            }
            XCTAssertEqual(frames.count, 120)
            XCTAssertGreaterThan(Set(frames.map(\.width)).count, 1)
            for frame in frames { XCTAssertEqual(frame.height, 42); XCTAssertLessThanOrEqual(frame.maxX, width - 8) }
            for (left, right) in zip(frames, frames.dropFirst()) {
                if left.minY == right.minY {
                    XCTAssertEqual(left.maxX, right.minX)
                } else {
                    XCTAssertEqual(right.minX, KeyboardDesignTokens.CandidateBar.horizontalPadding);
                    XCTAssertGreaterThan(right.minY, left.minY)
                }
            }
            let originalFrames = frames
            expanded.setContentOffset(CGPoint(x: 0, y: 120), animated: false)
            expanded.layoutIfNeeded()
            XCTAssertEqual(
                (0..<120).compactMap { expanded.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.frame },
                originalFrames)
            let point = CGPoint(x: width - 20, y: 23)
            XCTAssertTrue(panel.hitTest(point, with: nil) === button)
            let visiblePoint = CGPoint(x: 30, y: 70)
            let hit = try XCTUnwrap(panel.hitTest(visiblePoint, with: nil))
            XCTAssertTrue(hit === expanded || hit.isDescendant(of: expanded))
            panel.updateActionMaterial(reduceTransparency: true)
            XCTAssertNil(material.effect)
            XCTAssertEqual(material.contentView.subviews.first?.backgroundColor?.cgColor.alpha, 1)
            panel.updateActionMaterial(reduceTransparency: false)
            XCTAssertNotNil(material.effect)
            XCTAssertEqual(
                ObjectIdentifier(material),
                ObjectIdentifier(try XCTUnwrap(panel.subviews.compactMap { $0 as? UIVisualEffectView }.first)))
            let mask = try XCTUnwrap(sut.rootStack.layer.mask as? CAShapeLayer)
            XCTAssertFalse(mask.path?.contains(CGPoint(x: 40, y: 100)) == true)
            XCTAssertTrue(mask.path?.contains(CGPoint(x: 40, y: 17)) == true)
            expanded.scrollToItem(at: IndexPath(item: 119, section: 0), at: .bottom, animated: false)
            expanded.layoutIfNeeded()
            XCTAssertTrue(
                expanded.bounds.contains(
                    try XCTUnwrap(expanded.layoutAttributesForItem(at: IndexPath(item: 119, section: 0))).frame))
            assertRequiredEqualities(in: sut.view)
            sut.toggleCandidateExpand()
            XCTAssertNil(sut.rootStack.layer.mask)
        }
    }

    @MainActor
    func testRepeatedRevealAndRecoveryDismissRestoreOriginalGeometry() async throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        let sut = makeController(width: 390, nineKey: true)
        seedReadingCandidates(sut, count: 3)
        let keys = keyFrames(sut)
        let height = sut.view.bounds.height
        for _ in 0..<10 {
            sut.toggleCandidateExpand(); layout(sut)
            XCTAssertEqual(sut.expandedCandidateCollectionView?.contentOffset, .zero)
            sut.toggleCandidateExpand(); layout(sut)
            XCTAssertEqual(keyFrames(sut), keys)
            XCTAssertEqual(sut.view.bounds.height, height)
            XCTAssertNil(sut.rootStack.layer.mask)
        }
        UIView.setAnimationsEnabled(true)
        sut.toggleCandidateExpand()
        layout(sut)
        let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
        if panel.isTransitioning {
            sut.toggleCandidateExpand()
            XCTAssertTrue(sut.isCandidateExpanded)
            XCTAssertTrue(sut.candidateExpandedPanel === panel)
            XCTAssertTrue(panel.hitTest(CGPoint(x: 30, y: 70), with: nil) === panel)
        }
        // Recovery's UI adapter uses this immediate dismissal; no Core recovery state is fabricated here.
        sut.isCandidateExpanded = false
        sut.dismissExpandedCandidatePanel(animated: false)
        (sut.candidateBar as? CandidateBarView)?.setInputRecoveryNotice("输入恢复失败")
        try await Task.sleep(for: .milliseconds(250))
        XCTAssertNil(sut.candidateExpandedPanel)
        XCTAssertNil(sut.rootStack.layer.mask)
        XCTAssertEqual(keyFrames(sut), keys)
        XCTAssertFalse((sut.candidateBar as? CandidateBarView)?.expandButton.isEnabled == true)
    }

    @MainActor
    func testFewCandidatesAndPublicationChangesNeverReuseOldIndices() throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        for count in [0, 1, 3] {
            let sut = makeController(width: 320, nineKey: false)
            seedReadingCandidates(sut, count: count)
            sut.toggleCandidateExpand(); layout(sut)
            XCTAssertEqual(sut.expandedCandidateCollectionView?.numberOfItems(inSection: 0), count)
            sut.toggleCandidateExpand()
            XCTAssertEqual(sut.candidateCollectionView?.contentOffset, .zero)
        }
        for mutation in 0..<3 {
            let sut = makeController(width: 390, nineKey: false)
            seedReadingCandidates(sut)
            sut.candidateCollectionView?.setContentOffset(CGPoint(x: 400, y: 0), animated: false)
            sut.toggleCandidateExpand(); layout(sut)
            switch mutation {
            case 0: sut.candidateSnapshotCompositionRevision += 1
            case 1: sut.candidateSnapshotRawInput = "new composition"
            default: sut.accumulatedCandidates.reverse()  // Same count/text set is insufficient identity.
            }
            sut.toggleCandidateExpand()
            XCTAssertEqual(sut.candidateCollectionView?.contentOffset, .zero)
        }
        let sut = makeController(width: 390, nineKey: true)
        seedReadingCandidates(sut)
        sut.toggleCandidateExpand(); layout(sut)
        let snapshot = sut.currentCandidateReadingSnapshot
        sut.cachedLayoutStyle = .twentySixKey
        sut.reloadKeyboard(); layout(sut)
        XCTAssertNil(sut.candidateExpandedPanel)
        XCTAssertNil(sut.rootStack.layer.mask)
        XCTAssertFalse(sut.candidateBar.isHidden)
        XCTAssertNotEqual(snapshot, sut.currentCandidateReadingSnapshot)
    }

    @MainActor
    func testAnimatedRevealRejectsRapidToggleAndRestoresPagingInteraction() async throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(true)
        defer { UIView.setAnimationsEnabled(animations) }
        let sut = makeController(width: 390, nineKey: false)
        seedReadingCandidates(sut)
        let keys = keyFrames(sut)
        sut.toggleCandidateExpand(); layout(sut)
        let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
        if panel.isTransitioning {
            for _ in 0..<5 { sut.toggleCandidateExpand() }
            XCTAssertTrue(sut.isCandidateExpanded)
            XCTAssertTrue(sut.candidateExpandedPanel === panel)
        }
        try await Task.sleep(for: .milliseconds(250))
        XCTAssertFalse(panel.isTransitioning)
        sut.isCandidateScrollInteracting = true
        sut.toggleCandidateExpand()
        XCTAssertFalse(sut.isCandidateScrollInteracting)
        if panel.isTransitioning {
            for _ in 0..<5 { sut.toggleCandidateExpand() }
            XCTAssertFalse(sut.isCandidateExpanded)
            XCTAssertTrue(sut.candidateExpandedPanel === panel)
        }
        try await Task.sleep(for: .milliseconds(250))
        XCTAssertNil(sut.candidateExpandedPanel)
        XCTAssertNil(sut.rootStack.layer.mask)
        XCTAssertFalse(sut.candidateBar.isHidden)
        XCTAssertEqual(keyFrames(sut), keys)
    }

    @MainActor
    func testAdaptiveExpansionKeepsPanelReadingAndMaskGeometry() async throws {
        let previousAnimations = UIView.areAnimationsEnabled
        defer { UIView.setAnimationsEnabled(previousAnimations) }
        for animated in [false, true] {
            UIView.setAnimationsEnabled(false)
            let sut = makeController(width: 390, nineKey: true)
            seedReadingCandidates(sut)
            XCTAssertEqual(sut.t9PinyinPathBarView?.frame.height, 0)
            sut.toggleCandidateExpand()
            layout(sut)
            let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
            let expanded = try XCTUnwrap(sut.expandedCandidateCollectionView)
            expanded.scrollToItem(at: IndexPath(item: 40, section: 0), at: .top, animated: false)
            expanded.layoutIfNeeded()
            panel.recordUserScroll()
            let anchor = try XCTUnwrap(
                CandidateReadingAnchor.capture(
                    in: expanded, items: sut.presentedCandidates, horizontal: false,
                    occluded: panel.actionFrame(in: expanded)))
            let offset = expanded.contentOffset
            let snapshot = panel.readingPosition?.snapshot
            func expandAndCheck() {
                sut.refreshT9PinyinPathBarVisibility(.init(rimeRawInput: "64"))
                layout(sut)
                let frame = panel.convert(panel.bounds, to: sut.view)
                let candidate = sut.candidateBar.convert(sut.candidateBar.bounds, to: sut.view)
                let surface = sut.keyboardSurfaceView.convert(sut.keyboardSurfaceView.bounds, to: sut.view)
                XCTAssertEqual(frame.minY, candidate.minY, accuracy: 0.01)
                XCTAssertEqual(frame.maxY, sut.rootStack.frame.maxY, accuracy: 0.01)
                XCTAssertEqual(frame.minX, surface.minX, accuracy: 0.01)
                XCTAssertEqual(frame.width, surface.width, accuracy: 0.01)
                XCTAssertEqual(panel.revealViewport.bounds.width, panel.bounds.width)
                XCTAssertEqual(sut.rootStack.layer.mask?.frame, sut.rootStack.bounds)
                let mask = sut.rootStack.layer.mask as? CAShapeLayer
                XCTAssertTrue(
                    mask?.path?.contains(CGPoint(x: 20, y: 17)) == true,
                    "New Path row must remain outside the covered candidate/key region")
                XCTAssertEqual(panel.readingPosition?.snapshot, snapshot)
                XCTAssertEqual(expanded.contentOffset, offset)
                XCTAssertTrue(anchor.isValid(in: sut.presentedCandidates))
                assertRequiredEqualities(in: sut.view)
            }
            if animated {
                UIView.setAnimationsEnabled(true)
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    panel.animateReveal(
                        to: panel.bounds.height,
                        duration: KeyboardDesignTokens.ExpandedCandidates.expandDuration
                    ) { continuation.resume() }
                    XCTAssertTrue(panel.isTransitioning)
                    expandAndCheck()
                }
            } else {
                expandAndCheck()
            }
            XCTAssertFalse(panel.isTransitioning)
            XCTAssertEqual(sut.rootStack.layer.mask?.frame, sut.rootStack.bounds)
            let action = panel.actionFrame(in: sut.view)
            let hit = sut.view.hitTest(CGPoint(x: action.midX, y: action.midY), with: nil)
            XCTAssertTrue(hit is UIButton)
            let expectedKeys = keyFrames(sut)
            UIView.setAnimationsEnabled(false)
            sut.isCandidateExpanded = false
            sut.dismissExpandedCandidatePanel(animated: false)
            layout(sut)
            XCTAssertNil(sut.rootStack.layer.mask)
            XCTAssertEqual(keyFrames(sut), expectedKeys)
            XCTAssertFalse(sut.candidateBar.isHidden)
            assertFirstRowTouchCells(sut, nineKey: true)
            let compact = try XCTUnwrap(sut.candidateCollectionView)
            let cell = try XCTUnwrap(compact.layoutAttributesForItem(at: IndexPath(item: anchor.index, section: 0)))
            XCTAssertTrue(compact.bounds.intersects(cell.frame))
        }
    }

    @MainActor
    private func makeController(width: CGFloat, nineKey: Bool, hasPath: Bool = false, stickyEmpty: Bool = false)
        -> KeyboardViewController
    {
        let sut = AdaptiveCompactHeaderController()
        let core = KeyboardController(state: KeyboardState())
        sut.controller = core
        // Install the actual input view directly, without Main-App resources or a live RIME session.
        sut.loadView()
        XCTAssertTrue(sut.controller === core)
        sut.cachedLayoutStyle = nineKey ? .nineKey : .twentySixKey
        sut.cachedT9ReadinessMatched = nineKey
        sut.setupRootStack()
        sut.reloadKeyboard()
        if nineKey, hasPath {
            // Enter through the production snapshot/presentation path, never set the latch directly.
            let path = T9PinyinPath(displayText: "ni", replacementRawInput: "ni")
            sut.controller.state.t9PinyinPathState = .init(compactPaths: [path], trackedRawInput: "64")
            sut.refreshT9PinyinPathBar()
            if stickyEmpty {
                sut.controller.state.t9PinyinPathState = .empty
                sut.refreshT9PinyinPathBar()
            }
        }
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
        XCTAssertEqual(first.bounds.height, CGFloat(KeyboardHeightSettings.defaultRowHeight), accuracy: 0.01)
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
        // In-process geometry assumes the host accepts the single flexible request.
        sut.view.frame.size.height = sut.preferredKeyboardHeight
        // No host run loop installs the keyboard here. Explicitly flush pending arranged-view layout.
        sut.view.setNeedsLayout()
        sut.view.layoutIfNeeded()
        for view in [sut.rootStack!] + descendants(sut.rootStack) { view.layoutIfNeeded() }
        // Direct loadView bypasses UIKit containment; deliver the real post-layout callback.
        sut.viewDidLayoutSubviews()
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

@MainActor
private final class AdaptiveCompactHeaderController: KeyboardViewController {
    override var t9PathRowReservation: T9PathRowReservation { .adaptive }
}
