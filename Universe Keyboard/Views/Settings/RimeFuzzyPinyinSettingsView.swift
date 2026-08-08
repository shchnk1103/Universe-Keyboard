import SwiftUI

struct RimeFuzzyPinyinSettingsView: View {
    @Bindable var store: RimeSettingsStore
    @State private var showUnsupportedAlert = false

    var body: some View {
        Form {
            Section {
                Toggle("启用模糊音", isOn: masterBinding)
                    .toggleStyle(.switch)
                    .disabled(!store.supportsManagedFuzzyPinyin)

                Text(store.fuzzyPinyinCapabilityStatusText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("当前方案")
            } footer: {
                if store.supportsManagedFuzzyPinyin {
                    Text("这些是你的偏好设置。只有当前布局使用的方案支持时，开关才可以调整并在重新部署后生效。")
                } else {
                    Text("当前布局绑定的方案不支持 Universe 管理的模糊音。偏好已保留，不会在此页写入或部署。")
                }
            }

            Section {
                Toggle("zh / z", isOn: groupBinding(\.fuzzyZhZEnabled))
                    .toggleStyle(.switch)
                Toggle("ch / c", isOn: groupBinding(\.fuzzyChCEnabled))
                    .toggleStyle(.switch)
                Toggle("sh / s", isOn: groupBinding(\.fuzzyShSEnabled))
                    .toggleStyle(.switch)
            } header: {
                Text("平翘舌")
            } footer: {
                Text("开启后，z/zh、c/ch、s/sh 可互相匹配。候选会变宽，也可能增加近音候选。")
            }
            .disabled(!store.supportsManagedFuzzyPinyin || !store.fuzzyEnabled)
            .foregroundStyle(
                store.supportsManagedFuzzyPinyin && store.fuzzyEnabled ? .primary : .secondary
            )

            Section {
                Toggle("n / l", isOn: groupBinding(\.fuzzyNLEnabled))
                    .toggleStyle(.switch)
            } header: {
                Text("鼻边音")
            } footer: {
                Text("开启后，n/l 可互相匹配。若候选噪声过多，可关闭此项后重新部署。")
            }
            .disabled(!store.supportsManagedFuzzyPinyin || !store.fuzzyEnabled)
            .foregroundStyle(
                store.supportsManagedFuzzyPinyin && store.fuzzyEnabled ? .primary : .secondary
            )
        }
        .navigationTitle("模糊音设置")
        .tint(.primary)
        .onAppear { store.load() }
        .onDisappear {
            Task { await store.triggerPendingDeploymentIfNeeded() }
        }
        .alert("无法开启", isPresented: $showUnsupportedAlert) {
            Button("好", role: .cancel) {}
        } message: {
            Text(
                "当前方案（\(store.settingsCapabilitySchemeDisplayName)）暂不支持该功能。请切换到支持的方案（如雾凇拼音）后再试。"
            )
        }
    }

    /// When unsupported, UI shows off while stored preference is preserved.
    private var masterBinding: Binding<Bool> {
        Binding(
            get: {
                store.supportsManagedFuzzyPinyin ? store.fuzzyEnabled : false
            },
            set: { newValue in
                guard store.supportsManagedFuzzyPinyin else {
                    if newValue { showUnsupportedAlert = true }
                    return
                }
                store.fuzzyEnabled = newValue
                store.saveFuzzyPinyinSettings()
            }
        )
    }

    private func groupBinding(_ keyPath: ReferenceWritableKeyPath<RimeSettingsStore, Bool>) -> Binding<Bool> {
        Binding(
            get: {
                store.supportsManagedFuzzyPinyin ? store[keyPath: keyPath] : false
            },
            set: { newValue in
                guard store.supportsManagedFuzzyPinyin else {
                    if newValue { showUnsupportedAlert = true }
                    return
                }
                store[keyPath: keyPath] = newValue
                store.saveFuzzyPinyinSettings()
            }
        )
    }
}

#Preview {
    NavigationStack {
        RimeFuzzyPinyinSettingsView(store: RimeSettingsStore())
    }
}
