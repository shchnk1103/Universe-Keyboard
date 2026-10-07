import KeyboardCore
import UIKit

extension KeyboardViewController {
    // MARK: === 删除键 V1 会话（单击松手 / 擦除 / 长按气泡）===

    @objc func deleteKeyTouchDown(_ sender: UIButton, forEvent event: UIEvent) {
        endDeleteGestureSession(restoreAppearance: false, reason: .superseded)
        resetDeleteRepeatFeedback()
        keyTouchDown(sender)

        let origin = deleteTouchLocation(sender, event: event) ?? sender.center
        // One read per press. A change in the main app applies on the next touchDown.
        let holdFlags = DeleteKeyHoldFlags.load(from: sharedDefaults)
        deleteGestureSession = DeleteKeyGestureSession(
            button: sender,
            originX: origin.x,
            holdFlags: holdFlags
        )
        deleteRepeatController.begin { [weak self] in
            self?.handleDeleteRepeatTick()
        } onRepeatStarted: { [weak self] in
            self?.handleDeleteRepeatStarted()
        }
    }

    @objc func deleteKeyTouchDrag(_ sender: UIButton, forEvent event: UIEvent) {
        handleDeleteFingerMove(sender, event: event)
    }

    @objc func deleteKeyTouchUpInside(_ sender: UIButton, forEvent event: UIEvent) {
        handleDeleteFingerMove(sender, event: event)
        finishDeleteGesture(sender, event: event)
    }

    @objc func deleteKeyTouchUpOutside(_ sender: UIButton, forEvent event: UIEvent) {
        handleDeleteFingerMove(sender, event: event)
        finishDeleteGesture(sender, event: event)
    }

    @objc func deleteKeyTouchCancel(_ sender: UIButton) {
        endDeleteGestureSession(restoreAppearance: true, reason: .cancelled)
    }

    func handleDeleteFingerMove(_ sender: UIButton, event: UIEvent) {
        guard let session = deleteGestureSession, session.button === sender else { return }
        let location = deleteTouchLocation(sender, event: event) ?? sender.center

        if !view.bounds.contains(location) {
            endDeleteGestureSession(restoreAppearance: true, reason: .leftKeyboardBounds)
            return
        }

        if session.phase == .pressed,
            session.holdFlags.composingAbandonEnabled,
            hasActivePreedit,
            session.playhead.isLeftwardLocked(at: Double(location.x))
        {
            deleteRepeatController.stop()
            abandonActivePreedit()
            session.phase = .composingCleared
            return
        }

        if !session.holdFlags.scrubEnabled {
            handleScrubDisabledFingerMove(at: location, session: session)
            return
        }

        switch session.phase {
        case .pressed:
            if hasActivePreedit {
                if session.playhead.isHorizontallyLocked(at: Double(location.x)) {
                    deleteRepeatController.stop()
                    session.phase = .lockedWithoutDelete
                }
            } else if session.playhead.isHorizontallyLocked(at: Double(location.x)) {
                deleteRepeatController.stop()
                session.phase = .scrubCommitted
                applyCommittedScrub(at: location.x, session: session)
            }
        case .scrubCommitted:
            applyCommittedScrub(at: location.x, session: session)
        case .repeating:
            updateDeleteBubbleHover(at: location, session: session)
        case .composingCleared, .lockedWithoutDelete, .leftKeyPending, .exhausted:
            break
        }
    }

