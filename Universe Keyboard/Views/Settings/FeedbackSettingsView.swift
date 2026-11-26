import KeyboardCore
import SwiftUI

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
private let feedbackSettingsDefaults = UserDefaults(suiteName: appGroupID)

/// 重置为默认震动强度的纯逻辑（PB-001-FEEDBACK-UI-001）。
/// 独立于视图，便于在不触碰真实共享容器的前提下验证行为。
struct FeedbackHapticReset {
    let defaults: UserDefaults?

    func perform() -> Double {
        let intensity = KeyboardFeedbackLevel.defaultLevel.hapticIntensity
        KeyboardFeedbackSettingsStore.writeContinuousIntensity(intensity, in: defaults)
        defaults?.set(
            KeyboardFeedbackLevel.defaultLevel.rawValue,
            forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        defaults?.synchronize()
        return intensity
    }
}

/// 重置确认弹窗的固定文案与取消/确认分流（PB-001-FEEDBACK-UI-001）。
enum FeedbackResetConfirmationSheet {
    static let title = "重置为默认强度？"
    static let message = "震动强度将恢复为默认值（正常，65%），并预览一次默认强度。"
    static let confirmTitle = "重置"
    static let cancelTitle = "取消"

    static func handle(dismiss: () -> Void, confirm: Bool, action: () -> Void) {
        dismiss()
        guard confirm else { return }
        action()
    }
}

/// 键盘反馈设置子页面。
struct FeedbackSettingsView: View {
    @AppStorage(KeyboardFeedbackSettingsKey.keyClickEnabled, store: feedbackSettingsDefaults)
    private var keyClickEnabled = true
    /// PB-019 PR-2: 按键气泡预览开关（`keyboard.keyPopupEnabled`，默认开）。
    /// 独立卡片行，不复用触感卡片的 `.disabled`/`.opacity` 整段布局，避免锁死其它开关。
    @AppStorage(KeyboardKeyPopupSettings.enabledKey, store: feedbackSettingsDefaults)
    private var keyPopupEnabled = true
    @AppStorage(KeyboardFeedbackSettingsKey.hapticEnabled, store: feedbackSettingsDefaults)
    private var hapticEnabled = false
    @AppStorage(KeyboardFeedbackSettingsKey.hapticLevel, store: feedbackSettingsDefaults)
    private var hapticLevel = KeyboardFeedbackLevel.defaultLevel.rawValue
    @AppStorage(KeyboardFeedbackSettingsKey.hapticIntensityContinuous, store: feedbackSettingsDefaults)
    private var hapticIntensity = KeyboardFeedbackLevel.defaultLevel.hapticIntensity

    @StateObject private var previewCoordinator = FeedbackPreviewCoordinator()
    @State private var permissionMessage: String?
    @State private var showResetConfirmation = false

    var body: some View {
        Form {
            Section {
                Toggle("按键音", isOn: keyClickBinding)
                    .toggleStyle(.appSwitch)
            } header: {
                Text("按键音")
            } footer: {
                Text(keyClickFooter)
            }

            // PB-019 PR-2: 按键气泡预览为独立卡片行（纯视觉确认反馈，默认开）。
            Section {
                Toggle("按键气泡预览", isOn: $keyPopupEnabled)
                    .toggleStyle(.appSwitch)
            } header: {
                Text("按键气泡预览")
            } footer: {
                Text(keyPopupFooter)
            }

            // Always mounted: avoid Form Section insert/remove when haptic toggles (AsyncRenderer).
            // 触感反馈开关与震动强度合并为同一张卡片（PB-001-FEEDBACK-UI-001）。
            Section {
                Toggle("按键震动", isOn: hapticBinding)
                    .toggleStyle(.appSwitch)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("强度")
                        Spacer()
                        Text(intensityLabel)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $hapticIntensity, in: 0...1) { editing in
                        guard !editing else { return }
                        commitIntensity(hapticIntensity)
                    }
                    .disabled(!hapticEnabled)
                    Text("轻、正常、重只是参考。拖动时按当前强度即时预览。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .disabled(!hapticEnabled)
                .opacity(hapticEnabled ? 1 : 0.48)
                AppActionButton(
                    title: "重置为默认强度",
                    systemImage: "arrow.counterclockwise",
                    prominence: .secondary
                ) {
                    showResetConfirmation = true
                }
                .disabled(!hapticEnabled)
                .opacity(hapticEnabled ? 1 : 0.48)
                .accessibilityIdentifier("resetHapticIntensity")
            } header: {
                Text("触感反馈")
            } footer: {
                Text(
                    hapticEnabled
                        ? "震动设置会通过 App Group 同步到键盘，需要在系统键盘设置中开启「允许完全访问」。松手后记住这个强度，并按它预览一次。快速拖动会自动节流。"
                        : "开启「按键震动」后可拖动强度并预览。"
                )
            }
        }
        .sheet(isPresented: $showResetConfirmation) {
            FeedbackResetSheet(
                onConfirm: {
                    let intensity = FeedbackHapticReset(defaults: feedbackSettingsDefaults).perform()
                    hapticIntensity = intensity
                    hapticLevel = KeyboardFeedbackLevel.defaultLevel.rawValue
                    previewCoordinator.previewHaptic(intensity: intensity, force: true)
                },
                onCancel: {}
            )
            .presentationDetents([.medium])
        }
        .navigationTitle("键盘反馈")
        .tint(.primary)
        .alert(
            "需要完全访问",
            isPresented: Binding(
                get: { permissionMessage != nil },
                set: { if !$0 { permissionMessage = nil } }
            )
        ) {
            Button("知道了", role: .cancel) { permissionMessage = nil }
        } message: {
            Text(permissionMessage ?? "")
        }
        .onAppear {
            migrateLegacyFeedbackSettingsIfNeeded()
        }
    }

