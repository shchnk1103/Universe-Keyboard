//
//  KeyboardAudioFeedbackInputView.swift
//  Keyboard
//
//  让 UIKit 为自定义键盘管理系统输入点击音及其音频会话。
//

import UIKit

/// 键盘实际显示的输入视图。
///
/// 由输入视图而不是控制器实现 `UIInputViewAudioFeedback`，可以确保
/// `UIDevice.playInputClick()` 走系统键盘反馈策略，不创建 Extension 自己的音频会话。
final class KeyboardAudioFeedbackInputView: UIInputView, UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { true }
}
