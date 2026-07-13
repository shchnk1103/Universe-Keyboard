import SwiftUI

struct PrivacyDataView: View {
    var body: some View {
        List {
            Section {
                privacyRow(
                    "键盘输入不上传",
                    detail: "输入内容、候选、上下文和用户词典不会发送给开发者或第三方。",
                    icon: "keyboard.badge.ellipsis"
                )
                privacyRow(
                    "没有广告与跟踪",
                    detail: "不使用广告标识符，不跨 App 跟踪，也不建立用户账户画像。",
                    icon: "hand.raised"
                )
            } header: {
                Text("核心承诺")
            }

            Section {
                privacyRow(
                    "输入洞察",
                    detail: "默认关闭。开启后只保存不可逆的本地聚合统计，可随时清除。",
                    icon: "chart.xyaxis.line"
                )
                privacyRow(
                    "候选学习",
                    detail: "RIME 用户词典和纠错选择学习保存在设备上的共享容器中。",
                    icon: "character.book.closed"
                )
                privacyRow(
                    "诊断日志",
                    detail: "由你控制并留在设备上；只有你主动复制时才会离开 App。",
                    icon: "waveform.path.ecg.text"
                )
            } header: {
                Text("本地数据")
            }

            Section {
                Label("完全访问用于共享设置、RIME 资源、本地学习和输入洞察，不用于上传按键。", systemImage: "lock.shield")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } header: {
                Text("完全访问")
            }

            Section {
                privacyRow(
                    "方案下载",
                    detail: "主 App 只在你请求下载或更新可选输入方案时访问 GitHub。键盘输入不会加入请求。",
                    icon: "arrow.down.circle"
                )
                privacyRow(
                    "可选的 RIME 云同步",
                    detail: "默认关闭。开启后，主 App 只把端到端加密的 RIME 设置发送到你选择的 WebDAV 或文件夹；不包含用户词典、输入洞察、日志或输入内容。",
                    icon: "icloud.and.arrow.up"
                )
            } header: {
                Text("网络")
            }
        }
        .navigationTitle("隐私与数据")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacyRow(_ title: String, detail: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
#Preview {
    NavigationStack {
        PrivacyDataView()
    }
}