    private var keyClickFooter: String {
        keyClickEnabled
            ? "真实键盘使用 iOS 系统输入点击音，不会由 Universe Keyboard 激活音频会话。App 内开关需允许完全访问同步，系统键盘反馈中的声音也需开启。"
            : "开启后使用 iOS 系统输入点击音；声音大小、静音和音频路由由系统管理。"
    }

    private var keyPopupFooter: String {
        keyPopupEnabled
            ? "按下字符键时在键位上方显示字符气泡（26 键与九宫格第一行）。开关通过 App Group 同步到键盘，切回键盘后立即生效。"
            : "关闭后键盘不再显示按键气泡；切回键盘后立即生效。"
    }

    private var keyClickBinding: Binding<Bool> {
        Binding(
            get: { keyClickEnabled },
            set: { newValue in
                setKeyClickEnabled(newValue)
            }
        )
    }

    private var hapticBinding: Binding<Bool> {
        Binding(
            get: { hapticEnabled },
            set: { newValue in
                setHapticEnabled(newValue)
            }
        )
    }

    private func setKeyClickEnabled(_ enabled: Bool) {
        guard enabled else {
            keyClickEnabled = false
            feedbackSettingsDefaults?.synchronize()
            return
        }

        guard canAccessSharedFeedbackSettings else {
            keyClickEnabled = false
            permissionMessage = "按键音需要键盘的「允许完全访问」权限。请在系统设置中开启后再回来打开。"
            return
        }

        keyClickEnabled = true
        feedbackSettingsDefaults?.synchronize()
    }

    private func setHapticEnabled(_ enabled: Bool) {
        guard enabled else {
            hapticEnabled = false
            feedbackSettingsDefaults?.synchronize()
            return
        }

        guard canAccessSharedFeedbackSettings else {
            hapticEnabled = false
            permissionMessage = "按键震动需要键盘的「允许完全访问」权限。请在系统设置中开启后再回来打开。"
            return
        }

        hapticEnabled = true
        feedbackSettingsDefaults?.synchronize()
        previewCoordinator.previewHaptic(intensity: hapticIntensity, force: true)
    }

    /// 主 App 无法可靠读取键盘扩展的 Full Access 实时状态。
    /// 这里仅确认共享设置容器可写，避免用户已开启权限但尚未打开过键盘时被误拦截。
    private var canAccessSharedFeedbackSettings: Bool {
        feedbackSettingsDefaults != nil
    }

    private var intensityLabel: String {
        let percent = Int((KeyboardFeedbackIntensity.clamped(hapticIntensity) * 100).rounded())
        return "\(percent)%"
    }

    private func commitIntensity(_ value: Double) {
        let clamped = KeyboardFeedbackIntensity.clamped(value)
        hapticIntensity = clamped
        hapticLevel = KeyboardFeedbackLevel.migratedLevel(from: clamped).rawValue
        feedbackSettingsDefaults?.synchronize()
        guard hapticEnabled else { return }
        previewCoordinator.previewHaptic(intensity: clamped)
    }

    private func migrateLegacyFeedbackSettingsIfNeeded() {
        KeyboardFeedbackSettingsMigration.migrateLegacyLevelsIfNeeded(in: feedbackSettingsDefaults)
        hapticLevel = KeyboardFeedbackLevel.clamped(hapticLevel).rawValue
        if feedbackSettingsDefaults?.object(forKey: KeyboardFeedbackSettingsKey.hapticIntensityContinuous) == nil {
            hapticIntensity = KeyboardFeedbackLevel.clamped(hapticLevel).hapticIntensity
        } else {
            hapticIntensity = KeyboardFeedbackIntensity.clamped(hapticIntensity)
        }
        feedbackSettingsDefaults?.synchronize()
    }
}

/// 重置为默认强度的自定义确认 Sheet（PB-001-FEEDBACK-UI-001）。
/// 使用项目统一的 `AppActionButton`，而非系统 Alert。
struct FeedbackResetSheet: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppSpacing.group) {
            Text(FeedbackResetConfirmationSheet.title)
                .font(.headline)
            Text(FeedbackResetConfirmationSheet.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            AppActionButton(
                title: FeedbackResetConfirmationSheet.confirmTitle,
                systemImage: "arrow.counterclockwise",
                prominence: .destructive
            ) {
                FeedbackResetConfirmationSheet.handle(
                    dismiss: { dismiss() },
                    confirm: true,
                    action: onConfirm)
            }
            .accessibilityIdentifier("confirmResetHapticIntensity")
            AppActionButton(
                title: FeedbackResetConfirmationSheet.cancelTitle,
                systemImage: "xmark",
                prominence: .secondary
            ) {
                FeedbackResetConfirmationSheet.handle(
                    dismiss: { dismiss() },
                    confirm: false,
                    action: onCancel)
            }
            .accessibilityIdentifier("cancelResetHapticIntensity")
        }
        .padding(AppSpacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        FeedbackSettingsView()
    }
}
