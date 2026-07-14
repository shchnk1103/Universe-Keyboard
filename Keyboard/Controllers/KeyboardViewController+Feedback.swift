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

    func playKeyClick() {
        guard cachedKeyClickEnabled else {
            return
        }
        UIDevice.current.playInputClick()
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
            playKeyClick()
        }

        if effectiveDeleteCount.isMultiple(of: 4) {
            playHaptic(intensity: max(0.25, cachedHapticIntensity * 0.7))
        }
    }

    func refreshCachedSettings(source: String = "unspecified") {
        let defaults = sharedDefaults

        // 诊断开关与反馈设置使用同一生命周期快照；候选触控链路不自行轮询共享偏好。
        CandidateTouchDiagnostics.refreshFromSharedSettings()

        let rawSound = defaults?.object(forKey: KeyboardFeedbackSettingsKey.keyClickEnabled)
        let rawHaptic = defaults?.object(forKey: KeyboardFeedbackSettingsKey.hapticEnabled)
        let rawHapticLevel = defaults?.object(forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        let rawPairedSymbolCompletion = defaults?.object(
            forKey: KeyboardInputSettingsKey.pairedSymbolCompletionEnabled
        )
        let typoExperimentSettings = TypoCorrectionExperimentalSettings.load(from: defaults)

        cachedKeyClickEnabled = rawSound as? Bool ?? true
        cachedHapticEnabled = rawHaptic as? Bool ?? false
        cachedHapticLevel = feedbackLevelValue(rawHapticLevel)
        cachedHapticIntensity = CGFloat(cachedHapticLevel.hapticIntensity)
        cachedLiquidGlassMaterialEnabled = defaults?.bool(
            forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled
        ) ?? false
        controller.isPairedSymbolCompletionEnabled = rawPairedSymbolCompletion as? Bool ?? true
        controller.typoCorrectionExperimentalEdits = typoExperimentSettings.experimentalEdits
        controller.typoCorrectionLearningSnapshot = typoCorrectionLearningStore.snapshot()
        cachedTypingIntelligenceEnabled = defaults?.bool(
            forKey: TypingStatisticsStorageKey.enabled
        ) ?? false
        cachedTypingIntelligenceResetEpoch = defaults?.integer(
            forKey: TypingStatisticsStorageKey.resetEpoch
        ) ?? 0

        if cachedHapticEnabled {
            hapticGenerator.prepare()
            modeEnterHapticGenerator.prepare()
        }
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

    func logKeyPerformance(_ message: String, startTime: CFTimeInterval) {
        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        Logger.shared.performance("\(message) (\(String(format: "%.1f", elapsed))ms)")
    }
}
