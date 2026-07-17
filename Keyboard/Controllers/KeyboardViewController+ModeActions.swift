import KeyboardCore
import UIKit

extension KeyboardViewController {
    @objc func toggleShift(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.toggleShift)
        syncUI(with: effects)
    }

    @objc func toggleKeyboardPage(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.togglePage)
        syncUI(with: effects)
    }

    @objc func switchToLettersPage(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = cycleKeyboardPage(to: .letters)
        syncUI(with: effects)
    }

    @objc func switchToNumbersPage(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = cycleKeyboardPage(to: .numbers)
        syncUI(with: effects)
    }

    @objc func switchToEmojiPage(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = cycleKeyboardPage(to: .emoji)
        syncUI(with: effects)
    }

    @objc func switchToSymbolsPage(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = cycleKeyboardPage(to: .symbols)
        syncUI(with: effects)
    }

    /// Clears active T9 composition without committing raw digits (ADR 0018).
    @objc func reinputT9Composition(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.abandonCompositionForVisibilityChange()
        syncUI(with: effects)
    }

    /// Native-style punctuation entry on the nine-key grid (comma-first common mark).
    @objc func insertT9CommonPunctuation(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertDirectText("，"))
        syncUI(with: effects)
    }

    /// Placeholder for system-style「选拼音」on the nine-key bottom row.
    /// Visual chrome only for now; no composition/candidate behavior yet.
    @objc func t9SelectPinyinPlaceholder(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
    }

    @objc func showKaomojiCandidatesPlaceholder(_ sender: UIButton) {
        // TODO: 后续在候选栏展示颜表情列表；当前阶段只保留 UI 入口。
        emitKeyPressFeedbackIfNeeded(for: sender)
    }

    private func cycleKeyboardPage(to targetPage: KeyboardPage) -> KeyboardEffect {
        var effects: KeyboardEffect = []
        var remainingSteps = 4

        while controller.state.currentPage != targetPage && remainingSteps > 0 {
            effects.formUnion(controller.handle(.togglePage))
            remainingSteps -= 1
        }

        return effects
    }

    @objc func toggleInputMode(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        var effects = controller.handle(.toggleInputMode)

        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
            effects.formUnion(autoCapEffect)
        }

        syncUI(with: effects)
    }

    @objc func candidatePageUp() {
        emitKeyPressFeedback()
        let effects = controller.handle(.candidatePageUp)
        syncUI(with: effects)
    }

    @objc func candidatePageDown() {
        emitKeyPressFeedback()
        let effects = controller.handle(.candidatePageDown)
        syncUI(with: effects)
    }

    @objc func insertSpace(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertSpace)
        syncUI(with: effects)
    }

    @objc func insertReturn(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertReturn)
        syncUI(with: effects)
    }
}
