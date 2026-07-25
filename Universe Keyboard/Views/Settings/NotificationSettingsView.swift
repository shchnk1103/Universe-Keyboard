import SwiftUI
import UIKit

struct NotificationSettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var model: AppNotificationSettingsModel
    /// Matches RIME 云同步 page: notification scopes only apply after a sync method is chosen.
    var isRimeSyncMethodConfigured: Bool = false

    private var rimeSyncNotificationsAvailable: Bool {
        model.notificationsEnabled && isRimeSyncMethodConfigured
    }

    var body: some View {
        Form {
            systemNotificationsSection
            operationToastSection
        }
        .navigationTitle("通知与提醒")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .task { await model.refreshAuthorizationStatus() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await model.refreshAuthorizationStatus() }
        }
    }

    private var systemNotificationsSection: some View {
        Section {
            Toggle(
                "允许 App 通知",
                isOn: Binding(
                    get: { model.notificationsEnabled },
                    set: { enabled in
                        Task { await model.setNotificationsEnabled(enabled) }
                    }
                )
            )
            .toggleStyle(.switch)

            // Always mounted + disabled when master off or sync method unset (no Form remount).
            RimeSyncNotificationControls(
                model: model,
                title: "RIME 云同步",
                detail: isRimeSyncMethodConfigured
                    ? "选择手动或自动同步时需要提醒你的内容。"
                    : "请先在「RIME 云同步」中选择同步方式后，再开启此类通知。",
                isSyncMethodConfigured: isRimeSyncMethodConfigured
            )
            .disabled(!rimeSyncNotificationsAvailable)
            .opacity(rimeSyncNotificationsAvailable ? 1 : 0.48)

            // Notice / system-settings deep link are rare, slow-changing states — safe to
            // mount only when needed (avoids empty Form rows from opacity-0 placeholders).
            if let notice = model.notice, !notice.isEmpty {
                Text(notice)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if model.authorizationStatus == .denied {
                Button("前往系统设置", systemImage: "gearshape") {
                    guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else {
                        return
                    }
                    openURL(url)
                }
            }
        } header: {
            Text("系统通知")
        } footer: {
            Text(systemNotificationsFooter)
        }
    }

    private var systemNotificationsFooter: String {
        var parts = [model.permissionSummary]
        parts.append("关闭总开关会暂停所有系统通知，但会保留你选择的通知类别；重新开启后继续使用原来的选择。")
        if !isRimeSyncMethodConfigured {
            parts.append("RIME 云同步相关通知需先在设置中配置同步方式后才可开启。")
        }
        return parts.joined(separator: " ")
    }

    private var operationToastSection: some View {
        Section {
            Toggle(
                isOn: Binding(
                    get: { model.operationToastsEnabled },
                    set: { model.setOperationToastsEnabled($0) }
                )
            ) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("操作状态提示")
                    Text("在 App 底部显示同步、下载、部署和词典操作的进度与结果。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
        } header: {
            Text("App 内提示")
        } footer: {
            Text("此开关不需要系统通知权限。关闭后，当前提示会立即消失，之后也不会弹出新的全局提示；各功能页面仍会显示详细状态和错误。重新开启不会重复显示过去的提示。")
        }
    }

}

/// 两个设置入口复用同一组控件，避免标题、子项和父子开关规则逐渐分叉。
struct RimeSyncNotificationControls: View {
    @Bindable var model: AppNotificationSettingsModel
    let title: String
    let detail: String
    /// When false, category/scopes present as off and cannot be turned on (product gate).
    var isSyncMethodConfigured: Bool = true

    /// Effective on state for UI: requires sync method + category selection + deliverability.
    private var categoryOn: Bool {
        isSyncMethodConfigured && model.isCategoryEnabled(.rimeSync)
    }

    var body: some View {
        Toggle(
            isOn: Binding(
                get: { categoryOn },
                set: { selected in
                    guard isSyncMethodConfigured else { return }
                    Task { await model.setCategorySelected(selected, category: .rimeSync) }
                }
            )
        ) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)

        // Always-mounted scopes; disabled when category off or sync method unset.
        Group {
            ForEach(RimeSyncNotificationScope.allCases, id: \.self) { scope in
                let scopeOn = isSyncMethodConfigured
                    && model.isCategoryEnabled(.rimeSync)
                    && model.isRimeSyncScopeSelected(scope)
                Toggle(
                    isOn: Binding(
                        get: { scopeOn },
                        set: { selected in
                            guard isSyncMethodConfigured else { return }
                            Task {
                                await model.setRimeSyncScopeSelected(selected, scope: scope)
                            }
                        }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(scope.title)
                        Text(scope.notificationDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 16)
                }
                .toggleStyle(.switch)
            }
        }
        .disabled(!categoryOn)
        .opacity(categoryOn ? 1 : 0.48)
    }
}
