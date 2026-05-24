//
//  KeyboardViewController+Actions.swift
//  Keyboard
//
//  所有 @objc 按键动作方法 + 长按删除自动重复逻辑。
//  业务逻辑（状态转换）委托给 KeyboardController.handle(_:)。
//  此扩展只负责：调用控制器 → 播放反馈 → 同步 UI。
//
//  Apple 文档参考：
//  键盘通过 textDocumentProxy 与宿主 App 交互，所有文本操作都经过此代理。
//  insertText / deleteBackward 是 UIInputViewController 暴露的核心方法。
//

import UIKit
import KeyboardCore

// MARK: === 字母键 / 候选键 / 快捷符号 ===

extension KeyboardViewController {

    /// 插入字母键字符（@objc 方法，由 UIButton 的 .touchUpInside 触发）。
    ///
    /// 执行流程：
    ///   1. 从 button.title 获取按键字符
    ///   2. 播放按键音 + 触感反馈
    ///   3. 委托 controller.handle(.insertKey) 处理状态转换
    ///   4. 根据返回的 KeyboardEffect 同步 UI
    ///
    /// 性能说明：
    ///   keyTouchDownTimes 记录 touchDown 时间戳，用于计算从按下到动作触发的延迟。
    ///   这是性能诊断日志的一部分，在生产中由 Logger.shared.isEnabled 控制开关。
    @objc func insertKey(_ sender: UIButton) {
        guard let key = sender.title(for: .normal) else { return }
        let startTime = CACurrentMediaTime()

        // 性能诊断：计算 touchDown → 动作触发延迟
        if Logger.shared.isEnabled {
            let identifier = ObjectIdentifier(sender)
            if let touchDownTime = keyTouchDownTimes.removeValue(forKey: identifier) {
                let delay = (startTime - touchDownTime) * 1000
                Logger.shared.performance(
                    "insertKey enter '\(key)' after keyDown (\(String(format: "%.1f", delay))ms)"
                )
            } else {
                Logger.shared.performance("insertKey enter '\(key)' without keyDown timestamp")
            }
        }

        playKeyClick()
        playHaptic()

        let handleStartTime = CACurrentMediaTime()
        let effects = controller.handle(.insertKey(key))
        logKeyPerformance("controller.handle insertKey '\(key)'", startTime: handleStartTime)
        syncUI(with: effects)
        logKeyPerformance("insertKey total '\(key)'", startTime: startTime)
    }

    /// 插入候选词（@objc 方法，由候选栏按钮的 .touchUpInside 触发）。
    ///
    /// 与 insertKey 不同，候选文字从 UIButton.Configuration.title 读取。
    /// 原因：titleTextAttributesTransformer 只影响 attributedTitle 的视觉呈现，
    /// configuration.title 保持不变，因此更可靠。
    ///
    /// sender.tag 存储 CandidateKind.rawValue：
    ///   - 0 (.candidate): 正常候选词，插入并清除预编辑
    ///   - 1 (.composition): 拼音原字符串，用于提交原始拼音
    ///   - 2 (.placeholder): 占位符，不触发插入
    @objc func insertCandidate(_ sender: UIButton) {
        guard let candidate = sender.configuration?.title,
              let kind = CandidateKind(rawValue: sender.tag) else { return }
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertCandidate(candidate, kind: kind))
        syncUI(with: effects)
    }

    /// 插入直接文本（@objc 方法，用于 @ / . / .com 等快捷键按钮）。
    /// 与 insertKey 的区别：不经过 RIME 引擎，直接通过 textDocumentProxy.insertText() 插入。
    @objc func insertDirectText(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertDirectText(text))
        syncUI(with: effects)
    }
}

// MARK: === Shift / 页面切换 / 输入模式 ===

extension KeyboardViewController {

    /// 切换 Shift 状态：off → singleUse → capsLock → off
    /// 双击 Shift（0.35s 内）进入 Caps Lock。
    /// 单次点击在 off 和 singleUse（一次性大写）之间切换。
    @objc func toggleShift() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.toggleShift)
        syncUI(with: effects)
    }

    /// 切换键盘页面：letters → numbers → symbols → letters
    /// 按钮标题动态变化：letters 页显示 "123"、numbers 页显示 "#+="、symbols 页显示 "ABC"。
    @objc func toggleKeyboardPage() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.togglePage)
        syncUI(with: effects)
    }

    /// 切换输入模式：中文 ↔ 英文。
    /// 切换到英文模式后，额外检查是否需要对光标位置应用自动大写。
    /// 例如：从中文切到英文时，如果输入框为空或光标在句首，自动开启 Shift。
    @objc func toggleInputMode() {
        playKeyClick()
        playHaptic()
        var effects = controller.handle(.toggleInputMode)

        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
            effects.formUnion(autoCapEffect)
        }

        syncUI(with: effects)
    }
}

// MARK: === Emoji 插入 ===

extension KeyboardViewController {

    /// 插入 Emoji — 直接从按钮标题读取 emoji 字符，
    /// 通过 textDocumentProxy.insertText 直接上屏，不经过 RIME 引擎。
    @objc func insertEmoji(_ sender: UIButton) {
        guard let emoji = sender.title(for: .normal) else { return }
        playKeyClick()
        playHaptic()
        // Emoji 直接插入文本，不经过 RIME
        textDocumentProxy.insertText(emoji)
    }
}

