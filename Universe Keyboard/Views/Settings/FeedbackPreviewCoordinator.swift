import AVFoundation
import Combine
import KeyboardCore
import SwiftUI

@MainActor
final class FeedbackPreviewCoordinator: ObservableObject {
    private var previewPlayer: AVAudioPlayer?
    private var clickPreviewURL: URL?
    private var lastPreviewedClickLevel: KeyboardFeedbackLevel?
    private var lastPreviewedHapticLevel: KeyboardFeedbackLevel?
    private var lastClickPreviewTime = Date.distantPast
    private var lastHapticPreviewTime = Date.distantPast
    private var pendingClickPreview: DispatchWorkItem?
    private var pendingHapticPreview: DispatchWorkItem?

    func prepare() {
        preparePreviewAudioIfNeeded()
        UIImpactFeedbackGenerator(style: .light).prepare()
    }

    func previewClick(level: KeyboardFeedbackLevel, force: Bool = false) {
        guard force || lastPreviewedClickLevel != level else { return }
        lastPreviewedClickLevel = level
        scheduleThrottledPreview(
            interval: 0.12,
            lastTime: lastClickPreviewTime,
            pending: &pendingClickPreview
        ) { [weak self] in
            guard let self else { return }
            self.playClick(level: level)
            self.lastClickPreviewTime = Date()
        }
    }

    func previewHaptic(level: KeyboardFeedbackLevel, force: Bool = false) {
        guard force || lastPreviewedHapticLevel != level else { return }
        lastPreviewedHapticLevel = level
        scheduleThrottledPreview(
            interval: 0.18,
            lastTime: lastHapticPreviewTime,
            pending: &pendingHapticPreview
        ) { [weak self] in
            guard let self else { return }
            self.playHaptic(level: level)
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

    private func preparePreviewAudioIfNeeded() {
        guard clickPreviewURL == nil else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("preview_click.wav")
        try? ClickSoundGenerator.generateClickWAV().write(to: tempURL)
        clickPreviewURL = tempURL
    }

    private func playClick(level: KeyboardFeedbackLevel) {
        preparePreviewAudioIfNeeded()
        guard let clickPreviewURL else { return }
        previewPlayer = try? AVAudioPlayer(contentsOf: clickPreviewURL)
        previewPlayer?.volume = level.clickVolume
        previewPlayer?.play()
    }

    private func playHaptic(level: KeyboardFeedbackLevel) {
        let generator = UIImpactFeedbackGenerator(style: hapticStyle(for: level))
        generator.prepare()
        generator.impactOccurred(intensity: CGFloat(level.hapticIntensity))
    }

    private func hapticStyle(for level: KeyboardFeedbackLevel) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch level {
        case .light, .softer: return .light
        case .normal, .stronger: return .medium
        case .heavy: return .heavy
        }
    }
}
