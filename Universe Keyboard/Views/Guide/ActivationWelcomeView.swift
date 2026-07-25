import SwiftUI

/// Soft first-run Welcome (J0). Skippable; does not equal activation success.
///
/// Product: `PD-HELP-TIPKIT-001` / `ONBOARDING_ACTIVATION.md` J0.
struct ActivationWelcomeView: View {
    var onStart: () -> Void
    var onSkip: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    header
                    copyBlock
                    actions
                }
                .padding(.horizontal, AppSpacing.screen)
                .padding(.vertical, AppSpacing.screen)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("欢迎")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(spacing: AppSpacing.row) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(.primary)
                Image(systemName: "keyboard")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color(.systemBackground))
            }
            .frame(width: 56, height: 56)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(ActivationCopy.welcomeHeadline)
                    .font(.title3.weight(.semibold))
                Text("RIME 中文输入法")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var copyBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.group) {
            Text(ActivationCopy.valueLocal)
                .font(.body)
            Text(ActivationCopy.privacyNoUpload)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(ActivationCopy.systemLimitation)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.card)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var actions: some View {
        VStack(spacing: AppSpacing.group) {
            AppActionButton(
                title: ActivationCopy.welcomeStartTitle,
                systemImage: "arrow.right.circle",
                prominence: .primary
            ) {
                onStart()
            }
            .accessibilityHint("进入帮助中的启用清单")

            AppActionButton(
                title: ActivationCopy.welcomeSkipTitle,
                systemImage: "clock",
                prominence: .secondary
            ) {
                onSkip()
            }
            .accessibilityHint("稍后可在帮助页继续启用")
        }
    }
}

#Preview {
    ActivationWelcomeView(onStart: {}, onSkip: {})
}
