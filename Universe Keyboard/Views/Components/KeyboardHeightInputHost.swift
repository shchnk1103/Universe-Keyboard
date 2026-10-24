import SwiftUI
import UIKit

/// 可持有 first responder 的真实输入框，视觉、触摸与辅助功能分别隔离。
struct KeyboardHeightInputHost: UIViewRepresentable {
    let session: KeyboardHeightAdjustmentPageSession

    func makeUIView(context: Context) -> KeyboardHeightInputHostView {
        let host = KeyboardHeightInputHostView()
        session.inputHost = host
        host.update(marker: session.marker)
        return host
    }

    func updateUIView(_ uiView: KeyboardHeightInputHostView, context: Context) {
        session.inputHost = uiView
        uiView.update(marker: session.marker)
    }

    static func dismantleUIView(_ uiView: KeyboardHeightInputHostView, coordinator: ()) {
        uiView.stop()
    }
}

class KeyboardHeightInputHostView: UIView, UITextFieldDelegate {
    let textField = KeyboardHeightInvisibleTextField()
    private(set) var marker: String?
    private var attemptedMarker: String?
    private var focusTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = false
        accessibilityElementsHidden = true
        backgroundColor = .clear
        clipsToBounds = true
        textField.isAccessibilityElement = false
        textField.accessibilityElementsHidden = true
        textField.backgroundColor = .clear
        textField.textColor = .clear
        textField.tintColor = .clear
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 1)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
        textField.delegate = self
        // 不设 secure / hidden / disabled；这些属性可能使系统不再提供第三方键盘。
        addSubview(textField)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = bounds
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool { false }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil { stop() } else { scheduleFocusIfNeeded() }
    }

    func update(marker: String?) {
        guard let marker else { stop(); return }
        guard self.marker != marker else { return }
        self.marker = marker
        textField.text = marker
        textField.selectedTextRange = textField.textRange(
            from: textField.endOfDocument, to: textField.endOfDocument)
        scheduleFocusIfNeeded()
    }

    private func scheduleFocusIfNeeded() {
        guard let marker, window != nil, attemptedMarker != marker, focusTask == nil else { return }
        focusTask = Task { @MainActor [weak self] in
            // 等待 UIKit 完成当前挂载；不轮询、不在 SwiftUI 重绘时重复取焦点。
            await Task.yield()
            guard !Task.isCancelled, let self, self.window != nil, self.marker == marker else { return }
            self.focusTask = nil
            self.attemptedMarker = marker
            self.requestInputFocus()
        }
    }

    /// 独立的 UIKit 副作用边界，测试可观察调用次数而不弹出测试宿主的键盘。
    func requestInputFocus() {
        textField.becomeFirstResponder()
    }

    func stop() {
        focusTask?.cancel()
        focusTask = nil
        marker = nil
        textField.resignFirstResponder()
        textField.text = nil
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
        -> Bool
    {
        // 即使用户当前选中系统键盘，也不允许改写页面的协议标记。
        false
    }
}

final class KeyboardHeightInvisibleTextField: UITextField {
    override var accessibilityValue: String? {
        get { nil }
        set { /* 标记不得成为可朗读的内容。 */  }
    }

    override func caretRect(for position: UITextPosition) -> CGRect { .zero }
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] { [] }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { false }
}
