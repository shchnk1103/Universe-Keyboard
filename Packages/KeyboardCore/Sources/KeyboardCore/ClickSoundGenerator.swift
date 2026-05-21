import Foundation

/// 键盘点击音 WAV 生成器。
/// 生成接近原生 iOS 键盘的点击音（4ms，2000Hz+4000Hz 谐波，含噪音起音）。
/// 主 App 预览和键盘扩展共用。
public struct ClickSoundGenerator {

    public static func generateClickWAV() -> Data {
        let sampleRate = 44100.0
        let duration = 0.004
        let sampleCount = Int(sampleRate * duration)

        var samples = [Int16](repeating: 0, count: sampleCount)
        for i in 0..<sampleCount {
            let t = Double(i) / sampleRate
            let envelope = exp(-t / 0.0008)
            let fundamental = sin(2.0 * .pi * 2000.0 * t)
            let harmonic = sin(2.0 * .pi * 4000.0 * t) * 0.35
            let noise = Double.random(in: -0.15...0.15) * exp(-t / 0.0002)
            let amplitude = 0.75 * envelope
            let signal = (fundamental + harmonic + noise) * amplitude
            samples[i] = Int16(max(-1.0, min(1.0, signal)) * Double(Int16.max))
        }

        let dataSize = sampleCount * 2
        var wav = Data()
        wav.append("RIFF".data(using: .ascii)!)
        wav.append(withUnsafeBytes(of: UInt32(36 + dataSize).littleEndian) { Data($0) })
        wav.append("WAVE".data(using: .ascii)!)
        wav.append("fmt ".data(using: .ascii)!)
        wav.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt32(UInt(sampleRate) * 2).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })
        wav.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })
        wav.append("data".data(using: .ascii)!)
        wav.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })

        for sample in samples {
            wav.append(withUnsafeBytes(of: sample.littleEndian) { Data($0) })
        }

        return wav
    }
}
