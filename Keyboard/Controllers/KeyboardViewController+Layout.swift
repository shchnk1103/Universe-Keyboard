//
//  KeyboardViewController+Layout.swift
//  Keyboard
//
//  键盘行布局工厂方法。
//
//  Apple UIStackView 最佳实践参考：
//  https://developer.apple.com/documentation/uikit/uistackview
//
//  布局结构（垂直 StackView 根容器）：
//    ┌─────────────────────────────────┐
//    │  候选栏（UIScrollView + 展开按钮）│  ← makeCandidateBar()
//    ├─────────────────────────────────┤
//    │  第 1 行字母: q w e r t y u i o p │  ← makeLetterRow()
//    ├─────────────────────────────────┤
//    │  第 2 行字母:  a s d f g h j k l  │  ← makeLetterRow(horizontalInset: 18)
//    ├─────────────────────────────────┤
//    │  ⇧ | z x c v b n m | ⌫          │  ← makeLetterThirdRow()
//    ├─────────────────────────────────┤
//    │ 🌐 123 [中] space  [.] return   │  ← makeBottomRow()
//    └─────────────────────────────────┘
//
//  UIStackView 关键属性说明：
//  - axis: .horizontal → 水平排列子视图；.vertical → 垂直排列
//  - distribution: 控制子视图在主轴方向上的尺寸分配方式
//    · .fillEqually → 所有子视图等宽（字母行/数字行/符号行）
//    · .fill → 子视图使用自身 intrinsicContentSize + 约束（底部功能行）
//  - spacing: 子视图之间的固定间距
//  - isLayoutMarginsRelativeArrangement: true 时，layoutMargins 参与布局计算
//

import KeyboardCore
import UIKit

extension KeyboardViewController {
    var preferredKeyboardHeight: CGFloat {
        keyboardContentTopInset
            + candidateBarHeight
            + candidateToKeySpacing
            + keyHeight * 4
            + keySpacing * 2
            + keyboardGroupSpacing
            + keyboardContentBottomInset
    }

    /// Requests the compact visual height used by the current keyboard layout.
    /// Row heights remain unchanged; the reduction comes from candidate/top spacing only.
    func installPreferredKeyboardHeight() {
        keyboardHeightConstraint?.isActive = false
        let constraint = view.heightAnchor.constraint(equalToConstant: preferredKeyboardHeight)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        keyboardHeightConstraint = constraint
    }

    /// 高度是布局期望值而不是对系统输入容器的硬性要求。
    /// 与 Hamster/KeyboardKit 一致，系统过渡布局时可临时压缩或扩展按键行。
    func preferredRowHeightConstraint(for view: UIView, height: CGFloat) -> NSLayoutConstraint {
        let constraint = view.heightAnchor.constraint(equalToConstant: height)
        constraint.priority = .defaultHigh
        return constraint
    }
}
