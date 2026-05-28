import KeyboardCore
import UIKit

extension KeyboardViewController {
    @objc func insertKey(_ sender: UIButton) {
        guard let key = sender.title(for: .normal) else { return }
        let startTime = CACurrentMediaTime()
        inputEventSequence += 1
        let eventID = inputEventSequence
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

        playKeyClick()
        playHaptic()

        let handleStartTime = CACurrentMediaTime()
        let effects = controller.handle(.insertKey(key))
        let handleMs = (CACurrentMediaTime() - handleStartTime) * 1000
        Logger.shared.debug(
            "KEY ENGINE END #\(eventID) durationMs=\(String(format: "%.1f", handleMs)) "
                + "candidates=\(controller.state.lastRimeOutput?.candidates.count ?? 0)",
            category: .performance
        )

        let uiStartTime = CACurrentMediaTime()
        syncUI(with: effects)
        let endTime = CACurrentMediaTime()
        let uiMs = (endTime - uiStartTime) * 1000
        let totalMs = (endTime - startTime) * 1000
        lastInputCompletionTime = endTime
        Logger.shared.performance(
            "KEY END #\(eventID) keyLength=\(key.count) total=\(String(format: "%.1f", totalMs))ms "
                + "engine=\(String(format: "%.1f", handleMs))ms ui=\(String(format: "%.1f", uiMs))ms"
        )
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
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertCandidate(candidate, kind: kind))
        syncUI(with: effects)
    }

    @objc func insertDirectText(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertDirectText(text))
        syncUI(with: effects)
    }

    @objc func insertEmoji(_ sender: UIButton) {
        guard let emoji = sender.title(for: .normal) else { return }
        playKeyClick()
        playHaptic()
        textDocumentProxy.insertText(emoji)
    }
}
