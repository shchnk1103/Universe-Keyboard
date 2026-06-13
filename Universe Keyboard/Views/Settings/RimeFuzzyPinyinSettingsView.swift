import SwiftUI

struct RimeFuzzyPinyinSettingsView: View {
    @Bindable var store: RimeSettingsStore

    var body: some View {
        Form {
            Section {
                Toggle("zh / z", isOn: $store.fuzzyZhZEnabled)
                    .toggleStyle(MonochromeToggleStyle())
                    .onChange(of: store.fuzzyZhZEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
                Toggle("ch / c", isOn: $store.fuzzyChCEnabled)
                    .toggleStyle(MonochromeToggleStyle())
                    .onChange(of: store.fuzzyChCEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
                Toggle("sh / s", isOn: $store.fuzzyShSEnabled)
                    .toggleStyle(MonochromeToggleStyle())
                    .onChange(of: store.fuzzyShSEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
            } header: {
                Text("平翘舌")
            } footer: {
                Text("开启后，z/zh、c/ch、s/sh 可互相匹配。候选会变宽，也可能增加近音候选。")
            }

            Section {
                Toggle("n / l", isOn: $store.fuzzyNLEnabled)
                    .toggleStyle(MonochromeToggleStyle())
                    .onChange(of: store.fuzzyNLEnabled) { _, _ in store.saveFuzzyPinyinSettings() }
            } header: {
                Text("鼻边音")
            } footer: {
                Text("开启后，n/l 可互相匹配。若候选噪声过多，可关闭此项后重新部署。")
            }

            Section {
                Button {
                    Task { await store.triggerDeployment() }
                } label: {
                    Label("应用并重新部署", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(store.deploymentState == .triggered || store.deploymentState == .deploying)
            } footer: {
                Text("修改仅保存到主 App 设置。必须重新部署当前 RIME 方案后，键盘候选才会变化。")
            }
        }
        .navigationTitle("模糊音设置")
        .tint(.primary)
        .onAppear { store.load() }
    }
}

#Preview {
    NavigationStack {
        RimeFuzzyPinyinSettingsView(store: RimeSettingsStore())
    }
}
