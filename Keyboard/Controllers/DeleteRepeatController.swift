import Foundation

/// Owns the long-press delete timers so repeated deletion has one lifecycle owner.
///
/// Keep these timing values stable: they are part of the keyboard interaction
/// baseline and changing them would alter the perceived deletion behavior.
@MainActor
final class DeleteRepeatController {
    static let initialDelay: TimeInterval = 0.5
    static let repeatInterval: TimeInterval = 0.08
    static let bubbleDelayAfterRepeatStart: TimeInterval = 0.15

    private var timer: Timer?
    /// Invalidates callbacks already queued when `stop()` runs.
    private var repeatGeneration = 0

    func begin(
        repeatAction: @escaping @MainActor () -> Void,
        onRepeatStarted: (@MainActor () -> Void)? = nil
    ) {
        stop()
        let generation = repeatGeneration

        let initialTimer = Timer(timeInterval: Self.initialDelay, repeats: false) {
            [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.repeatGeneration == generation else { return }
                onRepeatStarted?()
                guard self.repeatGeneration == generation else { return }
                repeatAction()
                guard self.repeatGeneration == generation else { return }
                self.beginRepeating(action: repeatAction)
            }
        }
        timer = initialTimer
        RunLoop.main.add(initialTimer, forMode: .common)
    }

    func stop() {
        repeatGeneration += 1
        timer?.invalidate()
        timer = nil
    }

    /// Continues the 0.08s cadence without the 0.5s arming delay.
    /// Used when the finger leaves the trash bubble and returns to the key.
    func resumeRepeating(action: @escaping @MainActor () -> Void) {
        stop()
        beginRepeating(action: action)
    }

    private func beginRepeating(action: @escaping @MainActor () -> Void) {
        let generation = repeatGeneration
        let repeatTimer = Timer(timeInterval: Self.repeatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.repeatGeneration == generation else { return }
                action()
            }
        }
        timer = repeatTimer
        RunLoop.main.add(repeatTimer, forMode: .common)
    }
}
