import AVFoundation
import KeyboardCore

/// 键盘点击音播放器。
/// 使用 AVAudioPlayer 播放内嵌生成的点击音，支持音量控制。
/// 不需要「完全访问」权限。
/// 播放通过专用后台队列调度，避免阻塞主线程（AVAudioPlayer.play() 可能阻塞 18-76ms）。
final class KeyClickPlayer {

    private let player: AVAudioPlayer?
    private let player2: AVAudioPlayer?
    private var toggle = false
    private let queue = DispatchQueue(label: "com.universekeyboard.click", qos: .userInitiated)

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

    /// 播放点击音。调用立即返回，实际播放通过后台串行队列调度。
    /// - Parameter volume: 0.0（静音）到 1.0（最大）。
    func play(volume: Float) {
        guard volume > 0 else { return }
        queue.async {
            let active = self.toggle ? self.player : self.player2
            self.toggle.toggle()
            active?.volume = volume
            active?.currentTime = 0
            active?.play()
        }
    }
}
