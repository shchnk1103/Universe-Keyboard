import KeyboardCore
import UIKit

extension KeyboardViewController {
    #if DEBUG
        /// Correlates a UIKit pointer terminal with lifecycle/candidate state.
        /// `role` is deliberately coarse so diagnostics never record a typed key.
        func recordKeyboardTrackingDiagnostic(
            button: KeyboardKeyButton,
            phase: KeyboardKeyTrackingPhase
        ) {
            let role: String
            if button === shiftButton {
                role = "shift"
            } else if button === returnButton {
                role = "return"
            } else if button === nextKeyboardButton {
                role = "nextKeyboard"
            } else if button === t9SpaceButton {
                role = "space"
            } else {
                switch button.visualStyle {
                case .character:
                    role = "character"
                case .function:
                    role = "function"
                case .space:
                    role = "space"
                case .returnKey:
                    role = "return"
                case .active:
                    role = "active"
                }
            }
            Logger.shared.info(
                "KBDVIS touch phase=\(phase.rawValue) role=\(role) "
                    + "pressed=\(keyPressFeedbackEmittedButtonIDs.count)",
                category: .display
            )
            guard isHighFidelityDiagnosticsActive else { return }
            diagnosticsJournal.record(
                code: .touchTerminal,
                category: .display,
                appearanceID: diagnosticsAppearanceID,
                fields: [
                    .count(.highlightedKeyCount, keyPressFeedbackEmittedButtonIDs.count),
                    .flag(.isKeyHighlighted, phase == .began),
                ]
            )
        }

        /// Snapshot only structural state needed to separate stale UIKit paint,
        /// real key tracking, Core composition and lifecycle cleanup. No key text,
        /// candidate text or host-document text is emitted.
        func recordKeyboardVisualDiagnostic(
            _ marker: String,
            effects: KeyboardEffect? = nil
        ) {
            guard controller != nil else { return }
            let output = controller.state.lastRimeOutput
            let collectionItems = candidateCollectionView?.numberOfItems(inSection: 0) ?? 0
            let visibleCells = candidateCollectionView?.visibleCells.count ?? 0
            let ownerEpoch = controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch ?? 0
            let effectsRawValue = effects.map { String($0.rawValue) } ?? "none"
            Logger.shared.info(
                "KBDVIS marker=\(marker) effects=\(effectsRawValue) "
                    + "appeared=\(hasViewAppeared ? 1 : 0) "
                    + "ui=\(isKeyboardUIInstalled ? 1 : 0) "
                    + "ownerReady=\(controller.threadAffineRimeCoordinator?.isOwnerReady == true ? 1 : 0) "
                    + "epoch=\(ownerEpoch) "
                    + "pressed=\(keyPressFeedbackEmittedButtonIDs.count) "
                    + "compositionLength=\(controller.state.currentComposition.count) "
                    + "rawLength=\(output?.rawInput?.count ?? 0) "
                    + "coreCandidates=\(output?.candidates.count ?? 0) "
                    + "cachedCandidates=\(accumulatedCandidates.count) "
                    + "collectionItems=\(collectionItems) visibleCells=\(visibleCells) "
                    + "generation=\(candidateSnapshotGeneration) "
                    + "revision=\(controller.state.compositionRevision)",
                category: .display
            )
            guard isHighFidelityDiagnosticsActive else { return }
            diagnosticsJournal.record(
                code: .candidateVisibilityChanged,
                category: .display,
                appearanceID: diagnosticsAppearanceID,
                fields: [
                    .count(.candidateCount, output?.candidates.count ?? 0),
                    .count(.visibleCandidateCellCount, visibleCells),
                    .count(.highlightedKeyCount, keyPressFeedbackEmittedButtonIDs.count),
                    .count(.revision, Int(clamping: controller.state.compositionRevision)),
                    .count(.sessionEpoch, Int(clamping: ownerEpoch)),
                    .flag(.isCandidateBarVisible, collectionItems > 0),
                    .flag(.isHighFidelityEnabled, true),
                ]
            )
        }
    #endif

    /// Records touch timing and responds synchronously so rapid typing receives immediate feedback.
    @objc func keyTouchDown(_ sender: UIButton) {
        let identifier = ObjectIdentifier(sender)
        #if DEBUG
            keyTouchDownTimes[identifier] = CACurrentMediaTime()
        #endif
        keyPressFeedbackEmittedButtonIDs.insert(identifier)

        #if DEBUG
            Logger.shared.performance("keyDown registered")
        #endif

        sender.backgroundColor = highlightedKeyColor
        sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        emitKeyPressFeedback()
    }

    @objc func keyTouchUp(_ sender: UIButton) {
        keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(sender))
        restoreKeyAppearance(sender)
    }

    func restoreKeyAppearance(_ sender: UIButton) {
        let restore = {
            sender.transform = .identity

            if sender === self.shiftButton {
                self.updateShiftButtonAppearance()
                return
            }

            guard let style = self.keyStyle(for: sender) else {
                sender.backgroundColor = self.characterKeyColor
                return
            }
            sender.backgroundColor = self.backgroundForStyle(style)
        }

        guard !UIAccessibility.isReduceMotionEnabled else {
            restore()
            return
        }

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: restore,
            completion: nil
        )
    }

    func resetAllKeyPressVisualState() {
        keyTouchDownTimes.removeAll()
        keyPressFeedbackEmittedButtonIDs.removeAll()
        restoreButtons(in: view)
    }

    private func restoreButtons(in root: UIView?) {
        guard let root else { return }
        if let button = root as? UIButton {
            UIView.performWithoutAnimation {
                button.transform = .identity
                if button === shiftButton {
                    updateShiftButtonAppearance()
                } else if let style = keyStyle(for: button) {
                    button.backgroundColor = backgroundForStyle(style)
                }
            }
        }

        for subview in root.subviews {
            restoreButtons(in: subview)
        }
    }
}
