//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源。
//  UIScrollView 横向滚动 + SF Symbol 展开/收起候选面板。
//

import UIKit
import KeyboardCore

// MARK: - UIScrollViewDelegate

extension KeyboardViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

// MARK: - 候选栏

extension KeyboardViewController {

    // MARK: - 候选栏容器

    func makeCandidateBar() -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.layer.cornerRadius = 0
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
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        candidateScrollView = scrollView

        // 水平排列候选词的 Stack
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
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

        let separator = UIView()
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.22)
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])

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

        UIView.transition(with: rootStack, duration: 0.2, options: .transitionCrossDissolve) {
            self.reloadKeyboardContent()
        }
    }

    // MARK: - 展开面板

    func makeExpandedCandidatePanel(with precomputedItems: [CandidateItem]? = nil) -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.layer.cornerRadius = keyCornerRadius
        container.clipsToBounds = true

        // 展开面板高度严格匹配 4 行正常按键区域，避免键盘整体升高到半屏
        let keyRowsHeight = keyHeight * 4 + keySpacing * 3

        let items = precomputedItems ?? candidateItems()
        let candidates = items.filter { $0.kind != .placeholder }

        guard !candidates.isEmpty else {
            let label = UILabel()
            label.text = "暂无候选"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                container.heightAnchor.constraint(equalToConstant: keyRowsHeight)
            ])
            return container
        }

        let columns = 4
        let rows = (candidates.count + columns - 1) / columns
        let rowHeight: CGFloat = 44

        // 候选 Grid 放入滚动视图，超出的内容可纵向滚动
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.distribution = .fill
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

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

                    let color: UIColor = item.kind == .composition ? .secondaryLabel : .label

                    let button = CandidateButtonFactory.makeCandidateButton(
                        title: item.title,
                        kind: item.kind,
                        color: color,
                        bold: isFirstCandidate,
                        height: rowHeight,
                        highlighted: isFirstCandidate
                    )
                    button.tag = item.kind.rawValue
                    button.addTarget(self, action: #selector(insertCandidateFromPanel(_:)), for: .touchUpInside)
                    rowStack.addArrangedSubview(button)
                } else {
                    let spacer = UIView()
                    rowStack.addArrangedSubview(spacer)
                }
            }

            verticalStack.addArrangedSubview(rowStack)
        }

        scrollView.addSubview(verticalStack)
        container.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            verticalStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            verticalStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -8),
            verticalStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 6),
            verticalStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -6),
            verticalStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -16),

            container.heightAnchor.constraint(equalToConstant: keyRowsHeight)
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
        guard candidateStack != nil else { return }

        let allItems = candidateItems()
        Logger.shared.debug("refreshCandidateBar: items=\(allItems.count), expanded=\(isCandidateExpanded)", category: .display)
        fillCandidateBar(precomputedItems: allItems)

        if candidateScrollView.contentOffset.x != 0 {
            candidateScrollView.setContentOffset(.zero, animated: false)
        }

        if isCandidateExpanded {
            UIView.transition(with: rootStack, duration: 0.15, options: .transitionCrossDissolve) {
                self.reloadKeyboardContent(with: allItems)
            }
        }
    }

    /// 填充候选栏。每次完整清除旧按钮后重建，简单可靠，避免复用逻辑的边界 bug。
    /// 20 个候选词创建 UIButton 耗时 <0.5ms，RIME 处理耗时 2-5ms，创建开销可忽略。
    func fillCandidateBar(precomputedItems: [CandidateItem]? = nil) {
        guard let stack = candidateStack else {
            Logger.shared.warning("fillCandidateBar: candidateStack is nil", category: .general)
            return
        }

        let allItems = precomputedItems ?? candidateItems()
        let items = allItems.filter { $0.kind != .placeholder }

        let hasCandidates = items.contains { $0.kind == .candidate }
        candidateExpandButton?.isHidden = !hasCandidates
        let targetWidth: CGFloat = hasCandidates ? 34 : 0
        if candidateExpandButtonWidthConstraint?.constant != targetWidth {
            candidateExpandButtonWidthConstraint?.constant = targetWidth
        }

        // 清除所有旧按钮
        let oldCount = stack.arrangedSubviews.count
        for subview in stack.arrangedSubviews.reversed() {
            stack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        guard !items.isEmpty else {
            Logger.shared.debug("fillCandidateBar: cleared \(oldCount) old views, 0 new items", category: .display)
            return
        }

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

            let color: UIColor = item.kind == .composition ? .secondaryLabel : .label

            let button = CandidateButtonFactory.makeCandidateButton(
                title: item.title,
                kind: item.kind,
                color: color,
                bold: isFirstCandidate,
                height: candidateBarHeight,
                highlighted: isFirstCandidate
            )
            button.addTarget(self, action: #selector(insertCandidate(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        Logger.shared.debug("fillCandidateBar: cleared \(oldCount) old views, added \(items.count) new buttons, kinds=\(items.map { $0.kind.rawValue })", category: .display)
    }

    // MARK: - 候选数据

    func candidateItems() -> [CandidateItem] {
        CandidateBarDataSource.candidateItems(from: controller)
    }
}
