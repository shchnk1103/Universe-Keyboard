import UIKit
import UniformTypeIdentifiers

/// Retained by the toolbar, but never retained by a provider completion.
@MainActor
final class RetainedPasteReceiver: UIView {
    let session: PasteToolbarSession
    private var epoch: UInt64 = 0
    private var operationID: UInt64?

    init(session: PasteToolbarSession) {
        self.session = session
        super.init(frame: .zero)
        pasteConfiguration = UIPasteConfiguration(acceptableTypeIdentifiers: [UTType.plainText.identifier])
        isUserInteractionEnabled = false
        isAccessibilityElement = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func paste(itemProviders: [NSItemProvider]) {
        guard let id = session.begin() else { return }
        operationID = id
        let capturedEpoch = epoch
        guard
            let provider = itemProviders.first(where: {
                $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
            })
        else { session.complete(nil, operationID: id); return }
        provider.loadObject(ofClass: NSString.self) { [weak self] object, _ in
            // Convert before crossing isolation; the actor receives an immutable value only.
            let text = object as? String
            DispatchQueue.main.async { [weak self] in
                guard let self, self.epoch == capturedEpoch else { return }
                self.session.complete(text, operationID: id)
            }
        }
    }

    func invalidate() {
        epoch += 1
        session.invalidate()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil { invalidate() }
        super.willMove(toSuperview: newSuperview)
    }

    deinit {
        let session = session
        let id = operationID
        Task { @MainActor in
            if let id { session.invalidate(operationID: id) }
        }
    }
}
