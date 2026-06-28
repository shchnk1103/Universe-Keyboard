import KeyboardCore
import UIKit

extension KeyboardViewController {
    func emitKeyPressFeedback() {
        emitFeedback(for: .tap)
    }

    func emitKeyPressFeedbackIfNeeded(for sender: UIButton) {
        let identifier = ObjectIdentifier(sender)
        guard keyPressFeedbackEmittedButtonIDs.remove(identifier) == nil else {
            return
        }
        emitKeyPressFeedback()
    }

    func emitFeedback(for event: KeyboardFeedbackEvent) {
        switch event {
        case .tap, .commit:
            playHaptic()
            playKeyClick()

        case .modeEnter:
            playModeEnterHaptic()

        case .`repeat`:
            break

        case .preview:
            break
        }
    }

    func playKeyClick(volume: Float? = nil) {
        guard cachedKeyClickEnabled else {
            return
        }
        let volume = volume ?? cachedKeyClickVolume
        guard volume > 0 else {
            return
        }
        Task { await clickPlayer.play(volume: volume) }
    }

    func playHaptic(intensity: CGFloat? = nil) {
        guard cachedHapticEnabled else {
            return
        }
        hapticGenerator.impactOccurred(intensity: intensity ?? cachedHapticIntensity)
        hapticGenerator.prepare()
    }

    func playModeEnterHaptic() {
        guard cachedHapticEnabled else {
            return
        }
        modeEnterHapticGenerator.impactOccurred(intensity: 1.0)
        modeEnterHapticGenerator.prepare()
    }

    func playRepeatFeedback(effectiveDeleteCount: Int) {
        if effectiveDeleteCount == 1 || effectiveDeleteCount.isMultiple(of: 2) {
            playKeyClick(volume: cachedKeyClickVolume * 0.60)
        }

        if effectiveDeleteCount.isMultiple(of: 4) {
            playHaptic(intensity: max(0.25, cachedHapticIntensity * 0.7))
        }
    }

    func refreshCachedSettings(source: String = "unspecified") {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        KeyboardFeedbackSettingsMigration.migrateLegacyLevelsIfNeeded(in: defaults)

        let rawSound = defaults?.object(forKey: KeyboardFeedbackSettingsKey.keyClickEnabled)
        let rawHaptic = defaults?.object(forKey: KeyboardFeedbackSettingsKey.hapticEnabled)
        let rawClickLevel = defaults?.object(forKey: KeyboardFeedbackSettingsKey.keyClickLevel)
        let rawHapticLevel = defaults?.object(forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        let rawPairedSymbolCompletion = defaults?.object(
            forKey: KeyboardInputSettingsKey.pairedSymbolCompletionEnabled
        )
        let typoExperimentSettings = TypoCorrectionExperimentalSettings.load(from: defaults)

        cachedKeyClickEnabled = rawSound as? Bool ?? true
        cachedHapticEnabled = rawHaptic as? Bool ?? false
        cachedKeyClickLevel = feedbackLevelValue(rawClickLevel)
        cachedHapticLevel = feedbackLevelValue(rawHapticLevel)
        cachedKeyClickVolume = cachedKeyClickLevel.clickVolume
        cachedHapticIntensity = CGFloat(cachedHapticLevel.hapticIntensity)
        controller.isPairedSymbolCompletionEnabled = rawPairedSymbolCompletion as? Bool ?? true
        controller.typoCorrectionExperimentalEdits = typoExperimentSettings.experimentalEdits
    }

    func feedbackLevelValue(_ rawValue: Any?) -> KeyboardFeedbackLevel {
        if let value = rawValue as? Int {
            return KeyboardFeedbackLevel.clamped(value)
        }
        if let value = rawValue as? NSNumber {
            return KeyboardFeedbackLevel.clamped(value.intValue)
        }
        return .defaultLevel
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
