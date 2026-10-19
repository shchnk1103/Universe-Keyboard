import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// A cancelled unknown session may coexist with ordinary English/symbol entry.
    var shouldBlockT9RecoveryPresentation: Bool {
        controller.isCompositionInputRecoveryPending
            && controller.state.inputMode == .chinese && controller.state.currentPage == .letters
    }

    func invalidateCandidatesForInputRecovery() {
        candidateSnapshotGeneration += 1
        candidatePrefetchRequestSerial += 1
        accumulatedCandidates.removeAll(keepingCapacity: true)
        candidateCellSizeCache.removeAll(keepingCapacity: true)
        hasMoreCandidates = false
        isLoadingMoreCandidates = false
        deferredCandidatePrefetchMode = nil
        nextCandidateGlobalIndex = 0
    }

    /// Runs after the usual presentation refresh so no later refresh re-enables a blocked control.
    func refreshT9InputRecoveryPresentation() {
        let blocked = shouldBlockT9RecoveryPresentation
        if blocked {
            invalidateCandidatesForInputRecovery()
            if isCandidateExpanded {
                isCandidateExpanded = false
                dismissExpandedCandidatePanel(animated: false)
            }
            if isPinyinPathExpanded { dismissPinyinPathExpandedPanel(animated: false) }
            candidateCollectionView?.reloadData()
            expandedCandidateCollectionView?.reloadData()
        }
        (candidateBar as? CandidateBarView)?.setInputRecoveryNotice(
            blocked ? controller.compositionInputRecoveryMessage : nil)
        t9PinyinPathBarView?.isUserInteractionEnabled = !blocked
        t9SpaceButton?.isEnabled = !blocked
        if blocked {
            t9SelectPinyinButton?.isEnabled = false
            t9SelectPinyinButton?.alpha = 0.45
        } else if wasT9RecoveryPresentationBlocked {
            updateSelectPinyinButtonAvailability()
        }
        // An unrelated Return refresh may run before this one; only restore a
        // button that this recovery presentation previously disabled.
        if blocked || wasT9RecoveryPresentationBlocked {
            returnButton?.isEnabled = !blocked
        }
        if blocked || wasT9RecoveryPresentationBlocked {
            // Custom keyboard-key traits do not automatically publish UIButton's
            // disabled state. Keep AX aligned with the real control without
            // changing its keyboard-key role or unrelated disabled state.
            for case let button? in [t9SpaceButton, t9SelectPinyinButton, returnButton] {
                let unavailable = button.accessibilityTraits.contains(.notEnabled)
                if button.isEnabled, unavailable {
                    button.accessibilityTraits.remove(.notEnabled)
                } else if !button.isEnabled, !unavailable {
                    button.accessibilityTraits.insert(.notEnabled)
                }
            }
        }
        wasT9RecoveryPresentationBlocked = blocked
    }
}