    /// Scrub off: motion that stays on the key does not stop long-press.
    /// Leaving the key stops this press, except the seam into a visible trash bubble.
    func handleScrubDisabledFingerMove(at location: CGPoint, session: DeleteKeyGestureSession) {
        switch session.phase {
        case .composingCleared, .lockedWithoutDelete, .scrubCommitted, .exhausted:
            return
        case .pressed, .repeating, .leftKeyPending:
            break
        }

        let keyFrame = session.button.convert(session.button.bounds, to: view)
        if keyFrame.contains(location) {
            if session.phase == .leftKeyPending {
                session.returnedToDeleteKey = true
                deleteRepeatController.stop()
                hideDeleteTrashBubble()
                return
            }
            if session.phase == .repeating {
                updateDeleteBubbleHover(at: location, session: session)
            }
            return
        }

        let intent = DeleteKeyHoldPolicy.outsideKeyIntent(
            trashBubbleEnabled: session.holdFlags.trashBubbleEnabled,
            bubbleVisible: session.bubbleVisible,
            zone: deleteOffKeyZone(at: location, keyFrame: keyFrame),
            returnedToKey: session.returnedToDeleteKey
        )
        switch intent {
        case .seekBubble(let inBubble):
            deleteRepeatController.stop()
            session.phase = .leftKeyPending
            if inBubble, !session.fingerInBubble {
                session.fingerInBubble = true
                session.didVisitBubble = true
                deleteTrashBubbleView?.setFingerInside(true)
                playDeleteBubbleArmedFeedback()
            } else if !inBubble, session.fingerInBubble {
                session.fingerInBubble = false
                deleteTrashBubbleView?.setFingerInside(false)
            }
        case .stopWithoutResume:
            deleteRepeatController.stop()
            hideDeleteTrashBubble()
            session.phase = .leftKeyPending
        }
    }

    func deleteOffKeyZone(at location: CGPoint, keyFrame: CGRect) -> DeleteKeyOffKeyZone {
        guard let bubble = deleteTrashBubbleView, deleteGestureSession?.bubbleVisible == true else {
            return .elsewhere
        }
        if bubble.frame.contains(location) {
            return .inBubble
        }
        let minX = min(keyFrame.minX, bubble.frame.minX)
        let maxX = max(keyFrame.maxX, bubble.frame.maxX)
        let gap = CGRect(
            x: minX,
            y: bubble.frame.maxY,
            width: maxX - minX,
            height: max(0, keyFrame.minY - bubble.frame.maxY)
        )
        if gap.width > 0, gap.height > 0, gap.contains(location) {
            return .crossingGap
        }
        return .elsewhere
    }

    func finishDeleteGesture(_ sender: UIButton, event: UIEvent) {
        guard let session = deleteGestureSession, session.button === sender else {
            endDeleteGestureSession(restoreAppearance: true, reason: .cancelled)
            return
        }
        let location = deleteTouchLocation(sender, event: event) ?? sender.center
        let liftClearsBeforeCursor =
            session.holdFlags.trashBubbleEnabled
            && (session.phase == .repeating || session.phase == .leftKeyPending)
            && session.bubbleVisible
            && (session.fingerInBubble || deleteBubbleContains(location))
        if liftClearsBeforeCursor {
            performDeleteAllBeforeCursor()
        } else if session.phase == .pressed {
            _ = performDeleteBackward(shouldEmitFeedback: false)
        }
        endDeleteGestureSession(restoreAppearance: true, reason: .lifted)
    }

    func handleDeleteRepeatStarted() {
        guard let session = deleteGestureSession, session.phase == .pressed else { return }
        session.phase = .repeating
        scheduleDeleteTrashBubble(session: session)
    }

    func handleDeleteRepeatTick() {
        guard let session = deleteGestureSession else { return }
        guard session.phase == .repeating else { return }
        if session.fingerInBubble { return }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let hadText = textDocumentProxy.hasText
        let deleted = performDeleteBackward()
        if deleted {
            if !session.bubbleVisible, canShowDeleteTrashBubble {
                scheduleDeleteTrashBubble(session: session)
            }
            return
        }
        if before.isEmpty, hadText {
            return
        }
        session.phase = .exhausted
        deleteRepeatController.stop()
        hideDeleteTrashBubble()
    }

    func applyCommittedScrub(at currentX: CGFloat, session: DeleteKeyGestureSession) {
        let target = session.playhead.targetUnits(at: Double(currentX))
        while session.playhead.appliedUnits < target {
            switch deleteOneCommittedGraphemeForScrub() {
            case .recorded(let token):
                if !token.isEmpty, session.restoreLedger.count < DeleteScrubPlayhead.ledgerCap {
                    session.restoreLedger.append(token)
                }
                session.playhead.appliedUnits += 1
            case .blind:
                session.playhead.appliedUnits += 1
            case .stopped:
                return
            }
        }
        while session.playhead.appliedUnits > target {
            guard let token = session.restoreLedger.popLast() else {
                session.playhead.appliedUnits = target
                break
            }
            restoreScrubbedGrapheme(token)
            session.playhead.appliedUnits -= 1
        }
        if session.playhead.appliedUnits == 0, !canDeleteCommittedOrPreedit {
            session.phase = .exhausted
        }
    }

