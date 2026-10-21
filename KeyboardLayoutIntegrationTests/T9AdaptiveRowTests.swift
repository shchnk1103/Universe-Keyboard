import UIKit
import XCTest

@testable import KeyboardCore

/// Real production Controller and views, with bootstrap deliberately omitted:
/// this hostless target must not deploy resources or pretend to activate an Extension.
nonisolated final class T9AdaptiveRowTests: XCTestCase {
    @MainActor
    func testIdleCompositionAndRapidRetypePreserveCandidateAndKeys() throws {
        for width: CGFloat in [320, 390, 430] {
            let owner = makeOwner(width: width)
            XCTAssertEqual(owner.keyboardHeightWithoutT9Path, 254)
            XCTAssertEqual(expectedHeight(owner, expanded: true), 288)
            let bar = try XCTUnwrap(owner.t9PinyinPathBarView)
            let request = try XCTUnwrap(owner.keyboardHeightConstraint)
            let candidate = try XCTUnwrap(owner.candidateBar)
            let keys = descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }
            XCTAssertFalse(keys.isEmpty)
            let idle = measure(owner)
            XCTAssertEqual(idle.keys.first?.height, 45)
            XCTAssertEqual(request.constant, expectedHeight(owner, expanded: false))
            XCTAssertEqual(bar.frame.height, 0)
            XCTAssertTrue(bar.isHidden)
            XCTAssertNil(bar.hitTest(CGPoint(x: 20, y: 0), with: nil))
            XCTAssertTrue(bar.accessibilityElementsHidden)

            for _ in 0..<3 {
                owner.refreshT9PinyinPathBar()  // A no-input function/UI refresh is not first input.
                XCTAssertEqual(request.constant, expectedHeight(owner, expanded: false))
            }
            for raw in ["2", "", "6", "64", "", "2", ""] {
                owner.controller.state.t9PinyinPathState = .init(trackedRawInput: raw)
                owner.refreshT9PinyinPathBar()
                layout(owner)
                XCTAssertEqual(request.constant, expectedHeight(owner, expanded: true))
                XCTAssertEqual(bar.frame.height, 34, accuracy: 0.01)
                XCTAssertFalse(bar.isHidden)
                XCTAssertEqual(owner.rootStack.frame.height, request.constant - 2, accuracy: 0.01)
                let next = measure(owner)
                XCTAssertEqual(next.candidate.size, idle.candidate.size)
                XCTAssertEqual(next.candidate.height, KeyboardDesignTokens.CandidateBar.totalHeight, accuracy: 0.01)
                XCTAssertEqual(
                    next.candidate.minY - request.constant,
                    idle.candidate.minY - expectedHeight(owner, expanded: false), accuracy: 0.01)
                XCTAssertEqual(next.keys.count, idle.keys.count)
                for (before, after) in zip(idle.keys, next.keys) {
                    XCTAssertEqual(after.size, before.size)
                    XCTAssertEqual(after.minY - next.candidate.maxY, before.minY - idle.candidate.maxY, accuracy: 0.01)
                }
                XCTAssertTrue(owner.keyboardHeightConstraint === request)
                XCTAssertTrue(owner.candidateBar === candidate)
                XCTAssertEqual(
                    descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }.map(ObjectIdentifier.init),
                    keys.map(ObjectIdentifier.init))
                XCTAssertEqual(request.priority, .defaultHigh)
                print(
                    "UI2_GEOMETRY width=\(width) raw=\(raw) root=\(owner.rootStack.frame) target=\(request.constant) path=\(bar.frame) candidate=\(next.candidate) first=\(next.keys.first!) bottom=\(owner.t9SpaceButton!.convert(owner.t9SpaceButton!.bounds, to: owner.view))"
                )
            }
        }
    }

    @MainActor
    func testConservativeSignalsRecoveryAndLayoutSwitches() throws {
        let owner = makeOwner(width: 390)
        let snapshots: [T9CompositionPresentationSnapshot] = [
            .init(sourceDigits: "64"), .init(rimeRawInput: "ni"),
            .init(confirmedSyllables: ["ni"]), .init(lockedLetterPrefix: "n"),
            .init(provisionalPathID: "pending"), .init(visiblePreedit: "ni"),
            .init(compositionPreedit: "ni"),
            .init(paths: [.init(id: "path", displayText: "ni", replacementRawInput: "ni")]),
        ]
        for snapshot in snapshots {
            XCTAssertTrue(owner.shouldShowT9PinyinPathBar(snapshot))
        }
        XCTAssertFalse(owner.shouldShowT9PinyinPathBar(.init(candidates: [.init(text: "联想")])))
        for terminal in [false, true] {
            let blockedOwner = makeOwner(width: 390)
            blockedOwner.controller.t9ExactRetypeRecovery.freeze(
                verifiedDigits: "64",
                namespace: .init(ownerID: UUID(), sessionEpoch: 1, editingGeneration: 0),
                terminal: terminal)
            blockedOwner.refreshT9InputRecoveryPresentation()
            layout(blockedOwner)
            XCTAssertEqual(blockedOwner.t9PinyinPathBarView?.frame.height, 34)
            XCTAssertFalse(try XCTUnwrap(blockedOwner.t9PinyinPathBarView).isUserInteractionEnabled)
            XCTAssertFalse(try XCTUnwrap(blockedOwner.returnButton).isEnabled)
        }
        owner.controller.partialCommitFailureRecovery = .init(ownerID: UUID(), editingGeneration: 0)
        owner.refreshT9InputRecoveryPresentation()
        layout(owner)
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 34)
        XCTAssertFalse(try XCTUnwrap(owner.t9PinyinPathBarView).isUserInteractionEnabled)
        XCTAssertFalse(try XCTUnwrap(owner.t9SelectPinyinButton).isEnabled)
        XCTAssertFalse(try XCTUnwrap(owner.t9SpaceButton).isEnabled)
        XCTAssertTrue(
            descendants(owner.candidateBar).compactMap { $0 as? UILabel }.contains {
                $0.text == owner.controller.compositionInputRecoveryMessage && !$0.isHidden
            })
        owner.controller.partialCommitFailureRecovery = nil
        owner.refreshT9InputRecoveryPresentation()
        layout(owner)
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 34)
        XCTAssertTrue(try XCTUnwrap(owner.t9SpaceButton).isEnabled)
        for page: KeyboardPage in [.numbers, .symbols, .emoji, .letters] {
            owner.controller.state.currentPage = page
            owner.reloadKeyboard()
            layout(owner)
            XCTAssertEqual(
                owner.keyboardHeightConstraint?.constant,
                page == .letters ? expectedHeight(owner, expanded: true) : expectedHeight(owner, expanded: false))
            XCTAssertEqual(owner.t9PinyinPathBarView != nil, page == .letters)
        }
        owner.cachedLayoutStyle = .twentySixKey
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertNil(owner.t9PinyinPathBarView)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, expectedHeight(owner, expanded: false))
        owner.cachedLayoutStyle = .nineKey
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 34)
        owner.controller.state.t9PinyinPathState = .init(trackedRawInput: "64")
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 34)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, expectedHeight(owner, expanded: true))
        owner.cachedT9ReadinessMatched = false
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertNil(owner.t9PinyinPathBarView)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, expectedHeight(owner, expanded: false))
    }

    @MainActor
    func testExpandedPanelTracksRootAndRestoresBothRowStates() throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        let owner = makeOwner(width: 390)
        for raw in ["", "64"] {
            newPresentation(owner)
            owner.controller.state.t9PinyinPathState = .init(trackedRawInput: raw)
            owner.refreshT9PinyinPathBar()
            layout(owner)
            owner.controller.state.t9PinyinPathState = .init(trackedRawInput: "64")
            owner.refreshT9PinyinPathBar()
            layout(owner)
            let before = measure(owner)
            owner.isCandidateExpanded = true
            owner.presentExpandedCandidatePanel()
            layout(owner)
            let panel = try XCTUnwrap(owner.candidateExpandedPanel)
            assertPanelGeometry(owner, panel: panel)
            XCTAssertTrue(descendants(panel).compactMap { $0 as? UIButton }.contains { $0.isEnabled })
            // Dynamic state changes keep the existing overlay pinned to the root.
            for transientRaw in ["64", "", raw] {
                owner.controller.state.t9PinyinPathState = .init(trackedRawInput: transientRaw)
                owner.refreshT9PinyinPathBar()
                layout(owner)
                assertPanelGeometry(owner, panel: panel)
            }
            // An empty catalog during composition must not resize the overlay.
            owner.refreshT9PinyinPathBar()
            layout(owner)
            assertPanelGeometry(owner, panel: panel)
            owner.isCandidateExpanded = false
            owner.dismissExpandedCandidatePanel(animated: false)
            layout(owner)
            XCTAssertEqual(measure(owner).candidate, before.candidate)
            XCTAssertEqual(measure(owner).keys, before.keys)
            XCTAssertTrue(owner.rootStack.isUserInteractionEnabled)
        }
    }

    @MainActor
    func testQA001HiddenViewportPublishesFirstCellsWithoutSecondInput() throws {
        let receiver = PathReceiver()
        let bar = T9PinyinPathBarView(
            height: 34, target: receiver, selectAction: #selector(PathReceiver.select(_:)))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 100))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
            bar.topAnchor.constraint(equalTo: host.view.topAnchor),
            bar.widthAnchor.constraint(equalToConstant: 376),
        ])
        bar.setRowVisible(false)
        bar.setPaths([], selected: nil, compositionRevision: 0)
        window.isHidden = false
        defer { window.isHidden = true }
        host.view.layoutIfNeeded()
        XCTAssertEqual(bar.bounds.height, 0)
        let collection = try XCTUnwrap(descendants(bar).compactMap { $0 as? UICollectionView }.first)
        let first = T9PinyinPath(displayText: "m", replacementRawInput: "m")
        // Production binds the model before unhiding the row. Only normal parent
        // layout follows: no test-side collection reload or forced Cell layout.
        let reloadsBeforeFirstPath = bar.debugPathReloadCount
        bar.setPaths([first], selected: first, compositionRevision: 1)
        XCTAssertEqual(bar.debugPathReloadCount, reloadsBeforeFirstPath + 1)
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        XCTAssertTrue(collection.visibleCells.isEmpty)
        XCTAssertEqual(bar.debugPathReloadCount, reloadsBeforeFirstPath + 1)
        bar.setRowVisible(true)
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        XCTAssertEqual(bar.bounds.height, 34)
        XCTAssertEqual(bar.debugPathReloadCount, reloadsBeforeFirstPath + 2)
        bar.setNeedsLayout()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        XCTAssertEqual(bar.debugPathReloadCount, reloadsBeforeFirstPath + 2, "Ordinary layout must not reload again")
        let cell = try XCTUnwrap(collection.cellForItem(at: IndexPath(item: 0, section: 0)))
        let label = try XCTUnwrap(descendants(cell).compactMap { $0 as? UILabel }.first { $0.text == "m" })
        XCTAssertFalse(label.isHidden)
        XCTAssertGreaterThan(label.alpha, 0)
        XCTAssertGreaterThan(label.bounds.height, 0)
        XCTAssertTrue(collection.bounds.intersects(cell.frame))

        let next = T9PinyinPath(displayText: "ma", replacementRawInput: "ma")
        bar.setPaths([next], selected: next, compositionRevision: 2)
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        XCTAssertTrue(
            collection.visibleCells.contains { cell in
                descendants(cell).compactMap { $0 as? UILabel }.contains { $0.text == "ma" }
            })
        bar.setPaths([], selected: nil, compositionRevision: 3)
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        XCTAssertTrue(collection.visibleCells.isEmpty)
        XCTAssertEqual(bar.bounds.height, 34)
        bar.setRowVisible(false)
        host.view.layoutIfNeeded()
        XCTAssertEqual(bar.bounds.height, 0)
        XCTAssertNil(bar.hitTest(CGPoint(x: 20, y: 10), with: nil))
    }

    @MainActor
    func testHiddenPathShrinkEmptyAndRepeatedShowKeepCollectionConsistent() throws {
        let receiver = PathReceiver()
        let bar = T9PinyinPathBarView(
            height: 34, target: receiver, selectAction: #selector(PathReceiver.select(_:)))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 100))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
            bar.topAnchor.constraint(equalTo: host.view.topAnchor),
            bar.widthAnchor.constraint(equalToConstant: 376),
        ])
        window.isHidden = false
        defer { window.isHidden = true }
        let collection = try XCTUnwrap(descendants(bar).compactMap { $0 as? UICollectionView }.first)
        let paths = ["m", "n", "o"].map { T9PinyinPath(displayText: $0, replacementRawInput: $0) }
        bar.setRowVisible(true)
        bar.setPaths(paths, selected: nil, compositionRevision: 1)
        host.view.layoutIfNeeded()
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 3)
        XCTAssertEqual(collection.visibleCells.count, 3)

        for cycle in 0..<3 {
            bar.setRowVisible(false)
            host.view.layoutIfNeeded()
            bar.setPaths([paths[0]], selected: nil, compositionRevision: UInt64(2 + cycle * 3))
            let cachedCount = collection.numberOfItems(inSection: 0)
            XCTAssertEqual(cachedCount, 1, "Hidden reload must synchronize UIKit's cached item count")
            // Preserve an assertion failure on the old patch without deliberately
            // provoking its stale-index crash in subsequent UIKit invalidation.
            guard cachedCount == 1 else { return }
            collection.collectionViewLayout.invalidateLayout()
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            bar.setRowVisible(true)
            host.view.layoutIfNeeded()
            XCTAssertEqual(collection.visibleCells.count, 1)
            XCTAssertTrue(
                collection.visibleCells.allSatisfy { cell in
                    descendants(cell).compactMap { $0 as? UILabel }.contains { $0.text == "m" }
                })

            bar.setRowVisible(false)
            host.view.layoutIfNeeded()
            bar.setPaths([], selected: nil, compositionRevision: UInt64(3 + cycle * 3), idleHintText: "hint")
            XCTAssertEqual(collection.numberOfItems(inSection: 0), 0)
            XCTAssertTrue(collection.isHidden)
            let hintReloadCount = bar.debugPathReloadCount
            collection.collectionViewLayout.invalidateLayout()
            bar.setRowVisible(true)
            host.view.layoutIfNeeded()
            XCTAssertTrue(collection.visibleCells.isEmpty)
            XCTAssertEqual(bar.bounds.height, 34)
            XCTAssertEqual(bar.debugPathReloadCount, hintReloadCount, "A hidden collection is not a usable viewport")

            // The row is positive-height while the hint hides the collection.
            // A subsequent non-empty publication must restore actual Cell content.
            bar.setPaths(paths, selected: nil, compositionRevision: UInt64(4 + cycle * 3))
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            XCTAssertFalse(collection.isHidden)
            XCTAssertEqual(collection.numberOfItems(inSection: 0), 3)
            XCTAssertEqual(collection.visibleCells.count, 3)
        }
    }

    @MainActor
    func testAtomicSnapshotAndVisiblePathSelectionSurviveCollapse() throws {
        let owner = makeOwner(width: 390)
        let path = T9PinyinPath(displayText: "ni", replacementRawInput: "ni")
        let snapshot = T9CompositionPresentationSnapshot(
            rimeRawInput: "64", selectedPathID: path.id, paths: [path])
        owner.applyT9PresentationSnapshot(snapshot)
        // Deliberately do not alter Core here: the supplied presentation snapshot
        // must determine both row and height without a second state read.
        owner.view.frame.size.height = expectedHeight(owner, expanded: true)
        owner.view.layoutIfNeeded()
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, expectedHeight(owner, expanded: true))
        let bar = try XCTUnwrap(owner.t9PinyinPathBarView)
        XCTAssertEqual(bar.frame.height, 34)
        owner.applyT9PresentationSnapshot(.empty)
        layout(owner)
        XCTAssertEqual(bar.frame.height, 34)
        newPresentation(owner)
        layout(owner)
        XCTAssertEqual(bar.frame.height, 0)
        XCTAssertNil(bar.hitTest(CGPoint(x: 20, y: 10), with: nil))

        // UICollectionView only materializes visible Cells in a window. Attach the
        // view alone: attaching the Controller would invoke real host lifecycle work.
        let receiver = PathReceiver()
        let pathBar = T9PinyinPathBarView(
            height: 34, target: receiver, selectAction: #selector(PathReceiver.select(_:)))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 100))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(pathBar)
        NSLayoutConstraint.activate([
            pathBar.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
            pathBar.topAnchor.constraint(equalTo: host.view.topAnchor),
            pathBar.widthAnchor.constraint(equalToConstant: 376),
        ])
        pathBar.setRowVisible(false)
        pathBar.setPaths([path], selected: path, compositionRevision: 1)
        pathBar.setRowVisible(true)
        window.isHidden = false
        defer { window.isHidden = true }
        host.view.layoutIfNeeded()
        let collection = try XCTUnwrap(descendants(pathBar).compactMap { $0 as? UICollectionView }.first)
        collection.layoutIfNeeded()
        let index = IndexPath(item: 0, section: 0)
        let cell = try XCTUnwrap(collection.cellForItem(at: index))
        XCTAssertTrue(cell.accessibilityTraits.contains(.selected))
        XCTAssertNotNil(pathBar.hitTest(CGPoint(x: 20, y: 10), with: nil))
        pathBar.collectionView(collection, didSelectItemAt: index)
        XCTAssertEqual(receiver.path, path)
        pathBar.setRowVisible(false)
        host.view.layoutIfNeeded()
        XCTAssertEqual(pathBar.frame.height, 0)
        XCTAssertNil(pathBar.hitTest(CGPoint(x: 20, y: 10), with: nil))
        pathBar.setRowVisible(true)
        host.view.layoutIfNeeded()
        XCTAssertEqual(pathBar.frame.height, 34)
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 1)
    }

    @MainActor
    func testOnlyCompletedDetachedPresentationCanResetSticky() throws {
        let owner = makeOwner(width: 390)
        let request = try XCTUnwrap(owner.keyboardHeightConstraint)
        owner.controller.state.currentComposition = "ni"
        owner.refreshT9PinyinPathBar()
        owner.controller.state.currentComposition = ""
        for _ in 0..<3 {
            owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
            owner.beginT9PinyinPresentationIfNeeded()
            owner.refreshT9PinyinPathBar()
            layout(owner)
            XCTAssertEqual(request.constant, expectedHeight(owner, expanded: true))
            XCTAssertTrue(owner.keyboardHeightConstraint === request)
        }
        // Resign/host activity and an attached disappearance cannot prove a new cycle.
        owner.noteT9PinyinPresentationDidDisappear(hasWindow: false)  // gate is appearing
        XCTAssertFalse(owner.hasEndedT9PinyinPresentation)
        owner.hostLifecycleRecoveryGate.noteViewWillDisappear()
        owner.noteT9PinyinPresentationDidDisappear(hasWindow: true)
        owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
        owner.beginT9PinyinPresentationIfNeeded()
        XCTAssertEqual(owner.preferredKeyboardHeight, expectedHeight(owner, expanded: true))
        newPresentation(owner)
        layout(owner)
        XCTAssertEqual(request.constant, expectedHeight(owner, expanded: false))
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 0)
        XCTAssertTrue(owner.keyboardHeightConstraint === request)
        // A new presentation with safety state must expand immediately.
        owner.controller.partialCommitFailureRecovery = .init(ownerID: UUID(), editingGeneration: 0)
        newPresentation(owner)
        layout(owner)
        XCTAssertEqual(request.constant, expectedHeight(owner, expanded: true))
        XCTAssertTrue(owner.hasExpandedT9PinyinRowInPresentation)
        let partialOwner = makeOwner(width: 390)
        partialOwner.controller.state.partialCommit = .init(
            confirmedText: "你", remainingRawInput: "", remainingPreeditText: "", displayText: "")
        newPresentation(partialOwner)
        XCTAssertEqual(partialOwner.keyboardHeightConstraint?.constant, expectedHeight(partialOwner, expanded: true))
        partialOwner.controller.state.partialCommit = nil
        partialOwner.refreshT9PinyinPathBar()
        XCTAssertEqual(partialOwner.keyboardHeightConstraint?.constant, expectedHeight(partialOwner, expanded: true))
    }

    @MainActor
    private func newPresentation(_ owner: KeyboardViewController) {
        // Exercises the production policy with explicit boundary observations;
        // does not claim that a real Extension will deliver this callback sequence.
        owner.hostLifecycleRecoveryGate.noteViewWillDisappear()
        owner.viewDidDisappear(false)
        owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
        owner.beginT9PinyinPresentationIfNeeded()
    }

    /// Baseline also passes this synchronous seam guard: it does not reproduce or clear the native QA-001 finding.
    @MainActor
    func testQA001FirstPathIsVisibleAfterPendingPanelBeforeSecondKey() async throws {
        let animations = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animations) }
        for (kaomoji, stage) in [
            (false, 0), (true, 0), (false, 1), (true, 1), (false, 2), (true, 2), (false, 3), (true, 3),
        ] {
            UIView.setAnimationsEnabled(false)
            let closing = stage == 1 || stage == 2
            let owner = makeOwner(width: 390)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
            let host = UIViewController()
            window.rootViewController = host
            host.view.addSubview(owner.view)
            window.isHidden = false
            defer { window.isHidden = true }
            let input = QA001TextClient()
            owner.controller.textClient = input
            layout(owner)
            XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 0)
            if kaomoji { owner.insertKaomoji(UIButton()) } else { owner.insertT9CommonPunctuation(UIButton()) }
            UIView.setAnimationsEnabled(stage == 3)
            owner.toggleCandidateExpand()
            layout(owner)
            XCTAssertTrue(owner.isCandidateExpanded)
            XCTAssertTrue(
                owner.controller.state.pendingPunctuation != nil || owner.controller.state.pendingKaomoji != nil)
            let panel = try XCTUnwrap(owner.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
            if closing {
                UIView.setAnimationsEnabled(true)
                owner.toggleCandidateExpand()
                XCTAssertTrue(panel.isTransitioning)
            }
            let engine = QA001RimeEngine()
            owner.controller.rimeEngine = engine
            owner.controller.usesT9InputSemantics = true
            let key = try XCTUnwrap(
                descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }.first {
                    $0.accessibilityIdentifier == "6"
                })
            if stage == 2 || stage == 3 {
                let halfway = expectation(description: "real halfway reveal/collapse")
                let full = panel.bounds.height
                let observer = QA001DisplayObserver {
                    guard let shown = panel.revealViewport.layer.presentation()?.bounds.height else { return false }
                    return shown > 46 + (full - 46) * 0.25 && shown < full - (full - 46) * 0.25
                }
                observer.completion = {
                    print(
                        "QA001 halfway presentation=\(panel.revealViewport.layer.presentation()?.bounds.height ?? -1)")
                    owner.insertKey(key)
                    halfway.fulfill()
                }
                observer.start()
                await fulfillment(of: [halfway], timeout: 2)
                observer.stop()
            } else {
                owner.insertKey(key)
            }
            print(
                "QA001 engine=\(engine.keys) raw=\(owner.controller.state.lastRimeOutput?.rawInput ?? "nil") paths=\(owner.controller.t9CompositionPresentationSnapshot().paths.map(\.displayText))"
            )
            XCTAssertEqual(engine.keys, ["6"])
            let firstSnapshot = owner.controller.t9CompositionPresentationSnapshot()
            XCTAssertEqual(firstSnapshot.rimeRawInput, "6")
            XCTAssertEqual(firstSnapshot.paths.map(\.displayText), ["m", "n", "o"])
            XCTAssertEqual(input.marked, "m")
            layout(owner)
            owner.viewDidLayoutSubviews()
            let bar = try XCTUnwrap(owner.t9PinyinPathBarView)
            let collection = try XCTUnwrap(descendants(bar).compactMap { $0 as? UICollectionView }.first)
            collection.layoutIfNeeded()
            XCTAssertEqual(bar.frame.height, 34)
            XCTAssertEqual(collection.numberOfItems(inSection: 0), firstSnapshot.paths.count)
            let cell = try XCTUnwrap(collection.cellForItem(at: IndexPath(item: 0, section: 0)))
            let label = try XCTUnwrap(descendants(cell).compactMap { $0 as? UILabel }.first { $0.text == "m" })
            print(
                "QA001 first model=m row=\(bar.frame) collection=\(collection.frame) cell=\(cell.frame) label=\(label.frame) hidden=\(label.isHidden) alpha=\(label.alpha)"
            )
            XCTAssertFalse(label.isHidden)
            XCTAssertGreaterThan(label.bounds.width, 0)
            XCTAssertGreaterThan(label.bounds.height, 0)
            XCTAssertEqual(label.alpha, 1)
            XCTAssertTrue(collection.bounds.intersects(cell.frame))
            XCTAssertEqual(owner.presentedCandidates.first?.title, "哦")
            XCTAssertEqual(owner.candidateSnapshotRawInput, "6")
            assertPanelGeometry(owner, panel: panel)
            let textPoint = label.convert(CGPoint(x: label.bounds.midX, y: label.bounds.midY), to: owner.rootStack)
            let mask = try XCTUnwrap(owner.rootStack.layer.mask as? CAShapeLayer)
            XCTAssertTrue(mask.path?.contains(textPoint) == true)
            if let visibleMask = mask.presentation() {
                XCTAssertTrue(visibleMask.path?.contains(textPoint) == true)
            }
            for view in [label, cell, collection, bar, owner.rootStack!] {
                XCTAssertFalse(view.isHidden)
                XCTAssertGreaterThan(view.alpha, 0.99)
            }
            if closing || stage == 3 {
                // Wait for production animation completion, not for another input to repair UI.
                let finished = expectation(description: "production collapse removes panel")
                let observation = QA001DisplayObserver {
                    closing ? owner.candidateExpandedPanel == nil : !panel.isTransitioning
                }
                observation.completion = { finished.fulfill() }
                observation.start()
                await fulfillment(of: [finished], timeout: 2)
                observation.stop()
            }
            if !closing {
                UIView.setAnimationsEnabled(false)
                owner.toggleCandidateExpand()
            }
            layout(owner)
            XCTAssertNil(owner.candidateExpandedPanel)
            XCTAssertNil(owner.rootStack.layer.mask)
            XCTAssertEqual(bar.frame.height, 34)
            XCTAssertEqual(label.text, "m")
            let keyPoint = key.convert(CGPoint(x: key.bounds.midX, y: key.bounds.midY), to: owner.view)
            let hit = owner.view.hitTest(keyPoint, with: nil)
            XCTAssertTrue(hit === key || hit?.isDescendant(of: key) == true)
            owner.insertKey(key)
            layout(owner)
            XCTAssertEqual(engine.keys, ["6", "6"])
            XCTAssertEqual(owner.controller.state.lastRimeOutput?.rawInput, "66")
            XCTAssertEqual(input.marked, "mo")
            XCTAssertEqual(bar.frame.height, 34)
        }
    }

    #if DEBUG
        @MainActor
        func testDeviceTraceIsExplicitBoundedAndNeverExportsText() throws {
            let owner = makeOwner(width: 390)
            let trace = T9QA001DeviceTrace.shared
            T9QA001DeviceTrace.arm()
            T9QA001DeviceTrace.stop()
            trace.begin(owner: owner, event: 10)
            func exported() throws -> [String: Any] {
                let data = try XCTUnwrap(T9QA001DeviceTrace.report().data(using: .utf8))
                return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
            }
            XCTAssertEqual((try exported()["records"] as? [Any])?.count, 0)
            let privateText = "PRIVATE_SENTINEL_DO_NOT_EXPORT"
            owner.controller.state.currentComposition = privateText
            let path = T9PinyinPath(displayText: privateText, replacementRawInput: privateText)
            let snapshot = T9CompositionPresentationSnapshot(revision: 23, rimeRawInput: privateText, paths: [path])
            T9QA001DeviceTrace.arm()
            defer { T9QA001DeviceTrace.stop() }
            trace.begin(owner: owner, event: 11)
            trace.model(snapshot, owner: owner)
            owner.applyT9PresentationSnapshot(snapshot)
            let label = UILabel()
            label.text = privateText
            trace.bar(.label, bar: try XCTUnwrap(owner.t9PinyinPathBarView), label: label)
            T9QA001DeviceTrace.sawBlank()
            let report = T9QA001DeviceTrace.report()
            XCTAssertFalse(report.contains(privateText))
            XCTAssertTrue(report.contains("T2_MODEL_CAPTURED"))
            XCTAssertTrue(report.contains("T4_LABEL_CONFIGURED"))
            XCTAssertTrue(report.contains("T7_HUMAN"))
            XCTAssertEqual(try exported()["nativeOperationReturnObserved"] as? Bool, false)
            for _ in 0..<150 { trace.record(.returned, owner: owner) }
            let bounded = try exported()
            XCTAssertEqual((bounded["records"] as? [Any])?.count, 128)
            XCTAssertGreaterThan(try XCTUnwrap(bounded["dropped"] as? Int), 0)
            XCTAssertEqual(bounded["triageHint"] as? String, "INCONCLUSIVE")
            trace.begin(owner: owner, event: 12)
            trace.begin(owner: owner, event: 13)
            XCTAssertEqual(try exported()["keysCaptured"] as? Int, 2)
            XCTAssertEqual(try exported()["armed"] as? Bool, false)
            XCTAssertNotNil(NSClassFromString("DebugT9QA001Trace"))
            for name in ["arm", "report", "sawBlank", "sawVisible", "stop"] {
                XCTAssertTrue(T9QA001DeviceTrace.responds(to: NSSelectorFromString(name)))
            }
        }

    #endif

    @MainActor
    private func expectedHeight(_ owner: KeyboardViewController, expanded: Bool) -> CGFloat {
        owner.keyboardHeightWithoutT9Path + (expanded ? owner.t9PinyinPathBarHeight : 0)
    }

    @MainActor
    private func assertPanelGeometry(_ owner: KeyboardViewController, panel: UIView) {
        let frame = panel.convert(panel.bounds, to: owner.view)
        let surface = owner.keyboardSurfaceView.convert(owner.keyboardSurfaceView.bounds, to: owner.view)
        let candidate = owner.candidateBar.convert(owner.candidateBar.bounds, to: owner.view)
        let root = owner.rootStack.convert(owner.rootStack.bounds, to: owner.view)
        XCTAssertEqual(frame.minY, candidate.minY, accuracy: 0.01)
        XCTAssertEqual(frame.maxY, root.maxY, accuracy: 0.01)
        XCTAssertEqual(frame.minX, surface.minX, accuracy: 0.01)
        XCTAssertEqual(frame.maxX, surface.maxX, accuracy: 0.01)
    }

    @MainActor
    private func makeOwner(width: CGFloat) -> LayoutController {
        let owner = LayoutController()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.cachedLayoutStyle = .nineKey
        owner.cachedT9ReadinessMatched = true
        owner.view.frame = CGRect(x: 0, y: 0, width: width, height: expectedHeight(owner, expanded: false))
        owner.setupRootStack()
        owner.reloadKeyboard()
        layout(owner)
        return owner
    }

    @MainActor
    private func layout(_ owner: KeyboardViewController) {
        owner.view.frame.size.height = owner.preferredKeyboardHeight
        owner.view.setNeedsLayout()
        owner.view.layoutIfNeeded()
    }

    @MainActor
    private func descendants(_ view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }

    @MainActor
    private func measure(_ owner: KeyboardViewController) -> (candidate: CGRect, keys: [CGRect]) {
        (
            owner.candidateBar.convert(owner.candidateBar.bounds, to: owner.view),
            descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }.map {
                $0.convert($0.bounds, to: owner.view)
            }
        )
    }
}

