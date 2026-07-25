import SwiftUI

struct RimeFuzzyPinyinSettingsView: View {
    @Bindable var store: RimeSettingsStore

    var body: some View {
        Form {
            Section {
                Toggle("启用模糊音", isOn: $store.fuzzyEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: store.fuzzyEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
            } footer: {
                Text("修改模糊音设置会触发 RIME 重新部署。部署完成后设置才会在键盘中生效。")
            }

            Section {
                Toggle("zh / z", isOn: $store.fuzzyZhZEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: store.fuzzyZhZEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
                Toggle("ch / c", isOn: $store.fuzzyChCEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: store.fuzzyChCEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
                Toggle("sh / s", isOn: $store.fuzzyShSEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: store.fuzzyShSEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
            } header: {
                Text("平翘舌")
            } footer: {
                Text("开启后，z/zh、c/ch、s/sh 可互相匹配。候选会变宽，也可能增加近音候选。")
            }
            .disabled(!store.fuzzyEnabled)
            .foregroundStyle(store.fuzzyEnabled ? .primary : .secondary)

            Section {
                Toggle("n / l", isOn: $store.fuzzyNLEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: store.fuzzyNLEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
            } header: {
                Text("鼻边音")
            } footer: {
                Text("开启后，n/l 可互相匹配。若候选噪声过多，可关闭此项后重新部署。")
            }
            .disabled(!store.fuzzyEnabled)
            .foregroundStyle(store.fuzzyEnabled ? .primary : .secondary)
        }
        .navigationTitle("模糊音设置")
        .tint(.primary)
        .onAppear { store.load() }
        .onDisappear {
            Task { await store.triggerPendingDeploymentIfNeeded() }
        }
    }
}

#Preview {
    NavigationStack {
        RimeFuzzyPinyinSettingsView(store: RimeSettingsStore())
    }
}
