//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//
//  UIInputViewController 主控：管理键盘生命周期、根布局和 UI 刷新。
//  所有状态逻辑委托给 KeyboardCore.KeyboardController。
//  按键动作 → KeyboardViewController+Actions.swift
//  UI 工厂方法 → KeyboardViewController+Layout.swift
//

import AudioToolbox
import UIKit
import KeyboardCore

class KeyboardViewController: UIInputViewController {

    // MARK: - 视图引用

    var rootStack: UIStackView!
    var candidateBar: UIStackView!
    var nextKeyboardButton: UIButton!
    var shiftButton: UIButton!
    var returnButton: UIButton!
    var letterButtons: [UIButton] = []

    // MARK: - 控制器

    var controller: KeyboardController!

    // MARK: - 删除相关（UI 层）

    var deleteRepeatTimer: Timer?
    var isDeleteRepeatActive = false

    // MARK: - 长按变体字符

    var variantPopupView: KeyPopupView?
    var longPressedButton: UIButton?

    // MARK: - 布局常量

    let candidateBarHeight: CGFloat = 36
    let keyHeight: CGFloat = 44
    let keySpacing: CGFloat = 6

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGray5

        let keyboardType = KeyboardType.from(uiKeyboardType: textDocumentProxy.keyboardType)
        let state = KeyboardState(activeKeyboardType: keyboardType)
        controller = KeyboardController(state: state)
        controller.textClient = UITextDocumentProxyAdapter(proxy: textDocumentProxy)

        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            _ = controller.applyAutoCapitalization(contextBeforeInput: context)
        }

        hapticGenerator.prepare()

        setupRootStack()
        reloadKeyboard()
    }

    deinit {
        stopDeleteRepeat()
    }

    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    override func textWillChange(_ textInput: UITextInput?) {
    }

    override func textDidChange(_ textInput: UITextInput?) {
        let proxy = self.textDocumentProxy
        let textColor: UIColor = proxy.keyboardAppearance == .dark ? .white : .black
        nextKeyboardButton.setTitleColor(textColor, for: [])
        updateReturnKeyTitle()

        let keyboardType = KeyboardType.from(uiKeyboardType: proxy.keyboardType)
        var effects = controller.handle(.keyboardTypeChanged(keyboardType))

        let context = proxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)

        syncUI(with: effects)
    }

    // MARK: - 根布局

    func setupRootStack() {
        rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.spacing = keySpacing
        rootStack.distribution = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            rootStack.heightAnchor.constraint(greaterThanOrEqualToConstant: candidateBarHeight + keyHeight * 4 + keySpacing * 4)
        ])
    }

    func reloadKeyboard() {
        for arrangedSubview in rootStack.arrangedSubviews {
            rootStack.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        letterButtons.removeAll()
        candidateBar = makeCandidateBar()
        rootStack.addArrangedSubview(candidateBar)

        let state = controller.state
        switch state.currentPage {
        case .letters:
            rootStack.addArrangedSubview(makeLetterRow(["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]))
            rootStack.addArrangedSubview(makeLetterRow(["a", "s", "d", "f", "g", "h", "j", "k", "l"]))
            rootStack.addArrangedSubview(makeLetterThirdRow())
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: false))
        case .numbers:
            rootStack.addArrangedSubview(makeTextRow(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]))
            if state.inputMode == .chinese {
                rootStack.addArrangedSubview(makeTextRow(["-", "/", "：", "；", "（", "）", "¥", "\u{201C}", "\u{201D}", "\u{2018}"]))
                rootStack.addArrangedSubview(makeTextRow(["。", "，", "、", "？", "！", "…", "·", "《", "》"]))
            } else {
                rootStack.addArrangedSubview(makeTextRow(["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]))
                rootStack.addArrangedSubview(makeTextRow([".", ",", "?", "!", "'", "\"", "—", "…", "~"]))
            }
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        case .symbols:
            rootStack.addArrangedSubview(makeTextRow(["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]))
            rootStack.addArrangedSubview(makeTextRow(["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "&"]))
            rootStack.addArrangedSubview(makeTextRow(["·", "•", "…", "—", "–", "/", "'", "\"", "!", "?"]))
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        }
    }

    // MARK: - 按键反馈

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    func playKeyClick() {
        guard hasFullAccess else { return }
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        guard defaults?.bool(forKey: "key_click_enabled") ?? true else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playHaptic() {
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        guard defaults?.bool(forKey: "haptic_enabled") ?? false else { return }
        hapticGenerator.impactOccurred()
    }

    // MARK: - UI 同步

    func syncUI(with effects: KeyboardEffect) {
        if effects.contains(.pageChanged) || effects.contains(.inputModeChanged) || effects.contains(.keyboardTypeChanged) {
            reloadKeyboard()
            return
        }
        if effects.contains(.compositionChanged) {
            refreshCandidateBar()
        }
        if effects.contains(.shiftStateChanged) {
            refreshLetterButtons()
            updateShiftButtonAppearance()
        }
    }
}
