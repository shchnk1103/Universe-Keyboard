import KeyboardCore
import UIKit

extension KeyboardViewController {
    func emitKeyPressFeedback() {
        playHaptic()
        playKeyClick()
    }

    func emitKeyPressFeedbackIfNeeded(for sender: UIButton) {
        let identifier = ObjectIdentifier(sender)
        guard keyPressFeedbackEmittedButtonIDs.remove(identifier) == nil else {
            return
        }
        emitKeyPressFeedback()
    }

    func playKeyClick() {
        guard cachedKeyClickEnabled else {
            return
        }
        let volume = cachedKeyClickVolume
        guard volume > 0 else {
            return
        }
        Task { await clickPlayer.play(volume: volume) }
    }

    func playHaptic() {
        guard cachedHapticEnabled else {
            return
        }
        hapticGenerator.impactOccurred(intensity: cachedHapticIntensity)
        hapticGenerator.prepare()
    }

    func refreshCachedSettings(source: String = "unspecified") {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        let rawSound = defaults?.object(forKey: "key_click_enabled")
        let rawHaptic = defaults?.object(forKey: "haptic_enabled")
        let rawVolume = defaults?.object(forKey: "key_click_volume")
        let rawIntensity = defaults?.object(forKey: "haptic_intensity")
        cachedKeyClickEnabled =
            rawSound as? Bool ?? true
        cachedHapticEnabled =
            rawHaptic as? Bool ?? false
        let volume = feedbackDoubleValue(rawVolume)
        cachedKeyClickVolume = volume > 0 ? Float(volume) : 0.8
        let intensity = feedbackDoubleValue(rawIntensity)
        cachedHapticIntensity = intensity > 0 ? CGFloat(intensity) : 0.5
    }

    func feedbackDoubleValue(_ rawValue: Any?) -> Double {
        if let value = rawValue as? Double { return value }
        if let value = rawValue as? Float { return Double(value) }
        if let value = rawValue as? Int { return Double(value) }
        if let value = rawValue as? NSNumber { return value.doubleValue }
        return 0
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
        refreshCachedSettings(source: "UserDefaults.didChangeNotification")
    }

    func logKeyPerformance(_ message: String, startTime: CFTimeInterval) {
        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        Logger.shared.performance("\(message) (\(String(format: "%.1f", elapsed))ms)")
    }
}
