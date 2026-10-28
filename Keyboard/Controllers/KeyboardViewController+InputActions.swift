import KeyboardCore
import UIKit

extension KeyboardViewController {
    @objc func insertKey(_ sender: UIButton) {
        guard !isKeyboardHeightAdjusting else { return }
        // T9 letter-group keys show `ABC` etc. but must send the digit identity to RIME.
        let key: String
        if sender.accessibilityValue == KeyboardViewController.t9DigitAccessibilityValue,
            let digit = sender.accessibilityIdentifier,
            !digit.isEmpty
        {
            key = digit
        } else {
            key =
                sender.title(for: .normal)
                ?? sender.accessibilityIdentifier
                ?? ""
        }
        guard !key.isEmpty else { return }
        #if DEBUG && KEYBOARD_WAKE_OWNER_PROBE
            let wakeAttempt = KeyboardWakeOwnerProbe.shared.beginAttempt(appearanceOrdinal: wakeProbeAppearanceOrdinal)
            recordWakeOwnerProbe(.insertBegin)
            defer {
                recordWakeOwnerProbe(.insertEnd)
                if let wakeAttempt { KeyboardWakeOwnerProbe.shared.endAttempt(wakeAttempt) }
            }
        #endif
        let startTime = CACurrentMediaTime()
        inputEventSequence += 1
        let eventID = inputEventSequence
        #if DEBUG
            T9QA001DeviceTrace.shared.begin(owner: self, event: eventID)
        #endif
        let compositionLengthBefore = controller.state.currentComposition.count
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
            // Segmented sample for continuous T9 digit typing (no Path/candidate pick).
            // Privacy: lengths only — never log the digit sequence itself.
            let shouldSampleT9Segments =
                controller.usesT9InputSemantics
                && key.count == 1
                && key.first?.isNumber == true
            if shouldSampleT9Segments {
                #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
                    recordDevicePreflightExecutionGeometryBeforeFirstT9Key()
                #endif
                HotPathSegmentTiming.beginKey(
                    eventID: UInt64(eventID),
                    keyLength: key.count,
                    compositionLengthBefore: compositionLengthBefore,
                    session: controller.rimeEngine?.diagnosticSessionSnapshot
                )
            }
        #endif

        #if DEBUG
            let idleMs = lastInputCompletionTime.map { (startTime - $0) * 1000 }
            Logger.shared.debug(
                "KEY BEGIN #\(eventID) keyLength=\(key.count) idleMs=\(idleMs.map { String(format: "%.1f", $0) } ?? "first") "
                    + "compositionLength=\(compositionLengthBefore)",
                category: .performance
            )

            let identifier = ObjectIdentifier(sender)
            if let touchDownTime = keyTouchDownTimes.removeValue(forKey: identifier) {
                let delay = (startTime - touchDownTime) * 1000
                Logger.shared.performance(
                    "insertKey enter after keyDown (\(String(format: "%.1f", delay))ms)"
                )
            } else {
                Logger.shared.performance("insertKey enter without keyDown timestamp")
            }
        #endif

        emitKeyPressFeedbackIfNeeded(for: sender)

        let handleStartTime = CACurrentMediaTime()
        let effects = controller.handle(.insertKey(key))
        #if DEBUG
            T9QA001DeviceTrace.shared.record(.returned, owner: self)
        #endif
        let handleMs = (CACurrentMediaTime() - handleStartTime) * 1000
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
            if shouldSampleT9Segments {
                HotPathSegmentTiming.noteResult(
                    rawLength: controller.state.lastRimeOutput?.rawInput?.count
                        ?? controller.state.currentComposition.count,
                    pathCount: controller.state.t9PinyinPathState.compactPaths.count,
                    candidateCount: controller.state.lastRimeOutput?.candidates.count ?? 0,
                    didCommit: controller.state.lastRimeOutput?.committedText != nil,
                    session: controller.rimeEngine?.diagnosticSessionSnapshot
                )
                #if DEBUG
                    let shadow = controller.t9ShadowAnchorObservation()
                    Logger.shared.debug(
                        "T9SHADOW #\(eventID) status=\(shadow.status.rawValue) "
                            + "generation=\(shadow.rawInputGeneration) "
                            + "provenance=\(shadow.provenanceRevision) "
                            + "candidates=\(shadow.candidateCount) "
                            + "compatible=\(shadow.compatibleCandidateCount) "
                            + "uniquePaths=\(shadow.uniqueCompatiblePathCount) "
                            + "rejected=\(shadow.rejectedCandidateCount) "
                            + "commonSyllables=\(shadow.observedCommonSyllableCount) "
                            + "closedSyllables=\(shadow.closedCommonSyllableCount) "
                            + "anchorSlots=\(shadow.anchorSlotCount) "
                            + "unresolvedSlots=\(shadow.unresolvedSlotCount) "
                            + "complete=\(shadow.evidenceComplete)",
                        category: .performance
                    )
                    if let retryShadow = controller.t9AutoAnchorRetryShadowObservation() {
                        Logger.shared.debug(
                            "T9RETRYSHADOW #\(eventID) "
                                + "status=\(retryShadow.status.rawValue) "
                                + "sourceSlots=\(retryShadow.sourceDigitCount) "
                                + "rejectedAt=\(retryShadow.rejectedAtSourceDigitCount) "
                                + "candidates=\(retryShadow.candidateCount) "
                                + "anchorSlots=\(retryShadow.anchoredSlotCount) "
                                + "unresolvedSlots=\(retryShadow.unresolvedSlotCount)",
                            category: .performance
                        )
                    }
                #endif
            }
            #if DEBUG
                Logger.shared.debug(
                    "KEY ENGINE END #\(eventID) durationMs=\(String(format: "%.1f", handleMs)) "
                        + "candidates=\(controller.state.lastRimeOutput?.candidates.count ?? 0)",
                    category: .performance
                )
            #endif
        #endif

        let uiStartTime = CACurrentMediaTime()
        syncUI(with: effects)
        let endTime = CACurrentMediaTime()
        let uiMs = (endTime - uiStartTime) * 1000
        let totalMs = (endTime - startTime) * 1000
        #if DEBUG
            lastInputCompletionTime = endTime
            Logger.shared.performance(
                "KEY END #\(eventID) keyLength=\(key.count) total=\(String(format: "%.1f", totalMs))ms "
                    + "engine=\(String(format: "%.1f", handleMs))ms ui=\(String(format: "%.1f", uiMs))ms"
            )
        #endif
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
            if shouldSampleT9Segments {
                HotPathSegmentTiming.endKey(
                    totalMs: totalMs,
                    engineMs: handleMs,
                    uiMs: uiMs
                )
            }
        #endif
        // Track T9 digit cadence for bar-prefetch idle gating (release + debug).
        if controller.usesT9InputSemantics,
            key.count == 1,
            key.first?.isNumber == true
        {
            lastT9DigitKeyTime = endTime
        }
        if totalMs >= 50 {
            Logger.shared.warning(
                "SLOW KEY #\(eventID) keyLength=\(key.count) total=\(String(format: "%.1f", totalMs))ms "
                    + "engine=\(String(format: "%.1f", handleMs))ms ui=\(String(format: "%.1f", uiMs))ms",
                category: .performance
            )
        }
    }

