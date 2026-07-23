import KeyboardCore
import SwiftUI

/// Settings surface for 26-key / Chinese nine-key layout selection.
///
/// Visual direction follows a WeChat-style “主键盘” chooser (side-by-side previews
/// + radio labels), with colors and surfaces from the main-app UI style guide
/// (system grouped backgrounds, tint selection, continuous corners).
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
                mainKeyboardChooser
            } header: {
                Text("主键盘")
            } footer: {
                Text("九键依赖雾凇拼音的 T9 方案。启用前会检查安装与部署状态；失败时保持当前布局。部分高级能力在九键模式下可能不可用，切回全键盘后恢复。英文与自动英文场景在九键偏好下仍使用 26 键。")
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
                    HStack(spacing: 10) {
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

    /// Side-by-side previews (nine-key left / full keyboard right), WeChat-like rhythm.
    private var mainKeyboardChooser: some View {
        HStack(alignment: .top, spacing: 12) {
            layoutOption(
                style: .nineKey,
                title: "九宫格拼音",
                accessibilityHint: "中文使用九键，英文仍使用全键盘"
            ) {
                NineKeyThumbnail(isSelected: selectedLayout == .nineKey)
            }

            layoutOption(
                style: .twentySixKey,
                title: "全键盘拼音",
                accessibilityHint: "标准 26 键全键盘布局"
            ) {
                TwentySixKeyThumbnail(isSelected: selectedLayout == .twentySixKey)
            }
        }
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }

    private func layoutOption<Thumb: View>(
        style: KeyboardLayoutStyle,
        title: String,
        accessibilityHint: String,
        @ViewBuilder thumbnail: () -> Thumb
    ) -> some View {
        let isSelected = selectedLayout == style
        return Button {
            Task { await select(style) }
        } label: {
            VStack(spacing: 10) {
                thumbnail()
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)

                HStack(spacing: 6) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.body.weight(.medium))
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                        .symbolRenderingMode(.hierarchical)

                    Text(title)
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "已选择" : "未选择")
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    private func reload() {
        selectedLayout = rimeStore.layoutStyle
        t9Ready = rimeStore.t9ReadinessMatched
    }

    @MainActor
    private func select(_ style: KeyboardLayoutStyle) async {
        statusMessage = nil
        switch style {
        case .twentySixKey:
            rimeStore.selectTwentySixKeyLayout()
            reload()
            statusMessage = "已切换为全键盘拼音"
        case .nineKey:
            await enableNineKey()
        }
    }

    @MainActor
    private func enableNineKey() async {
        if rimeStore.t9ReadinessMatched, rimeStore.rimeIceInstalledFilesExist {
            rimeStore.persistNineKeyLayoutWhenReady()
            reload()
            statusMessage = "已启用九宫格拼音"
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
            statusMessage = "九宫格拼音已启用"
        }
    }
}

// MARK: - Shared preview palette (system semantic; native keyboard-like)

private enum LayoutPreviewPalette {
    /// Keyboard surface inside the preview card.
    static var board: Color { Color(.tertiarySystemFill) }
    /// Letter / character keys (lighter).
    static var characterKey: Color { Color(.secondarySystemFill) }
    /// Function keys (slightly stronger fill).
    static var functionKey: Color { Color(.systemFill) }
    static var keyCorner: CGFloat { 4 }
    static var boardCorner: CGFloat { 10 }
    static var selectedStroke: CGFloat { 2 }
}

// MARK: - Thumbnails (decorative placeholders only — no real glyphs)

/// Abstract QWERTY silhouette: key blocks only, no letters/symbols.
private struct TwentySixKeyThumbnail: View {
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 3) {
            equalKeyRow(count: 10, height: 11)
            equalKeyRow(count: 9, height: 11)
                .padding(.horizontal, 6)
            // Shift · letters · delete
            HStack(spacing: 2.5) {
                functionKey(height: 11)
                    .frame(width: 16)
                equalKeyRow(count: 7, height: 11)
                functionKey(height: 11)
                    .frame(width: 16)
            }
            // 123 · , · space · mode · return
            HStack(spacing: 2.5) {
                functionKey(height: 12)
                    .frame(width: 18)
                functionKey(height: 12)
                    .frame(width: 12)
                characterKey(height: 12)
                    .frame(maxWidth: .infinity)
                functionKey(height: 12)
                    .frame(width: 16)
                functionKey(height: 12)
                    .frame(width: 22)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .aspectRatio(1.35, contentMode: .fit)
        .background(
            LayoutPreviewPalette.board,
            in: RoundedRectangle(cornerRadius: LayoutPreviewPalette.boardCorner, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: LayoutPreviewPalette.boardCorner, style: .continuous)
                .strokeBorder(
                    isSelected ? Color.accentColor : Color.clear,
                    lineWidth: LayoutPreviewPalette.selectedStroke
                )
        }
    }

    private func equalKeyRow(count: Int, height: CGFloat) -> some View {
        HStack(spacing: 2.5) {
            ForEach(0..<count, id: \.self) { _ in
                characterKey(height: height)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func characterKey(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
            .fill(LayoutPreviewPalette.characterKey)
            .frame(height: height)
    }

    private func functionKey(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
            .fill(LayoutPreviewPalette.functionKey)
            .frame(height: height)
    }
}

/// Abstract nine-key silhouette (left pad + right function column + bottom row).
/// Placeholder blocks only — no ABC / 符号 labels.
private struct NineKeyThumbnail: View {
    var isSelected: Bool

    private let padKeyHeight: CGFloat = 16
    private let padSpacing: CGFloat = 3

    var body: some View {
        VStack(spacing: padSpacing) {
            HStack(alignment: .top, spacing: padSpacing) {
                // Left 3×3 letter-group pad
                VStack(spacing: padSpacing) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: padSpacing) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(
                                    cornerRadius: LayoutPreviewPalette.keyCorner,
                                    style: .continuous
                                )
                                .fill(LayoutPreviewPalette.characterKey)
                                .frame(height: padKeyHeight)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }

                // Right function column (delete / short / tall return)
                VStack(spacing: padSpacing) {
                    RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
                        .fill(LayoutPreviewPalette.functionKey)
                        .frame(width: 18, height: padKeyHeight)
                    RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
                        .fill(LayoutPreviewPalette.functionKey)
                        .frame(width: 18, height: padKeyHeight)
                    RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
                        .fill(LayoutPreviewPalette.functionKey)
                        .frame(width: 18, height: padKeyHeight)
                }
            }

            // Bottom chrome: symbol · 123 · space · mode
            HStack(spacing: padSpacing) {
                RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
                    .fill(LayoutPreviewPalette.functionKey)
                    .frame(width: 18, height: 12)
                RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
                    .fill(LayoutPreviewPalette.functionKey)
                    .frame(width: 18, height: 12)
                RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
                    .fill(LayoutPreviewPalette.characterKey)
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)
                RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
                    .fill(LayoutPreviewPalette.functionKey)
                    .frame(width: 22, height: 12)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .aspectRatio(1.35, contentMode: .fit)
        .background(
            LayoutPreviewPalette.board,
            in: RoundedRectangle(cornerRadius: LayoutPreviewPalette.boardCorner, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: LayoutPreviewPalette.boardCorner, style: .continuous)
                .strokeBorder(
                    isSelected ? Color.accentColor : Color.clear,
                    lineWidth: LayoutPreviewPalette.selectedStroke
                )
        }
    }
}