    func scheduleDeleteTrashBubble(session: DeleteKeyGestureSession) {
        // Repeat ticks arrive every 0.08s. Replacing this 0.15s timer on each
        // tick keeps the bubble from ever appearing while deletion is working.
        guard session.holdFlags.trashBubbleEnabled else { return }
        guard deleteBubbleTimer == nil, !session.bubbleVisible else { return }
        guard canShowDeleteTrashBubble else { return }
        let timer = Timer(
            timeInterval: DeleteRepeatController.bubbleDelayAfterRepeatStart,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.deleteBubbleTimer = nil
                self.showDeleteTrashBubbleIfNeeded()
            }
        }
        deleteBubbleTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func showDeleteTrashBubbleIfNeeded() {
        guard let session = deleteGestureSession, session.phase == .repeating else { return }
        guard session.holdFlags.trashBubbleEnabled else { return }
        guard canShowDeleteTrashBubble else { return }
        let keyFrame = session.button.convert(session.button.bounds, to: view)
        let available = keyFrame.minY - DeleteTrashBubbleView.gapAboveKey - DeleteTrashBubbleView.topInset
        guard available >= DeleteTrashBubbleView.minimumHeight else { return }
        hideDeleteTrashBubble()
        let bubble = DeleteTrashBubbleView()
        let height = min(DeleteTrashBubbleView.preferredHeight, available)
        let width = DeleteTrashBubbleView.width
        var frame = CGRect(
            x: keyFrame.midX - width / 2,
            y: keyFrame.minY - DeleteTrashBubbleView.gapAboveKey - height,
            width: width,
            height: height
        )
        frame.origin.x = max(3, min(frame.origin.x, view.bounds.width - width - 3))
        guard frame.minY >= DeleteTrashBubbleView.topInset,
            frame.maxY <= keyFrame.minY - DeleteTrashBubbleView.gapAboveKey,
            !frame.intersects(keyFrame)
        else { return }
        bubble.frame = frame
        bubble.isUserInteractionEnabled = false
        view.addSubview(bubble)
        deleteTrashBubbleView = bubble
        session.bubbleVisible = true
    }

    func updateDeleteBubbleHover(at location: CGPoint, session: DeleteKeyGestureSession) {
        guard session.bubbleVisible else { return }
        let inside = deleteBubbleContains(location)
        if inside, !session.fingerInBubble {
            session.fingerInBubble = true
            session.didVisitBubble = true
            deleteTrashBubbleView?.setFingerInside(true)
            playDeleteBubbleArmedFeedback()
            deleteRepeatController.stop()
        } else if !inside, session.fingerInBubble {
            session.fingerInBubble = false
            deleteTrashBubbleView?.setFingerInside(false)
            if session.phase == .repeating, session.holdFlags.scrubEnabled {
                deleteRepeatController.resumeRepeating { [weak self] in
                    self?.handleDeleteRepeatTick()
                }
            }
        }
    }

    func deleteBubbleContains(_ location: CGPoint) -> Bool {
        guard let bubble = deleteTrashBubbleView, let session = deleteGestureSession else {
            return false
        }
        let keyFrame = session.button.convert(session.button.bounds, to: view)
        if keyFrame.contains(location) { return false }
        return bubble.frame.contains(location)
    }

    func hideDeleteTrashBubble() {
        deleteBubbleTimer?.invalidate()
        deleteBubbleTimer = nil
        deleteTrashBubbleView?.removeFromSuperview()
        deleteTrashBubbleView = nil
        deleteGestureSession?.bubbleVisible = false
        deleteGestureSession?.fingerInBubble = false
    }

    enum DeleteSessionEndReason {
        case lifted
        case cancelled
        case leftKeyboardBounds
        case superseded
        case disappeared
    }

