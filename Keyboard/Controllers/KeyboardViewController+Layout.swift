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
    var keyboardHeightWithoutT9Path: CGFloat {
        keyboardContentTopInset
            + candidateBarHeight
            + keyHeight * 4
            + keySpacing * 2
            + keyboardGroupSpacing
            + keyboardContentBottomInset
    }

    var preferredKeyboardHeight: CGFloat {
        keyboardHeightWithoutT9Path + presentedT9PinyinPathBarHeight
    }

    /// 总高请求与行约束一起更新；宿主仍可压低 defaultHigh 的请求。
    func installPreferredKeyboardHeight(pathHeight: CGFloat? = nil) {
        let pathHeight = pathHeight ?? presentedT9PinyinPathBarHeight
        guard !isKeyboardHeightManaged || resolveKeyboardRowHeight(pathHeight: pathHeight) else { return }
        let height = keyboardUncompressedHeight ?? (keyboardHeightWithoutT9Path + pathHeight)
        if let constraint = keyboardHeightConstraint {
            // Keep a single flexible request; same-state refreshes do no constraint work.
            if constraint.constant != height { constraint.constant = height }
            constraint.isActive = true
            return
        }
        let constraint = view.heightAnchor.constraint(equalToConstant: height)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        keyboardHeightConstraint = constraint
    }

    /// 高度是布局期望值而不是对系统输入容器的硬性要求。
    /// 与 Hamster/KeyboardKit 一致，系统过渡布局时可临时压缩或扩展按键行。
    func preferredRowHeightConstraint(
        for view: UIView, rows: CGFloat = 1, extraHeight: CGFloat = 0, minimum: Bool = false
    ) -> NSLayoutConstraint {
        let height = keyHeight * rows + extraHeight
        let constraint =
            minimum
            ? view.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
            : view.heightAnchor.constraint(equalToConstant: height)
        constraint.priority = minimum ? .required : .defaultHigh
        keyboardHeightConstraints.removeAll { $0.constraint == nil }
        keyboardHeightConstraints.append(
            KeyboardRowHeightConstraint(constraint: constraint, rows: rows, extraHeight: extraHeight))
        return constraint
    }
}

#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    extension KeyboardViewController {
        func layoutQueryCostProbeControls() {
            installQueryCostProbeControlsIfNeeded()
            guard let controls = queryCostControls, let candidateBar else { return }
            let candidateFrame = candidateBar.convert(candidateBar.bounds, to: view)
            // Keep these DEBUG controls clear of the trailing dismiss/expand hit area
            // (56-point button, 16-point left hit outset, trailing inset and gap).
            let leadingInset: CGFloat = 4
            let trailingHitReservation: CGFloat = 84
            let width = min(286, max(0, candidateFrame.width - leadingInset - trailingHitReservation))
            controls.isHidden = width == 0 || candidateFrame.height == 0
            controls.frame = CGRect(
                x: candidateFrame.minX + leadingInset, y: candidateFrame.minY + 2,
                width: width, height: 24
            )
            // The overlay must receive its own touches before the candidate surface.
            view.bringSubviewToFront(controls)
        }
    }
#endif
