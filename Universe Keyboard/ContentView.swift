//
//  ContentView.swift
//  Universe Keyboard
//
//  主页面：引导用户启用键盘、管理设置、查看进度。
//

import SwiftUI

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

struct ContentView: View {
    @State private var keyClickEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "key_click_enabled") ?? true
    }()
    @State private var hapticEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "haptic_enabled") ?? false
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    feedbackSection
                    if keyClickEnabled {
                        fullAccessGuideSection
                    }
                    progressSection
                    enableKeyboardSection
                    testChecklistSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Universe Keyboard")
        }
    }

    // MARK: - 头部

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "keyboard")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.blue)

            Text("基础键盘已经可以测试")
                .font(.title2)
                .fontWeight(.semibold)

            Text("现在这个 App 先负责告诉我们如何启用键盘。真正输入文字的是另一个 Target：Keyboard Extension。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 键盘反馈

    private var feedbackSection: some View {
        InfoSection(title: "键盘反馈", systemImage: "waveform") {
            ToggleRow(
                title: "按键音",
                description: "按下按键时播放系统键盘音。需要「允许完全访问」。",
                isOn: $keyClickEnabled
            )
            .onChange(of: keyClickEnabled) { _, newValue in
                UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "key_click_enabled")
            }

            Divider()

            ToggleRow(
                title: "按键震动",
                description: "按下按键时提供触感反馈，无需额外权限。",
                isOn: $hapticEnabled
            )
            .onChange(of: hapticEnabled) { _, newValue in
                UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "haptic_enabled")
            }
        }
    }

    // MARK: - Full Access 引导

    private var fullAccessGuideSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("需要开启「允许完全访问」", systemImage: "exclamationmark.shield.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            Text("按键音和触感反馈需要键盘获得「允许完全访问」权限才能播放系统声音。")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                guideStep(number: 1, text: "打开系统「设置」")
                guideStep(number: 2, text: "进入「通用」→「键盘」→「键盘」")
                guideStep(number: 3, text: "点选「Keyboard」")
                guideStep(number: 4, text: "开启「允许完全访问」")
            }

            HStack(spacing: 6) {
                Image(systemName: "hand.raised.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("键盘不会上传任何输入内容，所有数据仅存储在本地。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemOrange).opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func guideStep(number: Int, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.orange)
                .frame(width: 18, height: 18)
                .background(Color.orange.opacity(0.15))
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
        }
    }

    // MARK: - 当前进度

    private var progressSection: some View {
        InfoSection(title: "当前进度", systemImage: "checkmark.circle") {
            BulletRow(text: "26 键字母输入")
            BulletRow(text: "Shift 大小写切换")
            BulletRow(text: "123 数字/符号页")
            BulletRow(text: "候选栏占位和假拼音候选")
        }
    }

    // MARK: - 启用键盘

    private var enableKeyboardSection: some View {
        InfoSection(title: "如何启用键盘", systemImage: "gearshape") {
            NumberedRow(number: 1, text: "打开系统设置")
            NumberedRow(number: 2, text: "进入 通用 -> 键盘 -> 键盘")
            NumberedRow(number: 3, text: "点 添加新键盘")
            NumberedRow(number: 4, text: "选择 Keyboard")
            NumberedRow(number: 5, text: "打开输入框，点地球键切换到 Universe Keyboard")

            Text("首次使用需要在系统设置中添加一次键盘，之后随时可通过地球键切换。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
    }

    // MARK: - 测试清单

    private var testChecklistSection: some View {
        InfoSection(title: "测试清单", systemImage: "list.bullet.clipboard") {
            BulletRow(text: "输入 nihao，候选栏应显示 你好")
            BulletRow(text: "按空格，应上屏第一个候选")
            BulletRow(text: "按 return，应提交原始拼音")
            BulletRow(text: "输入 abc 后点 123，应先上屏 abc 再切换")
        }
    }
}

// MARK: - 小型行组件

private struct BulletRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(.green)

            Text(text)
                .font(.body)
        }
    }
}

private struct NumberedRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.blue)
                .clipShape(Circle())

            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    ContentView()
}