    func endDeleteGestureSession(restoreAppearance: Bool, reason: DeleteSessionEndReason) {
        deleteRepeatController.stop()
        hideDeleteTrashBubble()
        if let session = deleteGestureSession {
            session.discardLedger()
            if restoreAppearance {
                keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(session.button))
                restoreKeyAppearance(session.button)
            }
        }
        deleteGestureSession = nil
        resetDeleteRepeatFeedback()
        _ = reason
    }

    func performDeleteBackward(
        shouldEmitFeedback: Bool = true,
        oneGraphemeBeforeCursor: Bool = false
    ) -> Bool {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let hadText = textDocumentProxy.hasText
        let preedit = hasActivePreedit
        var effects =
            oneGraphemeBeforeCursor
            ? controller.deleteOneGraphemeBeforeCursor()
            : controller.handle(.deleteBackward)
        let context = textDocumentProxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)
        syncUI(with: effects)

        let after = textDocumentProxy.documentContextBeforeInput ?? ""
        let observed: Bool
        if preedit {
            observed = true
        } else if after.count < before.count {
            observed = true
        } else if hadText && !textDocumentProxy.hasText {
            observed = true
        } else {
            observed = false
        }
        if shouldEmitFeedback, observed {
            deleteRepeatEffectiveFeedbackCount += 1
            playRepeatFeedback(effectiveDeleteCount: deleteRepeatEffectiveFeedbackCount)
        }
        return observed
    }

    func deleteOneCommittedGraphemeForScrub() -> DeleteScrubStep {
        if hasActivePreedit { return .stopped }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let hadText = textDocumentProxy.hasText
        if let grapheme = before.last {
            let token = String(grapheme)
            let observed = performDeleteBackward(
                shouldEmitFeedback: true,
                oneGraphemeBeforeCursor: true
            )
            guard observed else { return .stopped }
            return .recorded(token)
        }
        guard hadText else { return .stopped }
        _ = performDeleteBackward(shouldEmitFeedback: true, oneGraphemeBeforeCursor: true)
        let after = textDocumentProxy.documentContextBeforeInput ?? ""
        if !after.isEmpty { return .stopped }
        if !textDocumentProxy.hasText {
            return .blind
        }
        return .blind
    }

    func restoreScrubbedGrapheme(_ token: String) {
        guard !token.isEmpty, !hasActivePreedit else { return }
        let effects = controller.handle(.insertDirectText(token))
        syncUI(with: effects)
    }

    func abandonActivePreedit() {
        let effects = controller.dropRemainingPreeditKeepingConfirmedPrefix()
        syncUI(with: effects)
    }

    func performDeleteAllBeforeCursor() {
        if hasActivePreedit {
            abandonActivePreedit()
        }
        var remaining = DeleteScrubPlayhead.clearAllCap
        while remaining > 0 {
            let before = textDocumentProxy.documentContextBeforeInput ?? ""
            let hadText = textDocumentProxy.hasText
            if before.isEmpty, !hadText { break }
            let observed = performDeleteBackward(
                shouldEmitFeedback: false,
                oneGraphemeBeforeCursor: true
            )
            let after = textDocumentProxy.documentContextBeforeInput ?? ""
            let hasText = textDocumentProxy.hasText
            if !observed, after == before, hasText == hadText { break }
            if after.isEmpty, !observed { break }
            remaining -= 1
            if after.isEmpty, !hasText { break }
        }
        hideDeleteTrashBubble()
    }

    var hasActivePreedit: Bool {
        if !controller.state.currentComposition.isEmpty { return true }
        if controller.state.insertedPreeditCount > 0 { return true }
        if controller.state.partialCommit != nil { return true }
        if controller.state.lastRimeOutput?.composition != nil { return true }
        return false
    }

    var canShowDeleteTrashBubble: Bool {
        guard !hasActivePreedit else { return false }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        return !before.isEmpty
    }

    var canDeleteCommittedOrPreedit: Bool {
        canDeleteBeforeCurrentAction()
    }

    func canDeleteBeforeCurrentAction() -> Bool {
        if !controller.state.currentComposition.isEmpty {
            return true
        }

        if controller.state.insertedPreeditCount > 0 {
            return true
        }

        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        return !before.isEmpty
    }

    func deleteTouchLocation(_ sender: UIButton, event: UIEvent) -> CGPoint? {
        let touch = event.touches(for: sender)?.first ?? event.allTouches?.first
        return touch?.location(in: view)
    }

    func resetDeleteRepeatFeedback() {
        deleteRepeatEffectiveFeedbackCount = 0
    }
}
