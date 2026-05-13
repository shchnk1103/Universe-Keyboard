//
//  KeyPopupView.swift
//  Keyboard
//
//  长按字母键时弹出的变体字符选择面板。
//

import UIKit

/// 每个字母键的长按变体字符（小写形式）。
private let longPressVariants: [String: [String]] = [
    "a": ["à", "á", "â", "ä", "æ", "ã", "å", "ā"],
    "c": ["ç", "ć", "č"],
    "d": ["ð", "đ", "ď"],
    "e": ["è", "é", "ê", "ë", "ē", "ė", "ę"],
    "g": ["ĝ", "ğ", "ġ", "ǧ"],
    "h": ["ĥ", "ħ"],
    "i": ["ì", "í", "î", "ï", "ī", "į"],
    "j": ["ĵ"],
    "k": ["ķ"],
    "l": ["ł", "ĺ", "ľ"],
    "n": ["ñ", "ń", "ň"],
    "o": ["ò", "ó", "ô", "ö", "õ", "ø", "ō"],
    "r": ["ř", "ŕ"],
    "s": ["ß", "ś", "š", "ŝ"],
    "t": ["þ", "ť", "ţ"],
    "u": ["ù", "ú", "û", "ü", "ū", "ų"],
    "w": ["ŵ", "ẁ", "ẃ", "ẅ"],
    "y": ["ý", "ÿ", "ŷ"],
    "z": ["ź", "ż", "ž"],
]

final class KeyPopupView: UIView {

    // MARK: - Static

    static func hasVariants(for key: String) -> Bool {
        longPressVariants[key.lowercased()] != nil
    }

    /// 返回指定键的变体字符数组，根据是否大写调整大小写。
    static func variants(for key: String, uppercase: Bool) -> [String]? {
        guard let lowerVariants = longPressVariants[key.lowercased()] else { return nil }
        if uppercase {
            return lowerVariants.map { $0.uppercased() }
        }
        return lowerVariants
    }

    // MARK: - Properties

    private var labels: [UILabel] = []

    /// 当前选中的变体索引。
    private(set) var selectedIndex: Int = 0

    var currentVariant: String {
        guard !labels.isEmpty else { return "" }
        return labels[selectedIndex].text ?? ""
    }

    // MARK: - Init

    init(variants: [String], keyFrame: CGRect, in containerBounds: CGRect) {
        let itemWidth: CGFloat = 36
        let spacing: CGFloat = 2
        let padding: CGFloat = 8
        let popupHeight: CGFloat = 38

        let popupWidth = CGFloat(variants.count) * itemWidth
            + CGFloat(max(0, variants.count - 1)) * spacing
            + padding * 2
        let gap: CGFloat = 6

        var popupX = keyFrame.midX - popupWidth / 2
        let popupY = keyFrame.minY - popupHeight - gap

        // 水平方向限制在容器内
        popupX = max(3, min(popupX, containerBounds.width - popupWidth - 3))

        super.init(frame: CGRect(x: popupX, y: popupY, width: popupWidth, height: popupHeight))

        backgroundColor = UIColor.systemGray
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])

        for variant in variants {
            let label = UILabel()
            label.text = variant
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17, weight: .medium)
            labels.append(label)
            stackView.addArrangedSubview(label)
        }

        highlight(index: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selection

    /// 根据触摸点更新高亮的变体。
    func selectVariant(at point: CGPoint) {
        let localPoint = convert(point, from: superview)
        for (index, label) in labels.enumerated() {
            if label.frame.contains(localPoint) {
                highlight(index: index)
                return
            }
        }
    }

    private func highlight(index: Int) {
        selectedIndex = index
        for (i, label) in labels.enumerated() {
            if i == index {
                label.textColor = .systemBlue
                label.font = .systemFont(ofSize: 17, weight: .bold)
            } else {
                label.textColor = .white
                label.font = .systemFont(ofSize: 17, weight: .medium)
            }
        }
    }
}
