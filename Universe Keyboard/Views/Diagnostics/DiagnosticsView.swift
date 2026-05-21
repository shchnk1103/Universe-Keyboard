import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

/// 键盘诊断日志子页面。
/// 顶部固定刷新 + 清空按钮，带加载过渡动画。
struct DiagnosticsView: View {
    @State private var lines: [String] = []
    @State private var isRefreshing = false
    @State private var isClearing = false
    @State private var showClearConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // 固定顶部按钮栏
            HStack(spacing: 14) {
                // 刷新按钮
                Button(action: refresh) {
                    HStack(spacing: 6) {
                        if isRefreshing {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        Image(systemName: isRefreshing ? "" : "arrow.clockwise")
                        Text("刷新")
                            .font(.subheadline)
                    }
                    .frame(minWidth: 80)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(isRefreshing)
                .animation(.easeInOut(duration: 0.2), value: isRefreshing)

                Spacer()

                // 复制按钮
                if !lines.isEmpty {
                    Button(action: copyLog) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.doc")
                            Text("复制")
                                .font(.subheadline)
                        }
                        .frame(minWidth: 80)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                Spacer()

                // 条目计数
                if !lines.isEmpty {
                    Text("\(lines.count) 条")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // 清空按钮
                Button(role: .destructive, action: {
                    if isClearing {
                        performClear()
                    } else {
                        showClearConfirm = true
                    }
                }) {
                    HStack(spacing: 6) {
                        if isClearing {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        Image(systemName: isClearing ? "" : "trash")
                        Text(isClearing ? "清空中" : "清空")
                            .font(.subheadline)
                    }
                    .frame(minWidth: 80)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(lines.isEmpty || isClearing)
                .animation(.easeInOut(duration: 0.2), value: isClearing)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.bar)

            Divider()

            // 日志内容
            if lines.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.alignleft")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text("暂无诊断日志")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text("在设置中开启「引擎诊断日志」开关，切换到键盘输入后返回此页面刷新。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle("键盘诊断")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认清空", isPresented: $showClearConfirm) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive, action: performClear)
        } message: {
            Text("清空后诊断日志将永久删除，无法恢复。")
        }
        .onAppear { loadLog() }
    }

    // MARK: - Actions

    private func loadLog() {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else {
            lines = []
            return
        }
        lines = log.components(separatedBy: "\n")
    }

    private func copyLog() {
        UIPasteboard.general.string = lines.joined(separator: "\n")
    }

    private func refresh() {
        isRefreshing = true
        // 短暂延迟让用户看到加载动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            loadLog()
            isRefreshing = false
        }
    }

    private func performClear() {
        isClearing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let defaults = UserDefaults(suiteName: appGroupID)
            defaults?.removeObject(forKey: "rime_diag_log")
            defaults?.removeObject(forKey: "rime_diag_summary")
            defaults?.synchronize()
            lines = []
            isClearing = false
        }
    }
}

#Preview {
    NavigationStack {
        DiagnosticsView()
    }
}
