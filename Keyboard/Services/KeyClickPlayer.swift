import AVFoundation
import KeyboardCore

/// 键盘点击音播放器。
///
/// 使用 AVAudioPlayer 播放内嵌生成的点击音 WAV 文件。
/// 不需要「完全访问」权限 — 音频完全在键盘扩展内生成和播放。
///
/// ── 双播放器架构 ────────────────────────────────────────────────
/// 使用两个 AVAudioPlayer 实例交替播放（player ↔ player2）。
/// 原因：AVAudioPlayer.play() 是异步的，如果用户在第一个播放器
/// 结束之前再次按下按键，新的 play() 调用会截断当前正在播放的音频。
/// 使用双播放器交替，避免快速打字时的音频截断。
///
/// ── 隔离执行器 ──────────────────────────────────────────────────
/// 播放器状态仅由此 actor 访问，调用方通过异步消息触发播放。
/// 原因：AVAudioPlayer.play() 在某些设备上可能阻塞主线程 18-76ms，
/// 在快速打字时（>10 次/秒）这个延迟会明显影响键盘响应速度。
/// 将播放移出主 actor 后，主线程只承担提交播放请求的开销。
///
/// ── 音频配置 ────────────────────────────────────────────────────
/// AVAudioSession category: .ambient + mixWithOthers
/// 这意味着：
///   - 遵循设备的静音开关（铃声模式下播放，静音模式下不播放）
///   - 不打断其他音频（如音乐播放）
///   - 不需要激活音频会话（与 .playback 不同）
actor KeyClickPlayer {

    /// 第一个播放器实例
    private let player: AVAudioPlayer?
    /// 第二个播放器实例（用于交替，避免截断）
    private let player2: AVAudioPlayer?
    /// 交替标志：true → 用 player2；false → 用 player
    private var toggle = false
    // MARK: === Init ===

    init() {
        // 配置音频会话为 ambient 模式：
        //   - 遵循静音开关
        //   - 不打断其他音频
        //   - 不需要 Full Access
        try? AVAudioSession.sharedInstance().setCategory(
            .ambient,
            options: .mixWithOthers
        )
        try? AVAudioSession.sharedInstance().setActive(true)

        // 生成内置的点击音 WAV 数据（4ms, 2000Hz+4000Hz 双频谐波）
        let wav = ClickSoundGenerator.generateClickWAV()

        // 将 WAV 写入临时文件（AVAudioPlayer 需要文件 URL 或 Data）
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("keyclick.wav")
        try? wav.write(to: tempURL)

        // 创建双播放器并预加载
        // prepareToPlay() 预加载音频缓冲区，减少首次播放的延迟
        player = try? AVAudioPlayer(contentsOf: tempURL)
        player?.prepareToPlay()
        player2 = try? AVAudioPlayer(contentsOf: tempURL)
        player2?.prepareToPlay()
    }

    // MARK: === Play ===

    /// 播放按键点击音。
    ///
    /// 调用由 actor 串行处理，调用方不等待实际音频播放结束。
    /// volume=0 时直接返回（避免无用调度）。
    ///
    /// - Parameter volume: 音量 0.0（静音）~ 1.0（最大声）
    func play(volume: Float) {
        guard volume > 0 else { return }
        // 交替选择播放器：防止上一次播放被截断
        let active = toggle ? player : player2
        toggle.toggle()

        active?.volume = volume
        active?.currentTime = 0
        active?.play()
    }
}
