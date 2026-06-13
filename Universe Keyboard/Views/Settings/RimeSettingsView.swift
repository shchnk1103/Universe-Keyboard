import SwiftUI

struct RimeSettingsView: View {
    @State private var store = RimeSettingsStore()
    @State private var logExpanded = false
    @State private var showLicense = false
    @State private var showUninstallAlert = false

    var body: some View {
        Form {
            SchemaSelectionSection(
                store: store,
                onShowLicense: { showLicense = true }
            )
            SchemaDownloadSection(
                store: store,
                onShowLicense: { showLicense = true },
                onUninstall: { showUninstallAlert = true }
            )
            RimePreferencesSections(store: store)
            Section {
                NavigationLink {
                    RimeFuzzyPinyinSettingsView(store: store)
                } label: {
                    Label("模糊音设置", systemImage: "waveform.path")
                }
            } footer: {
                Text("传统拼音模糊音只作用于当前 RIME 方案，修改后需重新部署。")
            }
            RimeDeploymentStatusSection(store: store, logExpanded: $logExpanded)
        }
        .navigationTitle("RIME 方案设置")
        .tint(.primary)
        .onAppear { store.load() }
        .onChange(of: store.downloadState) { _, _ in store.refreshDeploymentState() }
        .onDisappear { store.stop() }
        .sheet(isPresented: $showLicense) {
            LicenseView { store.acceptLicense() }
        }
        .alert("确认卸载", isPresented: $showUninstallAlert) {
            Button("取消", role: .cancel) {}
            Button("卸载", role: .destructive) { store.uninstallRimeIce() }
        } message: {
            Text("卸载雾凇拼音后，将自动切换回朙月拼音。已下载的词库文件将被删除。")
        }
    }
}

#Preview {
    NavigationStack {
        RimeSettingsView()
    }
}
