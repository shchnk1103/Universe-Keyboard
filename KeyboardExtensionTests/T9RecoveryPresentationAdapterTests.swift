import UIKit
import XCTest

@testable import KeyboardCore

/// Production adapter + real Core state and UIKit controls, with recorded
/// panel/selection dependencies. This is not the real Extension controller.
nonisolated final class T9RecoveryPresentationAdapterTests: XCTestCase {
    @MainActor
    func testCheckpointFailureBlocksPresentationIndependentlyOfR174() throws {
        let f = Fixture()
        // Controlled Core state for the production presentation adapter only;
        // the actual checkpoint-failure entry is exercised in Core tests.
        f.owner.controller.partialCommitFailureRecovery = .init(ownerID: UUID(), editingGeneration: 0)
        XCTAssertFalse(f.owner.controller.isT9InputRecoveryPending)
        f.owner.accumulatedCandidates = [CandidateItem(title: "旧候选", kind: .candidate)]
        f.owner.hasMoreCandidates = true
        f.owner.refreshT9InputRecoveryPresentation()
        f.assertBlocked()
        XCTAssertTrue(f.owner.accumulatedCandidates.isEmpty)
        XCTAssertFalse(f.owner.hasMoreCandidates)
        XCTAssertEqual(try f.notice().text, "输入恢复失败，按删除取消未确认拼音后重新输入")
        XCTAssertTrue(f.digit.isEnabled)
        XCTAssertTrue(f.delete.isEnabled)
        f.owner.controller.state.inputMode = .english
        f.owner.refreshT9InputRecoveryPresentation()
        XCTAssertFalse(f.owner.shouldBlockT9RecoveryPresentation)
        XCTAssertTrue(f.returnKey.isEnabled)
        XCTAssertTrue(f.owner.controller.isCompositionInputRecoveryPending)
        f.owner.controller.state.inputMode = .chinese
        f.returnKey.isEnabled = true
        f.owner.refreshT9InputRecoveryPresentation()
        f.assertBlocked()
    }

    @MainActor
    func testWaitingAndFailedBlockControlsAndInvalidateOldCandidates() throws {
        for terminal in [false, true] {
            let f = Fixture()
            f.freeze(terminal: terminal)
            f.owner.isCandidateExpanded = true
            f.owner.isPinyinPathExpanded = true
            f.owner.accumulatedCandidates = [CandidateItem(title: "旧候选", kind: .candidate)]
            f.owner.candidateCellSizeCache["old"] = CGSize(
                width: 100, height: KeyboardDesignTokens.CandidateBar.normalCellHeight)
            f.owner.hasMoreCandidates = true
            f.owner.isLoadingMoreCandidates = true
            f.owner.deferredCandidatePrefetchMode = .expanded
            f.owner.nextCandidateGlobalIndex = 12
            let generation = f.owner.candidateSnapshotGeneration
            let serial = f.owner.candidatePrefetchRequestSerial
            f.owner.refreshT9InputRecoveryPresentation()
            XCTAssertTrue(f.owner.shouldBlockT9RecoveryPresentation)
            XCTAssertEqual(f.owner.candidateSnapshotGeneration, generation + 1)
            XCTAssertEqual(f.owner.candidatePrefetchRequestSerial, serial + 1)
            XCTAssertTrue(f.owner.accumulatedCandidates.isEmpty)
            XCTAssertTrue(f.owner.candidateCellSizeCache.isEmpty)
            XCTAssertFalse(f.owner.hasMoreCandidates)
            XCTAssertFalse(f.owner.isLoadingMoreCandidates)
            XCTAssertNil(f.owner.deferredCandidatePrefetchMode)
            XCTAssertEqual(f.owner.nextCandidateGlobalIndex, 0)
            XCTAssertEqual(f.owner.candidatePanelDismissals, 1)
            XCTAssertEqual(f.owner.pathPanelDismissals, 1)
            XCTAssertFalse(f.owner.isCandidateExpanded)
            XCTAssertFalse(f.owner.isPinyinPathExpanded)
            XCTAssertEqual(try f.notice().text, f.owner.controller.t9InputRecoveryMessage)
            XCTAssertFalse(try f.notice().isHidden)
            f.assertBlocked()
            XCTAssertTrue(f.digit.isEnabled)
            XCTAssertTrue(f.delete.isEnabled)
            XCTAssertTrue(f.owner.view.isUserInteractionEnabled)
        }
    }

    @MainActor
    func testLaterOrdinaryRefreshCannotLeaveSubmitEnabledWhilePending() {
        let f = Fixture()
        f.freeze(terminal: false)
        f.owner.refreshT9InputRecoveryPresentation()
        // Simulate an external refresh before the production adapter's tail call.
        f.space.isEnabled = true
        f.select.isEnabled = true
        f.returnKey.isEnabled = true
        f.bar.expandButton.isHidden = false
        f.owner.refreshT9InputRecoveryPresentation()
        f.assertBlocked()
        XCTAssertTrue(f.bar.expandButton.isHidden)
    }

    @MainActor
    func testVerifiedClearRestoresControlsAndRefreshesSelectionDependency() throws {
        let f = Fixture()
        f.freeze(terminal: true)
        f.owner.refreshT9InputRecoveryPresentation()
        // Controlled trusted-state transition, not a native recoverSession call.
        f.owner.controller.t9ExactRetypeRecovery = T9ExactRetypeRecovery()
        f.owner.refreshT9InputRecoveryPresentation()
        XCTAssertFalse(f.owner.shouldBlockT9RecoveryPresentation)
        XCTAssertTrue(f.space.isEnabled)
        XCTAssertTrue(f.select.isEnabled)
        XCTAssertTrue(f.returnKey.isEnabled)
        XCTAssertTrue(f.path.isUserInteractionEnabled)
        XCTAssertEqual(f.owner.selectionAvailabilityRefreshes, 1)
        XCTAssertEqual(f.select.alpha, 1)
        XCTAssertFalse(f.bar.collectionView.isHidden)
        XCTAssertTrue(f.bar.expandButton.isEnabled)
        XCTAssertTrue(try f.notice().isHidden)
        XCTAssertNil(try f.notice().accessibilityLabel)
        XCTAssertTrue(f.owner.accumulatedCandidates.isEmpty)
    }

    @MainActor
    func testFreshSessionIsolationAllowsEnglishAndSymbolsButBlocksChineseReturn() throws {
        let f = Fixture()
        f.freeze(terminal: true)
        f.owner.controller.t9ExactRetypeRecovery.didCancelSegment(namespace: f.namespace)
        f.owner.refreshT9InputRecoveryPresentation()
        f.assertBlocked()
        XCTAssertTrue(f.owner.controller.isT9InputRecoveryPending)
        f.owner.controller.state.inputMode = .english
        f.owner.refreshT9InputRecoveryPresentation()
        XCTAssertFalse(f.owner.shouldBlockT9RecoveryPresentation)
        XCTAssertTrue(f.returnKey.isEnabled)
        XCTAssertTrue(f.space.isEnabled)
        XCTAssertTrue(try f.notice().isHidden)
        XCTAssertTrue(f.owner.controller.isT9InputRecoveryPending)

        f.owner.controller.state.inputMode = .chinese
        f.owner.controller.state.currentPage = .symbols
        f.owner.refreshT9InputRecoveryPresentation()
        XCTAssertFalse(f.owner.shouldBlockT9RecoveryPresentation)
        XCTAssertTrue(f.returnKey.isEnabled)

        f.owner.controller.state.currentPage = .letters
        f.owner.refreshT9InputRecoveryPresentation()
        f.assertBlocked()
        XCTAssertEqual(try f.notice().text, "当前拼音已取消，请重新输入")
        XCTAssertTrue(f.owner.controller.isT9InputRecoveryPending)
    }

    @MainActor
    func testIdleRefreshPreservesUnrelatedReturnAndSelectionRestrictions() {
        let f = Fixture()
        f.returnKey.isEnabled = false
        f.select.isEnabled = false
        f.owner.refreshT9InputRecoveryPresentation()
        XCTAssertFalse(f.returnKey.isEnabled)
        XCTAssertFalse(f.select.isEnabled)
        XCTAssertEqual(f.owner.selectionAvailabilityRefreshes, 0)
    }

    @MainActor
    private final class Fixture {
        let owner = KeyboardViewController()
        let bar = CandidateBarView(
            backgroundColor: .clear,
            interactionTarget: nil, expandAction: NSSelectorFromString("unused"))
        let space = UIButton()
        let select = UIButton()
        let returnKey = UIButton()
        let digit = UIButton()
        let delete = UIButton()
        let path = UIView()
        let namespace = T9ExactRetypeRecovery.Namespace(
            ownerID: UUID(), sessionEpoch: 1, editingGeneration: 0)

        init() {
            owner.controller.state.inputMode = .chinese
            owner.controller.state.currentPage = .letters
            owner.candidateBar = bar
            owner.candidateCollectionView = bar.collectionView
            owner.t9PinyinPathBarView = path
            owner.t9SpaceButton = space
            owner.t9SelectPinyinButton = select
            owner.returnButton = returnKey
            for view in [bar, space, select, returnKey, digit, delete, path] {
                owner.view.addSubview(view)
            }
        }

        func freeze(terminal: Bool) {
            owner.controller.t9ExactRetypeRecovery.freeze(
                verifiedDigits: "94624", namespace: namespace, terminal: terminal)
        }

        func notice() throws -> UILabel {
            try XCTUnwrap(
                bar.subviews.compactMap { $0 as? UILabel }.first {
                    $0.accessibilityIdentifier == "t9.input-recovery.notice"
                })
        }

        func assertBlocked(file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertFalse(space.isEnabled, file: file, line: line)
            XCTAssertFalse(select.isEnabled, file: file, line: line)
            XCTAssertFalse(returnKey.isEnabled, file: file, line: line)
            XCTAssertFalse(path.isUserInteractionEnabled, file: file, line: line)
            XCTAssertFalse(bar.collectionView.isUserInteractionEnabled, file: file, line: line)
            XCTAssertFalse(bar.expandButton.isEnabled, file: file, line: line)
        }
    }
}
