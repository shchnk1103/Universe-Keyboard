//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源。
//  使用 UIScrollView 实现横向滚动，贴近原生体验。
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

        // 滚动视图
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.decelerationRate = .fast
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
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

        // 右侧渐隐遮罩
        addFadeMask(to: container)

        return container
    }

    // MARK: - 右侧渐隐遮罩

    private func addFadeMask(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.88, 1]
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
        // 刷新后回到最左
        candidateScrollView.setContentOffset(.zero, animated: false)
    }

    func fillCandidateBar() {
        guard let stack = candidateStack else { return }

        let items = candidateItems()

        // 空候选时显示占位
        guard !items.isEmpty else {
            let label = UILabel()
            label.text = " "
            label.font = .systemFont(ofSize: 16)
            stack.addArrangedSubview(label)
            return
        }

        for (index, item) in items.enumerated() {
            let button = makeCandidateButton(title: item.title, kind: item.kind)
            button.accessibilityIdentifier = item.kind

            // 高亮首个候选（composition 或第一候选）
            if index == 0 && item.kind == "candidate" {
                button.setTitleColor(tintColor, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            }

            button.addTarget(self, action: #selector(insertCandidate(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    // MARK: - 候选按钮工厂

    private func makeCandidateButton(title: String, kind: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.label, for: .normal)

        // composition 字符串使用浅色
        if kind == "composition" {
            button.setTitleColor(UIColor.secondaryLabel, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        }

        // placeholder 不可交互
        if kind == "placeholder" {
            button.isUserInteractionEnabled = false
            button.setTitleColor(UIColor.tertiaryLabel, for: .normal)
        }

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
            return [("输入拼音", "placeholder"), ("你好", "candidate"), ("世界", "candidate"), ("中国", "candidate"), ("测试", "candidate"), ("更多候选", "placeholder")]
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
