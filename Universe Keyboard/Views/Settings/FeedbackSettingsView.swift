import SwiftUI
import AVFoundation
import KeyboardCore

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

/// 键盘反馈设置子页面。
struct FeedbackSettingsView: View {
    @State private var keyClickEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "key_click_enabled") ?? true
    }()
    @State private var keyClickVolume: Double = {
        let v = UserDefaults(suiteName: appGroupID)?.double(forKey: "key_click_volume") ?? 0
        return v > 0 ? v : 0.8
    }()
    @State private var hapticEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "haptic_enabled") ?? false
    }()
    @State private var hapticIntensity: Double = {
        let v = UserDefaults(suiteName: appGroupID)?.double(forKey: "haptic_intensity") ?? 0
        return v > 0 ? v : 0.5
    }()

    /// 预览专用：主 App 内生成点击音
    @State private var previewPlayer: AVAudioPlayer?
    /// 预览专用：主 App 内触感反馈
    private let previewHaptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Form {
            // MARK: 按键音
            Section {
                Toggle("按键音", isOn: $keyClickEnabled)
                    .onChange(of: keyClickEnabled) { _, newValue in
                        UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "key_click_enabled")
                        if newValue { previewClick() }
                    }
            } header: {
                Text("按键音")
            } footer: {
                Text(keyClickEnabled
                     ? "无需「完全访问」权限。使用内嵌键盘点击音，可独立调节音量。"
                     : "开启后按下按键时播放点击音。")
            }

            if keyClickEnabled {
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "speaker.wave.1")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $keyClickVolume, in: 0.0...1.0, step: 0.1)
                                .onChange(of: keyClickVolume) { _, newValue in
                                    let rounded = (newValue * 10).rounded() / 10
                                    UserDefaults(suiteName: appGroupID)?.set(rounded, forKey: "key_click_volume")
                                    previewClick()
                                }
                            Image(systemName: "speaker.wave.3")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("静音")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(volumeLabel)
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Spacer()
                            Text("最大")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("按键音量")
                } footer: {
                    Text("拖动滑块可实时试听点击音效果。")
                }
            }

            // MARK: 按键震动
            Section {
                Toggle("按键震动", isOn: $hapticEnabled)
                    .onChange(of: hapticEnabled) { _, newValue in
                        UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "haptic_enabled")
                        if newValue { previewHaptic.impactOccurred(intensity: hapticIntensity) }
                    }
            } header: {
                Text("触感反馈")
            } footer: {
                Text("按下按键时提供震动反馈。无需额外权限。")
            }

            if hapticEnabled {
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "wave.3.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $hapticIntensity, in: 0.1...1.0, step: 0.1)
                                .onChange(of: hapticIntensity) { _, newValue in
                                    let rounded = (newValue * 10).rounded() / 10
                                    UserDefaults(suiteName: appGroupID)?.set(rounded, forKey: "haptic_intensity")
                                    previewHaptic.impactOccurred(intensity: rounded)
                                    previewHaptic.prepare()
                                }
                            Image(systemName: "wave.3.right")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("轻柔")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(intensityLabel)
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Spacer()
                            Text("强烈")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("震动强度")
                } footer: {
                    Text("拖动滑块即可实时感受当前强度。强度越高，震动越明显。")
                }
            }

        }
        .navigationTitle("键盘反馈")
        .onAppear { previewHaptic.prepare() }
    }

    // MARK: - 标签

    private var volumeLabel: String {
        switch keyClickVolume {
        case 0:       return "静音"
        case 0.0..<0.3: return "微弱"
        case 0.3..<0.6: return "适中"
        case 0.6..<0.9: return "响亮"
        default:       return "最大"
        }
    }

    private var intensityLabel: String {
        switch hapticIntensity {
        case 0.0..<0.3: return "轻"
        case 0.3..<0.6: return "中"
        case 0.6..<0.9: return "强"
        default:        return "最强"
        }
    }

    // MARK: - 点击音预览

    private func previewClick() {
        guard keyClickEnabled else { return }
        let wav = ClickSoundGenerator.generateClickWAV()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("preview_click.wav")
        try? wav.write(to: tempURL)
        let player = try? AVAudioPlayer(contentsOf: tempURL)
        player?.volume = Float(keyClickVolume)
        player?.play()
        // 延迟释放以完整播放
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = player
        }
    }
}

#Preview {
    NavigationStack {
        FeedbackSettingsView()
    }
}
