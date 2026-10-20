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
            let bar = try XCTUnwrap(owner.t9PinyinPathBarView)
            let request = try XCTUnwrap(owner.keyboardHeightConstraint)
            let candidate = try XCTUnwrap(owner.candidateBar)
            let keys = descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }
            XCTAssertFalse(keys.isEmpty)
            let idle = measure(owner)
            XCTAssertEqual(idle.keys.first?.height, 45)
            XCTAssertEqual(request.constant, 256)
            XCTAssertEqual(bar.frame.height, 0)
            XCTAssertTrue(bar.isHidden)
            XCTAssertNil(bar.hitTest(CGPoint(x: 20, y: 0), with: nil))
            XCTAssertTrue(bar.accessibilityElementsHidden)

            for raw in ["2", "", "6", "64", "", "2", ""] {
                owner.controller.state.t9PinyinPathState = .init(trackedRawInput: raw)
                owner.refreshT9PinyinPathBar()
                layout(owner)
                let active = !raw.isEmpty
                XCTAssertEqual(request.constant, active ? 290 : 256)
                XCTAssertEqual(bar.frame.height, active ? 34 : 0, accuracy: 0.01)
                XCTAssertEqual(bar.isHidden, !active)
                XCTAssertEqual(owner.rootStack.frame.height, request.constant - 2, accuracy: 0.01)
                let next = measure(owner)
                XCTAssertEqual(next.candidate.size, idle.candidate.size)
                XCTAssertEqual(next.candidate.height, 48, accuracy: 0.01)
                XCTAssertEqual(next.candidate.minY - request.constant, idle.candidate.minY - 256, accuracy: 0.01)
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
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 0)
        XCTAssertTrue(try XCTUnwrap(owner.t9SpaceButton).isEnabled)
        for page: KeyboardPage in [.numbers, .symbols, .emoji, .letters] {
            owner.controller.state.currentPage = page
            owner.reloadKeyboard()
            layout(owner)
            XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 256)
            XCTAssertEqual(owner.t9PinyinPathBarView != nil, page == .letters)
        }
        owner.cachedLayoutStyle = .twentySixKey
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertNil(owner.t9PinyinPathBarView)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 256)
        owner.cachedLayoutStyle = .nineKey
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 0)
        owner.controller.state.t9PinyinPathState = .init(trackedRawInput: "64")
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertEqual(owner.t9PinyinPathBarView?.frame.height, 34)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 290)
        owner.cachedT9ReadinessMatched = false
        owner.reloadKeyboard()
        layout(owner)
        XCTAssertNil(owner.t9PinyinPathBarView)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 256)
    }

    @MainActor
    func testExpandedPanelTracksRootAndRestoresBothRowStates() throws {
        let owner = makeOwner(width: 390)
        for raw in ["", "64"] {
            owner.controller.state.t9PinyinPathState = .init(trackedRawInput: raw)
            owner.refreshT9PinyinPathBar()
            layout(owner)
            let before = measure(owner)
            owner.isCandidateExpanded = true
            owner.presentExpandedCandidatePanel()
            layout(owner)
            let panel = try XCTUnwrap(owner.candidateExpandedPanel)
            XCTAssertEqual(panel.frame, owner.rootStack.frame)
            XCTAssertTrue(descendants(panel).compactMap { $0 as? UIButton }.contains { $0.isEnabled })
            // Dynamic state changes keep the existing overlay pinned to the root.
            for transientRaw in ["64", "", raw] {
                owner.controller.state.t9PinyinPathState = .init(trackedRawInput: transientRaw)
                owner.refreshT9PinyinPathBar()
                layout(owner)
                XCTAssertEqual(panel.frame, owner.rootStack.frame)
            }
            // An empty catalog during composition must not resize the overlay.
            owner.refreshT9PinyinPathBar()
            layout(owner)
            XCTAssertEqual(panel.frame, owner.rootStack.frame)
            owner.isCandidateExpanded = false
            owner.dismissExpandedCandidatePanel(animated: false)
            layout(owner)
            XCTAssertEqual(measure(owner).candidate, before.candidate)
            XCTAssertEqual(measure(owner).keys, before.keys)
            XCTAssertTrue(owner.rootStack.isUserInteractionEnabled)
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
        owner.view.frame.size.height = 290
        owner.view.layoutIfNeeded()
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 290)
        let bar = try XCTUnwrap(owner.t9PinyinPathBarView)
        XCTAssertEqual(bar.frame.height, 34)
        owner.applyT9PresentationSnapshot(.empty)
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
    private func makeOwner(width: CGFloat) -> LayoutController {
        let owner = LayoutController()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.cachedLayoutStyle = .nineKey
        owner.cachedT9ReadinessMatched = true
        owner.view.frame = CGRect(x: 0, y: 0, width: width, height: 256)
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
