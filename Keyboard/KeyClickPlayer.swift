import AVFoundation

/// 键盘点击音播放器。
/// 使用 AVAudioPlayer 播放内嵌生成的点击音，支持音量控制。
/// 不需要「完全访问」权限。
final class KeyClickPlayer {

    private var player: AVAudioPlayer?
    private var player2: AVAudioPlayer?  // 双播放器避免快速连按时截断

    /// 生成接近原生 iOS 键盘的点击音（4ms，2000Hz+4000Hz 谐波，含噪音起音）。
    private static func generateClickWAV() -> Data {
        let sampleRate = 44100.0
        let duration = 0.004  // 4ms — 短促清脆
        let sampleCount = Int(sampleRate * duration)

        var samples = [Int16](repeating: 0, count: sampleCount)
        for i in 0..<sampleCount {
            let t = Double(i) / sampleRate
            // 快速衰减包络
            let envelope = exp(-t / 0.0008)
            // 基频 2000Hz + 谐波 4000Hz
            let fundamental = sin(2.0 * .pi * 2000.0 * t)
            let harmonic = sin(2.0 * .pi * 4000.0 * t) * 0.35
            // 起音处加入轻微噪音模拟打击感
            let noise = Double.random(in: -0.15...0.15) * exp(-t / 0.0002)
            let amplitude = 0.75 * envelope
            let signal = (fundamental + harmonic + noise) * amplitude
            samples[i] = Int16(max(-1.0, min(1.0, signal)) * Double(Int16.max))
        }

        // WAV header
        let dataSize = sampleCount * 2
        var wav = Data()
        wav.append("RIFF".data(using: .ascii)!)
        wav.append(withUnsafeBytes(of: UInt32(36 + dataSize).littleEndian) { Data($0) })
        wav.append("WAVE".data(using: .ascii)!)
        wav.append("fmt ".data(using: .ascii)!)
        wav.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })      // chunk size
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })       // PCM
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })       // mono
        wav.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt32(UInt(sampleRate) * 2).littleEndian) { Data($0) })  // byte rate
        wav.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })       // block align
        wav.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })      // bits per sample
        wav.append("data".data(using: .ascii)!)
        wav.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })

        for sample in samples {
            wav.append(withUnsafeBytes(of: sample.littleEndian) { Data($0) })
        }

        return wav
    }

    // MARK: - Init

    init() {
        let wav = Self.generateClickWAV()
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
