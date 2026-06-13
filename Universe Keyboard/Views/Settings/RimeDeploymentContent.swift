import SwiftUI

struct RimeDeploymentContent: View {
    let state: RimeDeploymentState
    let statusHint: String
    let deployLog: [String]
    @Binding var logExpanded: Bool
    let onTriggerDeploy: () -> Void
    let onCancel: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: state.icon).font(.title2).foregroundStyle(state.color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.label).font(.headline).foregroundStyle(state.color)
                    Text(statusHint).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if state == .triggered || state == .deploying {
                    ProgressView()
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                RimeDeploymentStep(number: 1, text: "修改上方设置", done: state != .idle)
                RimeDeploymentStep(
                    number: 2, text: "点击下方部署按钮",
                    done: state == .triggered || state == .deploying || state == .deployed)
                RimeDeploymentStep(number: 3, text: "等待底部提示显示完成", done: state == .deployed)
                RimeDeploymentStep(number: 4, text: "切换到键盘直接输入", done: state == .deployed)
            }

            if !deployLog.isEmpty {
                DisclosureGroup(isExpanded: $logExpanded) {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(deployLog.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                } label: {
                    Text("部署日志 (\(deployLog.count) 条)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button(action: onTriggerDeploy) {
                    Label(
                        state == .deployed ? "重新部署" : "应用并重新部署",
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                    .font(.subheadline)
                    .foregroundStyle(Color(.systemBackground))
                }
                .buttonStyle(.borderedProminent)
                .disabled(state == .triggered || state == .deploying)

                if state == .failed {
                    Button("取消", action: onCancel)
                        .buttonStyle(.bordered)
                }

                Spacer()

                if !deployLog.isEmpty {
                    Button(role: .destructive, action: onReset) {
                        Label("重置", systemImage: "arrow.counterclockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }
}

private struct RimeDeploymentStep: View {
    let number: Int
    let text: String
    let done: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if done {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Text("\(number)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .frame(width: 18, height: 18)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Text(text)
                .font(.caption)
                .foregroundStyle(done ? .primary : .secondary)
        }
    }
}
