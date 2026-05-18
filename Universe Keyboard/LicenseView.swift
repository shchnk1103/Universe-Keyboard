import SwiftUI

/// 显示 GPL-3.0 许可证并获取用户同意。
struct LicenseView: View {
    @Environment(\.dismiss) private var dismiss
    let onAccept: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    warningSection
                    Divider()
                    licenseSummarySection
                    Divider()
                    implicationsSection
                }
                .padding()
            }
            .navigationTitle("雾凇拼音许可证")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                acceptButton
            }
        }
    }

    // MARK: - Sections

    private var warningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("许可证声明")
                    .font(.headline)
            }
            Text("雾凇拼音 (rime-ice) 采用 GNU General Public License v3.0 (GPL-3.0) 开源许可证。下载和使用该配置即表示你已阅读并理解以下条款。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var licenseSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GPL-3.0 核心条款")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                bulletRow("可以自由使用、修改和分发该配置")
                bulletRow("分发修改后的版本时必须同样以 GPL-3.0 开源")
                bulletRow("不提供任何担保，作者不承担任何责任")
                bulletRow("详情见完整 GPL-3.0 许可证文本")
            }
        }
    }

    private var implicationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("对 Universe Keyboard 的影响")
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                bulletRow("雾凇拼音配置（词库和 schema 文件）来自 rime-ice 项目")
                bulletRow("本 App 通过下载方式获取配置，不直接分发 GPL 代码")
                bulletRow("配置的修改（如去除 Lua 依赖）仅用于兼容性，不改变原始版权")
                bulletRow("用户可以随时删除雾凇拼音配置，只使用内置方案")
            }
        }
    }

    private var acceptButton: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                onAccept()
                dismiss()
            } label: {
                Label("我已阅读并同意", systemImage: "checkmark")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .background(.regularMaterial)
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    LicenseView(onAccept: {})
}
