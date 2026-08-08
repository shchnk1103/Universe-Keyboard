import SwiftUI

struct RimeFuzzyPinyinSettingsView: View {
    @Bindable var store: RimeSettingsStore
    @State private var showUnsupportedAlert = false

    var body: some View {
        Form {
            Section {
                // When unsupported, use a constant binding so SwiftUI never writes
                // "display off" into stored preferences (TD-010 preference preserve).
                if store.supportsManagedFuzzyPinyin {
                    Toggle("启用模糊音", isOn: liveMasterBinding)
                        .toggleStyle(.switch)
                } else {
                    Toggle("启用模糊音", isOn: .constant(false))
                        .toggleStyle(.switch)
                        .disabled(true)
                        .contentShape(Rectangle())
                        .onTapGesture { showUnsupportedAlert = true }
                }

                Text(store.fuzzyPinyinCapabilityStatusText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("当前方案")
            } footer: {
                if store.supportsManagedFuzzyPinyin {
                    Text("这些是你的偏好设置。只有当前布局使用的方案支持时，开关才可以调整并在重新部署后生效。切换方案不会清空你已保存的选择。")
                } else {
                    Text("当前布局绑定的方案不支持 Universe 管理的模糊音。已保存的偏好会保留，切回雾凇等支持方案后自动恢复，无需重新选择。")
                }
            }

            Section {
                if store.supportsManagedFuzzyPinyin {
                    Toggle("zh / z", isOn: liveGroupBinding(\.fuzzyZhZEnabled))
                        .toggleStyle(.switch)
                    Toggle("ch / c", isOn: liveGroupBinding(\.fuzzyChCEnabled))
                        .toggleStyle(.switch)
                    Toggle("sh / s", isOn: liveGroupBinding(\.fuzzyShSEnabled))
                        .toggleStyle(.switch)
                } else {
                    Toggle("zh / z", isOn: .constant(false)).toggleStyle(.switch).disabled(true)
                    Toggle("ch / c", isOn: .constant(false)).toggleStyle(.switch).disabled(true)
                    Toggle("sh / s", isOn: .constant(false)).toggleStyle(.switch).disabled(true)
                }
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
                if store.supportsManagedFuzzyPinyin {
                    Toggle("n / l", isOn: liveGroupBinding(\.fuzzyNLEnabled))
                        .toggleStyle(.switch)
                } else {
                    Toggle("n / l", isOn: .constant(false)).toggleStyle(.switch).disabled(true)
                }
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
                "当前方案（\(store.settingsCapabilitySchemeDisplayName)）暂不支持该功能。已保存的选择会在支持的方案下恢复。请切换到支持的方案（如雾凇拼音）后再试。"
            )
        }
    }

    /// Live binding only while the current scheme productizes managed fuzzy.
    private var liveMasterBinding: Binding<Bool> {
        Binding(
            get: { store.fuzzyEnabled },
            set: { newValue in
                guard store.supportsManagedFuzzyPinyin else { return }
                store.fuzzyEnabled = newValue
                store.saveFuzzyPinyinSettings()
            }
        )
    }

    private func liveGroupBinding(
        _ keyPath: ReferenceWritableKeyPath<RimeSettingsStore, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: { store[keyPath: keyPath] },
            set: { newValue in
                guard store.supportsManagedFuzzyPinyin else { return }
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
