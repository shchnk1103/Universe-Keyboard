//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源。
//  UIScrollView 横向滚动 + 可视区高亮 + SF Symbol 展开/收起候选面板。
//

import UIKit
import KeyboardCore

// MARK: - UIScrollViewDelegate（候选可视区高亮）

extension KeyboardViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === candidateScrollView else { return }
        updateCandidateVisibility()
    }

    /// 根据按钮在可视区内的可见比例平滑调整 alpha：
    /// 完全在视口内 → alpha 1.0，滚出视口 → alpha 0.35
    private func updateCandidateVisibility() {
        guard let stack = candidateStack, let scrollView = candidateScrollView else { return }
        let visibleBounds = scrollView.bounds

        for case let button as UIButton in stack.arrangedSubviews {
            guard button.accessibilityIdentifier == "candidate" else { continue }

            let frameInScroll = stack.convert(button.frame, to: scrollView)
            let intersection = frameInScroll.intersection(visibleBounds)
            let ratio: CGFloat
            if frameInScroll.width > 0 {
                ratio = max(0, min(1, intersection.width / frameInScroll.width))
            } else {
                ratio = 0
            }

            let targetAlpha = 0.35 + ratio * 0.65
            button.alpha = targetAlpha
        }
    }
}

// MARK: - 候选栏

extension KeyboardViewController {

    // MARK: - 候选栏容器

    func makeCandidateBar() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray5
        container.layer.cornerRadius = 6
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

        NSLayoutConstraint.activate([
            expandBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -3),
            expandBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            expandBtn.widthAnchor.constraint(equalToConstant: 34),
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
        updateCandidateVisibility()

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
        container.backgroundColor = UIColor.systemGray5
        container.layer.cornerRadius = 6

        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.distribution = .fill
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        let items = candidateItems()
        let candidates = items.filter { $0.kind == "candidate" || $0.kind == "composition" }

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

        for rowIndex in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually

            for colIndex in 0..<columns {
                let itemIndex = rowIndex * columns + colIndex
                if itemIndex < candidates.count {
                    let item = candidates[itemIndex]
                    let color: UIColor = item.kind == "composition" ? .secondaryLabel
                        : (itemIndex == 0 ? view.tintColor : .label)
                    let button = makeCandidateButton(title: item.title, kind: item.kind, color: color)
                    button.accessibilityIdentifier = item.kind
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
        guard let candidate = sender.title(for: .normal),
              let kind = sender.accessibilityIdentifier else { return }
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
        updateCandidateVisibility()

        if isCandidateExpanded {
            UIView.transition(with: rootStack, duration: 0.15, options: .transitionCrossDissolve) {
                self.reloadKeyboardContent()
            }
        }
    }

    func fillCandidateBar() {
        guard let stack = candidateStack else { return }

        let items = candidateItems()

        guard !items.isEmpty else {
            let label = UILabel()
            label.text = " "
            label.font = .systemFont(ofSize: 16)
            stack.addArrangedSubview(label)
            return
        }

        for (index, item) in items.enumerated() {
            let color: UIColor
            if item.kind == "composition" {
                color = .secondaryLabel
            } else if item.kind == "placeholder" {
                color = .tertiaryLabel
            } else if index == 0 {
                color = view.tintColor
            } else {
                color = .label
            }

            let button = makeCandidateButton(title: item.title, kind: item.kind, color: color)
            button.accessibilityIdentifier = item.kind

            if item.kind == "placeholder" {
                button.isUserInteractionEnabled = false
            }

            button.addTarget(self, action: #selector(insertCandidate(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    // MARK: - 候选按钮工厂（UIButtonConfiguration）

    private func makeCandidateButton(title: String, kind: String, color: UIColor) -> UIButton {
        let fontSize: CGFloat = kind == "composition" ? 14 : 16
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        var attr = AttributedString(title)
        attr.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        attr.foregroundColor = color
        config.attributedTitle = attr

        let button = UIButton(configuration: config, primaryAction: nil)
        button.heightAnchor.constraint(equalToConstant: candidateBarHeight).isActive = true
        return button
    }

    // MARK: - 候选数据

    func candidateItems() -> [(title: String, kind: String)] {
        let state = controller.state

        guard state.inputMode == .chinese else {
            return [("英文模式", "placeholder"), ("字母直接上屏", "placeholder")]
        }

        guard !state.currentComposition.isEmpty else {
            return [
                ("输入拼音", "placeholder"),
                ("你好", "candidate"), ("世界", "candidate"), ("中国", "candidate"),
                ("测试", "candidate"), ("我们", "candidate"), ("他们", "candidate"),
                ("更多候选", "placeholder")
            ]
        }

        let candidates = controller.candidateProvider.candidates(for: state.currentComposition)

        if candidates.isEmpty {
            return [
                (state.currentComposition, "composition"),
                ("继续输入拼音", "placeholder"),
                ("空格提交", "placeholder")
            ]
        } else {
            return [(state.currentComposition, "composition")] + candidates.map { ($0, "candidate") }
        }
    }
}
