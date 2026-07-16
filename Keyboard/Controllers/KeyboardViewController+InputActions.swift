import KeyboardCore
import UIKit

extension KeyboardViewController {
    @objc func insertKey(_ sender: UIButton) {
        // Prefer plain title; fall back to accessibilityIdentifier for multi-line T9 keys.
        let key = sender.title(for: .normal)
            ?? sender.accessibilityIdentifier
            ?? ""
        guard !key.isEmpty else { return }
        let startTime = CACurrentMediaTime()
        inputEventSequence += 1
        let eventID = inputEventSequence
#if DEBUG
        let idleMs = lastInputCompletionTime.map { (startTime - $0) * 1000 }
        Logger.shared.debug(
            "KEY BEGIN #\(eventID) keyLength=\(key.count) idleMs=\(idleMs.map { String(format: "%.1f", $0) } ?? "first") "
                + "compositionLength=\(controller.state.currentComposition.count)",
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
        let handleMs = (CACurrentMediaTime() - handleStartTime) * 1000
#if DEBUG
        Logger.shared.debug(
            "KEY ENGINE END #\(eventID) durationMs=\(String(format: "%.1f", handleMs)) "
                + "candidates=\(controller.state.lastRimeOutput?.candidates.count ?? 0)",
            category: .performance
        )
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
        if totalMs >= 50 {
            Logger.shared.warning(
                "SLOW KEY #\(eventID) keyLength=\(key.count) total=\(String(format: "%.1f", totalMs))ms "
                    + "engine=\(String(format: "%.1f", handleMs))ms ui=\(String(format: "%.1f", uiMs))ms",
                category: .performance
            )
        }
    }

    @objc func insertCandidate(_ sender: UIButton) {
        guard
            let candidate = sender.configuration?.title,
            let kind = CandidateKind(rawValue: sender.tag)
        else { return }
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertCandidate(candidate, kind: kind))
        syncUI(with: effects)
    }

    @objc func insertDirectText(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertDirectText(text))
        syncUI(with: effects)
    }

    @objc func insertSmartDoubleQuote(_ sender: UIButton) {
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
        guard let emoji = sender.title(for: .normal) else { return }
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertEmoji(emoji))
        syncUI(with: effects)
    }
}
