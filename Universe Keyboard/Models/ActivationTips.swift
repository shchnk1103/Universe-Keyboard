import Foundation
import TipKit

/// Main-App TipKit packaging for activation steps (`PD-HELP-TIPKIT-001` P3).
///
/// One tip = one checklist action. Copy stays within `ActivationCopy` / C1–C9.
/// Invalidation is driven by checklist completion parameters — not a second product contract.
/// Keyboard Extension must not import or present these tips.
enum ActivationTips {
    /// Call once at main-App launch. Failures are non-fatal (tips simply stay quiet).
    static func configure() {
        do {
            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        } catch {
            // TipKit datastore issues must not block app launch.
        }
    }

    /// Push checklist completion into TipKit `@Parameter` rules so finished steps stop showing.
    @MainActor
    static func sync(from state: ActivationChecklistState) {
        let flags = CompletionFlags(state: state)
        ActivationAddKeyboardTip.stepComplete = flags.addKeyboard
        ActivationFullAccessTip.stepComplete = flags.fullAccess
        ActivationPrepareResourcesTip.stepComplete = flags.prepareResources
        ActivationFirstInputTip.stepComplete = flags.firstInput
    }

    /// Pure projection of checklist → tip invalidation flags (unit-testable without Tip UI).
    struct CompletionFlags: Equatable, Sendable {
        var addKeyboard: Bool
        var fullAccess: Bool
        var prepareResources: Bool
        var firstInput: Bool

        init(state: ActivationChecklistState) {
            addKeyboard = state.isStepComplete(.addKeyboard)
            fullAccess = state.isStepComplete(.fullAccess)
            prepareResources = state.isStepComplete(.prepareResources)
            firstInput = state.isStepComplete(.firstInput)
        }
    }
}

// MARK: - Tips (one action each)

/// J1 — add keyboard in system Settings.
struct ActivationAddKeyboardTip: Tip {
    @Parameter
    static var stepComplete: Bool = false

    var title: Text {
        Text(ActivationCopy.title(for: .addKeyboard))
    }

    var message: Text? {
        Text("在系统设置中添加 \(ActivationCopy.keyboardDisplayName)。\(ActivationCopy.systemLimitation)")
    }

    var image: Image? {
        Image(systemName: "keyboard")
    }

    var rules: [Rule] {
        #Rule(Self.$stepComplete) { $0 == false }
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(3)]
    }
}

/// J2 — allow Full Access (purpose + non-upload; not full privacy policy).
struct ActivationFullAccessTip: Tip {
    @Parameter
    static var stepComplete: Bool = false

    var title: Text {
        Text(ActivationCopy.title(for: .fullAccess))
    }

    var message: Text? {
        Text("\(ActivationCopy.fullAccessPurpose) \(ActivationCopy.fullAccessNotUpload)")
    }

    var image: Image? {
        Image(systemName: "lock.open")
    }

    var rules: [Rule] {
        #Rule(Self.$stepComplete) { $0 == false }
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(3)]
    }
}

/// J3 — prepare RIME resources in the main App.
struct ActivationPrepareResourcesTip: Tip {
    @Parameter
    static var stepComplete: Bool = false

    var title: Text {
        Text(ActivationCopy.title(for: .prepareResources))
    }

    var message: Text? {
        Text(ActivationCopy.mainAppPreparesResources)
    }

    var image: Image? {
        Image(systemName: "externaldrive.badge.checkmark")
    }

    var rules: [Rule] {
        #Rule(Self.$stepComplete) { $0 == false }
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(3)]
    }
}

/// J4 — first successful Chinese input smoke.
struct ActivationFirstInputTip: Tip {
    @Parameter
    static var stepComplete: Bool = false

    var title: Text {
        Text(ActivationCopy.title(for: .firstInput))
    }

    var message: Text? {
        Text(ActivationCopy.nextActionTitle(for: .firstInput))
    }

    var image: Image? {
        Image(systemName: "text.cursor")
    }

    var rules: [Rule] {
        #Rule(Self.$stepComplete) { $0 == false }
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(3)]
    }
}

// MARK: - SwiftUI helpers

extension View {
    /// Attach the TipKit tip for the given activation step (if any).
    @ViewBuilder
    func activationPopoverTip(for step: ActivationChecklistState.Step?) -> some View {
        switch step {
        case .addKeyboard:
            self.popoverTip(ActivationAddKeyboardTip(), arrowEdge: .top)
        case .fullAccess:
            self.popoverTip(ActivationFullAccessTip(), arrowEdge: .top)
        case .prepareResources:
            self.popoverTip(ActivationPrepareResourcesTip(), arrowEdge: .top)
        case .firstInput:
            self.popoverTip(ActivationFirstInputTip(), arrowEdge: .top)
        case nil:
            self
        }
    }
}
