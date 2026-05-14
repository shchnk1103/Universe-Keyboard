//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源。
//  UIScrollView 横向滚动 + 可视区高亮 + SF Symbol 展开/收起候选面板。
//

import UIKit
import KeyboardCore

// MARK: - UIScrollViewDelegate

extension KeyboardViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 不再基于滚动位置调整 alpha —— 高亮逻辑改为：
        // 只高亮第一个真正的候选词（按空格会输入的那个词）
        // 见 fillCandidateBar() 中的 isFirstCandidate 处理
    }
}

// MARK: - 候选栏

extension KeyboardViewController {

    // MARK: - 候选栏容器

    func makeCandidateBar() -> UIView {
        let container = UIView()
        // 与键盘底板同色（systemGray4），使候选栏和键盘融为一体
        container.backgroundColor = UIColor.systemGray4
        container.layer.cornerRadius = keyCornerRadius
        container.clipsToBounds = true

        // 展开按钮（SF Symbol，固定在右侧）
        let expandBtn = makeExpandButton()
        container.addSubview(expandBtn)
        candidateExpandButton = expandBtn

        // 滚动视图
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.decelerationRate = .fast
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 4)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        candidateScrollView = scrollView

        // 水平排列候选词的 Stack
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        candidateStack = stack

        scrollView.addSubview(stack)
        container.addSubview(scrollView)

        let expandWidth = expandBtn.widthAnchor.constraint(equalToConstant: 34)
        candidateExpandButtonWidthConstraint = expandWidth

        NSLayoutConstraint.activate([
            expandBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -3),
            expandBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            expandWidth,
            expandBtn.heightAnchor.constraint(equalToConstant: candidateBarHeight),

            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: expandBtn.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        container.heightAnchor.constraint(equalToConstant: candidateBarHeight).isActive = true

        fillCandidateBar()

        // 右侧渐隐遮罩（只遮滚动区域，不影响展开按钮）
        addFadeMask(to: scrollView)

        return container
    }

    // MARK: - 展开按钮（SF Symbol）