@MainActor
private final class LayoutController: KeyboardViewController {
    override func viewDidLoad() {
        // No bootstrap/session/host side effects in process-local geometry tests.
    }
}

@MainActor
private final class PathReceiver: NSObject {
    var path: T9PinyinPath?
    @objc func select(_ sender: T9PinyinPathButton) { path = sender.path }
}

/// Synchronous engine seam only; it does not represent a native librime session.
private final class QA001RimeEngine: RimeEngine {
    var keys: [String] = []
    var raw = ""
    var runtimeSelection: RimeRuntimeSelection? { nil }
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)?
    func output() -> RimeOutput {
        RimeOutput(
            rawInput: raw, composition: .init(preeditText: raw == "6" ? "m" : "mo", cursorPosition: raw.count),
            candidates: [.init(text: "哦", comment: raw == "6" ? "m" : "mo")])
    }
    func processKey(_ key: String) -> RimeOutput { keys.append(key); raw += key; return output() }
    func replaceInput(_ input: String) -> RimeOutput { raw = input; return output() }
    func selectCandidate(at index: Int) -> RimeOutput { output() }
    func selectCandidate(globalIndex index: Int) -> RimeOutput { output() }
    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        .init(candidates: [], startIndex: globalIndex, nextIndex: globalIndex, hasMoreCandidates: false)
    }
    func deleteBackward() -> RimeOutput { if !raw.isEmpty { raw.removeLast() }; return output() }
    func resetSession() { raw = "" }
    func recoverSession() {}
    func suspendForVisibilityChange() {}
    func resumeAfterVisibilityChange() {}
    func isComposing() -> Bool { !raw.isEmpty }
    func pageUp() -> RimeOutput { output() }
    func pageDown() -> RimeOutput { output() }
}

@MainActor
private final class QA001TextClient: TextInputClient {
    var text = ""
    var marked = ""
    var hasTextBeforeInput: Bool { !text.isEmpty || !marked.isEmpty }
    func insertText(_ value: String) { text += value }
    func deleteBackward() { if !text.isEmpty { text.removeLast() } }
    func adjustTextPosition(byCharacterOffset offset: Int) {}
    func setMarkedText(_ value: String, selectedRange: Range<Int>) { marked = value }
    func unmarkText() { text += marked; marked = "" }
}

/// Waits for actual display/animation state, without a fixed sleep or product timing patch.
@MainActor
private final class QA001DisplayObserver: NSObject {
    let condition: () -> Bool
    var completion: (() -> Void)?
    private var link: CADisplayLink?
    init(condition: @escaping () -> Bool) { self.condition = condition }
    func start() {
        let link = CADisplayLink(target: self, selector: #selector(tick))
        self.link = link
        link.add(to: .main, forMode: .common)
    }
    func stop() { link?.invalidate(); link = nil }
    @objc private func tick() {
        if condition() { stop(); completion?() }
    }
}
