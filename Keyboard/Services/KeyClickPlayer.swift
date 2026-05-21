import AVFoundation
import KeyboardCore

/// 键盘点击音播放器。
/// 使用 AVAudioPlayer 播放内嵌生成的点击音，支持音量控制。
/// 不需要「完全访问」权限。
final class KeyClickPlayer {

    private var player: AVAudioPlayer?
    private var player2: AVAudioPlayer?  // 双播放器避免快速连按时截断

    // MARK: - Init

    init() {
        let wav = ClickSoundGenerator.generateClickWAV()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("keyclick.wav")
        try? wav.write(to: tempURL)

        // 双播放器：交替使用，避免快速打字时截断前一个音
        player = try? AVAudioPlayer(contentsOf: tempURL)
        player?.prepareToPlay()
        player2 = try? AVAudioPlayer(contentsOf: tempURL)
        player2?.prepareToPlay()
    }

    // MARK: - Play

    private var toggle = false

    /// 播放点击音。
    /// - Parameter volume: 0.0（静音）到 1.0（最大）。
    func play(volume: Float) {
        guard volume > 0 else { return }
        let active = toggle ? player : player2
        toggle.toggle()
        active?.volume = volume
        active?.currentTime = 0
        active?.play()
    }
}
