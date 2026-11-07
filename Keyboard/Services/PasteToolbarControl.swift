import UIKit

/// System paste authorization stays attached to the visible, user-operated control.
@MainActor
final class PasteToolbarControl: UIView {
    let receiver: RetainedPasteReceiver
    let control: UIPasteControl

    init(session: PasteToolbarSession) {
        receiver = RetainedPasteReceiver(session: session)
        let configuration = UIPasteControl.Configuration()
        configuration.displayMode = .iconAndLabel
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .label
        control = UIPasteControl(configuration: configuration)
        super.init(frame: .zero)
        accessibilityIdentifier = "keyboard.paste.toolbar"
        control.accessibilityLabel = "粘贴"
        control.target = receiver
        addSubview(receiver)
        addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            control.leadingAnchor.constraint(equalTo: leadingAnchor),
            control.trailingAnchor.constraint(equalTo: trailingAnchor),
            control.topAnchor.constraint(equalTo: topAnchor),
            control.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil { receiver.invalidate() }
        super.willMove(toSuperview: newSuperview)
    }
}
