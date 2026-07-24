import KeyboardCore
import SwiftUI

/// Settings surface for 26-key / Chinese nine-key layout selection.
///
/// WeChat-style side-by-side “主键盘” chooser: equal-size previews, radio under each,
/// accent selection ring. Key silhouettes mirror Extension chrome (placeholder fills only).
struct KeyboardLayoutSettingsView: View {
    @Bindable var rimeStore: RimeSettingsStore

    @State private var selectedLayout: KeyboardLayoutStyle = .twentySixKey
    @State private var isBusy = false
    @State private var showLicenseSheet = false
    @State private var pendingNineKeyAfterInstall = false

    /// Shared preview frame so both boards match width & height.
    private let previewSize = CGSize(width: 148, height: 112)

    var body: some View {
        Form {
            Section {
                mainKeyboardChooser
            } header: {
                Text("主键盘")
            } footer: {
                Text("九键依赖雾凇拼音的 T9 方案。启用前会检查安装与部署状态；失败时保持当前布局。部分高级能力在九键模式下可能不可用，切回全键盘后恢复。英文与自动英文场景在九键偏好下仍使用 26 键。长句建议尽早点选拼音路径或分段上屏，可减少未确认数字串变长时的卡顿。")
            }

            if isBusy {
                Section {
                    LoadingStateView(message: "正在处理…", font: .body)
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
                            rimeStore.presentLayoutToast("已取消，保持原布局", succeeded: false)
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
                rimeStore.presentLayoutToast("安装失败：\(message)。已保持原布局。", succeeded: false)
            default:
                break
            }
        }
    }

    /// Full keyboard left · nine-key right (product preference); equal frames.
    private var mainKeyboardChooser: some View {
        HStack(alignment: .top, spacing: 14) {
            layoutOption(
                style: .twentySixKey,
                title: "全键盘拼音",
                accessibilityHint: "标准 26 键全键盘布局"
            ) {
                TwentySixKeyThumbnail(isSelected: selectedLayout == .twentySixKey)
                    .frame(width: previewSize.width, height: previewSize.height)
            }

            layoutOption(
                style: .nineKey,
                title: "九宫格拼音",
                accessibilityHint: "中文使用九键，英文仍使用全键盘"
            ) {
                NineKeyThumbnail(isSelected: selectedLayout == .nineKey)
                    .frame(width: previewSize.width, height: previewSize.height)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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
    }

    @MainActor
    private func select(_ style: KeyboardLayoutStyle) async {
        switch style {
        case .twentySixKey:
            rimeStore.selectTwentySixKeyLayout()
            reload()
            rimeStore.presentLayoutToast("已切换为全键盘拼音", succeeded: true)
        case .nineKey:
            await enableNineKey()
        }
    }

    @MainActor
    private func enableNineKey() async {
        if rimeStore.t9ReadinessMatched, rimeStore.rimeIceInstalledFilesExist {
            rimeStore.persistNineKeyLayoutWhenReady()
            reload()
            rimeStore.presentLayoutToast("已启用九宫格拼音", succeeded: true)
            return
        }

        if !rimeStore.rimeIceInstalledFilesExist {
            if !rimeStore.licenseAccepted {
                showLicenseSheet = true
                return
            }
            pendingNineKeyAfterInstall = true
            isBusy = true
            // Download progress uses the existing global download toast.
            rimeStore.startDownload(schemaID: "rime_ice")
            isBusy = false
            return
        }

        isBusy = true
        // Deploy progress is covered by the global deployment toast when active.
        let failure = await rimeStore.enableNineKeyLayout()
        isBusy = false
        reload()
        if let failure {
            rimeStore.presentLayoutToast(failure, succeeded: false)
        } else {
            rimeStore.presentLayoutToast("九宫格拼音已启用", succeeded: true)
        }
    }
}

// MARK: - Preview palette (system semantic ≈ Extension character/function keys)

private enum LayoutPreviewPalette {
    static var board: Color { Color(.systemGray5).opacity(0.55) }
    static var characterKey: Color { Color(.systemGray4) }
    static var functionKey: Color { Color(.systemGray3) }
    static var keyCorner: CGFloat { 3.5 }
    static var boardCorner: CGFloat { 10 }
    static var selectedStroke: CGFloat { 2 }
    static var keySpacing: CGFloat { 2.5 }
    static var rowSpacing: CGFloat { 3 }
}

// MARK: - 26-key silhouette (matches QWERTY row rhythm)

private struct TwentySixKeyThumbnail: View {
    var isSelected: Bool

    var body: some View {
        VStack(spacing: LayoutPreviewPalette.rowSpacing) {
            // Number/letter top row — 10 equal keys
            equalRow(count: 10, height: 13, style: .character)
            // Second letter row — 9 keys, inset like native QWERTY
            equalRow(count: 9, height: 13, style: .character)
                .padding(.horizontal, 7)
            // Shift · 7 letters · Delete
            HStack(spacing: LayoutPreviewPalette.keySpacing) {
                key(.function, width: 17, height: 13)
                equalRow(count: 7, height: 13, style: .character)
                key(.function, width: 17, height: 13)
            }
            // 123 · globe · space · 中英 · return
            HStack(spacing: LayoutPreviewPalette.keySpacing) {
                key(.function, width: 20, height: 14)
                key(.function, width: 14, height: 14)
                key(.character, height: 14)
                    .frame(maxWidth: .infinity)
                key(.function, width: 18, height: 14)
                key(.returnKey, width: 24, height: 14)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private enum KeyKind { case character, function, returnKey }

    private func equalRow(count: Int, height: CGFloat, style: KeyKind) -> some View {
        HStack(spacing: LayoutPreviewPalette.keySpacing) {
            ForEach(0..<count, id: \.self) { _ in
                key(style, height: height)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func key(_ kind: KeyKind, width: CGFloat? = nil, height: CGFloat) -> some View {
        let fill: Color = {
            switch kind {
            case .character: return LayoutPreviewPalette.characterKey
            case .function, .returnKey: return LayoutPreviewPalette.functionKey
            }
        }()
        return RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
            .fill(fill)
            .frame(width: width, height: height)
    }
}

// MARK: - Nine-key silhouette (left 4-col pad + right function column + tall return)

/// Mirrors Extension `makeT9NineKeyChrome` structure without glyphs:
/// ```
/// [f][c][c][c] | [del]
/// [f][c][c][c] | [kao]
/// [f][c][c][c] | ┌───┐
/// [f][f][  sp ] | │ret│
/// ```
private struct NineKeyThumbnail: View {
    var isSelected: Bool

    private let letterH: CGFloat = 15
    private let bottomH: CGFloat = 13
    private let gap = LayoutPreviewPalette.rowSpacing
    private let colGap = LayoutPreviewPalette.keySpacing

    var body: some View {
        GeometryReader { geo in
            let rightW = max(16, (geo.size.width - 16) * 0.18)
            let leftW = geo.size.width - 16 - rightW - colGap
            let padH = letterH * 3 + gap * 2
            let returnH = letterH + gap + bottomH

            HStack(alignment: .top, spacing: colGap) {
                // Left: 4×3 main pad + bottom utility
                VStack(spacing: gap) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: colGap) {
                            // Col0 function (123 / #+= / 中)
                            keyBlock(
                                fill: LayoutPreviewPalette.functionKey,
                                height: letterH
                            )
                            // Col1–3 character/letter groups
                            ForEach(0..<3, id: \.self) { _ in
                                keyBlock(
                                    fill: LayoutPreviewPalette.characterKey,
                                    height: letterH
                                )
                            }
                        }
                        .frame(width: leftW)
                    }

                    // Bottom: emoji · 选拼音 · space (1+1+2 of 4 cols)
                    HStack(spacing: colGap) {
                        keyBlock(fill: LayoutPreviewPalette.functionKey, height: bottomH)
                            .frame(width: (leftW - colGap * 3) / 4)
                        keyBlock(fill: LayoutPreviewPalette.functionKey, height: bottomH)
                            .frame(width: (leftW - colGap * 3) / 4)
                        keyBlock(fill: LayoutPreviewPalette.characterKey, height: bottomH)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: leftW)
                }

                // Right: delete · 颜表情 · tall return
                VStack(spacing: gap) {
                    keyBlock(fill: LayoutPreviewPalette.functionKey, height: letterH)
                        .frame(width: rightW)
                    keyBlock(fill: LayoutPreviewPalette.functionKey, height: letterH)
                        .frame(width: rightW)
                    keyBlock(fill: LayoutPreviewPalette.functionKey, height: returnH)
                        .frame(width: rightW)
                }
                .frame(height: padH + gap + bottomH, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(8)
        }
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

    private func keyBlock(fill: Color, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: LayoutPreviewPalette.keyCorner, style: .continuous)
            .fill(fill)
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
}
