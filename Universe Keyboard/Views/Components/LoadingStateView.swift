import SwiftUI

/// Lightweight loading indicator for Form sections and overview rows.
///
/// Use for inline “busy” feedback. Toasts and toolbar-only spinners may keep
/// a bare `ProgressView()` when no message is needed.
struct LoadingStateView: View {
    var message: String? = nil
    var font: Font = .footnote

    var body: some View {
        if let message, !message.isEmpty {
            HStack(spacing: AppSpacing.tight) {
                ProgressView()
                Text(message)
                    .font(font)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("加载中")
        }
    }
}
