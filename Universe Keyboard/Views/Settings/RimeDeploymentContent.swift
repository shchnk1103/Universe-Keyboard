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
                RimeDeploymentStep(number: 1, text: "完成方案与输入设置", done: state != .idle)
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
                AppActionButton(
                    title: state == .deployed ? "重新部署" : "应用并重新部署",
                    systemImage: "arrow.triangle.2.circlepath",
                    prominence: .primary,
                    action: onTriggerDeploy
                )
                .disabled(state == .triggered || state == .deploying)

                if state == .failed {
                    AppActionButton(
                        title: "取消",
                        systemImage: "xmark",
                        action: onCancel
                    )
                }

                Spacer()

                if !deployLog.isEmpty {
                    AppActionButton(
                        title: "重置",
                        systemImage: "arrow.counterclockwise",
                        minHeight: 30,
                        action: onReset
                    )
                    .frame(maxWidth: 112)
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
