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

import UIKit
import KeyboardCore

extension KeyboardViewController {

    // MARK: === 字母行 ===

    /// 构建一排字母键按钮。
    /// - Parameters:
    ///   - keys: 按键标题数组（小写形式，displayTitle(for:) 会根据 Shift 状态转换）
    ///   - horizontalInset: 水平内缩距离（第二行使用 18pt 模拟原生键盘的错位布局）
    /// - Returns: 包含字母键的水平 UIStackView
    ///
    /// UIStackView 配置说明：
    /// - distribution: .fillEqually → 每个字母键等宽，与原生键盘一致
    /// - isLayoutMarginsRelativeArrangement + layoutMargins →
    ///   当 horizontalInset > 0 时启用，让行两端留出额外空间
    func makeLetterRow(_ keys: [String], horizontalInset: CGFloat = 0) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fillEqually

        // Apple 文档：isLayoutMarginsRelativeArrangement = true 时，
        // StackView 将 arrangedSubviews 的布局限制在 layoutMargins 范围内，
        // 而不是整个 bounds。这比手动添加 spacer 视图更简洁。
        row.isLayoutMarginsRelativeArrangement = horizontalInset > 0
        row.layoutMargins = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)

        for key in keys {
            // displayTitle(for:) 根据当前 Shift 状态返回大写或小写标题
            let button = makeKeyButton(
                title: displayTitle(for: key),
                action: #selector(insertKey(_:))
            )
            // 用 accessibilityIdentifier 存储原始键值（小写），
            // 因为 button.title 可能被 Shift 改变，而我们需要原始值来查找变体字符
            button.accessibilityIdentifier = key
            letterButtons.append(button)

            // 检查是否有长按变体（如 a → à á â ä æ）
            if KeyPopupView.hasVariants(for: key) {
                let longPress = UILongPressGestureRecognizer(
                    target: self,
                    action: #selector(handleKeyLongPress(_:))
                )
                // Apple 默认长按时间为 0.5s，我们使用 0.3s 以提高输入效率
                longPress.minimumPressDuration = 0.3
                button.addGestureRecognizer(longPress)
            }

            row.addArrangedSubview(button)
        }

        // 固定行高 = 按键高度（44pt）
        row.heightAnchor.constraint(equalToConstant: keyHeight).isActive = true
        return row
    }

    // MARK: === 文本行（数字/符号）===

    /// 构建一排纯文本键（数字或符号，无变体字符）。
    /// 与字母行不同，文本键没有长按变体、不需要 accessibilityIdentifier 追踪。
    /// - Parameter keys: 按键标题数组
    /// - Returns: 包含文本键的水平 UIStackView
    func makeTextRow(_ keys: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        // .fillEqually 确保每个按键等宽 — 数字/符号行都是 10 个按键各占 1/10 宽度
        row.distribution = .fillEqually

        for key in keys {
            row.addArrangedSubview(
                makeKeyButton(title: key, action: #selector(insertKey(_:)))
            )
        }

        row.heightAnchor.constraint(equalToConstant: keyHeight).isActive = true
        return row
    }

    // MARK: === 第三行（Shift + 字母 + 删除）===

    /// 构建字母页的第三行：Shift 键 + 7 个字母键(z-m) + 删除键。
    ///
    /// 使用 .fill 分布 + 固定宽度约束：
    /// - Shift 键: 58pt 宽
    /// - 字母键: 通过嵌套 makeLetterRow 实现等宽分配
    /// - 删除键: 58pt 宽
    ///
    /// `.fill` 分布在此处的含义：
    /// 子视图中有一个（letterRow）不设置宽度约束，让它填充剩余空间。
    /// Shift 和删除键都有固定的 widthAnchor，letterRow 自动获得剩余宽度。
    func makeLetterThirdRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fill  // 非 fillEqually：子视图宽度由各自约束/内容决定

        // Shift 键 — 使用计算属性 shiftButtonTitle（⇧ 或 ⇪）
        shiftButton = makeKeyButton(title: shiftButtonTitle, action: #selector(toggleShift))
        // 嵌套的字母行使用 fillEqually 分布
        let letterRow = makeLetterRow(["z", "x", "c", "v", "b", "n", "m"])
        let deleteButton = makeDeleteButton()
        applyKeyStyle(.function, to: shiftButton)

        row.addArrangedSubview(shiftButton)
        row.addArrangedSubview(letterRow)
        row.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: keyHeight),
            shiftButton.widthAnchor.constraint(equalToConstant: 58),
            deleteButton.widthAnchor.constraint(equalToConstant: 58)
        ])

        // Shift 按钮的外观取决于当前 Shift 状态（off/singleUse/capsLock）
        updateShiftButtonAppearance()
        return row
    }

    // MARK: === Emoji 页面 ===

    /// 构建 Emoji 键盘页面。
    ///
    /// 布局：
    ///   - 分类标签行（水平滚动选择：表情/手势/动物/食物/交通/符号/活动）
    ///   - Emoji 网格：8 列 × 4 行 = 32 个 emoji 一页
    ///   - 底部功能行（页面切换 + 删除 + 空格 + 回车）
    func makeEmojiPage() -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 2
        container.distribution = .fill

        // ── 分类标签行 ────────────────────────────────────────
        let categoryRow = UIStackView()
        categoryRow.axis = .horizontal
        categoryRow.spacing = 2
        categoryRow.distribution = .fillEqually

        for category in EmojiDataSource.categories {
            let label = UIButton(type: .system)
            label.setTitle(category.name, for: .normal)
            label.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            label.setTitleColor(.secondaryLabel, for: .normal)
            label.backgroundColor = characterKeyColor
            label.layer.cornerRadius = 4
            categoryRow.addArrangedSubview(label)
        }

        // ── Emoji 网格滚动视图 ─────────────────────────────────
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let emojiGrid = UIStackView()
        emojiGrid.axis = .vertical
        emojiGrid.spacing = 2
        emojiGrid.distribution = .fillEqually
        emojiGrid.translatesAutoresizingMaskIntoConstraints = false

        // 使用第一个分类（表情）的 emoji 初始填充
        let initialEmojis = EmojiDataSource.categories.first?.emojis ?? []
        let columns = 8
        let maxRows = 4
        let visibleCount = columns * maxRows
        let displayEmojis = Array(initialEmojis.prefix(visibleCount))

        for rowIndex in 0..<maxRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 2
            rowStack.distribution = .fillEqually

            for colIndex in 0..<columns {
                let idx = rowIndex * columns + colIndex
                if idx < displayEmojis.count {
                    let emoji = displayEmojis[idx]
                    let btn = makeEmojiButton(emoji: emoji)
                    rowStack.addArrangedSubview(btn)
                } else {
                    let spacer = UIView()
                    rowStack.addArrangedSubview(spacer)
                }
            }
            emojiGrid.addArrangedSubview(rowStack)
        }

        scrollView.addSubview(emojiGrid)
        container.addArrangedSubview(categoryRow)
        container.addArrangedSubview(scrollView)

        NSLayoutConstraint.activate([
            categoryRow.heightAnchor.constraint(equalToConstant: 24),
            emojiGrid.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            emojiGrid.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            emojiGrid.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            emojiGrid.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            emojiGrid.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            // Emoji 网格高度: 4行 × 每行高度
            emojiGrid.heightAnchor.constraint(equalToConstant: keyHeight * 3 + keySpacing * 2),
        ])

        return container
    }

    /// 创建单个 Emoji 按钮。
    /// 比普通字符键大，无阴影，点击时直接插入 emoji 到 textDocumentProxy。
    private func makeEmojiButton(emoji: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(emoji, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.backgroundColor = characterKeyColor
        button.layer.cornerRadius = 6
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(insertEmoji(_:)), for: .touchUpInside)
        return button
    }

    // MARK: === 底部功能行 ===

    /// 构建所有键盘页面的底部功能行。
    /// 布局因页面类型和键盘类型（邮箱/URL/默认）而异。
    ///
    /// 底部行结构（字母页，默认键盘类型）：
    ///   [🌐(48)] [123(58)] [中/英(48)] [Space(填充)] [return(78)]
    ///
    /// 底部行结构（数字/符号页）：
    ///   [🌐(48)] [ABC(58)] [中/英(48)] [Space(填充)] [⌫(58)] [return(78)]
    ///
    /// 邮箱键盘类型额外显示 @ 和 . 快捷键。
    /// URL 键盘类型额外显示 / 和 .com 快捷键。
    ///
    /// `.fill` 分布下，Space 键通过不设宽度约束来填充剩余空间。
    /// 这模仿了原生 iOS 键盘中空格键占据最大空间的行为。
    ///
    /// - Parameters:
    ///   - pageSwitchTitle: 页面切换按钮标题（"123" / "#+=" / "ABC"）
    ///   - includeDelete: 是否在行中显示删除键
    func makeBottomRow(pageSwitchTitle: String, includeDelete: Bool) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fill

        let showEmail = shouldShowEmailShortcutKeys
        let showURL = shouldShowURLShortcutKeys

        // ── 创建按钮 ──────────────────────────────────────────────
        // 地球键：Apple 要求必须提供，使用 SF Symbol globe 图标
        nextKeyboardButton = makeKeyButton(
            title: "",
            action: #selector(handleInputModeList(from:with:))
        )
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)

        let pageSwitchButton = makeKeyButton(
            title: pageSwitchTitle,
            action: #selector(toggleKeyboardPage)
        )
        let spaceButton = makeKeyButton(
            title: spaceButtonTitle,   // 中文模式显示"拼音"，英文显示"English"
            action: #selector(insertSpace)
        )
        returnButton = makeKeyButton(
            title: returnKeyTitle,     // 动态标题：return/search/send/go/done 等
            action: #selector(insertReturn)
        )

        // ── 应用视觉样式 ──────────────────────────────────────────
        applyKeyStyle(.function, to: nextKeyboardButton)
        applyKeyStyle(.function, to: pageSwitchButton)
        applyKeyStyle(.space, to: spaceButton)
        applyKeyStyle(.returnKey, to: returnButton)

        // ── 组装行 ────────────────────────────────────────────────
        row.addArrangedSubview(nextKeyboardButton)
        row.addArrangedSubview(pageSwitchButton)

        var constraints: [NSLayoutConstraint] = [
            row.heightAnchor.constraint(equalToConstant: keyHeight),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 48),
            pageSwitchButton.widthAnchor.constraint(equalToConstant: 58),
            returnButton.widthAnchor.constraint(equalToConstant: 78)
        ]

        // ── 邮箱/URL 快捷键 或 输入模式切换键 ────────────────────
        // 这三个是互斥的：邮箱快捷键 > URL 快捷键 > 默认输入模式键
        if showEmail {
            let atButton = makeKeyButton(title: "@", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: atButton)
            row.addArrangedSubview(atButton)
            constraints.append(atButton.widthAnchor.constraint(equalToConstant: 40))
        } else if showURL {
            let slashButton = makeKeyButton(title: "/", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: slashButton)
            row.addArrangedSubview(slashButton)
            constraints.append(slashButton.widthAnchor.constraint(equalToConstant: 40))
        } else {
            // 默认：显示输入模式切换键（"中" / "英"）
            let inputModeButton = makeKeyButton(
                title: inputModeButtonTitle,
                action: #selector(toggleInputMode)
            )
            applyKeyStyle(.function, to: inputModeButton)
            row.addArrangedSubview(inputModeButton)
            constraints.append(inputModeButton.widthAnchor.constraint(equalToConstant: 48))
        }

        // Space 键 — 不设宽度约束，利用 .fill 分布自动填充剩余空间
        // 添加滑动手势用于光标移动（模仿原生 iOS 键盘的 Space Cursor）
        let spacePan = UIPanGestureRecognizer(target: self, action: #selector(handleSpaceCursorPan(_:)))
        // 不取消按钮的 touchUpInside，确保点击空格仍然正常插入空格
        spacePan.cancelsTouchesInView = false
        spacePan.delaysTouchesBegan = false
        spaceButton.addGestureRecognizer(spacePan)
        row.addArrangedSubview(spaceButton)

        // ── 邮箱/URL 的第二个快捷键 ────────────────────────────────
        if showEmail {
            let dotButton = makeKeyButton(title: ".", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: dotButton)
            row.addArrangedSubview(dotButton)
            constraints.append(dotButton.widthAnchor.constraint(equalToConstant: 40))
        } else if showURL {
            let dotComButton = makeKeyButton(title: ".com", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: dotComButton)
            row.addArrangedSubview(dotComButton)
            constraints.append(dotComButton.widthAnchor.constraint(equalToConstant: 60))
        }

        // ── 删除键（仅数字/符号页需要） ───────────────────────────
        if includeDelete {
            let deleteButton = makeDeleteButton()
            row.addArrangedSubview(deleteButton)
            constraints.append(deleteButton.widthAnchor.constraint(equalToConstant: 58))
        }

        // 回车键总是最右侧
        row.addArrangedSubview(returnButton)

        NSLayoutConstraint.activate(constraints)

        return row
    }
}
