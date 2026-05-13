//
//  KeyboardViewController+Display.swift
//  Keyboard
//
//  显示相关的计算属性和按钮状态刷新。
//

import UIKit
import KeyboardCore

// MARK: - 显示计算属性

extension KeyboardViewController {

    var inputModeButtonTitle: String {
        controller.state.inputMode == .chinese ? "中" : "英"
    }

    var shouldShowEmailShortcutKeys: Bool {
        controller.state.currentPage == .letters && controller.state.activeKeyboardType == .emailAddress
    }

    var shouldShowURLShortcutKeys: Bool {
        controller.state.currentPage == .letters
            && (controller.state.activeKeyboardType == .URL || controller.state.activeKeyboardType == .webSearch)
    }

    var pageSwitchTitle: String {
        switch controller.state.currentPage {
        case .letters: return "123"
        case .numbers: return "#+="
        case .symbols: return "ABC"
        }
    }

    var spaceButtonTitle: String {
        let state = controller.state
        if state.currentPage != .letters { return "space" }
        switch state.inputMode {
        case .chinese: return "拼音"
        case .english: return "English"
        }
    }

    var returnKeyTitle: String {
        switch textDocumentProxy.returnKeyType {
        case .go:             return "go"
        case .google:         return "google"
        case .join:           return "join"
        case .next:           return "next"
        case .route:          return "route"
        case .search:         return "search"
        case .send:           return "send"
        case .yahoo:          return "yahoo"
        case .done:           return "done"
        case .emergencyCall:  return "SOS"
        case .continue:       return "continue"
        default:              return "return"
        }
    }

    var isShiftActive: Bool {
        let shift = controller.state.shiftState
        return shift == .singleUse || shift == .capsLock
    }

    var shiftButtonTitle: String {
        controller.state.shiftState == .capsLock ? "⇪" : "⇧"
    }
}

// MARK: - 按钮状态刷新

extension KeyboardViewController {

    func refreshLetterButtons() {
        for button in letterButtons {
            guard let key = button.accessibilityIdentifier else { continue }
            button.setTitle(displayTitle(for: key), for: .normal)
        }
        updateShiftButtonAppearance()
    }

    func updateShiftButtonAppearance() {
        guard let shiftButton else { return }
        shiftButton.setTitle(shiftButtonTitle, for: .normal)

        switch controller.state.shiftState {
        case .off:
            shiftButton.backgroundColor = UIColor.secondarySystemBackground
            shiftButton.setTitleColor(UIColor.label, for: .normal)
        case .singleUse:
            shiftButton.backgroundColor = UIColor.systemGray3
            shiftButton.setTitleColor(UIColor.label, for: .normal)
        case .capsLock:
            shiftButton.backgroundColor = UIColor.systemBlue
            shiftButton.setTitleColor(UIColor.white, for: .normal)
        }
    }

    func updateReturnKeyTitle() {
        guard let returnButton else { return }
        returnButton.setTitle(returnKeyTitle, for: .normal)
    }
}
