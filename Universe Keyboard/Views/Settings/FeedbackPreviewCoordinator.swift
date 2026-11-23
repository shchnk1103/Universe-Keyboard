import Combine
import KeyboardCore
import SwiftUI

@MainActor
final class FeedbackPreviewCoordinator: ObservableObject {
    private var lastPreviewedHapticLevel: KeyboardFeedbackLevel?
    private var lastPreviewedIntensity = -1.0
    private var lastHapticPreviewTime = Date.distantPast
    private var pendingHapticPreview: DispatchWorkItem?

    func previewHaptic(level: KeyboardFeedbackLevel, force: Bool = false) {
        previewHaptic(intensity: level.hapticIntensity, force: force)
    }

    func previewHaptic(intensity: Double, force: Bool = false) {
        let value = KeyboardFeedbackIntensity.clamped(intensity)
        let bucket = KeyboardFeedbackLevel.migratedLevel(from: value)
        guard force || lastPreviewedHapticLevel != bucket || abs(value - lastPreviewedIntensity) > 0.02 else { return }
        lastPreviewedHapticLevel = bucket
        lastPreviewedIntensity = value
        scheduleThrottledPreview(
            interval: 0.18,
            lastTime: lastHapticPreviewTime,
            pending: &pendingHapticPreview
        ) { [weak self] in
            guard let self else { return }
            self.playHaptic(intensity: value)
            self.lastHapticPreviewTime = Date()
        }
    }

    private func scheduleThrottledPreview(
        interval: TimeInterval,
        lastTime: Date,
        pending: inout DispatchWorkItem?,
        action: @escaping () -> Void
    ) {
        pending?.cancel()

        let elapsed = Date().timeIntervalSince(lastTime)
        guard elapsed < interval else {
            action()
            return
        }

        let workItem = DispatchWorkItem(block: action)
        pending = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + (interval - elapsed), execute: workItem)
    }

    private func playHaptic(intensity: Double) {
        let value = KeyboardFeedbackIntensity.clamped(intensity)
        let generator = UIImpactFeedbackGenerator(style: hapticStyle(for: value))
        generator.prepare()
        generator.impactOccurred(intensity: CGFloat(value))
    }

    private func hapticStyle(for intensity: Double) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch KeyboardFeedbackIntensity.hardwareStyle(for: intensity) {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        }
    }
}
