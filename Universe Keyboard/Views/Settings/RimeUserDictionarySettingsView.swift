import SwiftUI

struct RimeUserDictionarySettingsView: View {
    @Bindable var store: RimeSettingsStore

    private let schemes: [UserDictionaryScheme] = [
        .init(id: "luna_pinyin", title: "朙月拼音", requiresInstall: false),
        .init(id: "rime_ice", title: "雾凇拼音", requiresInstall: true),
    ]

    var body: some View {
        Form {
            Section {
                Toggle("自动备份学习记录", isOn: $store.userDictionaryAutoBackupEnabled)
                    .toggleStyle(MonochromeToggleStyle())
                    .onChange(of: store.userDictionaryAutoBackupEnabled) { _, _ in
                        store.saveUserDictionaryAutoBackupSetting()
                        store.runAutomaticUserDictionaryBackupIfNeeded()
                    }
            } header: {
                Text("自动备份")
            } footer: {
                Text("仅在主 App 中保存本机恢复副本，不影响打字；跨设备合并请使用 RIME 云同步。")
            }

            Section {
                ForEach(schemes) { scheme in
                    NavigationLink {
                        RimeUserDictionarySchemeDetailView(store: store, scheme: scheme)
                    } label: {
                        UserDictionarySchemeRow(
                            title: scheme.title,
                            status: store.userDictionaryListStatusText(for: scheme.id),
                            symbol: store.userDictionaryStatusSymbol(for: scheme.id),
                            isEnabled: !scheme.requiresInstall || store.isRimeIceInstalled
                        )
                    }
                    .disabled(scheme.requiresInstall && !store.isRimeIceInstalled)
                }
            } header: {
                Text("方案")
            } footer: {
                Text("学习记录遵循 RIME 官方用户词典；选择一个方案进行开关、备份、恢复或清空。")
            }
        }
        .navigationTitle("RIME 用户词典")
        .tint(.primary)
        .onAppear {
            store.load()
            store.runAutomaticUserDictionaryBackupIfNeeded()
        }
        .onDisappear {
            Task { await store.triggerPendingDeploymentIfNeeded() }
        }
    }
}

private struct RimeUserDictionarySchemeDetailView: View {
    @Bindable var store: RimeSettingsStore
    let scheme: UserDictionaryScheme
    @State private var showResetAlert = false
    @State private var showRestoreAlert = false

    var body: some View {
        Form {
            Section {
                Toggle(scheme.title, isOn: userDictionaryEnabledBinding)
                    .toggleStyle(MonochromeToggleStyle())
                    .onChange(of: userDictionaryEnabledBinding.wrappedValue) { _, _ in
                        store.saveUserDictionarySettings()
                    }
                Text(store.userDictionaryLearningStatusText(for: scheme.id))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("候选学习")
            } footer: {
                Text("开启后，键盘会记住你常选的词，下次更容易排在前面。设置会自动应用。")
            }

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text(store.userDictionaryBackupStatusText(for: scheme.id))
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 10)], spacing: 10) {
                        AppActionButton(
                            title: "备份",
                            systemImage: "tray.and.arrow.down",
                            prominence: .secondary
                        ) {
                            store.backupUserDictionary(for: scheme.id)
                        }
                        .disabled(!store.userDictionaryCanBackup(for: scheme.id))
                        .opacity(store.userDictionaryCanBackup(for: scheme.id) ? 1 : 0.45)

                        AppActionButton(
                            title: "恢复",
                            systemImage: "clock.arrow.circlepath",
                            prominence: .secondary
                        ) {
                            showRestoreAlert = true
                        }
                        .disabled(!store.userDictionaryHasBackup(for: scheme.id))
                        .opacity(store.userDictionaryHasBackup(for: scheme.id) ? 1 : 0.45)
                    }
                }
            } header: {
                Text("本机保护")
            } footer: {
                Text("恢复或清空前会先创建并校验当前学习记录的恢复副本；失败时不会继续替换或删除。")
            }

            Section {
                AppActionButton(
                    title: "清空\(scheme.title)学习记录",
                    systemImage: "arrow.counterclockwise",
                    prominence: .destructive,
                    role: .destructive
                ) {
                    showResetAlert = true
                }
            } header: {
                Text("重置学习记录")
            } footer: {
                Text("清空后，候选会回到默认顺序，再从你的新选择开始学习。词库和键盘设置不会被删除。")
            }
        }
        .navigationTitle(scheme.title)
        .tint(.primary)
        .alert("恢复学习记录？", isPresented: $showRestoreAlert) {
            Button("取消", role: .cancel) {}
            Button("恢复") {
                store.restoreLatestUserDictionaryBackup(for: scheme.id)
            }
        } message: {
            Text("恢复前会先创建并校验当前学习记录的本机恢复副本，再使用最近一次备份替换它。")
        }
        .alert("清空学习记录？", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                store.resetUserDictionary(for: scheme.id)
            }
        } message: {
            Text("清空前会先创建并校验本机恢复副本。候选会回到默认顺序，再从你的新选择开始学习。")
        }
    }

    private var userDictionaryEnabledBinding: Binding<Bool> {
        switch scheme.id {
        case "rime_ice":
            return $store.rimeIceUserDictionaryEnabled
        default:
            return $store.lunaPinyinUserDictionaryEnabled
        }
    }
}

private struct UserDictionarySchemeRow: View {
    let title: String
    let status: String
    let symbol: RimeUserDictionaryStatusSymbol
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(isEnabled ? .primary : .secondary)
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            UserDictionaryStatusIcon(symbol: symbol)
        }
        .padding(.vertical, 2)
    }
}

private struct UserDictionaryStatusIcon: View {
    let symbol: RimeUserDictionaryStatusSymbol

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(imageColor)
        }
        .frame(width: 24, height: 24)
    }

    private var systemImage: String {
        switch symbol {
        case .upToDate:
            return "checkmark"
        case .changed, .ready, .warning:
            return "exclamationmark"
        case .off:
            return "power"
        case .unavailable, .empty:
            return "minus"
        }
    }

    private var backgroundColor: Color {
        switch symbol {
        case .upToDate:
            return .green
        case .changed, .ready, .warning:
            return .orange.opacity(0.18)
        case .off, .unavailable, .empty:
            return Color(.tertiarySystemFill)
        }
    }

    private var imageColor: Color {
        switch symbol {
        case .upToDate:
            return .white
        case .changed, .ready, .warning:
            return .orange
        case .off, .unavailable, .empty:
            return .secondary
        }
    }
}

private struct UserDictionaryScheme: Identifiable, Hashable {
    let id: String
    let title: String
    let requiresInstall: Bool
}

#Preview {
    NavigationStack {
        RimeUserDictionarySettingsView(store: RimeSettingsStore())
    }
}
