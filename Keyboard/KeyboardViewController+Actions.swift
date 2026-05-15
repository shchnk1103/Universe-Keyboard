//
//  KeyboardViewController+Actions.swift
//  Keyboard
//
//  所有 @objc 按键动作和删除逻辑。业务逻辑委托给 KeyboardController.handle(_:)。
//

import UIKit
import KeyboardCore

// MARK: - 字母 / 候选 / 快捷符号

extension KeyboardViewController {

    @objc func insertKey(_ sender: UIButton) {
        guard let key = sender.title(for: .normal) else { return }
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertKey(key))
        syncUI(with: effects)
    }

    @objc func insertCandidate(_ sender: UIButton) {
        // 从 configuration.title 读取候选文字，比 title(for:) 更可靠
        // 因为 titleTextAttributesTransformer 不会影响 configuration.title
        guard let candidate = sender.configuration?.title,
              let kind = CandidateKind(rawValue: sender.tag) else { return }
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
}

// MARK: - Shift / 页面切换 / 输入模式

extension KeyboardViewController {

    @objc func toggleShift() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.toggleShift)
        syncUI(with: effects)
    }

    @objc func toggleKeyboardPage() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.togglePage)
        syncUI(with: effects)
    }

    @objc func toggleInputMode() {
        playKeyClick()
        playHaptic()
        var effects = controller.handle(.toggleInputMode)

        // 切换到英文模式后，根据当前文本上下文决定是否需要自动大写
        // 例如：从中文切换到英文时，如果输入框为空或光标在句首，应自动开启 Shift
        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
            effects.formUnion(autoCapEffect)
        }

        syncUI(with: effects)
    }
}

// MARK: - 空格 / 回车

extension KeyboardViewController {

    @objc func insertSpace() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertSpace)
        syncUI(with: effects)
    }

    @objc func insertReturn() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertReturn)
        syncUI(with: effects)
    }
}

// MARK: - 删除

extension KeyboardViewController {

    @objc func deleteKeyTouchDown(_ sender: UIButton) {
        sender.alpha = 0.5
        // 立即执行第一次删除（模拟原生键盘行为）
        performDeleteBackward()
        isDeleteRepeatActive = false
        scheduleDeleteRepeat()
    }

    @objc func deleteKeyTouchUpInside(_ sender: UIButton) {
        stopDeleteRepeat()
        // 如果长按自动重复未触发，touchDown 时已经执行过删除，不再重复
        sender.alpha = 1.0
    }

    @objc func deleteKeyTouchUpOutside(_ sender: UIButton) {
        stopDeleteRepeat()
        sender.alpha = 1.0
    }

    func performDeleteBackward() {
        playKeyClick()
        playHaptic()
        var effects = controller.handle(.deleteBackward)

        // 删除后检查是否需要重新触发自动大写。
        // 这里显式做一次检测，而不是只依赖 textDidChange 中的检测：
        // UITextDocumentProxy 的 documentContextBeforeInput 在 textDidChange
        // 被调用时可能还未更新（已知的系统延迟），导致应该大写时没大写。
        // 在 performDeleteBackward 中加一层兜底，确保删除到空文档时自动大写能重新启用。
        let context = textDocumentProxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)

        syncUI(with: effects)
    }

    func scheduleDeleteRepeat() {
        stopDeleteRepeat()
        // 延迟 0.5s 后开始连续删除（模拟原生键盘节奏）
        let timer = Timer(timeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.isDeleteRepeatActive = true
            // 快速连续删除，间隔 0.08s（原生键盘约 0.08-0.1s）
            let repeatTimer = Timer(timeInterval: 0.08, repeats: true) { [weak self] _ in
                self?.performDeleteBackward()
            }
            self.deleteRepeatTimer = repeatTimer
            RunLoop.main.add(repeatTimer, forMode: .common)
        }
        deleteRepeatTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopDeleteRepeat() {
        deleteRepeatTimer?.invalidate()
        deleteRepeatTimer = nil
        isDeleteRepeatActive = false
    }
}
