import KeyboardCore
import UIKit

extension KeyboardViewController {
    func playKeyClick() {
        guard cachedKeyClickEnabled else { return }
        let volume = cachedKeyClickVolume
        Task { await clickPlayer.play(volume: volume) }
    }

    func playHaptic() {
        guard cachedHapticEnabled else { return }
        hapticGenerator.impactOccurred(intensity: cachedHapticIntensity)
        hapticGenerator.prepare()
    }

    func refreshCachedSettings() {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        cachedKeyClickEnabled = defaults?.bool(forKey: "key_click_enabled") ?? true
        cachedHapticEnabled = defaults?.bool(forKey: "haptic_enabled") ?? false
        let volume = defaults?.double(forKey: "key_click_volume") ?? 0
        cachedKeyClickVolume = volume > 0 ? Float(volume) : 0.8
        let intensity = defaults?.double(forKey: "haptic_intensity") ?? 0
        cachedHapticIntensity = intensity > 0 ? CGFloat(intensity) : 0.5
    }

    func observeSettingsChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChanged),
            name: UserDefaults.didChangeNotification,
            object: UserDefaults(suiteName: Self.appGroupID)
        )
    }

    @objc private func handleSettingsChanged() {
        refreshCachedSettings()
    }

    func logKeyPerformance(_ message: String, startTime: CFTimeInterval) {
        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        Logger.shared.performance("\(message) (\(String(format: "%.1f", elapsed))ms)")
    }
}
