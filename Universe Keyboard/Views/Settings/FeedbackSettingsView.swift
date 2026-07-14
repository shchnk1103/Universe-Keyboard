import KeyboardCore
import SwiftUI

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
private let feedbackSettingsDefaults = UserDefaults(suiteName: appGroupID)

/// 键盘反馈设置子页面。
struct FeedbackSettingsView: View {
    @AppStorage(KeyboardFeedbackSettingsKey.keyClickEnabled, store: feedbackSettingsDefaults)
    private var keyClickEnabled = true
    @AppStorage(KeyboardFeedbackSettingsKey.hapticEnabled, store: feedbackSettingsDefaults)
    private var hapticEnabled = false
    @AppStorage(KeyboardFeedbackSettingsKey.hapticLevel, store: feedbackSettingsDefaults)
    private var hapticLevel = KeyboardFeedbackLevel.defaultLevel.rawValue

    @StateObject private var previewCoordinator = FeedbackPreviewCoordinator()
    @State private var permissionMessage: String?

    var body: some View {
        Form {
            Section {
                Toggle("按键音", isOn: keyClickBinding)
                    .toggleStyle(MonochromeToggleStyle())
            } header: {
                Text("按键音")
            } footer: {
                Text(keyClickFooter)
            }

            Section {
                Toggle("按键震动", isOn: hapticBinding)
                    .toggleStyle(MonochromeToggleStyle())
            } header: {
                Text("触感反馈")
            } footer: {
                Text(hapticFooter)
            }

            if hapticEnabled {
                Section {
                    FeedbackLevelSelectionView(selection: $hapticLevel) { level in
                        feedbackSettingsDefaults?.synchronize()
                        previewCoordinator.previewHaptic(level: level)
                    }
                } header: {
                    Text("震动强度")
                } footer: {
                    Text("选择档位后会自动感受一次。同一档位不会重复触发，快速连续选择时会自动节流。")
                }
            }
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

    private var hapticFooter: String {
        hapticEnabled
            ? "震动设置会通过 App Group 同步到键盘，需要在系统键盘设置中开启「允许完全访问」。"
            : "开启后按下按键时提供震动反馈。"
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
        previewCoordinator.previewHaptic(
            level: KeyboardFeedbackLevel.clamped(hapticLevel),
            force: true
        )
    }

    /// 主 App 无法可靠读取键盘扩展的 Full Access 实时状态。
    /// 这里仅确认共享设置容器可写，避免用户已开启权限但尚未打开过键盘时被误拦截。
    private var canAccessSharedFeedbackSettings: Bool {
        feedbackSettingsDefaults != nil
    }

    private func migrateLegacyFeedbackSettingsIfNeeded() {
        KeyboardFeedbackSettingsMigration.migrateLegacyLevelsIfNeeded(in: feedbackSettingsDefaults)
        hapticLevel = KeyboardFeedbackLevel.clamped(hapticLevel).rawValue
        feedbackSettingsDefaults?.synchronize()
    }
}

#Preview {
    NavigationStack {
        FeedbackSettingsView()
    }
}
