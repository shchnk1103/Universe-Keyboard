import SwiftUI

struct RimeUserDictionarySettingsView: View {
    @Bindable var store: RimeSettingsStore
    @State private var resetSchemaID: String?

    var body: some View {
        Form {
            Section {
                Toggle("朙月拼音", isOn: $store.lunaPinyinUserDictionaryEnabled)
                    .toggleStyle(MonochromeToggleStyle())
                    .onChange(of: store.lunaPinyinUserDictionaryEnabled) { _, _ in
                        store.saveUserDictionarySettings()
                    }

                Toggle("雾凇拼音", isOn: $store.rimeIceUserDictionaryEnabled)
                    .toggleStyle(MonochromeToggleStyle())
                    .disabled(!store.isRimeIceInstalled)
                    .foregroundStyle(store.isRimeIceInstalled ? .primary : .secondary)
                    .onChange(of: store.rimeIceUserDictionaryEnabled) { _, _ in
                        store.saveUserDictionarySettings()
                    }
            } header: {
                Text("候选学习")
            } footer: {
                Text("开启后，键盘会记住你选过的候选词，并在之后优先展示。设置会自动应用，无需手动部署。")
            }

            Section {
                AppActionButton(
                    title: "清空朙月拼音学习记录",
                    systemImage: "arrow.counterclockwise",
                    prominence: .destructive,
                    role: .destructive
                ) {
                    resetSchemaID = "luna_pinyin"
                }

                AppActionButton(
                    title: "清空雾凇拼音学习记录",
                    systemImage: "arrow.counterclockwise",
                    prominence: .destructive,
                    role: .destructive
                ) {
                    resetSchemaID = "rime_ice"
                }
                .disabled(!store.isRimeIceInstalled)
                .opacity(store.isRimeIceInstalled ? 1 : 0.45)
            } header: {
                Text("重置学习记录")
            } footer: {
                Text("只会清空对应方案由你选择候选产生的排序记录，不会删除词库文件或其他方案设置。")
            }
        }
        .navigationTitle("候选学习")
        .tint(.primary)
        .onAppear { store.load() }
        .onDisappear {
            Task { await store.triggerPendingDeploymentIfNeeded() }
        }
        .alert("清空学习记录？", isPresented: resetAlertBinding) {
            Button("取消", role: .cancel) { resetSchemaID = nil }
            Button("清空", role: .destructive) {
                if let resetSchemaID {
                    store.resetUserDictionary(for: resetSchemaID)
                }
                resetSchemaID = nil
            }
        } message: {
            Text("清空后，该方案会重新按词库默认顺序学习你的候选偏好。")
        }
    }

    private var resetAlertBinding: Binding<Bool> {
        Binding(
            get: { resetSchemaID != nil },
            set: { if !$0 { resetSchemaID = nil } }
        )
    }
}

#Preview {
    NavigationStack {
        RimeUserDictionarySettingsView(store: RimeSettingsStore())
    }
}
