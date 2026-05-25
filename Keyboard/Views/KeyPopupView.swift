//
//  KeyPopupView.swift
//  Keyboard
//
//  长按字母键时弹出的变体字符选择面板。
//
//  变体字符系统：
//  19 个字母（a-z 中有变体的）在长按时会显示带变音符号的版本。
//  例如：a → à á â ä æ ã å ā
//        e → è é ê ë ē ė ę
//        n → ñ ń ň
//
//  Apple 文档参考：
//  - UILongPressGestureRecognizer：用于检测长按（minimumPressDuration=0.3s）
//  - UIButton.cancelTracking(with:)：取消按钮的默认 touchUpInside 追踪，
//    防止长按结束时意外触发按键插入。
//
//  交互设计（模仿原生 iOS 键盘）：
//   1. 长按字母键 0.3s → 弹出面板
//   2. 手指在面板上滑动 → 高亮当前手指下的变体字符
//   3. 手指松开 → 插入当前高亮的变体字符
//   4. 手指滑到面板外松开 → 取消（不插入任何字符）
//   5. 面板弹出后在面板外点击 → 关闭面板
//

import UIKit

/// 每个字母键的长按变体字符集合（小写形式）。
/// 显示时根据 Shift 状态自动转换大小写。
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

    // MARK: === Static Helpers ===

    /// 检查指定字母键是否有长按变体。
    /// - Parameter key: 按键的原始标识符（小写，如 "a"）
    /// - Returns: 是否有变体字符
    static func hasVariants(for key: String) -> Bool {
        longPressVariants[key.lowercased()] != nil
    }

    /// 返回指定键的变体字符数组。
    /// - Parameters:
    ///   - key: 按键的原始标识符（小写）
    ///   - uppercase: 是否转换为大写
    /// - Returns: 变体字符数组，无变体时返回 nil
    static func variants(for key: String, uppercase: Bool) -> [String]? {
        guard let lowerVariants = longPressVariants[key.lowercased()] else { return nil }
        if uppercase {
            return lowerVariants.map { $0.uppercased() }
        }
        return lowerVariants
    }

    // MARK: === Instance Properties ===

    /// 面板中所有变体字符的 UILabel 引用
    private var labels: [UILabel] = []

    /// 当前高亮的变体索引（-1 表示无高亮）
    private(set) var selectedIndex: Int = 0

    /// 当前手指下选中的变体字符
    var currentVariant: String {
        guard !labels.isEmpty else { return "" }
        return labels[selectedIndex].text ?? ""
    }

    // MARK: === Init ===

    /// 创建变体字符弹出面板。
    ///
    /// 面板位置计算：
    ///   - 水平：以按键中心为基准居中，若超出屏幕边界则自动靠边（最小 3pt padding）
    ///   - 垂直：在按键上方，距按键顶部 6pt 的间距
    ///
    /// - Parameters:
    ///   - variants: 变体字符列表
    ///   - keyFrame: 触发按键在容器视图坐标系中的 frame
    ///   - containerBounds: 容器视图的 bounds（用于边界限制）
    init(variants: [String], keyFrame: CGRect, in containerBounds: CGRect) {
        let itemWidth: CGFloat = 36      // 每个变体标签的宽度
        let spacing: CGFloat = 2         // 标签之间的间距
        let padding: CGFloat = 8         // 面板内边距（左右）
        let popupHeight: CGFloat = 38    // 面板高度
        let gap: CGFloat = 6             // 面板与按键之间的间距

        // 计算面板总宽度
        let popupWidth = CGFloat(variants.count) * itemWidth
            + CGFloat(max(0, variants.count - 1)) * spacing
            + padding * 2

        // 水平定位：以按键中心为基准
        var popupX = keyFrame.midX - popupWidth / 2
        // 垂直定位：按键顶部上方
        let popupY = keyFrame.minY - popupHeight - gap

        // 水平边界限制：不超出容器左右 3pt
        popupX = max(3, min(popupX, containerBounds.width - popupWidth - 3))

        super.init(frame: CGRect(x: popupX, y: popupY, width: popupWidth, height: popupHeight))

        // ── 视觉样式 ────────────────────────────────────────────
        backgroundColor = UIColor.systemGray
        layer.cornerRadius = 8
        // 面板阴影
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)

        // ── 布局变体标签 ────────────────────────────────────────
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        // fillEqually：每个变体标签等宽（36pt）
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])

        // 为每个变体字符创建 UILabel
        for variant in variants {
            let label = UILabel()
            label.text = variant
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17, weight: .medium)
            labels.append(label)
            stackView.addArrangedSubview(label)
        }

        // 默认高亮第一个变体
        highlight(index: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: === Selection ===

    /// 根据容器坐标系中的触摸点更新高亮的变体字符。
    ///
    /// 将容器坐标系中的点转换为面板本地坐标，然后检查哪个标签的 frame
    /// 包含了该点。命中的标签反转为高对比文字，其他恢复白色。
    ///
    /// - Parameter point: 容器坐标系中的触摸点
    func selectVariant(at point: CGPoint) {
        let localPoint = convert(point, from: superview)
        for (index, label) in labels.enumerated() {
            if label.frame.contains(localPoint) {
                highlight(index: index)
                return
            }
        }
    }

    /// 高亮指定索引的变体字符标签。
    ///
    /// 高亮效果：
    ///   - 选中的变体：黑色 + 粗体
    ///   - 未选中的变体：白色 + 中等粗细
    private func highlight(index: Int) {
        selectedIndex = index
        for (i, label) in labels.enumerated() {
            if i == index {
                label.textColor = .black
                label.font = .systemFont(ofSize: 17, weight: .bold)
            } else {
                label.textColor = .white
                label.font = .systemFont(ofSize: 17, weight: .medium)
            }
        }
    }
}
