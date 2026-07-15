import SwiftUI
import UIKit

struct NotificationSettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var model: AppNotificationSettingsModel

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

            if model.notificationsEnabled {
                notificationCategoryRow(.rimeSync)
            }

            if let notice = model.notice {
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
            Text("\(model.permissionSummary) 关闭总开关会暂停所有系统通知，但会保留你选择的通知类别；重新开启后继续使用原来的选择。")
        }
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
        } header: {
            Text("App 内提示")
        } footer: {
            Text("此开关不需要系统通知权限。关闭后，当前提示会立即消失，之后也不会弹出新的全局提示；各功能页面仍会显示详细状态和错误。重新开启不会重复显示过去的提示。")
        }
    }

    private func notificationCategoryRow(_ category: AppNotificationCategory) -> some View {
        Toggle(
            isOn: Binding(
                get: { model.isCategorySelected(category) },
                set: { selected in
                    Task { await model.setCategorySelected(selected, category: category) }
                }
            )
        ) {
            VStack(alignment: .leading, spacing: 3) {
                Text(category.title)
                Text(category.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