    @objc func insertCandidate(_ sender: UIButton) {
        guard !isKeyboardHeightAdjusting else { commitTrace.reject(suppressed: false); return }
        guard
            let candidate = sender.configuration?.title,
            let kind = CandidateKind(rawValue: sender.tag)
        else { commitTrace.reject(suppressed: false); return }
        // The legacy title-only button cannot authenticate a native page item.
        // Collection and expanded paths carry the original selectionReference.
        if kind == .candidate,
            candidateSnapshotOrigin != nil || controller.state.lastRimeOutput?.candidateOrigin != nil
        {
            commitTrace.reject(suppressed: false)
            return
        }
        emitKeyPressFeedbackIfNeeded(for: sender)
        beginCandidateTrace(.legacy)
        let effects = controller.handle(.insertCandidate(candidate, kind: kind))
        endCandidateTrace()
        syncUI(with: effects)
    }

    @objc func insertDirectText(_ sender: UIButton) {
        guard !isKeyboardHeightAdjusting else { return }
        guard let text = sender.title(for: .normal) else { return }
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertDirectText(text))
        syncUI(with: effects)
    }

    @objc func insertSmartDoubleQuote(_ sender: UIButton) {
        guard !isKeyboardHeightAdjusting else { return }
        emitKeyPressFeedbackIfNeeded(for: sender)
        let quote = nextSmartDoubleQuote(contextBeforeInput: textDocumentProxy.documentContextBeforeInput)
        let effects = controller.handle(.insertDirectText(quote))
        syncUI(with: effects)
    }

    private func nextSmartDoubleQuote(contextBeforeInput: String?) -> String {
        guard let contextBeforeInput, !contextBeforeInput.isEmpty else { return "“" }

        let openingCount = contextBeforeInput.filter { $0 == "“" }.count
        let closingCount = contextBeforeInput.filter { $0 == "”" }.count

        // 第一次输入左引号；如果已有未闭合的左引号，下一次输入右引号。
        // 一旦左右引号都被删除，光标前不再包含它们，下一次又会回到左引号。
        if openingCount == 0 && closingCount == 0 { return "“" }
        if openingCount > closingCount { return "”" }
        return "”"
    }

    @objc func insertEmoji(_ sender: UIButton) {
        guard !isKeyboardHeightAdjusting else { return }
        guard let emoji = sender.title(for: .normal) else { return }
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertEmoji(emoji))
        syncUI(with: effects)
    }
}
