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
        guard let candidate = sender.title(for: .normal),
              let kind = sender.accessibilityIdentifier else { return }
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
        let effects = controller.handle(.toggleInputMode)
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
        isDeleteRepeatActive = false
        scheduleDeleteRepeat()
    }

    @objc func deleteKeyTouchUpInside(_ sender: UIButton) {
        if isDeleteRepeatActive {
            stopDeleteRepeat()
        } else {
            stopDeleteRepeat()
            performDeleteBackward()
        }
        sender.alpha = 1.0
    }

    @objc func deleteKeyTouchUpOutside(_ sender: UIButton) {
        stopDeleteRepeat()
        sender.alpha = 1.0
    }

    func performDeleteBackward() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.deleteBackward)
        syncUI(with: effects)
    }

    func scheduleDeleteRepeat() {
        stopDeleteRepeat()
        let timer = Timer(timeInterval: 0.35, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.isDeleteRepeatActive = true
            self.performDeleteBackward()
            let repeatTimer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
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