    private func makeExpandButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        config.baseForegroundColor = .secondaryLabel

        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleCandidateExpand), for: .touchUpInside)
        return button
    }

    @objc func toggleCandidateExpand() {
        isCandidateExpanded.toggle()

        // chevron 旋转 180°
        if let btn = candidateExpandButton {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                btn.imageView?.transform = self.isCandidateExpanded
                    ? CGAffineTransform(rotationAngle: .pi)
                    : .identity
            }
            var config = btn.configuration
            config?.baseForegroundColor = isCandidateExpanded ? view.tintColor : .secondaryLabel
            btn.configuration = config
        }

        // 键盘内容区淡入淡出
        UIView.transition(with: rootStack, duration: 0.2, options: .transitionCrossDissolve) {
            self.reloadKeyboardContent()
        }
    }

    // MARK: - 展开面板

    func makeExpandedCandidatePanel() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray4
        container.layer.cornerRadius = keyCornerRadius

        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.distribution = .fill
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        let items = candidateItems()
        // 展开面板只显示候选词和拼音组合，过滤掉占位提示
        let candidates = items.filter { $0.kind != .placeholder }

        guard !candidates.isEmpty else {
            let label = UILabel()
            label.text = "暂无候选"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            verticalStack.addArrangedSubview(label)
            container.addSubview(verticalStack)
            NSLayoutConstraint.activate([
                verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
                verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
                verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
                container.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
            ])
            return container
        }

        let columns = 4
        let rows = (candidates.count + columns - 1) / columns
        let rowHeight: CGFloat = 44

        // 追踪第一个真正的候选词（.candidate），与横向滚动栏的高亮逻辑一致
        var firstCandidateFound = false

        for rowIndex in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually

            for colIndex in 0..<columns {
                let itemIndex = rowIndex * columns + colIndex
                if itemIndex < candidates.count {
                    let item = candidates[itemIndex]

                    let isFirstCandidate: Bool = {
                        if firstCandidateFound { return false }
                        if item.kind == .candidate {
                            firstCandidateFound = true
                            return true
                        }
                        return false
                    }()

                    let color: UIColor
                    if item.kind == .composition {
                        color = .secondaryLabel
                    } else if isFirstCandidate {
                        color = view.tintColor
                    } else {
                        color = .label
                    }

                    let button = makeCandidateButton(
                        title: item.title,
                        kind: item.kind,
                        color: color,
                        bold: isFirstCandidate
                    )
                    button.tag = item.kind.rawValue
                    button.addTarget(self, action: #selector(insertCandidateFromPanel(_:)), for: .touchUpInside)
                    button.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
                    rowStack.addArrangedSubview(button)
                } else {
                    let spacer = UIView()
                    rowStack.addArrangedSubview(spacer)
                }
            }

            verticalStack.addArrangedSubview(rowStack)
        }

        let filler = UIView()
        filler.setContentHuggingPriority(.defaultLow, for: .vertical)
        verticalStack.addArrangedSubview(filler)

        container.addSubview(verticalStack)

        let minHeight = CGFloat(rows) * rowHeight + CGFloat(rows - 1) * 4 + 12
        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        ])

        return container
    }

    @objc func insertCandidateFromPanel(_ sender: UIButton) {
        guard let candidate = sender.configuration?.title,
              let kind = CandidateKind(rawValue: sender.tag) else { return }
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertCandidate(candidate, kind: kind))
        syncUI(with: effects)

        isCandidateExpanded = false
        UIView.transition(with: rootStack, duration: 0.2, options: .transitionCrossDissolve) {
            self.reloadKeyboardContent()
        }
    }

    // MARK: - 右侧渐隐遮罩

    private func addFadeMask(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.82, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = view.bounds
        view.layer.mask = gradient
        candidateFadeGradient = gradient
    }

    // MARK: - 刷新

    func refreshCandidateBar() {
        guard let stack = candidateStack else { return }
        for arrangedSubview in stack.arrangedSubviews {
            stack.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        fillCandidateBar()
        candidateScrollView.setContentOffset(.zero, animated: false)

        if isCandidateExpanded {
            UIView.transition(with: rootStack, duration: 0.15, options: .transitionCrossDissolve) {
                self.reloadKeyboardContent()
            }
        }
    }

    /// 填充候选栏的横向滚动区域。
    ///
    /// 和 makeExpandedCandidatePanel() 共享同一份数据源（candidateItems()），
    /// 并且同样过滤掉 .placeholder 类型的提示项。
    /// 两者展示的候选词数量和内容完全一致。
    ///
    /// 高亮逻辑：只高亮第一个真正的候选词（.candidate 类型）。
    /// 这是按空格键会输入的那个词 —— 对它加粗 + 主题色，
    /// 让用户一眼就知道空格会输入什么。
    func fillCandidateBar() {
        guard let stack = candidateStack else { return }

        let allItems = candidateItems()
        // 过滤掉占位提示，只展示候选词和拼音组合
        // 与 makeExpandedCandidatePanel() 保持一致的过滤逻辑
        let items = allItems.filter { $0.kind != .placeholder }

        // 展开按钮只在有候选内容时才显示
        // 与原生键盘行为一致：没有候选词时没有展开面板的必要
        // 收起宽度到 0，让 scrollView 填充整个容器
        let hasCandidates = items.contains { $0.kind == .candidate }
        candidateExpandButton?.isHidden = !hasCandidates
        candidateExpandButtonWidthConstraint?.constant = hasCandidates ? 34 : 0

        // 全部被过滤掉了（如英文模式只有 placeholder 或完全无输入）→ 显示空栏
        guard !items.isEmpty else {
            let label = UILabel()
            label.text = " "
            label.font = .systemFont(ofSize: 16)
            stack.addArrangedSubview(label)
            return
        }

        // 用布尔标记追踪"第一个 .candidate 已经出现过了吗"
        // 这样 index=0 即使是 .composition（拼音组合），也能正确识别
        // 真正的第一个候选词（即按空格会输入的那个）
        var firstCandidateFound = false

        for item in items {
            let isFirstCandidate: Bool = {
                if firstCandidateFound { return false }
                if item.kind == .candidate {
                    firstCandidateFound = true
                    return true
                }
                return false
            }()

            // 颜色：拼音组合用次要灰，第一个候选用主题色，其余用标签色
            let color: UIColor
            if item.kind == .composition {
                color = .secondaryLabel
            } else if isFirstCandidate {
                color = view.tintColor
            } else {
                color = .label
            }

            let button = makeCandidateButton(
                title: item.title,
                kind: item.kind,
                color: color,
                bold: isFirstCandidate
            )
            // 将 CandidateKind 存到 tag 中，供 action handler 读取
            button.tag = item.kind.rawValue

            button.addTarget(self, action: #selector(insertCandidate(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    // MARK: - 候选按钮工厂（UIButtonConfiguration）

    /// 候选按钮工厂，使用现代 UIButton.Configuration API（iOS 15+）。
    /// 拼音组合使用比候选词小一号的字体（14pt vs 16pt），视觉上区分"输入中"和"可选择"。
    /// 第一个真正的候选词（bold=true）使用粗体 + 主题色，指示这是按空格会输入的那个词。
    ///
    /// 关键设计决策：使用 titleTextAttributesTransformer 而非 attributedTitle 来设置字体和颜色。
    /// 原因：UIButton.Configuration 中 attributedTitle 和 title 是互斥的 ——
    /// 一旦设置 attributedTitle，title 就被忽略，导致 sender.title(for: .normal) 返回 nil。
    /// titleTextAttributesTransformer 只改变 title 的显示属性，不替换 title 本身，
    /// 因此 action handler 中能可靠读取 sender.configuration?.title。
    private func makeCandidateButton(
        title: String,
        kind: CandidateKind,
        color: UIColor,
        bold: Bool = false
    ) -> UIButton {
        let fontSize: CGFloat = kind == .composition ? 14 : 16
        let weight: UIFont.Weight = bold ? .bold : .regular

        var config = UIButton.Configuration.plain()
        config.title = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var container = container
            container.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
            container.foregroundColor = color
            return container
        }

        let button = UIButton(configuration: config, primaryAction: nil)
        button.heightAnchor.constraint(equalToConstant: candidateBarHeight).isActive = true
        return button
    }

    // MARK: - 候选数据

    /// 构建候选栏要显示的数据数组。
    ///
    /// 数据流：CandidateProvider.candidates(for:) 返回 [String]
    ///       → 这个方法把它们包装成 [CandidateItem]
    ///       → fillCandidateBar() / makeExpandedCandidatePanel() 渲染为 UIButton
    ///
    /// 行为模仿原生 iOS 键盘：
    /// - 英文模式：候选栏为空（英文直接上屏，无需候选）
    /// - 中文模式，无拼音组合：候选栏为空（和原生键盘一样，不输入时候选栏不显示任何东西）
    /// - 中文模式，有拼音但无匹配：只显示拼音组合本身（用户可以点它提交原始拼音）
    /// - 中文模式，有拼音且有匹配：拼音组合 + 候选词列表
    func candidateItems() -> [CandidateItem] {
        let state = controller.state

        // 英文模式：候选栏为空（原生键盘在英文模式下不显示候选）
        guard state.inputMode == .chinese else {
            return []
        }

        // 没有拼音输入：候选栏为空（原生键盘不输入时候选栏是空的）
        guard !state.currentComposition.isEmpty else {
            return []
        }

        let candidates = controller.candidateProvider.candidates(for: state.currentComposition)

        if candidates.isEmpty {
            // 有拼音但无匹配候选：只显示拼音组合本身，用户可以点击提交原始拼音
            return [CandidateItem(title: state.currentComposition, kind: .composition)]
        } else {
            // 有拼音且有匹配候选：拼音组合 + 候选词列表
            return [CandidateItem(title: state.currentComposition, kind: .composition)]
                + candidates.map { CandidateItem(title: $0, kind: .candidate) }
        }
    }
}
