import KeyboardCore
import SwiftUI

/// Settings surface for 26-key / Chinese nine-key layout selection.
struct KeyboardLayoutSettingsView: View {
    @Bindable var rimeStore: RimeSettingsStore

    @State private var selectedLayout: KeyboardLayoutStyle = .twentySixKey
    @State private var t9Ready = false
    @State private var isBusy = false
    @State private var statusMessage: String?
    @State private var showLicenseSheet = false
    @State private var pendingNineKeyAfterInstall = false

    var body: some View {
        Form {
            Section {
                layoutCard(
                    style: .twentySixKey,
                    title: "26键",
                    subtitle: "标准全键盘布局",
                    thumbnail: { TwentySixKeyThumbnail() }
                )
                layoutCard(
                    style: .nineKey,
                    title: "9键",
                    subtitle: "中文使用九键，英文仍使用26键",
                    thumbnail: { NineKeyThumbnail() }
                )
            } footer: {
                Text("九键依赖雾凇拼音的 T9 方案。启用前会检查安装与部署状态；失败时保持当前布局。部分高级能力在九键模式下可能不可用，切回 26 键后恢复。")
            }

            if let statusMessage {
                Section("状态") {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if isBusy {
                Section {
                    HStack {
                        ProgressView()
                        Text("正在处理…")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("键盘布局")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: reload)
        .disabled(isBusy)
        .sheet(isPresented: $showLicenseSheet) {
            NavigationStack {
                Form {
                    Section("许可") {
                        Text("雾凇拼音使用 GPL-3.0 许可。启用九键前需要接受许可并安装雾凇拼音。")
                    }
                    Section {
                        Button("接受并继续安装") {
                            showLicenseSheet = false
                            pendingNineKeyAfterInstall = true
                            rimeStore.acceptLicense(for: "rime_ice")
                            rimeStore.startDownload(schemaID: "rime_ice")
                        }
                        Button("取消", role: .cancel) {
                            showLicenseSheet = false
                            pendingNineKeyAfterInstall = false
                            statusMessage = "已取消，保持原布局"
                        }
                    }
                }
                .navigationTitle("安装雾凇拼音")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
        .onChange(of: rimeStore.downloadState) { _, newValue in
            guard pendingNineKeyAfterInstall else { return }
            switch newValue {
            case .completed:
                pendingNineKeyAfterInstall = false
                Task { await enableNineKey() }
            case .failed(let message):
                pendingNineKeyAfterInstall = false
                statusMessage = "安装失败：\(message)。已保持原布局。"
            default:
                break
            }
        }
    }

    private func reload() {
        selectedLayout = rimeStore.layoutStyle
        t9Ready = rimeStore.t9ReadinessMatched
    }

    @ViewBuilder
    private func layoutCard<Thumb: View>(
        style: KeyboardLayoutStyle,
        title: String,
        subtitle: String,
        @ViewBuilder thumbnail: () -> Thumb
    ) -> some View {
        Button {
            Task { await select(style) }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selectedLayout == style {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    thumbnail()
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(selectedLayout == style ? "已选择" : "未选择")
        .accessibilityHint(subtitle)
        .accessibilityAddTraits(selectedLayout == style ? [.isSelected, .isButton] : .isButton)
    }

    @MainActor
    private func select(_ style: KeyboardLayoutStyle) async {
        statusMessage = nil
        switch style {
        case .twentySixKey:
            rimeStore.selectTwentySixKeyLayout()
            reload()
            statusMessage = "已切换为 26 键"
        case .nineKey:
            await enableNineKey()
        }
    }

    @MainActor
    private func enableNineKey() async {
        if rimeStore.t9ReadinessMatched, rimeStore.rimeIceInstalledFilesExist {
            // Already verified: persist nineKey only (readiness already written).
            rimeStore.persistNineKeyLayoutWhenReady()
            reload()
            statusMessage = "已启用九键"
            return
        }

        if !rimeStore.rimeIceInstalledFilesExist {
            if !rimeStore.licenseAccepted {
                showLicenseSheet = true
                return
            }
            pendingNineKeyAfterInstall = true
            isBusy = true
            statusMessage = "正在下载并安装雾凇拼音…"
            rimeStore.startDownload(schemaID: "rime_ice")
            isBusy = false
            return
        }

        isBusy = true
        statusMessage = "正在部署并验证九键…"
        let failure = await rimeStore.enableNineKeyLayout()
        isBusy = false
        reload()
        if let failure {
            statusMessage = failure
        } else {
            statusMessage = "九键已启用"
        }
    }
}

// MARK: - Thumbnails (decorative, no characters)

private struct TwentySixKeyThumbnail: View {
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.45), lineWidth: 1)
                .frame(height: 10)
            keyRow(count: 10)
            keyRow(count: 9)
            keyRow(count: 7)
            keyRow(count: 5)
        }
        .padding(8)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func keyRow(count: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.secondary.opacity(0.28))
                    .frame(height: 12)
            }
        }
    }
}

private struct NineKeyThumbnail: View {
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.45), lineWidth: 1)
                .frame(height: 10)
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.secondary.opacity(0.28))
                            .frame(height: 22)
                    }
                }
            }
            keyRow(count: 5)
        }
        .padding(8)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func keyRow(count: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.secondary.opacity(0.28))
                    .frame(height: 12)
            }
        }
    }
}
