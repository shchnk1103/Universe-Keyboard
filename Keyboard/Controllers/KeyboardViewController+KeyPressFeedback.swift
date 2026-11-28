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
            #if KEYBOARD_WAKE_OWNER_PROBE
                wakeOwnerProbeTouch(ObjectIdentifier(button), began: phase == .began)
            #endif
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
        guard !isKeyboardHeightAdjusting else { return }
        let identifier = ObjectIdentifier(sender)
        #if DEBUG
            keyTouchDownTimes[identifier] = CACurrentMediaTime()
        #endif
        keyPressFeedbackEmittedButtonIDs.insert(identifier)

        #if DEBUG
            Logger.shared.performance("keyDown registered")
        #endif

        sender.backgroundColor = highlightedKeyColor
        if keyStyle(for: sender) == .character {
            sender.titleLabel?.font = .systemFont(
                ofSize: characterKeyTitlePointSize, weight: characterKeyStyle.bold ? .bold : .semibold)
            showKeyCallout(for: sender)
        }
        sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        emitKeyPressFeedback()
    }

    /// Shows the resident callout for a pressed character key.
    ///
    /// Synchronous press path: no view allocation and no defaults reads — the
    /// switch is the `cachedKeyPopupEnabled` snapshot from
    /// `refreshCachedSettings` (PB-019 PR-2), and the character is evaluated
    /// through the same `characterKeyStyle.displayTitle` pipeline as the
    /// key-cap title. Suppressed while the long-press variant popup is up (the
    /// callout must never coexist with the variant panel).
    func showKeyCallout(for button: UIButton) {
        guard variantPopupView == nil,
            let callout = keyCalloutView,
            cachedKeyPopupEnabled,
            controller.state.currentPage == .letters,
            isKeyCalloutCandidate(button)
        else { return }
        let keyFrame = button.convert(button.bounds, to: view)
        // Fail-closed (arch review Minor-1): the bubble itself must fit
        // between the container top edge and the key top; otherwise an
        // extremely short floating keyboard or a host-compressed surface
        // would clip it — suppress instead of showing a truncated bubble.
        guard canShowKeyCallout(keyFrame: keyFrame, containerBounds: view.bounds) else { return }
        let rawKey = button.accessibilityIdentifier ?? button.title(for: .normal) ?? ""
        guard !rawKey.isEmpty else { return }
        let character: String
        if button.accessibilityValue == KeyboardViewController.t9DigitAccessibilityValue {
            // Nine-key letter groups confirm the visible letter-group label,
            // which `makeT9KeyButton` already evaluated through the
            // `displayTitle` pipeline (digit identity stays the payload).
            character = button.title(for: .normal) ?? ""
        } else {
            character = displayTitle(for: rawKey)
        }
        guard !character.isEmpty else { return }
        callout.sourceButton = button
        callout.show(
            character: character,
            keyFrame: keyFrame,
            containerBounds: view.bounds
        )
        // Fail-closed clamp: the frozen host layout puts the top letter row at
        // 48pt (2pt top inset + 46pt candidate bar), so the 6pt gap shrinks
        // toward 0 to keep the whole bubble inside the container instead of
        // piercing its top edge. The pointer arrow stays horizontal-only.
        callout.frame = clampedCalloutFrame(keyFrame: keyFrame, containerBounds: view.bounds)
        view.bringSubviewToFront(callout)
    }

    /// Nine-key letters-page letter groups: every letter-bearing digit key
    /// 2–9 (ABC / DEF / GHI / JKL / MNO / PQRS / TUV / WXYZ). The digits page
    /// stays excluded by the `currentPage` guard.
    ///
    /// PB-019-T9-LOWER-ROWS-POPUP-FIX-001 (Human-approved Option A, reversing
    /// the PB-019 PR-2 "first row only" 拍板项): deeper letter-group rows now
    /// show the press callout — the diagnosis confirmed nothing in geometry,
    /// z-order or rendering blocks them, and their 3–4 character labels fit
    /// the key-width bubble just like ABC / DEF.
    static let nineKeyLetterGroupCalloutDigitIdentities: Set<String> = [
        "2", "3", "4", "5", "6", "7", "8", "9",
    ]

    /// PB-019 PR-2: whether a pressed key may open the press callout.
    ///
    /// 26-key letters-page character keys keep the PR-1 behavior. On the
    /// Chinese nine-key letters chrome only the letter-group digit keys
    /// 2–9 are eligible: the multi-character punctuation utility key
    ///（，。？！）cannot confirm a single character inside the key-width
    /// bubble, and the digits page is excluded by both the `currentPage`
    /// guard and this identity check.
    func isKeyCalloutCandidate(_ button: UIButton) -> Bool {
        if isNineKeyLettersChromeActive {
            return button.accessibilityValue == KeyboardViewController.t9DigitAccessibilityValue
                && KeyboardViewController.nineKeyLetterGroupCalloutDigitIdentities.contains(
                    button.accessibilityIdentifier ?? ""
                )
        }
        return button.accessibilityValue != KeyboardViewController.t9DigitAccessibilityValue
    }

    /// Mirrors the `usesT9Chrome` condition in `addKeyboardRows` so eligibility
    /// always tracks the chrome that is actually built.
    private var isNineKeyLettersChromeActive: Bool {
        controller.state.inputMode == .chinese
            && cachedLayoutStyle == .nineKey
            && cachedT9ReadinessMatched
    }

    /// Fail-closed geometry gate (arch review Minor-1): the 44pt bubble itself
    /// must fit between the container top edge and the key top. The 6pt gap is
    /// elastic (clamped toward 0 by `clampedCalloutFrame`), so this only fails
    /// for genuinely insufficient heights — iPad floating keyboards and
    /// host-compressed surfaces suppress the callout entirely instead of
    /// clipping it.
    func canShowKeyCallout(keyFrame: CGRect, containerBounds: CGRect) -> Bool {
        keyFrame.minY - KeyCalloutView.preferredHeight >= containerBounds.minY
    }

    /// `KeyCalloutView.bubbleFrame` with the fail-closed clamp applied: the
    /// vertical gap shrinks toward 0 so the bubble never pierces the container
    /// top edge. Horizontal clamp and pointer semantics are unchanged.
    func clampedCalloutFrame(keyFrame: CGRect, containerBounds: CGRect) -> CGRect {
        var bubble = KeyCalloutView.bubbleFrame(for: keyFrame, containerBounds: containerBounds)
        bubble.origin.y = max(containerBounds.minY, bubble.origin.y)
        return bubble
    }

    @objc func keyTouchUp(_ sender: UIButton) {
        keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(sender))
        restoreKeyAppearance(sender)
        keyCalloutView?.dismissIfSource(sender)
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
            if style == .character {
                sender.titleLabel?.font = .systemFont(
                    ofSize: self.characterKeyTitlePointSize, weight: self.characterKeyStyle.bold ? .bold : .regular)
            }
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
        invalidateOrdinaryKeyRollover()
        keyTouchDownTimes.removeAll()
        keyPressFeedbackEmittedButtonIDs.removeAll()
        keyCalloutView?.dismiss()
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
