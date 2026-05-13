//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源。
//  使用 UIScrollView 实现横向滚动，右侧展开按钮可弹出多行候选面板。
//

import UIKit
import KeyboardCore

extension KeyboardViewController {

    // MARK: - 候选栏容器

    func makeCandidateBar() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray5
        container.layer.cornerRadius = 6
        container.clipsToBounds = true

        // 展开按钮（固定在右侧，不随候选滚动）
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

        // 右侧渐隐遮罩（只遮滚动区域，不影响展开按钮）
        addFadeMask(to: scrollView)

        return container
    }

    // MARK: - 展开按钮

    private func makeExpandButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.attributedTitle = attributedButtonTitle("…", fontSize: 14, color: .secondaryLabel)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.addTarget(self, action: #selector(toggleCandidateExpand), for: .touchUpInside)
        return button
    }

    @objc func toggleCandidateExpand() {
        if let panel = candidateExpandedPanel {
            dismissExpandedPanel(panel)
        } else {
            showExpandedPanel()
        }
    }

    // MARK: - 展开面板

    private func showExpandedPanel() {
        guard candidateExpandedPanel == nil else { return }

        let panel = makeExpandedCandidatePanel()
        candidateExpandedPanel = panel

        guard let barIndex = rootStack.arrangedSubviews.firstIndex(of: candidateBar) else { return }
        rootStack.insertArrangedSubview(panel, at: barIndex + 1)

        panel.alpha = 0
        panel.transform = CGAffineTransform(translationX: 0, y: -8)
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            panel.alpha = 1
            panel.transform = .identity
        }

        updateExpandButtonAppearance(expanded: true)
    }

    private func dismissExpandedPanel(_ panel: UIView) {
        candidateExpandedPanel = nil

        UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseIn) {
            panel.alpha = 0
            panel.transform = CGAffineTransform(translationX: 0, y: -8)
        } completion: { _ in
            panel.removeFromSuperview()
        }

        updateExpandButtonAppearance(expanded: false)
    }

    private func updateExpandButtonAppearance(expanded: Bool) {
        guard let btn = candidateExpandButton else { return }
        var config = btn.configuration
        if expanded {
            config?.attributedTitle = attributedButtonTitle("收起", fontSize: 12, color: view.tintColor)
        } else {
            config?.attributedTitle = attributedButtonTitle("…", fontSize: 14, color: .secondaryLabel)
        }
        btn.configuration = config
    }

    func makeExpandedCandidatePanel() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray5
        container.layer.cornerRadius = 6

        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.distribution = .fillEqually
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
                container.heightAnchor.constraint(equalToConstant: 32)
            ])
            return container
        }

        let columns = 4
        let rows = (candidates.count + columns - 1) / columns
        let rowHeight: CGFloat = 36

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

        container.addSubview(verticalStack)

        let totalHeight = CGFloat(rows) * rowHeight + CGFloat(rows - 1) * 4 + 12
        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            container.heightAnchor.constraint(equalToConstant: totalHeight)
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

        if let panel = candidateExpandedPanel {
            dismissExpandedPanel(panel)
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

        // 如果展开面板在显示，同步刷新
        if let panel = candidateExpandedPanel {
            panel.removeFromSuperview()
            candidateExpandedPanel = nil
            showExpandedPanel()
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

    // MARK: - 候选按钮工厂（UIButtonConfiguration，iOS 15+）

    private func makeCandidateButton(title: String, kind: String, color: UIColor) -> UIButton {
        let fontSize: CGFloat = kind == "composition" ? 14 : 16
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        config.attributedTitle = attributedButtonTitle(title, fontSize: fontSize, color: color)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.heightAnchor.constraint(equalToConstant: candidateBarHeight).isActive = true
        return button
    }

    // MARK: - AttributedString 工具

    private func attributedButtonTitle(_ text: String, fontSize: CGFloat, color: UIColor) -> AttributedString {
        var attr = AttributedString(text)
        attr.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        attr.foregroundColor = color
        return attr
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