// MARK: === 候选翻页 ===

extension KeyboardViewController {

    /// 候选词上一页（发送 Page_Up 到 RIME 引擎）
    @objc func candidatePageUp() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.candidatePageUp)
        syncUI(with: effects)
    }

    /// 候选词下一页（发送 Page_Down 到 RIME 引擎）
    @objc func candidatePageDown() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.candidatePageDown)
        syncUI(with: effects)
    }
}

// MARK: === 空格 / 回车 ===

extension KeyboardViewController {

    /// 插入空格。
    /// 功能：
    /// - 中文模式：如果存在 composition（拼音缓冲区），空格用于提交第一个候选词
    /// - 英文模式：直接插入空格字符
    /// - 句号自动插入（Double-space period）：英文空 composition 状态下，
    ///   0.45s 内连续两次空格 → 删除前一空格 → 插入 ". "
    @objc func insertSpace() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertSpace)
        syncUI(with: effects)
    }

    /// 插入回车（\n）。
    /// 中文模式下如果有 composition，回车提交原始拼音；否则插入换行符。
    @objc func insertReturn() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertReturn)
        syncUI(with: effects)
    }
}

// MARK: === 删除（含长按自动重复）===

extension KeyboardViewController {

    /// 删除键按下时的处理（.touchDown 事件）。
    ///
    /// 模拟原生 iOS 键盘行为：
    ///   1. 立即执行第一次删除（无延迟）
    ///   2. 延迟 0.5s 后开始自动重复
    ///   3. 重复阶段间隔 0.08s（约 12.5 次/秒）
    ///
    /// 使用 Timer + RunLoop.main(.common) 确保在滚动和交互期间继续触发。
    @objc func deleteKeyTouchDown(_ sender: UIButton) {
        keyTouchDown(sender)
        // 立即执行第一次删除（与原生键盘行为一致）
        performDeleteBackward()
        isDeleteRepeatActive = false
        scheduleDeleteRepeat()
    }

    /// 删除键释放（.touchUpInside）。
    /// 停止自动重复，恢复按钮外观。
    @objc func deleteKeyTouchUpInside(_ sender: UIButton) {
        stopDeleteRepeat()
        // 避免重复删除：touchDown 已执行过第一次删除
        restoreKeyAppearance(sender)
    }

    /// 删除键在按钮外释放（.touchUpOutside / .touchDragExit）。
    /// 与 touchUpInside 相同的处理逻辑，但表明手指滑出了删除键区域。
    @objc func deleteKeyTouchUpOutside(_ sender: UIButton) {
        stopDeleteRepeat()
        restoreKeyAppearance(sender)
    }

    /// 执行一次删除操作。
    ///
    /// 删除逻辑（在 KeyboardController 中处理）：
    ///   1. 如果存在 composition（拼音缓冲区），删除 composition 中最后一个字符
    ///   2. 如果 composition 为空，调用 textDocumentProxy.deleteBackward() 删除宿主 App 中的文字
    ///
    /// 额外的自动大写检查（防御性）：
    ///   删除操作可能导致光标位置变化（例如删除到空文档），此时需要重新启用自动大写。
    ///   虽然 textDidChange 也会做此检查，但 UITextDocumentProxy 的
    ///   documentContextBeforeInput 在 textDidChange 触发时可能还未更新（已知系统延迟），
    ///   所以在此增加一层兜底检查。
    func performDeleteBackward() {
        playKeyClick()
        playHaptic()
        var effects = controller.handle(.deleteBackward)

        let context = textDocumentProxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)

        syncUI(with: effects)
    }

    /// 调度删除自动重复。
    ///
    /// 两步计时器设计：
    ///   1. 延迟计时器（0.5s，不重复）：
    ///      - 触发后标记 isDeleteRepeatActive = true
    ///      - 创建快速重复计时器
    ///   2. 快速重复计时器（0.08s 间隔，重复）：
    ///      - 持续调用 performDeleteBackward()
    ///      - 直到用户松手触发 stopDeleteRepeat()
    ///
    /// 使用 RunLoop.main.add(timer, forMode: .common) 而非 scheduledTimer：
    ///   .common mode 确保计时器在 UIScrollView 滚动等情况下也能触发。
    ///   如果使用 .default mode，滚动候选栏时会暂停删除。
    func scheduleDeleteRepeat() {
        stopDeleteRepeat()  // 清除任何残留计时器

        // 阶段 1：延迟计时器（0.5s 后进入自动重复阶段）
        let timer = Timer(timeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.isDeleteRepeatActive = true

            // 阶段 2：快速重复计时器（0.08s 间隔）
            let repeatTimer = Timer(timeInterval: 0.08, repeats: true) { [weak self] _ in
                self?.performDeleteBackward()
            }
            self.deleteRepeatTimer = repeatTimer
            RunLoop.main.add(repeatTimer, forMode: .common)
        }
        deleteRepeatTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    /// 停止所有删除自动重复计时器。
    /// 安全地调用多次 — invalidate() 后的 Timer 不会再触发。
    func stopDeleteRepeat() {
        deleteRepeatTimer?.invalidate()
        deleteRepeatTimer = nil
        isDeleteRepeatActive = false
    }
}
