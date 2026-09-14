import SwiftUI

/// Single activation sheet for J0–J5 (`PD-HELP-GUIDE-SHEET-001`).
///
/// Incomplete sessions cannot be swipe-dismissed; 「稍后再说」 only ends this process.
struct ActivationGuideSheet: View {
    @Bindable var rimeStore: RimeSettingsStore
    var showsWelcome: Bool
    var isReRead: Bool
    var onStartFromWelcome: () -> Void
    var onDefer: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        Group {
            if showsWelcome {
                ActivationWelcomeView(
                    onStart: onStartFromWelcome,
                    onSkip: onDefer
                )
            } else {
                GuideTab(
                    rimeStore: rimeStore,
                    onDefer: isReRead ? nil : onDefer,
                    onClose: isReRead ? onDismiss : nil
                )
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(isReRead ? .visible : .hidden)
        .interactiveDismissDisabled(!isReRead)
    }
}
