import KeyboardCore
import SwiftUI

/// 模糊音独立页（保留给 Search 深链 `.fuzzyPinyin`）。
struct RimeFuzzyPinyinSettingsView: View {
    @Bindable var store: RimeSettingsStore

    var body: some View {
        Form {
            RimeFuzzyPinyinSettingsContent(store: store)
        }
        .navigationTitle("模糊音设置")
        .tint(.primary)
        .onAppear { store.load() }
        .onDisappear {
            Task { await store.triggerPendingDeploymentIfNeeded() }
        }
    }
}

/// PB-015 PR-4（M5）：模糊音的可复用 Form 区块。
///
/// 同一份控件同时用于独立页与 `RimeSettingsView` 方案页嵌入；
/// 双拼激活态说明与「无法开启」弹窗随内容走，两种宿主行为一致。
struct RimeFuzzyPinyinSettingsContent: View {
    @Bindable var store: RimeSettingsStore
    @State private var showUnsupportedAlert = false

    /// PB-017 PR-3：双拼激活态（含九宫格切回前的 binding26 残留，由 capability 层归一）。
    private var isShuangpinActive: Bool {
        RimeShuangpinVariant.isDoublePinyinSchemaID(store.settingsCapabilitySchemaID)
    }

    var body: some View {
        Group {
            masterSection
            retroflexSection
            nasalLateralSection
        }
    }

    private var masterSection: some View {
        Section {
            // When unsupported, use a constant binding so SwiftUI never writes
            // "display off" into stored preferences (TD-010 preference preserve).
            if store.supportsManagedFuzzyPinyin {
                Toggle("启用模糊音", isOn: liveMasterBinding)
                    .toggleStyle(.appSwitch)
            } else {
                Toggle("启用模糊音", isOn: .constant(false))
                    .toggleStyle(.appSwitch)
                    .disabled(true)
                    .contentShape(Rectangle())
                    .onTapGesture { showUnsupportedAlert = true }
                    .alert("无法开启", isPresented: $showUnsupportedAlert) {
                        Button("好", role: .cancel) {}
                    } message: {
                        if isShuangpinActive {
                            Text(
                                "双拼方案（\(store.settingsCapabilitySchemeDisplayName)）两键一音，声母和韵母由固定键位映射决定，模糊音不再适用。已保存的选择会在切回全拼方案后自动恢复。"
                            )
                        } else {
                            Text(
                                "当前方案（\(store.settingsCapabilitySchemeDisplayName)）暂不支持该功能。已保存的选择会在支持的方案下恢复。请切换到支持的方案（如雾凇拼音）后再试。"
                            )
                        }
                    }
            }

            Text(shuangpinAwareCapabilityStatusText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("当前方案")
        } footer: {
            if store.supportsManagedFuzzyPinyin {
                Text("这些是你的偏好设置。只有当前布局使用的方案支持时，开关才可以调整并在重新部署后生效。切换方案不会清空你已保存的选择。")
            } else if isShuangpinActive {
                Text("双拼方案两键一音，声母和韵母由固定键位映射决定，模糊音不再适用。已保存的偏好会保留，切回全拼方案后自动恢复，无需重新选择。")
            } else {
                Text("当前布局绑定的方案不支持 Universe 管理的模糊音。已保存的偏好会保留，切回雾凇等支持方案后自动恢复，无需重新选择。")
            }
        }
    }

    private var retroflexSection: some View {
        Section {
            if store.supportsManagedFuzzyPinyin {
                Toggle("zh / z", isOn: liveGroupBinding(\.fuzzyZhZEnabled))
                    .toggleStyle(.appSwitch)
                Toggle("ch / c", isOn: liveGroupBinding(\.fuzzyChCEnabled))
                    .toggleStyle(.appSwitch)
                Toggle("sh / s", isOn: liveGroupBinding(\.fuzzyShSEnabled))
                    .toggleStyle(.appSwitch)
            } else {
                Toggle("zh / z", isOn: .constant(false)).toggleStyle(.appSwitch).disabled(true)
                Toggle("ch / c", isOn: .constant(false)).toggleStyle(.appSwitch).disabled(true)
                Toggle("sh / s", isOn: .constant(false)).toggleStyle(.appSwitch).disabled(true)
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
    }

    private var nasalLateralSection: some View {
        Section {
            if store.supportsManagedFuzzyPinyin {
                Toggle("n / l", isOn: liveGroupBinding(\.fuzzyNLEnabled))
                    .toggleStyle(.appSwitch)
            } else {
                Toggle("n / l", isOn: .constant(false)).toggleStyle(.appSwitch).disabled(true)
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

    /// PB-017 PR-3：双拼激活态给双拼专用原因说明，其余方案沿用通用文案。
    private var shuangpinAwareCapabilityStatusText: String {
        guard !store.supportsManagedFuzzyPinyin, isShuangpinActive else {
            return store.fuzzyPinyinCapabilityStatusText
        }
        return
            "当前方案（\(store.settingsCapabilitySchemeDisplayName)）为双拼方案：两键一音，模糊音不再适用。你的选择会保留，切换到全拼方案后可再开启。"
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
