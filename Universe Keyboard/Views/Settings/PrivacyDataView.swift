import SwiftUI

struct PrivacyDataView: View {
    var body: some View {
        List {
            Section {
                privacyRow(
                    "键盘输入不上传",
                    detail: "键盘扩展不向开发者或第三方发送输入内容、候选、上下文或用户词典。你在主 App 主动确认的标准 RIME 同步另行处理，见下方“网络”说明。",
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
                    detail: "RIME 用户词典和纠错选择学习保存在设备上的共享容器中。若你在主 App 确认标准 RIME 同步，词典快照可写入你选择的共享文件夹。",
                    icon: "character.book.closed"
                )
                privacyRow(
                    "上屏后联想",
                    detail: "只在键盘进程内短暂使用本次上屏内容；不读取宿主上下文，也不保存输入历史。",
                    icon: "text.append"
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
                    detail: "当你请求查询、下载或更新可选输入方案时，主 App 可能连接 GitHub、南京大学开源镜像或 CNB 下载源。键盘输入不会加入这些方案请求。",
                    icon: "arrow.down.circle"
                )
                privacyRow(
                    "可选的 RIME 同步",
                    detail:
                        "Universe 私有设置同步在你选择目的地前保持关闭；设置包离开设备前加密，不含用户词典、输入洞察、日志或输入内容。标准 RIME 同步需另选共享文件夹并确认，可包含用户词典快照及非生成的 YAML/TXT 配置备份，Universe 不对这些文件加密。首次标准同步成功后，自动同步仍需你另行开启；后台执行由 iOS 安排，可能延迟或不执行。",
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
