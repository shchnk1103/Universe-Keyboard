//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源。
//

import UIKit
import KeyboardCore

extension KeyboardViewController {

    func makeCandidateBar() -> UIStackView {
        let bar = UIStackView()
        bar.axis = .horizontal
        bar.spacing = keySpacing
        bar.distribution = .fillEqually
        bar.backgroundColor = UIColor.systemGray6
        bar.layer.cornerRadius = 6
        bar.layoutMargins = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        bar.isLayoutMarginsRelativeArrangement = true

        fillCandidateBar(bar)

        bar.heightAnchor.constraint(equalToConstant: candidateBarHeight).isActive = true
        return bar
    }

    func refreshCandidateBar() {
        guard let candidateBar else { return }
        for arrangedSubview in candidateBar.arrangedSubviews {
            candidateBar.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        fillCandidateBar(candidateBar)
    }

    func fillCandidateBar(_ bar: UIStackView) {
        for item in candidateItems() {
            let button = UIButton(type: .system)
            button.setTitle(item.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            button.backgroundColor = UIColor.clear
            button.accessibilityIdentifier = item.kind
            button.addTarget(self, action: #selector(insertCandidate(_:)), for: .touchUpInside)
            bar.addArrangedSubview(button)
        }
    }

    func candidateItems() -> [(title: String, kind: String)] {
        let state = controller.state

        guard state.inputMode == .chinese else {
            return [("英文模式", "placeholder"), ("字母直接上屏", "placeholder")]
        }

        guard !state.currentComposition.isEmpty else {
            return [("候选", "placeholder"), ("你好", "candidate"), ("世界", "candidate"), ("更多", "placeholder")]
        }

        let candidates = controller.candidateProvider.candidates(for: state.currentComposition)

        if candidates.isEmpty {
            return [
                (state.currentComposition, "composition"),
                ("继续输入", "placeholder"),
                ("空格提交拼音", "placeholder")
            ]
        } else {
            return [(state.currentComposition, "composition")] + candidates.map { ($0, "candidate") }
        }
    }
}
